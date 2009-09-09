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
		
		private var _panels:PanelsManager;
		private var _styles:Style;
		
		
		public function Console(pass:String = "") {
			name = NAME;
			
			_styles = new Style();
			_panels = new PanelsManager(this);
			
			var panel:MainPanel = new MainPanel(this, _styles);
			_panels.addPanel(panel);
			
			var fps:FPSPanel = new FPSPanel(_styles);
			fps.x = panel.x+panel.width-80;
			fps.y = panel.y+15;
			_panels.addPanel(fps);
			
			var mem:MemoryPanel = new MemoryPanel(_styles);
			mem.x = panel.x+panel.width-160;
			mem.y = panel.y+15;
			_panels.addPanel(mem);
			
			
			
			var roller:RollerPanel = new RollerPanel(_styles);
			roller.x = 0;
			roller.y = 100;
			_panels.addPanel(roller);
			roller.start(this);
			
			// TEST...
			var graph:GraphingPanel = new GraphingPanel(_styles, 100,100);
			graph.x = 50;
			graph.y = 150;
			graph.inverse = true;
			graph.add(this,"mouseX",0x00DD00, "x");
			graph.add(this,"mouseY",0xDD0000, "y");
			_panels.addPanel(graph);
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
	}
}
