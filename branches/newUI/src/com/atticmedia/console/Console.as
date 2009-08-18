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
		
		
		
		public function Console(pass:String = "") {
			name = NAME;
			
			
			var panel:MainPanel = new MainPanel(this);
			addChild(panel);
			
			// test
			var grapher:GraphingPanel = new GraphingPanel();
			grapher.fixGraph(-1,2);
			grapher.add(grapher,"rand", 0xFF0000);
			grapher.add(grapher,"rand", 0x00FF00);
			grapher.add(grapher,"rand", 0x3333FF);
			addChild(grapher);
			grapher.x = 100;
			grapher.y = 120;
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
