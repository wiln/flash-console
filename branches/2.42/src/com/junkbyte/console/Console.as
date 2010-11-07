/*
* 
* Copyright (c) 2008-2010 Lu Aye Oo
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
package com.junkbyte.console 
{
	import com.junkbyte.console.core.CommandLine;
	import com.junkbyte.console.core.DisplayMapper;
	import com.junkbyte.console.core.Graphing;
	import com.junkbyte.console.core.KeyBinder;
	import com.junkbyte.console.core.LogReferences;
	import com.junkbyte.console.core.MemoryMonitor;
	import com.junkbyte.console.core.Remoting;
	import com.junkbyte.console.core.UserData;
	import com.junkbyte.console.utils.ShortClassName;
	import com.junkbyte.console.view.PanelsManager;
	import com.junkbyte.console.view.RollerPanel;
	import com.junkbyte.console.vos.Log;
	import com.junkbyte.console.core.Logs;

	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	//import com.junkbyte.console.core.ObjectsMonitor;
	

	/**
	 * Console is the main class. 
	 * Please see com.junkbyte.console.Cc for documentation as it shares the same properties and methods structure.
	 * @see http://code.google.com/p/flash-console/
	 * @see com.junkbyte.console.Cc
	 */
	public class Console extends Sprite {

		public static const VERSION:Number = 2.45;
		public static const VERSION_STAGE:String = "alpha";
		public static const BUILD:int = 521;
		public static const BUILD_DATE:String = "2010/11/06 02:15";
		//
		public static const NAME:String = "Console";
		//
		public static const LOG:uint = 1;
		public static const INFO:uint = 3;
		public static const DEBUG:uint = 6;
		public static const WARN:uint = 8;
		public static const ERROR:uint = 9;
		public static const FATAL:uint = 10;
		//
		//
		private var _config:ConsoleConfig;
		private var _panels:PanelsManager;
		private var _cl:CommandLine;
		private var _ud:UserData;
		private var _kb:KeyBinder;
		private var _links:LogReferences;
		private var _mm:MemoryMonitor;
		private var _graphing:Graphing;
		private var _remoter:Remoting;
		private var _mapper:DisplayMapper;
		private var _topTries:int = 50;
		//
		private var _paused:Boolean;
		private var _rollerKey:KeyBind;
		private var _lines:Logs;
		private var _lineAdded:Boolean;
		
		/**
		 * Console is the main class. However please use C for singleton Console adapter.
		 * Using Console through C will also make sure you can remove console in a later date
		 * by simply removing Cc.start() or Cc.startOnStage()
		 * 
		 * 
		 * @see com.junkbyte.console.Cc
		 * @see http://code.google.com/p/flash-console/
		 */
		public function Console(pass:String = "", config:ConsoleConfig = null) {
			name = NAME;
			tabChildren = false; // Tabbing is not supported
			_config = config?config:new ConsoleConfig();
			//
			_lines = new Logs(_config);
			_ud = new UserData(_config.sharedObjectName, _config.sharedObjectPath);
			_links = new LogReferences(this);
			_cl = new CommandLine(this);
			_mapper =  new DisplayMapper(this);
			_graphing = new Graphing(report);
			_remoter = new Remoting(this, pass);
			_kb = new KeyBinder(pass);
			_kb.addEventListener(Event.CONNECT, passwordEnteredHandle, false, 0, true);
			
			_config.style.updateStyleSheet();
			_panels = new PanelsManager(this, _lines);
			
			report("<b>Console v"+VERSION+VERSION_STAGE+" b"+BUILD+". Happy coding!</b>", -2);
			addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			if(pass) visible = false;
			// must have enterFrame here because user can start without a parent display and use remoting.
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		private function stageAddedHandle(e:Event=null):void{
			if(_cl.base == null) _cl.base = parent;
			if(loaderInfo){
				listenUncaughtErrors(loaderInfo);
			}
			removeEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			addEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _kb.keyDownHandler, false, 0, true);
		}
		private function stageRemovedHandle(e:Event=null):void{
			_cl.base = null;
			removeEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
			addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, _kb.keyDownHandler);
		}
		private function onStageMouseLeave(e:Event):void{
			_panels.tooltip(null);
		}
		private function passwordEnteredHandle(e:Event):void{
			if(visible && !_panels.mainPanel.visible){
				_panels.mainPanel.visible = true;
			}else visible = !visible;
		}
		public function destroy():void{
			_remoter.close();
			removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
			removeEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			_cl.destory();
		}
		
		// requires flash player target to be 10.1
		public function listenUncaughtErrors(loaderinfo:LoaderInfo):void {
			try{
				var uncaughtErrorEvents:IEventDispatcher = loaderinfo["uncaughtErrorEvents"];
				if(uncaughtErrorEvents){
					uncaughtErrorEvents.addEventListener("uncaughtError", uncaughtErrorHandle, false, 0, true);
				}
			}catch(err:Error){
				// seems uncaughtErrorEvents is not avaviable on this player/target, which is fine.
			}
		}
		private function uncaughtErrorHandle(e:Event):void{
			var error:* = e.hasOwnProperty("error")?e["error"]:e; // for flash 9 compatibility
			var str:String;
			if (error is Error){
				str = _links.makeString(error);
			}else if (error is ErrorEvent){
				str = ErrorEvent(error).text;
			}
			if(!str){
				str = String(error);
			}
			report(str, FATAL, false);
		}
		
		public function addGraph(n:String, obj:Object, prop:String, col:Number = -1, key:String = null, rect:Rectangle = null, inverse:Boolean = false):void{
			if(obj == null) {
				report("ERROR: Graph ["+n+"] received a null object to graph property ["+prop+"].", 10);
				return;
			}
			_graphing.add(n,obj,prop,col,key,rect,inverse);
		}
		public function fixGraphRange(n:String, min:Number = NaN, max:Number = NaN):void{
			_graphing.fixRange(n, min, max);
		}
		public function removeGraph(n:String, obj:Object = null, prop:String = null):void{
			_graphing.remove(n, obj, prop);
		}
		//
		// WARNING: key binding hard references the function. 
		// This should only be used for development purposes only.
		//
		public function bindKey(key:KeyBind, fun:Function ,args:Array = null):void{
			if(!_kb.bindKey(key, fun, args)){
				report("Warning: bindKey character ["+key.char+"] is conflicting with Console password.",8);
			}else if(!config.quiet) {
				report((fun ==null?"Unbined":"Bined")+" "+key.toString(),-1);
			}
		}
		//
		// Panel settings
		// basically passing through to panels manager to save lines
		//
		public function get displayRoller():Boolean{
			return _panels.displayRoller;
		}
		public function set displayRoller(b:Boolean):void{
			_panels.displayRoller = b;
		}
		public function setRollerCaptureKey(char:String, shift:Boolean = false, ctrl:Boolean = false, alt:Boolean = false):void{
			if(_rollerKey){
				_kb.bindKey(_rollerKey, null);
				_rollerKey = null;
			}
			if(char && char.length==1) {
				_rollerKey = new KeyBind(char, shift, ctrl, alt);
				_kb.bindKey(_rollerKey, onRollerCaptureKey);
			}
		}
		public function get rollerCaptureKey():KeyBind{
			return _rollerKey;
		}
		private function onRollerCaptureKey():void{
			if(displayRoller){
				report("Display Roller Capture:<br/>"+RollerPanel(_panels.getPanel(RollerPanel.NAME)).capture(), -1);
			}
		}
		//
		public function get fpsMonitor():Boolean{
			if(_remoter.isRemote) return panels.fpsMonitor;
			return _graphing.fpsMonitor;
		}
		public function set fpsMonitor(b:Boolean):void{
			if(_remoter.isRemote){
				_remoter.send(Remoting.FPS, b);
			}else{
				_graphing.fpsMonitor = b;
				panels.mainPanel.updateMenu();
			}
		}
		//
		public function get memoryMonitor():Boolean{
			if(_remoter.isRemote) return panels.memoryMonitor;
			return _graphing.memoryMonitor;
		}
		public function set memoryMonitor(b:Boolean):void{
			if(_remoter.isRemote){
				_remoter.send(Remoting.MEM, b);
			}else{
				_graphing.memoryMonitor = b;
				panels.mainPanel.updateMenu();
			}
		}
		
		//
		public function watch(o:Object,n:String = null):String{
			var className:String = getQualifiedClassName(o);
			if(!n) n = className+"@"+getTimer();
			if(!_mm) _mm = new MemoryMonitor();
			var nn:String = _mm.watch(o,n);
			if(!config.quiet) report("Watching <b>"+className+"</b> as <p5>"+ nn +"</p5>.",-1);
			return nn;
		}
		public function unwatch(n:String):void{
			if(_mm) _mm.unwatch(n);
		}
		public function gc():void{
			if(remote){
				try{
					report("Sending garbage collection request to client",-1);
					_remoter.send(Remoting.GC);
				}catch(e:Error){
					report(e,10);
				}
			}else{
				var ok:Boolean = MemoryMonitor.Gc();
				var str:String = "Manual garbage collection "+(ok?"successful.":"FAILED. You need debugger version of flash player.");
				report(str,(ok?-1:10));
			}
		}
		public function store(n:String, obj:Object, strong:Boolean = false):void{
			_cl.store(n, obj, strong);
		}
		public function map(base:DisplayObjectContainer, maxstep:uint = 0):void{
			_mapper.map(base, maxstep);
		}
		public function reMap(path:String):void{
			if(remote){
				_remoter.send(Remoting.RMAP, path);
			}else{
				_cl.setReturned(_mapper.reMap(path, stage), true);
			}
		}
		public function inspect(obj:Object, detail:Boolean = true):void{
			_links.inspect(obj,detail);
		}
		public function explode(obj:Object, depth:int = 3):void{
			report(_links.explode(obj, depth), 1);
		}
		public function get paused():Boolean{
			return _paused;
		}
		public function set paused(newV:Boolean):void{
			if(_paused == newV) return;
			if(newV) report("Paused", 10);
			else report("Resumed", -1);
			_paused = newV;
			_panels.mainPanel.setPaused(newV);
		}
		//
		//
		//
		override public function get width():Number{
			return _panels.mainPanel.width;
		}
		override public function set width(newW:Number):void{
			_panels.mainPanel.width = newW;
		}
		override public function set height(newW:Number):void{
			_panels.mainPanel.height = newW;
		}
		override public function get height():Number{
			return _panels.mainPanel.height;
		}
		override public function get x():Number{
			return _panels.mainPanel.x;
		}
		override public function set x(newW:Number):void{
			_panels.mainPanel.x = newW;
		}
		override public function set y(newW:Number):void{
			_panels.mainPanel.y = newW;
		}
		override public function get y():Number{
			return _panels.mainPanel.y;
		}
		//
		//
		//
		private function _onEnterFrame(e:Event):void{
			_lines.tick();
			if(_mm){
				var arr:Array = _mm.update();
				if(arr.length>0){
					report("<b>GARBAGE COLLECTED "+arr.length+" item(s): </b>"+arr.join(", "),-2);
					if(_mm.count == 0) _mm = null;
				}
			}
			var graphsList:Array;
			if(!_remoter.isRemote){
			 	//om = _om.update();
			 	graphsList = _graphing.update(stage?stage.frameRate:0);
			}
			_remoter.update(graphsList);
			
			// VIEW UPDATES ONLY
			if(visible && parent){
				if(config.alwaysOnTop && parent.getChildAt(parent.numChildren-1) != this && _topTries>0){
					_topTries--;
					parent.addChild(this);
					if(!config.quiet) report("Moved console on top (alwaysOnTop enabled), "+_topTries+" attempts left.",-1);
				}
				_panels.update(_paused, _lineAdded);
				if(graphsList) _panels.updateGraphs(graphsList, !_paused); 
				_lineAdded = false;
			}
		}
		//
		// REMOTING
		//
		public function get remoting():Boolean{
			return _remoter.remoting;
		}
		public function set remoting(newV:Boolean):void{
			_remoter.remoting = newV;
		}
		public function get remote():Boolean{
			return _remoter.isRemote;
		}
		public function set remote(newV:Boolean):void{
			_remoter.isRemote = newV;
			_panels.updateMenu();
		}
		public function set remotingPassword(str:String):void{
			_remoter.remotingPassword = str;
		}
		//
		//
		//
		public function get viewingChannels():Array{
			return _panels.mainPanel.viewingChannels;
		}
		public function set viewingChannels(a:Array):void{
			_panels.mainPanel.viewingChannels = a;
		}
		public function report(obj:*, priority:int = 0, skipSafe:Boolean = true):void{
			var cn:String = viewingChannels[0] == config.globalChannel?config.consoleChannel:viewingChannels[0];
			addLine([obj], priority, cn, false, skipSafe, 0);
		}
		public function addLine(arr:Array, priority:Number = 0,channel:String = null,isRepeating:Boolean = false, html:Boolean = false, stacks:int = -1):void{
			var txt:String = "";
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++){
				txt += (i?" ":"")+_links.makeString(arr[i], null, html);
			}
			
			if(priority >= _config.autoStackPriority && stacks<0) stacks = _config.defaultStackDepth;
			
			if(!channel || channel == _config.globalChannel) channel = _config.defaultChannel;
			if(channel == LogReferences.INSPECTING_CHANNEL && viewingChannels[0] != LogReferences.INSPECTING_CHANNEL){
				viewingChannels = [LogReferences.INSPECTING_CHANNEL];
			}
			
			if(!html && stacks>=0){
				txt += getStack(stacks, priority);
			}
			var line:Log = new Log(txt, channel, priority, isRepeating, html);
			
			var cantrace:Boolean = _lines.add(line, isRepeating);
			if( _config.tracing && cantrace && _config.traceCall != null){
				_config.traceCall(channel, line.plainText(), priority);
			}
			
			_lineAdded = true;
			_remoter.addLineQueue(line);
		}
		private function getStack(depth:int, priority:int):String{
			var e:Error = new Error();
			var str:String = e.hasOwnProperty("getStackTrace")?e.getStackTrace():null;
			if(!str) return "";
			var txt:String = "";
			var lines:Array = str.split(/\n\sat\s/);
			var len:int = lines.length;
			var reg:RegExp = new RegExp("Function|"+getQualifiedClassName(this)+"|"+getQualifiedClassName(Cc));
			var found:Boolean = false;
			for (var i:int = 2; i < len; i++){
				if(!found && (lines[i].search(reg) != 0)){
					found = true;
				}
				if(found){
					txt += "\n<p"+priority+"> @ "+lines[i]+"</p"+priority+">";
					if(priority>0) priority--;
					depth--;
					if(depth<=0){
						break;
					}
				}
			}
			return txt;
		}
		//
		// COMMAND LINE
		//
		public function set commandLine(b:Boolean):void{
			if(b) _config.commandLineAllowed = true;
			_panels.mainPanel.commandLine = b;
		}
		public function get commandLine ():Boolean{
			return _panels.mainPanel.commandLine;
		}
		public function runCommand(line:String):*{
			if(_remoter.isRemote){
				if(line && line.charAt(0) == "~"){
					return _cl.run(line.substring(1));
				}else{
					report("Run command at remote: "+line,-2);
					if(!_remoter.send(Remoting.CMD, line)){
						report("Command could not be sent to client.", 10);
					}
				}
			}else{
				return _cl.run(line);
			}
			return null;
		}
		public function addSlashCommand(n:String, callback:Function):void{
			_cl.addSlashCommand(n, callback);
		}
		//
		// LOGGING
		//
		public function add(newLine:*, priority:int = 2, isRepeating:Boolean = false):void{
			addLine(new Array(newLine), priority, _config.defaultChannel, isRepeating);
		}
		public function stack(newLine:*, depth:int = -1, priority:int = 5):void{
			addLine(new Array(newLine), priority, _config.defaultChannel, false, false, depth>=0?depth:_config.defaultStackDepth);
		}
		public function stackch(ch:String, newLine:*, depth:int = -1, priority:int = 5):void{
			addLine(new Array(newLine), priority, ch, false, false, depth>=0?depth:_config.defaultStackDepth);
		}
		public function log(...args):void{
			addLine(args, LOG);
		}
		public function info(...args):void{
			addLine(args, INFO);
		}
		public function debug(...args):void{
			addLine(args, DEBUG);
		}
		public function warn(...args):void{
			addLine(args, WARN);
		}
		public function error(...args):void{
			addLine(args, ERROR);
		}
		public function fatal(...args):void{
			addLine(args, FATAL);
		}
		public function ch(channel:*, newLine:*, priority:Number = 2, isRepeating:Boolean = false):void{
			addCh(channel, new Array(newLine), priority, isRepeating);
		}
		public function logch(channel:*, ...args):void{
			addCh(channel, args, LOG);
		}
		public function infoch(channel:*, ...args):void{
			addCh(channel, args, INFO);
		}
		public function debugch(channel:*, ...args):void{
			addCh(channel, args, DEBUG);
		}
		public function warnch(channel:*, ...args):void{
			addCh(channel, args, WARN);
		}
		public function errorch(channel:*, ...args):void{
			addCh(channel, args, ERROR);
		}
		public function fatalch(channel:*, ...args):void{
			addCh(channel, args, FATAL);
		}
		private function addCh(channel:*, newLine:Array, priority:int = 2, isRepeating:Boolean = false):void{
			var chn:String;
			if(channel is String) chn = channel as String;
			else if(channel) chn = ShortClassName(channel);
			else chn = _config.defaultChannel;
			addLine(newLine, priority,chn, isRepeating);
		}
		//
		//
		//
		public function clear(channel:String = null):void{
			_lines.clear(channel);
			if(!_paused) _panels.mainPanel.updateToBottom();
			_panels.updateMenu();
		}
		public function getAllLog(splitter:String = "\n"):String{
			return _lines.getAllLog(splitter);
		}
		//
		public function get config():ConsoleConfig{return _config;}
		public function get panels():PanelsManager{return _panels;}
		public function get cl():CommandLine{return _cl;}
		public function get ud():UserData{return _ud;}
		public function get remoter():Remoting{return _remoter;}
		public function get graphing():Graphing{return _graphing;}
		public function get links():LogReferences{return _links;}
		public function get lines():Logs{return _lines;}
	}
}