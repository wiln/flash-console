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
		public static const VERSION:Number = 1.2;

		public static const REMOTE_CONN_NAME:String = "_ConsoleRemote";
		public static const REMOTER_CONN_NAME:String = "_ConsoleRemoter";
		
		public static const CONSOLE_CHANNEL:String = "C";
		public static const FILTERED_CHANNEL:String = "Filtered";
		public static const GLOBAL_CHANNEL:String = "global";
		
		private var _isPaused:Boolean;
		private var _enabled:Boolean = true;
		private var _isRemoting:Boolean;
		private var _isRemote:Boolean;
		private var _remoteMSPF:int;
		private var _remoteMem:int;
		
		//
		public var master:Console;
		public var style:Style;
		public var panels:PanelsManager;
		public var cl:CommandLine;
		public var mm:MemoryMonitor;
		//
		
		public var quiet:Boolean;
		
		public function Console(pass:String = "") {
			name = NAME;
			
			style = new Style();
			panels = new PanelsManager(this);
			mm = new MemoryMonitor();
			cl = new CommandLine(this);
			cl.store("C",this);
			cl.reserved.push("C");
			//cl.addEventListener(CommandLine.SEARCH_REQUEST, onCommandSearch, false, 0, true);
			
			
			var panel:MainPanel = new MainPanel(this);
			panels.addPanel(panel);
			addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
			
			// TEST...
			var graph:GraphingPanel = new GraphingPanel(this, 100,100);
			graph.x = 50;
			graph.y = 150;
			graph.inverse = true;
			graph.add(this,"mouseX",0x00DD00, "x");
			graph.add(this,"mouseY",0xDD0000, "y");
			panels.addPanel(graph);
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
		
		
		
		public function get displayRoller():Boolean{
			var roller:RollerPanel = panels.getPanel(RollerPanel.NAME) as RollerPanel;
			if(!roller) return false;
			return true;
		}
		public function set displayRoller(n:Boolean):void{
			if(displayRoller != n){
				var panel:MainPanel = panels.getPanel(MainPanel.NAME) as MainPanel;
				if(!n){
					panels.removePanel(RollerPanel.NAME);
				}else if(n){
					var roller:RollerPanel = new RollerPanel(this);
					roller.x = panel.x+panel.width-160;
					roller.y = panel.y+55;
					panels.addPanel(roller);
					roller.start(this);
				}
				panel.updateMenu();
			}
		}
		public function get fpsMode():int{
			var fps:FPSPanel = panels.getPanel(FPSPanel.NAME) as FPSPanel;
			if(!fps) return 0;
			return 1;
		}
		public function set fpsMode(n:int):void{
			if(fpsMode != n){
				var panel:MainPanel = panels.getPanel(MainPanel.NAME) as MainPanel;
				if(n == 0){
					panels.removePanel(FPSPanel.NAME);
				}else if(n > 0){
					var fps:FPSPanel = new FPSPanel(this);
					fps.x = panel.x+panel.width-160;
					fps.y = panel.y+15;
					panels.addPanel(fps);
				}
				panel.updateMenu();
			}
		}
		public function get memoryMonitor():int{
			var mp:MemoryPanel = panels.getPanel(MemoryPanel.NAME) as MemoryPanel;
			if(!mp) return 0;
			return 1;
		}
		public function set memoryMonitor(n:int):void{
			if(memoryMonitor != n){
				var panel:MainPanel = panels.getPanel(MainPanel.NAME) as MainPanel;
				if(n == 0){
					panels.removePanel(MemoryPanel.NAME);
				}else if(n > 0){
					var mp:MemoryPanel = new MemoryPanel(this);
					mp.x = panel.x+panel.width-80;
					mp.y = panel.y+15;
					panels.addPanel(mp);
				}
				panel.updateMenu();
			}
		}
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
		private function _onEnterFrame(e:Event):void{
			if(!_enabled){
				return;
			}
			if(!_isPaused && visible){
				var arr:Array = mm.update();
				if(arr.length>0){
					addLine("GARBAGE COLLECTED: "+arr.join(", "),10,CONSOLE_CHANNEL);
				}
			}
		}
		public function addLogLine(line:LogLineVO, q:Boolean = false):void{
			if(!(this.quiet && q)){
				addLine(line.text, line.p, line.c==null?CONSOLE_CHANNEL:line.c, line.r, line.s);
			}
		}
		private function addLine(obj:Object,priority:Number = 0,channel:String = "",isRepeating:Boolean = false, skipSafe:Boolean = false):void{
			trace(obj);
		}
	}
}
