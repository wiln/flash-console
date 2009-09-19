/*
* 
* Copyright (c) 2008 Atticmedia
* 
* @author 		Lu Aye Oo
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
* 
*/
package com.atticmedia.console {
	import flash.geom.Point;	
	
	import com.atticmedia.console.view.GraphingPanel;
	import flash.text.TextFieldAutoSize;	
	import flash.system.System;	
	
	import com.atticmedia.console.view.*;
	
	import flash.utils.getTimer;	
	import flash.system.Security;	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	import com.atticmedia.console.core.*;	

	public class Console extends Sprite {

		public static const NAME:String = "Console";
		public static const PANEL_MAIN:String = "mainPanel";
		public static const PANEL_CHANNELS:String = "channelsPanel";
		public static const PANEL_FPS:String = "fpsPanel";
		public static const PANEL_MEMORY:String = "memoryPanel";
		public static const PANEL_ROLLER:String = "rollerPanel";
		
		public static const VERSION:Number = 1.5;

		public static const REMOTE_CONN_NAME:String = "_ConsoleRemote";
		public static const REMOTER_CONN_NAME:String = "_ConsoleRemoter";
		
		public static const CONSOLE_CHANNEL:String = "C";
		public static const FILTERED_CHANNEL:String = "Filtered";
		public static const GLOBAL_CHANNEL:String = "global";
		//
		public var style:Style;
		public var panels:PanelsManager;
		public var mm:MemoryMonitor;
		public var cl:CommandLine;
		//
		public var quiet:Boolean;
		public var tracing:Boolean;
		public var maxLines:int = 500;
		public var prefixChannelNames:Boolean = true;
		public var alwaysOnTop:Boolean = true;
		public var maxRepeats:Number = 100;
		public var remoteDelay:int = 25;
		//
		private var _isPaused:Boolean;
		private var _enabled:Boolean = true;
		private var _isRemoting:Boolean;
		private var _isRemote:Boolean;
		private var _remoteMSPF:int;
		private var _remoteMem:int;
		
		private var _channels:Array = [GLOBAL_CHANNEL];
		private var _viewingChannels:Array = [GLOBAL_CHANNEL];
		private var _defaultChannel:String = "traces";
		private var _tracingChannels:Array;
		private var _remoteLinesQueue:Array;
		private var _isRepeating:Boolean;
		private var _repeated:int;
		private var _lines:Array = [];
		private var _linesChanged:Boolean;
		
		public function Console(pass:String = "") {
			name = NAME;
			
			style = new Style();
			panels = new PanelsManager(this, new MainPanel(this, _lines, _channels));
			mm = new MemoryMonitor();
			cl = new CommandLine(this);
			cl.store("C",this);
			cl.reserved.push("C");
			//cl.addEventListener(CommandLine.SEARCH_REQUEST, onCommandSearch, false, 0, true);
			
			addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
			addLine("<b>v"+VERSION+", Happy bug fixing!</b>",-2,CONSOLE_CHANNEL,false,true);
			//
			// TEST...TEST TEST
			//
			/*
			addLine("Hey how are you, priority 0",0);
			addLine("<b>priority 0</b>",1);
			addLine("priority 1",2);
			addLine("<b>v"+VERSION+", Happy bug fixing!</b>",3);
			addLine("<b>v"+VERSION+", Happy bug fixing!</b>",4, "test");
			addLine("<b>v"+VERSION+", Happy bug fixing!</b>",5, "test");
			addLine("<b>v"+VERSION+", Happy bug fixing!</b>",6, "rofl");
			addLine("<test>rolm anasf <gigoe></test>",7, "rofl");
			addLine("<b>v"+VERSION+", Happy bug fixing!</b>",8, "rofl");
			addLine("<b>v"+VERSION+", Happy bug fixing!</b>",9, "GG");
			addLine("<b>v"+VERSION+", Happy bug fixing!</b>",10, "GG");*/
			panels.mainPanel.height = 350;
			//addGraph("mouse", this,"mouseX", 0x00DD00, "x");
			//addGraph("mouse", this,"mouseY", 0xDD0000, "y", new Rectangle(10,120,200,100), true);
		}
		public static function get remoteIsRunning():Boolean{
			var sCon:LocalConnection = new LocalConnection();
			try{
				sCon.allowInsecureDomain("*", "localhost");
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
			}else{
				panels.mainPanel.updateMenu();
			}
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
			var ok:Boolean = mm.gc();
			var str:String = "Manual garbage collection "+(ok?"successful.":"FAILED. You need debugger version of flash player.");
			addLine(str,(ok?-1:10),CONSOLE_CHANNEL);
		}
		public function get paused():Boolean{
			return _isPaused;
		}
		public function set paused(newV:Boolean):void{
			if(newV){
				this.addLine("Paused",10,CONSOLE_CHANNEL);
				// refresh page here to show the message before it pauses.
				//panels.mainPanel.refresh();
			}else{
				this.addLine("Resumed",-1,CONSOLE_CHANNEL);
			}
			_isPaused = newV;
			panels.mainPanel.refresh();
		}
		private function _onEnterFrame(e:Event):void{
			if(!_enabled){
				return;
			}
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
				//_fps.update(_isRemote?_remoteMSPF:0);
				var arr:Array = mm.update();
				if(arr.length>0){
					addLine("GARBAGE COLLECTED: "+arr.join(", "),10,CONSOLE_CHANNEL);
				}
			}
			panels.mainPanel.update(!_isPaused && _linesChanged);
			if(_linesChanged) {
				var chPanel:ChannelsPanel = panels.getPanel(PANEL_CHANNELS) as ChannelsPanel;
				if(chPanel){
					chPanel.update();
				}
			}
			_linesChanged = false;
			/*if(_isRemoting){
				_remoteDelayed++;
				if(_remoteDelayed > remoteDelay){
					updateRemote();
					_remoteDelayed = 0;
				}
			}*/
		}
		public function get viewingChannels():Array{
			return _viewingChannels;
		}
		public function get defaultChannel():String{
			return _defaultChannel;
		}
		public function addLine(obj:Object,priority:Number = 0,channel:String = "",isRepeating:Boolean = false, skipSafe:Boolean = false):void{
			if(!_enabled){
				return;
			}
			var txt:String = String(obj);
			var tmpText:String = txt;
			if(!skipSafe){
				txt = txt.replace(/</gim, "&lt;");
 				txt = txt.replace(/>/gim, "&gt;");
			}
			if(channel == ""){
				channel = _defaultChannel;
			}
			if(_channels.indexOf(channel) < 0){
				_channels.push(channel);
			}
			var line:LogLineVO = new LogLineVO(txt,channel,priority, isRepeating, skipSafe);
			_linesChanged = true;
			if(isRepeating && _isRepeating){
				_lines.pop();
				_lines.push(line);
			}else{
				_repeated = 0;
				_lines.push(line);
				if(_lines.length > maxLines && maxLines > 0 ){
					_lines.splice(0,1);
				}
				if( tracing && (_tracingChannels == null || _tracingChannels.indexOf(channel)>=0) ){
					trace("["+channel+"] "+tmpText);
				}
			}
			_isRepeating = isRepeating;
			
			if(_isRemoting){
				_remoteLinesQueue.push(line);
			}
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
				chn = _defaultChannel;
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
			addLine(newLine,priority, _defaultChannel, isRepeating);
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
			panels.mainPanel.updateMenu();
		}
	}
}
