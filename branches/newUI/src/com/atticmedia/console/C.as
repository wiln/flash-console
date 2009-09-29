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
	import flash.geom.Point;	
	import flash.geom.Rectangle;	
	import flash.display.DisplayObjectContainer;
	import flash.system.Capabilities;		

	public class C{
		
		private static var _console:Console;
		
		public function C() {
			throw new Error("[CONSOLE] Do not construct class. Please use c.start(mc:DisplayObjectContainer, password:String='')");
		}
		public static function start(mc:DisplayObjectContainer, pass:String = "", skin:int= 1, allowInBrowser:Boolean = true, forceRunOnRemote:Boolean = true):void{
			if(!allowInBrowser && mc.stage && (Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX")){
				var flashVars:Object = mc.stage.loaderInfo.parameters;
				if(flashVars["allowConsole"] != "true" && (!forceRunOnRemote || (forceRunOnRemote && !Console.remoteIsRunning)) ){
					return;
				}
			}
			if(_console){
				trace("[CONSOLE] already exists. Will keep using the previously created console. If you want to create a fresh 1, c.remove() first.");
			}else{
				_console = new Console(pass, skin);
				mc.addChild(_console);
			}
		}
		public static function get version():Number{
			return Console.VERSION;
		}
		public static function get versionStage():uint{
			return Console.VERSION_STAGE;
		}
		//
		//
		//
		public static function add(newLine:Object, priority:Number = 2, isRepeating:Boolean = false):void{
			if(_console){
				_console.add(newLine,priority, isRepeating);
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
		public static function set viewingChannel(v:String):void{
			setter("viewingChannel",v);
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
		public static function store(n:String, obj:Object):void{
			if(_console ){
				_console.store(n, obj);
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
		public static function addGraph(n:String, obj:Object, prop:String, col:Number, key:String, rect:Rectangle = null, inverse:Boolean = false):void{
			if(_console){
				_console.addGraph(n,obj,prop,col,key,rect,inverse);
			}
		}
		public static function removeGraph(n:String, obj:Object = null, prop:String = null):void{
			if(_console){
				_console.removeGraph(n, obj, prop);
			}
		}
		//
		// WARNING: key binding hard references the function. 
		// This should only be used for development purposes only.
		//
		public static function bindKey(char:String, ctrl:Boolean, alt:Boolean, shift:Boolean, fun:Function ,args:Array = null):void{
			if(_console){
				_console.bindKey(char, ctrl, alt, shift, fun ,args);
			}
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