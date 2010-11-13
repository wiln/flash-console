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
*/
package com.junkbyte.console.core 
{
	import com.junkbyte.console.Console;
	import com.junkbyte.console.KeyBind;

	import flash.events.KeyboardEvent;

	/**
	 * Suppse this could be 'view' ?
	 */
	public class KeyBinder extends ConsoleCore{
		
		private var _pass:String;
		private var _passInd:int;
		private var _binds:Object = {};
		
		public function KeyBinder(console:Console, pass:String) {
			super(console);
			_pass = pass == ""?null:pass;
			
			
			console.cl.addCLCmd("keybinds", printBinds, "List all keybinds used");
		}
		public function keyDownHandler(e:KeyboardEvent):void{
			var char:String = String.fromCharCode(e.charCode);
			if(_pass != null && char && char == _pass.substring(_passInd,_passInd+1)){
				_passInd++;
				if(_passInd >= _pass.length){
					_passInd = 0;
					passwordEnteredHandle();
				}
			}
			else
			{
				_passInd = 0;
				var bind:KeyBind = new KeyBind(e.keyCode, e.shiftKey, e.ctrlKey, e.altKey);
				tryRunKey(bind.key);
				if(char){
					bind = new KeyBind(char, e.shiftKey, e.ctrlKey, e.altKey);
					tryRunKey(bind.key);
				}
			}
		}
		private function printBinds(...args:Array):void{
			report("Key binds:", -2);
			var i:uint = 0;
			for (var X:String in _binds){
				i++;
				report(X, -2);
			}
			report("--- Found "+i, -2);
		}
		private function passwordEnteredHandle():void{
			if(console.visible && !console.panels.mainPanel.visible){
				console.panels.mainPanel.visible = true;
			}else console.visible = !console.visible;
		}
		private function tryRunKey(key:String):void
		{
			var a:Array = _binds[key];
			if(a){
				(a[0] as Function).apply(this, a[1]);
			}
		}
		public function bindKey(key:KeyBind, fun:Function ,args:Array = null):void{
			if(_pass && (!key.useKeyCode && key.key.charAt(0) == _pass.charAt(0))){
				report("Error: KeyBind ["+key.key+"] is conflicting with Console password.",9);
				return;
			}
			if(fun == null){
				delete _binds[key.key];
				if(!config.quiet) report("Unbined key "+key.key+".", -1);
			}else{
				_binds[key.key] = [fun, args];
				if(!config.quiet) report("Bined key "+key.key+" to a function.", -1);
			}
		}
	}
}