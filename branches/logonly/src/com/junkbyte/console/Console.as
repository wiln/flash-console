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
	import com.junkbyte.console.core.Graphing;
	import com.junkbyte.console.core.MemoryMonitor;
	import com.junkbyte.console.core.Remoting;
	import com.junkbyte.console.utils.ShortClassName;
	import com.junkbyte.console.view.MainPanel;
	import com.junkbyte.console.view.PanelsManager;
	import com.junkbyte.console.vos.Log;
	import com.junkbyte.console.vos.Logs;

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

	/**
	 * Console is the main class. 
	 * Please see com.junkbyte.console.Cc for documentation as it shares the same properties and methods structure.
	 * @see http://code.google.com/p/flash-console/
	 * @see com.junkbyte.console.Cc
	 */
	public class Console extends Sprite {

		public static const VERSION:Number = 2.4;
		public static const VERSION_STAGE:String = "beta2";
		//
		public static const NAME:String = "Console";
		//
		public static const LOG_LEVEL:uint = 1;
		public static const INFO_LEVEL:uint = 3;
		public static const DEBUG_LEVEL:uint = 5;
		public static const WARN_LEVEL:uint = 7;
		public static const ERROR_LEVEL:uint = 9;
		public static const FATAL_LEVEL:uint = 10;
		//
		public static const MAPPING_SPLITTER:String = "|";
		//
		public var quiet:Boolean;
		public var alwaysOnTop:Boolean = true;
		//
		private var _config:ConsoleConfig;
		private var _panels:PanelsManager;
		private var _graphing:Graphing;
		private var _remoter:Remoting;
		private var _topTries:int = 50;
		//
		private var _paused:Boolean;
		private var _tracing:Boolean;
		private var _mspf:Number;
		private var _prevTime:int;
		private var _rollerKey:KeyBind;
		private var _channels:Array;
		private var _repeating:uint;
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
			_channels = [_config.globalChannel, _config.defaultChannel];
			_lines = new Logs();
			_graphing = new Graphing(report);
			_remoter = new Remoting(this, pass);
			//
			// VIEW setup
			_config.updateStyleSheet();
			var mainPanel:MainPanel = new MainPanel(this, _lines, _channels);
			_panels = new PanelsManager(this, mainPanel, _channels);
			//
			report("<b>Console v"+VERSION+(VERSION_STAGE?(" "+VERSION_STAGE):"")+", Happy coding!</b>", -2);
			addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			if(pass) visible = false;
			// must have enterFrame here because user can start without a parent display and use remoting.
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		private function stageAddedHandle(e:Event=null):void{
			if(loaderInfo){
				listenUncaughtErrors(loaderInfo);
			}
			removeEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			addEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave, false, 0, true);
		}
		private function stageRemovedHandle(e:Event=null):void{
			removeEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
			addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		private function onStageMouseLeave(e:Event):void{
			_panels.tooltip(null);
		}
		public function destroy():void{
			_remoter.close();
			removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle);
			removeEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
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
			var error:Object = e["error"]; // for flash 9 compatibility
			var str:String;
			if (error is Error){
				str = Error(error).getStackTrace();
			}else if (error is ErrorEvent){
				str = ErrorEvent(error).text;
			}
			if(!str){
				str = String(error);
			}
			report(str, FATAL_LEVEL, false);
		}
		//
		public function get fpsMonitor():Boolean{
			return _graphing.fpsMonitor;
		}
		public function set fpsMonitor(b:Boolean):void{
			_graphing.fpsMonitor = b;
			panels.mainPanel.updateMenu();
		}
		//
		public function get memoryMonitor():Boolean{
			return _graphing.memoryMonitor;
		}
		public function set memoryMonitor(b:Boolean):void{
			_graphing.memoryMonitor = b;
			panels.mainPanel.updateMenu();
		}
		//
		public function gc():void{
			var ok:Boolean = MemoryMonitor.Gc();
			var str:String = "Manual garbage collection "+(ok?"successful.":"FAILED. You need debugger version of flash player.");
			report(str,(ok?-1:10));
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
			var time:int = getTimer();
			_mspf = time-_prevTime;
			_prevTime = time;
			
			if(_repeating > 0) _repeating--;
			
			var graphsList:Array = _graphing.update(stage?stage.frameRate:0);
			_remoter.update(graphsList, null);
			
			// VIEW UPDATES ONLY
			if(visible && parent!=null){
				if(alwaysOnTop && parent.getChildAt(parent.numChildren-1) != this && _topTries>0){
					_topTries--;
					parent.addChild(this);
					if(!quiet) report("Moved console on top (alwaysOnTop enabled), "+_topTries+" attempts left.",-1);
				}
				_panels.mainPanel.update(!_paused && _lineAdded);
				_panels.update(_paused, _lineAdded);
				if(graphsList != null) _panels.updateGraphs(graphsList, !_paused); 
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
		//
		public function get tracing():Boolean{
			return _tracing;
		}
		public function set tracing(b:Boolean):void{
			_tracing = b;
			_panels.mainPanel.updateMenu();
		}
		public function report(obj:*, priority:Number = 0, skipSafe:Boolean = true):void{
			addLine(castString(obj), priority, _config.consoleChannel, false, skipSafe, 0);
		}
		public function addLine(txt:String, priority:Number = 0,channel:String = null,isRepeating:Boolean = false, skipSafe:Boolean = false, stacks:int = -1):void{
			var isRepeat:Boolean = (isRepeating && _repeating > 0);
			if(!channel || channel == _config.globalChannel) channel = _config.defaultChannel;
			if(priority >= _config.autoStackPriority && stacks<0) stacks = _config.defaultStackDepth;
			if(skipSafe) stacks = -1;
			var stackArr:Array = stacks>0?getStack(stacks):null;
			
			if( _tracing && !isRepeat && _config.traceCall != null){
				_config.traceCall(channel, (stackArr==null?txt:(txt+"\n @ "+stackArr.join("\n @ "))), priority);
			}
			if(!skipSafe){
				txt = txt.replace(/</gm, "&lt;");
 				txt = txt.replace(new RegExp(">", "gm"), "&gt;");
			}
			if(stackArr != null) {
				var tp:int = priority;
				for each(var sline:String in stackArr) {
					txt += "\n<p"+tp+"> @ "+sline+"</p"+tp+">";
					if(tp>0) tp--;
				}
			}
			if(_channels.indexOf(channel) < 0){
				_channels.push(channel);
			}
			var line:Log = new Log(txt,channel,priority, isRepeating);
			if(isRepeat){
				_lines.pop();
				_lines.push(line);
			}else{
				_repeating = isRepeating?_config.maxRepeats:0;
				_lines.push(line);
				if(_config.maxLines > 0 ){
					var off:int = _lines.length - _config.maxLines;
					if(off > 0){
						_lines.shift(off);
					}
				}
			}
			_lineAdded = true;
			
			_remoter.addLineQueue(line);
		}
		private function getStack(depth:int):Array{
			var e:Error = new Error();
			var str:String = e.hasOwnProperty("getStackTrace")?e.getStackTrace():null;
			if(!str) return null;
			var lines:Array = str.split(/\n\sat\s/);
			var len:int = lines.length;
			var reg:RegExp = new RegExp("Function|"+getQualifiedClassName(this)+"|"+getQualifiedClassName(Cc));
			for (var i:int = 2; i < len; i++){
				if((lines[i].search(reg) != 0)){
					return lines.slice(i, i+depth);
				}
			}
			return null;
		}
		//
		// LOGGING
		//
		public function ch(channel:*, newLine:*, priority:Number = 2, isRepeating:Boolean = false):void{
			var chn:String;
			if(channel is String) chn = channel as String;
			else if(channel) chn = ShortClassName(channel);
			else chn = _config.defaultChannel;
			addLine(castString(newLine), priority,chn, isRepeating);
		}
		public function add(newLine:*, priority:Number = 2, isRepeating:Boolean = false):void{
			addLine(castString(newLine), priority, _config.defaultChannel, isRepeating);
		}
		public function stack(newLine:*, depth:int = -1, priority:Number = 5, ch:String = null):void{
			addLine(castString(newLine), priority, ch, false, false, depth>=0?depth:_config.defaultStackDepth);
		}
		public function log(...args):void{
			addLine(joinArgs(args), LOG_LEVEL);
		}
		public function info(...args):void{
			addLine(joinArgs(args), INFO_LEVEL);
		}
		public function debug(...args):void{
			addLine(joinArgs(args), DEBUG_LEVEL);
		}
		public function warn(...args):void{
			addLine(joinArgs(args), WARN_LEVEL);
		}
		public function error(...args):void{
			addLine(joinArgs(args), ERROR_LEVEL);
		}
		public function fatal(...args):void{
			addLine(joinArgs(args), FATAL_LEVEL);
		}
		public function logch(channel:*, ...args):void{
			ch(channel, joinArgs(args), LOG_LEVEL);
		}
		public function infoch(channel:*, ...args):void{
			ch(channel, joinArgs(args), INFO_LEVEL);
		}
		public function debugch(channel:*, ...args):void{
			ch(channel, joinArgs(args), DEBUG_LEVEL);
		}
		public function warnch(channel:*, ...args):void{
			ch(channel, joinArgs(args), WARN_LEVEL);
		}
		public function errorch(channel:*, ...args):void{
			ch(channel, joinArgs(args), ERROR_LEVEL);
		}
		public function fatalch(channel:*, ...args):void{
			ch(channel, joinArgs(args), FATAL_LEVEL);
		}
		private function joinArgs(args:Array):String{
			var str:String = "";
			var len:int = args.length;
			for(var i:int = 0; i < len; i++){
				// need to spifically cast to string to produce correct results
				// example arg.join produces null/undefined values to "".
				str += (i?" ":"")+((args[i] is XML || args[i] is XMLList)?args[i].toXMLString():String(args[i]));
			}
			return str;
		}
		private function castString(obj:*):String{
			return (obj is XML || obj is XMLList)?obj.toXMLString():String(obj);
		}
		//
		//
		//
		public function set filterText(str:String):void{
			_panels.mainPanel.filterText = str;
		}
		public function get filterText():String{
			return _panels.mainPanel.filterText;
		}
		public function set filterRegExp(exp:RegExp):void{
			_panels.mainPanel.filterRegExp = exp;
		}
		//
		public function clear(channel:String = null):void{
			if(channel){
				var line:Log = _lines.first;
				while(line){
					if(line.c == channel){
						_lines.remove(line);
					}
					line = line.next;
				}
				var ind:int = _channels.indexOf(channel);
				if(ind>=0) _channels.splice(ind,1);
			}else{
				_lines.clear();
				_channels.splice(0);
				_channels.push(_config.globalChannel, _config.defaultChannel);
			}
			if(!_paused) _panels.mainPanel.updateToBottom();
			_panels.updateMenu();
		}
		//
		public function get config():ConsoleConfig{return _config;}
		public function get panels():PanelsManager{return _panels;}
		public function get graphing():Graphing{return _graphing;}
		//
		public function getLogsAsObjects():Array{
			var a:Array = [];
			var line:Log = _lines.first;
			while(line){
				a.push(line.toObject());
				line = line.next;
			}
			return a;
		}
		public function getAllLog(splitter:String = "\n"):String{
			var str:String = "";
			var line:Log = _lines.first;
			while(line){
				str += (line.toString()+(line.next?splitter:""));
				line = line.next;
			}
			return str;
		}
	}
}