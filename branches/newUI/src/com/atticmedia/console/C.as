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
* 

	USAGE:
		
		import com.atticmedia.console.*;
		C.start(this); // this = preferably the root
		
		// OR  C.start(this,"debug");
		// Start console, parameter "debug" (optional) sets the console's password.
		//  console will only open after you type "debug" in sequence at anytime on stage. 
		// Leave blank to disable password, where console will launch straight away.
		
		C.add("Hello World"); 
		// Output "Hello World" with default priority in defaultChannel
		
		C.add( ["Hello World" , "this is", "an array", "of arguments"] );
		// Passes multiple arguments as array (for the time being this is the only alternative)
		
		C.add("Important Trace!", 10);
		// Output "Important Trace!" with priority 10 in defaultChannel
		
		C.add("A Looping trace that I dont want to see a long list", 10, true);
		// Output the text in defaultChannel, replacing the last 'repeating' line. preventing it from generating so many lines.
		// good for tracing loops.
		// use C.forceLine = # to force print the line on # frames. # = a number.
		
		C.ch("myChannel","Hello my Channel"); 
		// Output "Hello my Channel" in "myChannel" channel.
		// note: "global" channel show trace lines from all channels.
		
		C.ch("myChannel","Hello my Channel", 8); 
		// Output "Hello my Channel" in "myChannel" channel with priority 8
		// note: "global" channel show trace lines from all channels.
		
		C.ch("myChannel","Hello my Channel", 8, true); 
		// Output "Hello my Channel" in "myChannel" channel with priority 8 replacing the last 'repeating' line
		// note: "global" channel show trace lines from all channels.
		
		
		// OPTIONAL USAGE
		C.remove(); // Completely remove console
		C.clear(); // Clear tracing lines
		
		C.paused = true // pauses printing in console, it still record and print back out on resume.
		C.enabled = false // disables printing and recording. pauses FPS/memory monitor.
		C.visible = false // (defauilt: true) set to change visibility. It will still record but will not update prints etc
		C.maxRepeats = 100; // (default:100)  frames before repeating line is forced to print to next line. set to -1 to never force. set to 0 to force every line.
		
		C.commandLine = true; // (default: false) enable command line
		C.fpsMonitor = 1; // (default: 0) show FPS graph monitor.
		C.memoryMonitor = 1; // (default: 0) show memory usage graph.
		C.width = 200; // (defauilt: 420) change width of console
		C.height = 200; //(defauilt: 16) change hight of console
		C.x = 300; // (defauilt: 0) change x of console
		C.y = 200; // (defauilt: 0) change y of console
		C.maxLines = 500; // maximum number of lines allowed to store. 0 = unlimited. setting to very high will slow down as it grows
		C.tracing = true; // (default: false) when set, all console input will be re-traced during authoring
		C.alwaysOnTop = false; // (default: true) when set this console will try to keep it self on top of its parent display container.

		C.defaultChannel = "myChannel"; // (default: "traces") change default channel to print.
		C.viewingChannel = "myChannel"; // (default: "global") change current channel view. If you want to view multiple channels, seperate the names with commas.
		
		C.remoting = true; // (default: false) set to broadcast traces to LocalConnection
		C.isRemote = true; // (default: false) set to recieve broadcasts from LocalConnection remote

*/
		
package com.atticmedia.console {
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;		

	public class C{
		
		private static var _console:Console;
		
		public function C() {
			throw new Error("[CONSOLE] Do not construct class. Please use C.start(mc:DisplayObjectContainer, password:String='')");
		}
		/**
		 * Start Console inside given Display.
		 * Calling any other C calls before this will fail silently.
		 * When Console is no longer needed, removing this line alone will stop console from working without having any other errors.
		 *
		 * @param  mc  	Display in which console should be added to. Preferably stage or root of your flash document.
		 * @param  pass Password sequence to toggle console's visibility. If password is set, console will start hidden. Must be ASCII chars.
		 * @param  skin Skin preset number to use. 1 = black base, 2 = white base
		 * @param  allowInBrowser If set to false, console will not start if run on browser, except if there is flashVar allowConsole=true passed in.
		 * 
		 */
		public static function start(mc:DisplayObjectContainer, pass:String = "", skin:int= 1, disallowBrowser:uint = 0):void{
			if(_console){
				trace("[CONSOLE] already exists. Will keep using the previously created console. If you want to create a fresh 1, C.remove() first.");
			}else{
				if(canRunWithBrowserSetup(mc.stage, disallowBrowser)){
					_console = new Console(pass, skin);
					mc.addChild(_console);
				}
			}
		}
		/**
		 * Start Console in top level (Stage). 
		 * Starting in stage makes sure console is added at the very top level.
		 * It will look for stage of mc (first param), if mc isn't a Stage or on Stage, console will be added to stage when mc get added to stage.
		 * Calling any other C calls before this will fail silently.
		 * When Console is no longer needed, removing this line alone will stop console from working without having any other errors.
		 * 
		 * @param  mc  	Display which is Stage or will be added to Stage.
		 * @param  pass Password sequence to toggle console's visibility. If password is set, console will start hidden. Must be ASCII chars.
		 * @param  skin Skin preset number to use. 1 = black base, 2 = white base
		 * @param  allowInBrowser If set to false, console will not start if run on browser, except if there is flashVar allowConsole=true passed in.
		 * 
		 */
		public static function startOnStage(mc:DisplayObjectContainer, pass:String = "", skin:int= 1, disallowBrowser:uint = 0):void{
			if(_console){
				trace("[CONSOLE] already exists. Will keep using the previously created console. If you want to create a fresh 1, C.remove() first.");
			}else if(mc.stage){
				start(mc.stage, pass, skin, disallowBrowser);
			}else{
			 	_console = new Console(pass, skin);
			 	_console.disallowBrowser = disallowBrowser;
				mc.addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle, false, 0, true);
			}
		}
		private static function stageAddedHandle(e:Event):void{
			var mc:DisplayObjectContainer = e.currentTarget as DisplayObjectContainer;
			mc.removeEventListener(Event.ADDED_TO_STAGE, stageAddedHandle);
			if(_console && !_console.parent){
				if(canRunWithBrowserSetup(mc.stage, _console.disallowBrowser)){
					mc.stage.addChild(_console);
				}else{
					_console = null;
				}
			}
		}
		private static function canRunWithBrowserSetup(s:Stage, setup:uint):Boolean{
			if(setup>0 && s && (Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX")){
				var flashVars:Object = s.loaderInfo.parameters;
				if(flashVars["allowConsole"] != "true" && (setup == 1 || (setup == 2 && !Console.remoteIsRunning)) ){
					return false;
				}
			}
			return true;
		}
		
		public static function get version():Number{
			return Console.VERSION;
		}
		public static function get versionStage():String{
			return Console.VERSION_STAGE;
		}
		//
		//
		//
		/**
		 * Add log line
		 *
		 * @param  str  String to add
		 * @param  priority Priority of line. 0-10, the higher the number the more visibilty it is in the log, and can be filtered through UI
		 * @param  isRepeating When set to true, log line will replace the previous line rather than making a new line (unless it has repeated more than C.maxRepeats)
		 * 
		 */
		public static function add(str:*, priority:Number = 2, isRepeating:Boolean = false):void{
			if(_console){
				_console.add(str,priority, isRepeating);
			}
		}
		public static function ch(channel:Object, newLine:Object, priority:Number = 2, isRepeating:Boolean = false):void{
			if(_console){
				_console.ch(channel,newLine,priority, isRepeating);
			}
		}
		public static function pk(channel:Object, newLine:Object, priority:Number = 2, isRepeating:Boolean = false):void{
			if(_console){
				_console.pk(channel,newLine,priority, isRepeating);
			}
		}
		//
		//
		//
		public static function remove():void{
			if(_console){
				if(_console.parent){
					_console.parent.removeChild(_console);
				}
				_console.destroy();
				_console = null;
			}
		}
		public static function set enabled(v:Boolean):void{
			setter("enabled",v);
		}
		public static function get enabled():Boolean{
			return getter("enabled") as Boolean;
		}
		//
		// Logging settings
		//
		public static function clear(channel:String = null):void{
			if(_console){
				_console.clear(channel);
			}
		}
		public static function set tracing(v:Boolean):void{
			setter("tracing",v);
		}
		public static function get tracing():Boolean{
			return getter("tracing") as Boolean;
		}
		public static function set tracingChannels(v:String):void{
			setter("tracingChannels",v);
		}
		public static function get tracingChannels():String{
			return getter("tracingChannels") as String;
		}
		public static function set tracingPriority(v:int):void{
			setter("tracingPriority",v);
		}
		public static function get tracingPriority():int{
			return getter("tracingChannels") as int;
		}
		public static function get defaultChannel():String{
			return getter("defaultChannel") as String;
		}
		public static function set defaultChannel(v:String):void{
			setter("defaultChannel",v);
		}
		public static function get viewingChannel():String{
			return getter("viewingChannel") as String;
		}
		public static function get filterText():String{
			return getter("filterText") as String;
		}
		public static function set filterText(v:String):void{
			setter("filterText",v);
		}
		public static function get prefixChannelNames():Boolean{
			return getter("prefixChannelNames") as Boolean;
		}
		public static function set prefixChannelNames(v:Boolean):void{
			setter("prefixChannelNames",v);
		}
		public static function get maxLines():int{
			return getter("maxLines") as int;
		}
		public static function set maxLines(v:int):void{
			setter("maxLines",v);
		}
		public static function get maxRepeats():Number{
			return getter("maxRepeats") as Number;
		}
		public static function set maxRepeats(v:Number):void{
			setter("maxRepeats",v);
		}
		public static function get paused():Boolean{
			return getter("paused") as Boolean;
		}
		public static function set paused(v:Boolean):void{
			setter("paused",v);
		}
		//
		// Panel settings
		//
		// see panelnames in Console.PANEL_MAIN, Console.PANEL_FPS, etc...
		public static function setPanelPosition(panelname:String, p:Point):void{
			if(_console){
				_console.setPanelPosition(panelname, p);
			}
		}
		public static function setPanelArea(panelname:String, rect:Rectangle):void{
			if(_console){
				_console.setPanelArea(panelname, rect);
			}
		}
		//
		public static function set fpsMonitor(v:int):void{
			setter("fpsMonitor", v);
		}
		public static function get fpsMonitor():int{
			return getter("fpsMonitor") as int;
		}
		//
		public static function set memoryMonitor(v:int):void{
			setter("memoryMonitor", v);
		}
		public static function get memoryMonitor():int{
			return getter("memoryMonitor") as int;
		}
		public static function set rulerHidesMouse(v:Boolean):void{
			setter("rulerHidesMouse",v);
		}
		public static function get rulerHidesMouse():Boolean{
			return getter("rulerHidesMouse") as Boolean;
		}
		public static function set displayRoller(v:Boolean):void{
			setter("displayRoller", v);
		}
		public static function get displayRoller():Boolean{
			return getter("displayRoller") as Boolean;
		}
		//
		public static function get width():Number{
			return getter("width") as Number;
		}
		public static function set width(v:Number):void{
			setter("width",v);
		}
		public static function get height():Number{
			return getter("height") as Number;
		}
		public static function set height(v:Number):void{
			setter("height",v);
		}
		public static function get x():Number{
			return getter("x") as Number;
		}
		public static function set x(v:Number):void{
			setter("x",v);
		}
		public static function get y():Number{
			return getter("y") as Number;
		}
		public static function set y(v:Number):void{
			setter("y",v);
		}
		public static function get visible():Boolean{
			return getter("visible") as Boolean;
		}
		public static function set visible(v:Boolean):void{
			setter("visible",v);
		}
		//
		//
		public static function get exists():Boolean{
			var e:Boolean = _console? true: false;
			return e;
		}
		public static function set quiet(v:Boolean):void{
			setter("quiet",v);
		}
		public static function get quiet():Boolean{
			return getter("quiet") as Boolean;
		}
		public static function set alwaysOnTop(v:Boolean):void{
			setter("alwaysOnTop",v);
		}
		public static function get alwaysOnTop():Boolean{
			return getter("alwaysOnTop") as Boolean;
		}
		//
		// Remoting
		//
		public static function get remoting():Boolean{
			return getter("remoting") as Boolean;
		}
		public static function set remoting(v:Boolean):void{
			setter("remoting",v);
		}
		public static function get isRemote():Boolean{
			return getter("isRemote") as Boolean;
		}
		public static function set isRemote(v:Boolean):void{
			setter("isRemote",v);
		}
		//
		// Command line tools
		//
		public static function set commandLine (v:Boolean):void{
			setter("commandLine",v);
		}
		public static function get commandLine ():Boolean{
			return getter("commandLine") as Boolean;
		}
		public static function inspect(obj:Object, detail:Boolean = true):void {
			if(_console){
				_console.inspect(obj,detail);
			}
		}
		public static function get commandBase():Object{
			return getter("commandBase") as int;
		}
		public static function set commandBase(v:Object):void{
			setter("commandBase",v);
		}
		public static function get strongRef():Boolean{
			return getter("strongRef") as Boolean;
		}
		public static function set strongRef(v:Boolean):void{
			setter("strongRef",v);
		}
		public static function store(n:String, obj:Object, strong:Boolean = false):void{
			if(_console ){
				_console.store(n, obj, strong);
			}
		}
		public static function runCommand(str:String):Object{
			if(_console){
				return _console.runCommand(str);
			}
			return null;
		}
		//
		// Memory management tools
		//
		public static function watch(o:Object,n:String = null):String{
			if(_console){
				return _console.watch(o,n);
			}
			return null;
		}
		public static function unwatch(n:String):void{
			if(_console){
				_console.unwatch(n);
			}
		}
		public static function gc():void {
			if(_console){
				_console.gc();
			}
		}
		//
		// Graphing utilites
		//
		/**
		 * Add graph
		 * Creates a new graph panel (or use an already existing one)
		 * Graphs numeric values every frame. Reference to the object is weak, so when the object is garbage collected 
		 * graph will also remove that particular graph line. (hopefully)
		 * 
		 * Example: to graph both mouseX and mouseY of stage:
		 * C.addGraph("mouse", stage, "mouseX", 0xFF0000, "x");
		 * C.addGraph("mouse", stage, "mouseY", 0x0000FF, "y");
		 *
		 * @param  n  Name of graph, if same name already exist, graph line will be added to it.
		 * @param  obj  Object of interest.
		 * @param  prop	Property name of interest belonging to obj.
		 * @param  col	color of graph line (optional, if not passed it will randomally generate).
		 * @param  key	key string to use as identifier (optional, if not passed, it will use string from 'prop' param).
		 * 
		 */
		public static function addGraph(n:String, obj:Object, prop:String, col:Number = -1, key:String = null, rect:Rectangle = null, inverse:Boolean = false):void{
			if(_console){
				_console.addGraph(n,obj,prop,col,key,rect,inverse);
			}
		}
		/**
		 * Remove graph
		 * 
		 * Leave obj and prop params blank to remove the whole graph.
		 *
		 * @param  n  Name of graph.
		 * @param  obj  Object of interest to remove (optional).
		 * @param  prop	Property name of interest to remove (optional).
		 * 
		 */
		public static function removeGraph(n:String, obj:Object = null, prop:String = null):void{
			if(_console){
				_console.removeGraph(n, obj, prop);
			}
		}
		/**
		 * Bind keyboard key to a function
		 * WARNING: key binding hard references the function. 
		 * This should only be used for development purposes.
		 *
		 * @param  char  Keyboard character, must be ASCII.
		 * @param  ctrl  set to true if CTRL key press is required to trigger.
		 * @param  alt	set to true if ALT key press is required to trigger.
		 * @param  shift	set to true if SHIFT key press is required to trigger.
		 * @param  fun	Function to call on trigger.
		 * @param  args	Arguments to pass when calling the Function.
		 * 
		 */
		public static function bindKey(char:String, ctrl:Boolean, alt:Boolean, shift:Boolean, fun:Function ,args:Array = null):void{
			if(_console){
				_console.bindKey(char, ctrl, alt, shift, fun ,args);
			}
		}
		/**
		 * Assign custom trace function.
		 * Console will only call this when C.tracing is true.
		 *
		 * @param  f  Custom function to use, must accept at least 1 parameter as String.
		 * @return	Current trace function, default is flash's build in trace.
		 * 
		 */
		public static function set traceCall(f:Function):void{
			setter("traceCall",f);
		}
		public static function get traceCall():Function{
			return getter("traceCall") as Function;
		}
		//
		//
		private static function getter(str:String):*{
			if(_console){
				return _console[str];
			}else{
				return null;
			}
		}
		private static function setter(str:String,v:*):void{
			if(_console){
				_console[str] = v;
			}
		}
		//
		//	This is for debugging of console.
		//	PLEASE avoid using it!
		public static function get instance():Console{
			return _console;
		}
	}
}