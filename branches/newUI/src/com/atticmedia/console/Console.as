/*
* 
* Copyright (c) 2008-2009 Lu Aye Oo
* 
* @author 		Lu Aye Oo
* 
* http://code.google.com/p/flash-console/
* 
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
* 
*/
package com.atticmedia.console {
	import com.atticmedia.console.core.*;
	import com.atticmedia.console.view.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.system.System;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;	

	public class Console extends Sprite {

		public static const NAME:String = "Console";
		public static const PANEL_MAIN:String = "mainPanel";
		public static const PANEL_CHANNELS:String = "channelsPanel";
		public static const PANEL_FPS:String = "fpsPanel";
		public static const PANEL_MEMORY:String = "memoryPanel";
		public static const PANEL_ROLLER:String = "rollerPanel";
		public static const FPS_MAX_LAG_FRAMES:uint = 25;
		
		public static const VERSION:Number = 2;
		public static const VERSION_STAGE:String = "beta2";

		public static const REMOTE_CONN_NAME:String = "_ConsoleRemote";
		public static const REMOTER_CONN_NAME:String = "_ConsoleRemoter";
		
		public static const CONSOLE_CHANNEL:String = "C";
		public static const FILTERED_CHANNEL:String = "filtered";
		public static const GLOBAL_CHANNEL:String = "global";
		//
		public var style:Style;
		public var panels:PanelsManager;
		private var mm:MemoryMonitor;
		private var cl:CommandLine;
		private var remote:Remoting;
		//
		public var quiet:Boolean;
		public var maxLines:int = 500;
		public var prefixChannelNames:Boolean = true;
		public var alwaysOnTop:Boolean = true;
		public var maxRepeats:Number = 75;
		public var remoteDelay:int = 20;
		public var defaultChannel:String = "traces";
		public var tracingPriority:int = 0;
		public var rulerHidesMouse:Boolean = true;
		//
		private var _isPaused:Boolean;
		private var _enabled:Boolean = true;
		private var _password:String;
		private var _passwordIndex:int;
		private var _tracing:Boolean = false;
		private var _filterText:String;
		private var _keyBinds:Object = {};
		private var _mspf:Number;
		private var _previousTime:Number;
		private var _traceCall:Function = trace;
		
		private var _channels:Array = [GLOBAL_CHANNEL];
		private var _viewingChannels:Array = [GLOBAL_CHANNEL];
		private var _tracingChannels:Array;
		private var _isRepeating:Boolean;
		private var _repeated:int;
		private var _lines:Array = [];
		private var _linesChanged:Boolean;
		
		public function Console(pass:String = "", uiset:int = 1) {
			name = NAME;
			_password = pass;
			style = new Style(uiset);
			panels = new PanelsManager(this, new MainPanel(this, _lines, _channels));
			mm = new MemoryMonitor();
			cl = new CommandLine(this);
			remote = new Remoting(this);
			remote.logsend = remoteLogSend; // Don't want to expose remoteLogSend in this class
			cl.store("C",this);
			cl.reserved.push("C");
			
			addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
			var t:String = VERSION_STAGE?(" "+VERSION_STAGE):"";
			addLine("<b>Console v"+VERSION+t+", Happy bug fixing!</b>",-2,CONSOLE_CHANNEL,false,true);
			
			addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle, false, 0, true);
			if(_password != ""){
				if(stage){
					stageAddedHandle();
				}
				visible = false;
			}
		}
		private function stageAddedHandle(e:Event=null):void{
			if(cl.base == null && root){
				cl.base = root;
			}
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);
		}
		private function stageRemovedHandle(e:Event=null):void{
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		private function onStageMouseLeave(e:Event):void{
			panels.tooltip(null);
		}
		private function keyUpHandler(e:KeyboardEvent):void{
			if(!_enabled) return;
			if(e.keyLocation == 0){
				var char:String = String.fromCharCode(e.charCode);
				if(char == _password.substring(_passwordIndex,_passwordIndex+1)){
					_passwordIndex++;
					if(_passwordIndex >= _password.length){
						_passwordIndex = 0;
						if(visible && !panels.mainPanel.visible){
							panels.mainPanel.visible = true;
						}else{
							visible = !visible;
						}
					}
				}else{
					_passwordIndex = 0;
					var key:String = char.toLowerCase()+(e.ctrlKey?"0":"1")+(e.altKey?"0":"1")+(e.shiftKey?"0":"1");
					if(_keyBinds[key]){
						var bind:Array = _keyBinds[key];
						bind[0].apply(this, bind[1]);
					}
				}
			}
		}
		public function destroy():void{
			enabled = false;
			remote.close();
			removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			cl.destory();
			if(stage){
				stageRemovedHandle();
			}
		}
		public static function get remoteIsRunning():Boolean{
			var sCon:LocalConnection = new LocalConnection();
			try{
				sCon.allowInsecureDomain("*");
				sCon.connect(REMOTE_CONN_NAME);
			}catch(error:Error){
				return true;
			}
			sCon.close();
			return false;
		}
		public function addGraph(n:String, obj:Object, prop:String, col:Number, key:String, rect:Rectangle = null, inverse:Boolean = false):void{
			panels.addGraph(n,obj,prop,col,key,rect,inverse);
		}
		public function removeGraph(n:String, obj:Object = null, prop:String = null):void{
			panels.removeGraph(n, obj, prop);
		}
		//
		// WARNING: key binding hard references the function. 
		// This should only be used for development purposes only.
		//
		public function bindKey(char:String, ctrl:Boolean, alt:Boolean, shift:Boolean, fun:Function ,args:Array = null):void{
			if(!char || char.length!=1){
				addLine("Binding key must be a single character. You gave ["+char+"]", 10,CONSOLE_CHANNEL);
				return;
			}
			var key:String = char.toLowerCase()+(ctrl?"0":"1")+(alt?"0":"1")+(shift?"0":"1");
			if(fun is Function){
				_keyBinds[key] = [fun,args];
			}else{
				delete _keyBinds[key];
			}
			if(!quiet){
				addLine((fun is Function?"Bined":"Unbined")+" key <b>"+ char.toUpperCase() +"</b>"+ (ctrl?"+ctrl":"")+(alt?"+alt":"")+(shift?"+shift":"")+".",-1,CONSOLE_CHANNEL);
			}
		}
		public function setPanelPosition(panelname:String, p:Point):void{
			var panel:AbstractPanel = panels.getPanel(panelname);
			if(panel){
				panel.x = p.x;
				panel.y = p.y;
			}
		}
		public function setPanelArea(panelname:String, rect:Rectangle):void{
			var panel:AbstractPanel = panels.getPanel(panelname);
			if(panel){
				panel.x = rect.x;
				panel.y = rect.y;
				panel.width = rect.width;
				panel.height = rect.height;
			}
		}
		//
		// Panel settings
		// basically passing through to panels manager to save lines
		//
		public function get channelsPanel():Boolean{
			return panels.channelsPanel;
		}
		public function set channelsPanel(b:Boolean):void{
			panels.channelsPanel = b;
			if(b){
				var chPanel:ChannelsPanel = panels.getPanel(PANEL_CHANNELS) as ChannelsPanel;
				chPanel.start(_channels);
			}
			panels.updateMenu();
		}
		//
		public function get displayRoller():Boolean{
			return panels.displayRoller;
		}
		public function set displayRoller(b:Boolean):void{
			panels.displayRoller = b;
		}
		//
		public function get fpsMonitor():int{
			return panels.fpsMonitor;
		}
		public function set fpsMonitor(n:int):void{
			panels.fpsMonitor = n;
		}
		//
		public function get memoryMonitor():int{
			return panels.memoryMonitor;
		}
		public function set memoryMonitor(n:int):void{
			panels.memoryMonitor = n;
		}
		//
		public function watch(o:Object,n:String = null):String{
			var className:String = getQualifiedClassName(o);
			if(!n) n = className+"@"+getTimer();
			var nn:String = mm.watch(o,n);
			if(!quiet)
				addLine("Watching <b>"+className+"</b> as <font color=\"#FF0000\"><b>"+ nn +"</b></font>.",-1,CONSOLE_CHANNEL, false, true);
			return nn;
		}
		public function unwatch(n:String):void{
			mm.unwatch(n);
		}
		public function gc():void{
			if(isRemote){
				try{
					addLine("Sending garbage collection request to client",-1,CONSOLE_CHANNEL);
					remote.send("gc");
				}catch(e:Error){
					addLine(e,10,CONSOLE_CHANNEL);
				}
			}else{
				var ok:Boolean = mm.gc();
				var str:String = "Manual garbage collection "+(ok?"successful.":"FAILED. You need debugger version of flash player.");
				addLine(str,(ok?-1:10),CONSOLE_CHANNEL);
			}
		}
		public function store(n:String, obj:Object, strong:Boolean = false):void{
			var nn:String = cl.store(n, obj, strong);
			if(!quiet && nn){
				var str:String = obj is Function?"using <b>STRONG</b> reference":("for <b>"+getQualifiedClassName(obj)+"</b> using WEAK reference");
				addLine("Stored <font color=\"#FF0000\"><b>$"+nn+"</b></font> in commandLine for "+ str +".",-1,CONSOLE_CHANNEL,false,true);
			}
		}
		public function get strongRef():Boolean{
			return cl.useStrong;
		}
		public function set strongRef(b:Boolean):void{
			cl.useStrong = b;
		}
		public function inspect(obj:Object, detail:Boolean = true):void{
			addLine("INSPECT: "+ cl.inspect(obj,detail),5 ,CONSOLE_CHANNEL, false, true);
		}
		public function set enabled(newB:Boolean):void{
			if(_enabled == newB) return;
			if(_enabled && !newB){
				addLine("Disabled",10,CONSOLE_CHANNEL);
			}
			var pre:Boolean = _enabled;
			_enabled = newB;
			if(!pre && newB){
				addLine("Enabled",-1,CONSOLE_CHANNEL);
			}
		}
		public function get enabled():Boolean{
			return _enabled;
		}
		public function get paused():Boolean{
			return _isPaused;
		}
		public function set paused(newV:Boolean):void{
			if(_isPaused == newV) return;
			if(newV){
				addLine("Paused",10,CONSOLE_CHANNEL);
			}else{
				addLine("Resumed",-1,CONSOLE_CHANNEL);
			}
			_isPaused = newV;
			panels.mainPanel.updateMenu(true);
			panels.mainPanel.refresh();
		}
		//
		//
		//
		override public function get width():Number{
			return panels.mainPanel.width;
		}
		override public function set width(newW:Number):void{
			panels.mainPanel.width = newW;
		}
		override public function set height(newW:Number):void{
			panels.mainPanel.height = newW;
		}
		override public function get height():Number{
			return panels.mainPanel.height;
		}
		override public function get x():Number{
			return panels.mainPanel.x;
		}
		override public function set x(newW:Number):void{
			panels.mainPanel.x = newW;
		}
		override public function set y(newW:Number):void{
			panels.mainPanel.y = newW;
		}
		override public function get y():Number{
			return panels.mainPanel.y;
		}
		//
		//
		//
		private function _onEnterFrame(e:Event):void{
			if(!_enabled){
				return;
			}
			var time:int = getTimer();
			_mspf = time-_previousTime;

			_previousTime = time;
			if(alwaysOnTop && parent &&  parent.getChildIndex(this) < (parent.numChildren-1)){
				parent.setChildIndex(this,(parent.numChildren-1));
				if(!quiet){
					addLine("Attempted to move console on top (alwaysOnTop enabled)",-1,CONSOLE_CHANNEL);
				}
			}
			if( _isRepeating ){
				_repeated++;
				if(_repeated > maxRepeats && maxRepeats >= 0){
					_isRepeating = false;
				}
			}
			if(!_isPaused && visible){
				var arr:Array = mm.update();
				if(arr.length>0){
					addLine("GARBAGE COLLECTED "+arr.length+" item(s): "+arr.join(", "),10,CONSOLE_CHANNEL);
				}
				panels.mainPanel.update(!_isPaused && _linesChanged);
				if(_linesChanged) {
					var chPanel:ChannelsPanel = panels.getPanel(PANEL_CHANNELS) as ChannelsPanel;
					if(chPanel){
						chPanel.update();
					}
				}
				_linesChanged = false;
			}
			if(remote.remoting){
				remote.update(_mspf, stage?stage.frameRate:0);
			}
		}
		public function get fps():Number{
			return 1000/mspf;
		}
		public function get mspf():Number{
			return _mspf;
		}
		public function get currentMemory():uint {
			return remote.isRemote?remote.remoteMem:System.totalMemory;
		}
		//
		// REMOTING
		//
		public function get remoting():Boolean{
			return remote.remoting;
		}
		public function set remoting(newV:Boolean):void{
			remote.remoting = newV;
		}
		public function get isRemote():Boolean{
			return remote.isRemote;
		}
		public function set isRemote(newV:Boolean):void{
			remote.isRemote = newV;
			panels.updateMenu();
		}
		private function remoteLogSend(obj:Array):void{
			if(!remote.isRemote || !obj) return;
			var lines:Array = obj[0];
			for each( var line:Object in lines){
				if(line){
					var p:int = line["p"]?line["p"]:5;
					var channel:String = line["c"]?line["c"]:"";
					var r:Boolean = line["r"];
					var safe:Boolean = line["s"];
					addLine(line["text"],p,channel,r,safe);
				}
			}
			var remoteMSPFs:Array = obj[1];
			if(remoteMSPFs){
				var fpsp:FPSPanel = panels.getPanel(PANEL_FPS) as FPSPanel;
				if(fpsp){
					// the first value is stage.FrameRate
					var highest:Number = remoteMSPFs[0];
					fpsp.highest = highest;
					var len:int = remoteMSPFs.length;
					for(var i:int = 1; i<len;i++){
						var fps:Number = 1000/remoteMSPFs[i];
						if(fps > highest) fps = highest;
						fpsp.addCurrent(fps);
					}
					fpsp.updateKeyText();
					fpsp.drawGraph();
				}
			}
			remote.remoteMem = obj[2];
		}
		//
		//
		//
		public function set viewingChannel(str:String):void{
			viewingChannels = [str];
		}
		public function get viewingChannel():String{
			return _viewingChannels.join(",");
		}
		public function get viewingChannels():Array{
			return _viewingChannels.concat();
		}
		public function set viewingChannels(a:Array):void{
			_viewingChannels.splice(0);
			_viewingChannels.push.apply(this, a);
			panels.mainPanel.refresh();
			panels.updateMenu();
		}
		public function set tracingChannels(newVar:String):void{
			if(newVar.length>0){
				_tracingChannels = newVar.split(",");
			}
		}
		public function get tracingChannels():String{
			return String(_tracingChannels);
		}
		//
		public function get tracing():Boolean{
			return _tracing;
		}
		public function set tracing(b:Boolean):void{
			_tracing = b;
			panels.mainPanel.updateMenu();
		}
		public function set traceCall (f:Function):void{
			if(f==null){
				addLine("C.traceCall function setter must be not be null.", 10,CONSOLE_CHANNEL);
			}else{
				_traceCall = f;
			}
		}
		public function get traceCall ():Function{
			return _traceCall;
		}
		public function addLine(obj:Object,priority:Number = 0,channel:String = "",isRepeating:Boolean = false, skipSafe:Boolean = false):void{
			if(!_enabled){
				return;
			}
			var isRepeat:Boolean = (isRepeating && _isRepeating);
			var txt:String = String(obj);
			if( _tracing && !isRepeat && (_tracingChannels == null || _tracingChannels.indexOf(channel)>=0) ){
				if(tracingPriority <= priority || tracingPriority <= 0){
					_traceCall("["+channel+"] "+txt);
				}
			}
			if(!skipSafe){
				txt = txt.replace(/</gim, "&lt;");
 				txt = txt.replace(/>/gim, "&gt;");
			}
			if(!channel){
				channel = defaultChannel;
			}
			if(_channels.indexOf(channel) < 0){
				_channels.push(channel);
			}
			_linesChanged = true;
			var line:LogLineVO = new LogLineVO(txt,channel,priority, isRepeating, skipSafe);
			if(isRepeat){
				_lines.pop();
				_lines.push(line);
			}else{
				_repeated = 0;
				_lines.push(line);
				if(_lines.length > maxLines && maxLines > 0 ){
					_lines.splice(0,1);
				}
			}
			_isRepeating = isRepeating;
			
			if(remote.remoting){
				remote.addLineQueue(line);
			}
		}
		//
		// COMMAND LINE
		//
		public function set commandLine (newB:Boolean):void{
			panels.mainPanel.commandLine = newB;
		}
		public function get commandLine ():Boolean{
			return panels.mainPanel.commandLine;
		}
		public function runCommand(line:String):Object{
			if(remote.isRemote){
				addLine("Run command at remote: "+line,-2,CONSOLE_CHANNEL);
				try{
					remote.send("runCommand", line);
				}catch(err:Error){
					addLine("Command could not be sent to client: " + err, 10,CONSOLE_CHANNEL);
				}
			}else{
				return cl.run(line);
			}
			return null;
		}
		//
		// LOGGING
		//
		public function ch(channel:Object, newLine:Object, priority:Number = 2, isRepeating:Boolean = false):void{
			var chn:String;
			if(channel is String){
				chn = String(channel);
			}else if(channel){
				chn = getQualifiedClassName(channel);
				var ind:int = chn.lastIndexOf("::");
				chn = chn.substring(ind>=0?(ind+2):0);
			}else{
				chn = defaultChannel;
			}
			addLine(newLine,priority,chn, isRepeating);
		}
		public function pk(channel:Object, newLine:Object, priority:Number = 2, isRepeating:Boolean = false):void{
			var chn:String = getQualifiedClassName(channel);
			var ind:int = chn.lastIndexOf("::");
			if(ind>=0){
				chn = chn.substring(0,ind);
			}
			addLine(newLine,priority,chn, isRepeating);
		}
		public function add(newLine:Object, priority:Number = 2, isRepeating:Boolean = false):void{
			addLine(newLine,priority, defaultChannel, isRepeating);
		}
		public function set filterText(str:String):void{
			_filterText = str;
			if(str){
				clear(FILTERED_CHANNEL);
				addLine("Filtering ["+str+"]", 10,FILTERED_CHANNEL);
				viewingChannels = [FILTERED_CHANNEL];
			}else if(viewingChannel == FILTERED_CHANNEL){
				viewingChannels = [GLOBAL_CHANNEL];
			}
		}
		public function get filterText():String{
			return _filterText;
		}
		public function clear(channel:String = null):void{
			if(channel){
				for(var i:int=(_lines.length-1);i>=0;i--){
					if(_lines[i] && _lines[i].c == channel){
						delete _lines[i];
					}
				}
			}else{
				_lines.splice(0);
				_channels.splice(0);
				_channels.push(GLOBAL_CHANNEL);
			}
			panels.mainPanel.refresh();
			panels.updateMenu();
		}
	}
}
