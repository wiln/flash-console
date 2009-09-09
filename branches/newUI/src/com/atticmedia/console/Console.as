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
	import flash.system.System;	
	
	import com.atticmedia.console.panels.*;
	
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
		
		private var _central:Central;
		
		
		public function Console(pass:String = "") {
			name = NAME;
			
			_central = new Central(this);
			_central.style = new Style();
			_central.panels = new PanelsManager(_central);
			
			var panel:MainPanel = new MainPanel(_central);
			_central.panels.addPanel(panel);
			
			
			var mem:MemoryPanel = new MemoryPanel(_central);
			mem.x = panel.x+panel.width-160;
			mem.y = panel.y+15;
			_central.panels.addPanel(mem);
			
			
			
			var roller:RollerPanel = new RollerPanel(_central);
			roller.x = 0;
			roller.y = 100;
			_central.panels.addPanel(roller);
			roller.start(this);
			
			// TEST...
			var graph:GraphingPanel = new GraphingPanel(_central, 100,100);
			graph.x = 50;
			graph.y = 150;
			graph.inverse = true;
			graph.add(this,"mouseX",0x00DD00, "x");
			graph.add(this,"mouseY",0xDD0000, "y");
			_central.panels.addPanel(graph);
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
		
		
		
		public function get fpsMode():int{
			var fps:FPSPanel = _central.panels.getPanel(FPSPanel.NAME) as FPSPanel;
			if(!fps) return 0;
			return 1;
		}
		public function set fpsMode(n:int):void{
			if(fpsMode != n){
				var panel:MainPanel = _central.panels.getPanel(MainPanel.NAME) as MainPanel;
				var fps:FPSPanel;
				if(n == 0){
					fps = _central.panels.getPanel(FPSPanel.NAME) as FPSPanel;
					fps.destory();
					_central.panels.removePanel(FPSPanel.NAME);
				}else if(n == 1){
					fps = new FPSPanel(_central);
					fps.x = panel.x+panel.width-80;
					fps.y = panel.y+15;
					_central.panels.addPanel(fps);
				}
				panel.updateMenu();
			}
		}
	}
}
