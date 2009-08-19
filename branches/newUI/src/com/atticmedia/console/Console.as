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
		public static const MINIMUM_HEIGHT:int = 16;
		public static const MINIMUM_WIDTH:int = 20;
		
		private var _panels:Array = [];
		
		
		public function Console(pass:String = "") {
			name = NAME;
			
			
			var panel:MainPanel = new MainPanel(this);
			addPanel(panel);
			
			var fps:FPSPanel = new FPSPanel();
			fps.x = panel.x+panel.width-80;
			fps.y = panel.y+15;
			addPanel(fps);
			
			var mem:MemoryPanel = new MemoryPanel();
			mem.x = panel.x+panel.width-160;
			mem.y = panel.y+15;
			addPanel(mem);
		}
		private function addPanel(panel:AbstractPanel):void{
			_panels.push(panel);
			panel.addEventListener(AbstractPanel.STARTED_DRAGGING, onPanelStartDragScale, false,0, true);
			panel.addEventListener(AbstractPanel.STARTED_SCALING, onPanelStartDragScale, false,0, true);
			addChild(panel);
		}
		private function onPanelStartDragScale(e:Event):void{
			var target:AbstractPanel = e.currentTarget as AbstractPanel;
			if(target.snapping){
				var X:Array = [0];
				var Y:Array = [0];
				if(stage){
					// this will only work if stage size is not changed or top left aligned
					X.push(stage.stageWidth);
					Y.push(stage.stageHeight);
				}
				for each(var panel:AbstractPanel in _panels){
					X.push(panel.x);
					X.push(panel.x+panel.width);
					Y.push(panel.y);
					Y.push(panel.y+panel.height);
				}
				target.registerSnaps(X, Y);
			}
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
