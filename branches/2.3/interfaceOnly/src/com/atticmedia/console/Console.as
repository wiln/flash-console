/*
* 
* Copyright (c) 2008-2009 Lu Aye Oo
* 
* @author Lu Aye Oo
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
DUMMY Console interface

Where would you need it?
If you are loading a module (swf/swc) that require the use of Console, but you don't want to
embed the console inside that swf (because of size), you might as well use a dummy Console interfce (this) in these swfs.
When loaded into the main/shell swf which have the real console instantiated, Console would work as intended in the loaded swfs.
- Thats provided you set the applicationDomain to use the main swf's applicationDomain.
While using this class, console related functions will silently fail to work.
If C.tracing is set to true, you will get traces in your flash authoring.
//
Another use is when you have finished development and no longer need Console. 
Replacing the real console's C class with this one will save you some size (~35kb) on the final SWF.
*/
package com.atticmedia.console{
	import flash.display.Sprite;

	public class Console extends Sprite {
		
		public static const VERSION:Number = 2.2;
		public static const VERSION_STAGE:String = "";
		//
		public static const NAME:String = "Console";
		public static const PANEL_MAIN:String = "mainPanel";
		public static const PANEL_CHANNELS:String = "channelsPanel";
		public static const PANEL_FPS:String = "fpsPanel";
		public static const PANEL_MEMORY:String = "memoryPanel";
		public static const PANEL_ROLLER:String = "rollerPanel";
		
		public static var REMOTING_CONN_NAME:String = "_Console";
		//
		public static const CONSOLE_CHANNEL:String = "C";
		public static const FILTERED_CHANNEL:String = "~";
		public static const GLOBAL_CHANNEL:String = " * ";
		public static const DEFAULT_CHANNEL:String = "-";
		//
		public static const LOG_LEVEL:uint = 1;
		public static const INFO_LEVEL:uint = 3;
		public static const DEBUG_LEVEL:uint = 6;
		public static const WARN_LEVEL:uint = 8;
		public static const ERROR_LEVEL:uint = 10;
		//
		public static const FPS_MAX_LAG_FRAMES:uint = 25;
		public static const MAPPING_SPLITTER:String = "|";
		
	}
}