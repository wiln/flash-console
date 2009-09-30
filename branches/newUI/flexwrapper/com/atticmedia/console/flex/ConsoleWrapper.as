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
*/
package com.atticmedia.console.flex
{
	import com.atticmedia.console.C;
	
	import flash.events.Event;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	
	public class ConsoleWrapper extends UIComponent
	{
		private static var _wrapper:ConsoleWrapper;
		
		public function ConsoleWrapper()
		{
		}
		public function listChanged(e:Event):void
		{
			if(C.exists && C.alwaysOnTop){
				if(!_wrapper.parent || _wrapper.parent != e.currentTarget){
					(e.currentTarget as Container).removeEventListener(Event.ADDED, _wrapper.listChanged);
				}else{
					_wrapper.parent.setChildIndex(_wrapper,_wrapper.parent.numChildren-1);
				}
			}
		}
		
		public static function start(ui:Container, p:String = "", allowInBrowser:Boolean = true, forceRunOnRemote:Boolean = true):void{
			if(!C.exists){
				_wrapper = new ConsoleWrapper();
				C.start(_wrapper, p, allowInBrowser, forceRunOnRemote);
				ui.addChild(_wrapper);
				ui.addEventListener(Event.ADDED, _wrapper.listChanged, false, 0, true);
			}
		}
	}
}