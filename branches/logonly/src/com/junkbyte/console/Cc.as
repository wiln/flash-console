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
* 

	BASICc USAGE:
		
		import com.junkbyte.console.*;
		Cc.start(this); // this = preferably the root or stage
		
		// OR  Cc.start(this,"debug");
		// Start console, parameter "debug" (optional) sets the console's password.
		// console will only open after you type "debug" in sequence at anytime on stage. 
		// Leave blank to disable password, where console will launch straight away.
		
		Cc.add("Hello World"); 
		// Output "Hello World" with default priority in defaultChannel
		
		Cc.add( ["Hello World" , "this is", "an array", "of arguments"] );
		// Passes multiple arguments as array (for the time being this is the only alternative)
		
		Cc.add("Important Trace!", 10);
		// Output "Important Trace!" with priority 10 in defaultChannel
		
		Cc.add("A Looping trace that I dont want to see a long list", 10, true);
		// Output the text in defaultChannel, replacing the last 'repeating' line. preventing it from generating so many lines.
		// good for tracing loops.
		// use Cc.forceLine = # to force print the line on # frames. # = a number.
		
		Cc.ch("myChannel","Hello my Channel"); 
		// Output "Hello my Channel" in "myChannel" channel.
		// note: "global" channel show trace lines from all channels.
		
		Cc.ch("myChannel","Hello my Channel", 8); 
		// Output "Hello my Channel" in "myChannel" channel with priority 8
		// note: "global" channel show trace lines from all channels.
		
		Cc.ch("myChannel","Hello my Channel", 8, true); 
		// Output "Hello my Channel" in "myChannel" channel with priority 8 replacing the last 'repeating' line
		// note: "global" channel show trace lines from all channels.
		
		
		// OPTIONAL USAGE
		Cc.visible = false // (defauilt: true) set to change visibility. It will still record but will not update prints etc

		Cc.tracing = true; // (default: false) when set, all console input will be re-traced during authoring
		Cc.alwaysOnTop = false; // (default: true) when set this console will try to keep it self on top of its parent display container.

		Cc.remoting = true; // (default: false) set to broadcast traces to LocalConnection
		Cc.isRemote = true; // (default: false) set to recieve broadcasts from LocalConnection remote
*/
package com.junkbyte.console {
	import flash.display.LoaderInfo;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * Cc stands for Console Controller.
	 * It is a static / singleton controller for Console (com.junkbyte.console.Console).
	 * In a later date when Console is no longer needed, remove Cc.start(..) or Cc.startOnStage(..) 
	 * and the rest of console related codes will stop executing to save memory and performance.
	 * @author  Lu Aye Oo
	 * @version 2.4
	 * @see http://code.google.com/p/flash-console/
	 * @see #start()
	 * @see #startOnStage()
	 */
	public class Cc{
		
		private static const ERROR_EXISTS:String = "[CONSOLE] already started.";
		
		private static var _console:Console;
		
		/**
		 * Do not construct.
		 * Please use Cc.start(..); or Cc.startOnStage(...);
		 * 
		 * @throws Error error
		 * @see #start()
		 * @see #startOnStage()
		 */
		public function Cc() {
			throw new Error("[CONSOLE] Do not construct. Please use Cc.start() or Cc.startOnStage()");
		}
		/**
		 * Start Console inside given Display.
		 * <p>
		 * Calling any other C calls before this (or startOnStage(...)) will fail silently.
		 * When Console is no longer needed, removing this line alone will stop console from working without having any other errors.
		 * In flex, it is more convenient to use Cc.startOnStage() as it will avoid UIComponent typing issue.
		 * </p>
		 * @see #startOnStage()
		 *
		 * @param  Display in which console should be added to. Preferably stage or root of your flash document.
		 * @param  Password sequence to toggle console's visibility. If password is set, console will start hidden. Set Cc.visible = ture to unhide at start.
		 * 			Must be ASCII chars. Example passwords: ` OR debug. Make sure Controls > Disable Keyboard Shortcuts in Flash.
		 * @param  Skin preset number to use. 1 = black base, 2 = white base
		 */
		public static function start(mc:DisplayObjectContainer, pass:String = "", config:ConsoleConfig = null):void{
			if(_console){
				trace(ERROR_EXISTS);
			}else{
				_console = new Console(pass, config);
				// if no parent display, console will always be hidden, but using Cc.remoting is still possible so its not the end.
				if(mc!=null) mc.addChild(_console);
			}
		}
		/**
		 * Start Console in top level (Stage). 
		 * Starting in stage makes sure console is added at the very top level.
		 * <p>
		 * It will look for stage of mc (first param), if mc isn't a Stage or on Stage, console will be added to stage when mc get added to stage.
		 * Calling any other C calls before this will fail silently.
		 * When Console is no longer needed, removing this line alone will stop console from working without having any other errors.
		 * </p>
		 * 
		 * @param  Display which is Stage or will be added to Stage.
		 * @param  Password sequence to toggle console's visibility. If password is set, console will start hidden. Set Cc.visible = ture to unhide at start.
		 * 			Must be ASCII chars. Example passwords: ` OR debug. Make sure Controls > Disable Keyboard Shortcuts in Flash.
		 * @param  Skin preset number to use. 1 = black base, 2 = white base
		 * 			
		 */
		public static function startOnStage(mc:DisplayObject, pass:String = "", config:ConsoleConfig = null):void{
			if(_console){
				trace(ERROR_EXISTS);
			}else if(mc !=null && mc.stage !=null ){
				start(mc.stage, pass, config);
			}else{
			 	_console = new Console(pass, config);
			 	// if no parent display, console will always be hidden, but using Cc.remoting is still possible so its not the end.
				if(mc!=null) mc.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandle);
			}
		}
		//
		//
		//
		/**
		 * Add log line to default channel
		 *
		 * @param  String to add, any type can be passed and will be converted to string
		 * @param  Priority of line. 0-10, the higher the number the more visibilty it is in the log, and can be filtered through UI
		 * @param  When set to true, log line will replace the previous line rather than making a new line (unless it has repeated more than ConsoleConfig -> maxRepeats)
		 */
		public static function add(str:*, priority:Number = 2, isRepeating:Boolean = false):void{
			if(_console){
				_console.add(str,priority, isRepeating);
			}
		}
		/**
		 * Stack log
		 *
		 * @param  String to add
		 * @param  The depth of stack trace
		 * @param  Priority of line. 0-10 (optional, default: 5)
		 * @param  Name of channel (optional)
		 * 
		 */
		public static function stack(str:*, depth:int = -1, priority:Number = 5, ch:String = null):void{
			if(_console){
				_console.stack(str,depth,priority, ch);
			}
		}
		/**
		 * Add log line to channel.
		 * If channel name doesn't exists it creates one.
		 *
		 * @param  Name of channel, if a non-string param is passed, it will use the object's class name as channel name.
		 * @param  String to add, any type can be passed and will be converted to string
		 * @param  Priority of line. 0-10, the higher the number the more visibilty it is in the log, and can be filtered through UI
		 * @param  When set to true, log line will replace the previous line rather than making a new line (unless it has repeated more than ConsoleConfig -> maxRepeats)
		 */
		public static function ch(channel:*, str:*, priority:Number = 2, isRepeating:Boolean = false):void{
			if(_console){
				_console.ch(channel,str, priority, isRepeating);
			}
		}
		/**
		 * Add log line with priority 1
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function log(...args):void{
			if(_console){
				_console.log.apply(null, args);
			}
		}
		/**
		 * Add log line with priority 3
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function info(...args):void{
			if(_console){
				_console.info.apply(null, args);
			}
		}
		/**
		 * Add log line with priority 5
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function debug(...args):void{
			if(_console){
				_console.debug.apply(null, args);
			}
		}
		/**
		 * Add log line with priority 7
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function warn(...args):void{
			if(_console){
				_console.warn.apply(null, args);
			}
		}
		/**
		 * Add log line with priority 9
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function error(...args):void{
			if(_console){
				_console.error.apply(null, args);
			}
		}
		/**
		 * Add log line with priority 10
		 * Allows multiple arguments for convenience use.
		 *
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function fatal(...args):void{
			if(_console){
				_console.fatal.apply(null, args);
			}
		}
		/**
		 * Add log line with priority 1 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param  Name of channel, if a non-string param is passed, it will use the object's class name as channel name.
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function logch(channel:*, ...args):void{
			if(_console){
				_console.logch.apply(null, concat(channel, args));
			}
		}
		/**
		 * Add log line with priority 3 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param  Name of channel, if a non-string param is passed, it will use the object's class name as channel name.
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function infoch(channel:*, ...args):void{
			if(_console){
				_console.infoch.apply(null, concat(channel, args));
			}
		}
		/**
		 * Add log line with priority 5 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param  Name of channel, if a non-string param is passed, it will use the object's class name as channel name.
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function debugch(channel:*, ...args):void{
			if(_console){
				_console.debugch.apply(null, concat(channel, args));
			}
		}
		/**
		 * Add log line with priority 7 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param  Name of channel, if a non-string param is passed, it will use the object's class name as channel name.
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function warnch(channel:*, ...args):void{
			if(_console){
				_console.warnch.apply(null, concat(channel, args));
			}
		}
		/**
		 * Add log line with priority 9 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param  Name of channel, if a non-string param is passed, it will use the object's class name as channel name.
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function errorch(channel:*, ...args):void{
			if(_console){
				_console.errorch.apply(null, concat(channel, args));
			}
		}
		/**
		 * Add log line with priority 10 to channel
		 * Allows multiple arguments for convenience use.
		 *
		 * @param  Name of channel, if a non-string param is passed, it will use the object's class name as channel name.
		 * @param String to be logged, any type can be passed and will be converted to string
		 */
		public static function fatalch(channel:*, ...args):void{
			if(_console){
				_console.fatalch.apply(null, concat(channel, args));
			}
		}
		private static function concat(o:*, args:Array):Array{
			return [o].concat(args);
		}
		/**
		 * Remove console from it's parent display and clean up
		 */
		public static function remove():void{
			if(_console){
				if(_console.parent != null){
					_console.parent.removeChild(_console);
				}
				_console.destroy();
				_console = null;
			}
		}
		/**
		 * Pauses output log and graphs in Console.
		 * It still record and print back out on resume.
		 */
		public static function get paused():Boolean{
			return getter("paused") as Boolean;
		}
		public static function set paused(v:Boolean):void{
			setter("paused",v);
		}
		//
		// Logging settings
		//
		/**
		 * Clear console logs.
		 * @param  (optional) name of log channel to clear, leave blank to clear all.
		 */
		public static function clear(channel:String = null):void{
			if(_console){
				_console.clear(channel);
			}
		}
		
		/**
		 * Listen for uncaught errors from loaderInfo instance
		 * Only works for flash player target 10.1 or later
		 * @param  loaderInfo instance that can dispatch errors
		 */
		public static function listenUncaughtErrors(loaderinfo:LoaderInfo):void{
			if(_console){
				_console.listenUncaughtErrors(loaderinfo);
			}
		}
		
		/**
		 * Accessor for currently viewing channels.
		 * <p>
		 * Set to null or empty array to view all channels (global channel).
		 * </p>
		 */
		public static function get viewingChannels():Array{
			return getter("viewingChannels") as Array;
		}
		public static function set viewingChannels(v:Array):void{
			setter("viewingChannels",v);
		}

		/**
		 * Accessor for using flash's build in (or external) trace().
		 * <p>
		 * When turned on, Console will also call trace() for all console logs.
		 * trace function can be replaced with something of your own (such as Flex's logging).
		 * default is trace(...);
		 * </p>
		 * @see ConsoleConfig -> traceCall
		 */
		public static function get tracing():Boolean{
			return getter("tracing") as Boolean;
		}
		public static function set tracing(v:Boolean):void{
			setter("tracing",v);
		}
		/**
		 * Start/stop FPS monitor graph.
		 */
		public static function get fpsMonitor():Boolean{
			return getter("fpsMonitor") as Boolean;
		}
		public static function set fpsMonitor(v:Boolean):void{
			setter("fpsMonitor", v);
		}
		/**
		 * Start/stop Memory monitor graph.
		 */
		public static function get memoryMonitor():Boolean{
			return getter("memoryMonitor") as Boolean;
		}
		public static function set memoryMonitor(v:Boolean):void{
			setter("memoryMonitor", v);
		}
		/**
		 * width of main console panel
		 */
		public static function get width():Number{
			return getter("width") as Number;
		}
		public static function set width(v:Number):void{
			setter("width",v);
		}
		/**
		 * height of main console panel
		 */
		public static function get height():Number{
			return getter("height") as Number;
		}
		public static function set height(v:Number):void{
			setter("height",v);
		}
		/**
		 * x position of main console panel
		 */
		public static function get x():Number{
			return getter("x") as Number;
		}
		public static function set x(v:Number):void{
			setter("x",v);
		}
		/**
		 * y position of main console panel
		 */
		public static function get y():Number{
			return getter("y") as Number;
		}
		public static function set y(v:Number):void{
			setter("y",v);
		}
		/**
		 * visibility of all console panels
		 * <p>
		 * If you have closed the main console by pressing the X button, setting true here will not turn it back on.
		 * You will need to press the password key to turn that panel back on instead.
		 * </p>
		 */
		public static function get visible():Boolean{
			return getter("visible") as Boolean;
		}
		public static function set visible(v:Boolean):void{
			setter("visible",v);
		}
		/**
		 * When set to true, Console will *try* not to trace too much info about it self.
		 * <p>
		 * It will stop tracing about start of storing and watching objects - and a few others.
		 * If not sure, keep it to false.
		 * Default: false;
		 * </p>
		 */
		public static function get quiet():Boolean{
			return getter("quiet") as Boolean;
		}
		public static function set quiet(v:Boolean):void{
			setter("quiet",v);
		}
		/**
		 * Accessor for keeping Console on top of display list.
		 * <p>
		 * When turned on (by default), console will always try to put it self on top of the parent's display list.
		 * For example, if console is started in root, when a child display is added in root, console will move it self to the 
		 * top of root's display list to try to overlay the new child display. - making sure that console don't get covered.
		 * </p>
		 * <p>
		 * However, if Console's parent display (root in example) is covered by another display (example: adding a child directly to stage), 
		 * console will not be able to pull it self above it as it is in root, not stage.
		 * If console is added on stage in the first place, there won't be an issue as described above. Use Cc.startOnStage(...).
		 * </p>
		 * <p>
		 * Keeping it turned on may have other side effects if another display is also trying to put it self on top, 
		 * they could be jumping layers as they fight for the top layer.
		 * </p>
		 */
		public static function get alwaysOnTop():Boolean{
			return getter("alwaysOnTop") as Boolean;
		}
		public static function set alwaysOnTop(v:Boolean):void{
			setter("alwaysOnTop",v);
		}
		//
		// Remoting
		//
		/**
		 * Accessor for remoting (sender).
		 * When turned on, Console will periodically broadcast logs, FPS history and memory usage
		 * for another Console remote to receive. 
		 * <p>
		 * Can not be remoting (sender) and remote (reciever) at the same time.
		 * The broadcast interval can be changed through ConsoleConfig -> remoteDelay.
		 * </p>
		 */
		public static function get remoting():Boolean{
			return getter("remoting") as Boolean;
		}
		public static function set remoting(v:Boolean):void{
			setter("remoting",v);
		}
		/**
		 * Accessor for remote (reciever).
		 * When turned on, Console will listen for broadcast of logs/FPS/memory usage from another Console.
		 * Can not be remoting (sender) and remote (reciever) at the same time
		 */
		public static function get remote():Boolean{
			return getter("remote") as Boolean;
		}
		public static function set remote(v:Boolean):void{
			setter("remote",v);
		}
		/**
		 * Set Password required to connect from remote.
		 * <p>
		 * By default this is the same as the password used in Cc.start() / Cc.startOnStage();
		 * If you set this to null, remote will no longer need a password to connect.
		 * </p>
		 */
		public static function set remotingPassword(v:String):void{
			setter("remotingPassword",v);
		}
		/////
		//
		// UNSUPPORTED FEATURES IN LITE VERSION
		// 
		/////
		[Inspectable(environment="none")]
		public static function setPanelArea(panelname:String, rect:Rectangle):void{
			
		}
		[Inspectable(environment="none")]
		public static function get displayRoller():Boolean{
			return false;
		}
		[Inspectable(environment="none")]
		public static function set displayRoller(v:Boolean):void{
			
		}
		[Inspectable(environment="none")]
		public static function inspect(obj:Object, detail:Boolean = true):void {
			
		}
		[Inspectable(environment="none")]
		public static function explode(obj:Object, depth:int = 3):void {
			
		}
		[Inspectable(environment="none")]
		public static function monitor(obj:Object, n:String = null):void {
			
		}
		[Inspectable(environment="none")]
		public static function get commandLine ():Boolean{
			return false;
		}
		[Inspectable(environment="none")]
		public static function set commandLine (v:Boolean):void{
			
		}
		[Inspectable(environment="none")]
		public static function get commandBase():Object{
			return null;
		}
		public static function set commandBase(v:Object):void{
			
		}
		[Inspectable(environment="none")]
		public static function store(n:String, obj:Object, strong:Boolean = false):void{
			
		}
		[Inspectable(environment="none")]
		public static function map(base:DisplayObjectContainer, maxstep:uint = 0):void{
			
		}
		[Inspectable(environment="none")]
		public static function runCommand(str:String):*{
			return null;
		}
		[Inspectable(environment="none")]
		public static function watch(obj:Object,n:String = null):String{
			return null;
		}
		[Inspectable(environment="none")]
		public static function unwatch(n:String):void{
			
		}
		[Inspectable(environment="none")]
		public static function addGraph(n:String, obj:Object, prop:String, col:Number = -1, key:String = null, rect:Rectangle = null, inverse:Boolean = false):void{
			
		}
		[Inspectable(environment="none")]
		public static function fixGraphRange(n:String, min:Number = NaN, max:Number = NaN):void{
			
		}
		[Inspectable(environment="none")]
		public static function removeGraph(n:String, obj:Object = null, prop:String = null):void{
			
		}
		[Inspectable(environment="none")]
		public static function bindKey(key:KeyBind, fun:Function = null,args:Array = null):void{
			
		}
		[Inspectable(environment="none")]
		public static function setRollerCaptureKey(char:String, ctrl:Boolean = false, alt:Boolean = false, shift:Boolean = false):void{
			
		}
		/**
		 * Console already exists?
		 * @return true if console is already running
		 * 
		 */
		public static function get exists():Boolean{
			var e:Boolean = _console? true: false;
			return e;
		}
		//
		private static function addedToStageHandle(e:Event):void{
			var mc:DisplayObjectContainer = e.currentTarget as DisplayObjectContainer;
			mc.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandle);
			if(_console && _console.parent == null){
				mc.stage.addChild(_console);
			}
		}
		/*private static function canRunWithBrowserSetup(s:Stage, setup:uint):Boolean{
			if(setup>0 && s && (Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX")){
				var flashVars:Object = s.loaderInfo.parameters;
				if(flashVars["allowConsole"] != "true" && (setup == 1 || (setup == 2 && !Remoting.RemoteIsRunning)) ){
					return false;
				}
			}
			return true;
		}*/
		private static function getter(str:String):*{
			if(_console)return _console[str];
			else return null;
		}
		private static function setter(str:String,v:*):void{
			if(_console){
				_console[str] = v;
			}
		}
		
		
		[Inspectable(environment="none")]
		public static function getAllLog(splitter:String = "\n"):String{
			if(_console)return _console.getAllLog(splitter);
			else return "";
		}
		[Inspectable(environment="none")]
		public static function get instance():Console{
			return _console;
		}
	}
}