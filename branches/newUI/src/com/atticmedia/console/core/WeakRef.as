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
package com.atticmedia.console.core {
	import flash.utils.Dictionary;
	
	public dynamic class WeakRef{
		
		private var _val:*;
		private var _strong:Boolean;
		
		// There is abilty to actually store it 'strong' but thats incase
		// you need to mix weak and strong references somewhere, this lets you manage them all together.
		public function WeakRef(obj:*, strong:Boolean = false) {
			_strong = strong;
			if(strong){
				_val = obj;
			}else{
				_val = new Dictionary(true);
				_val[obj] = null;
			}
		}
		public function get reference():*{
			if(_strong){
				return _val;
			}else{
				//there should be only 1 key in it anyway
				for(var X:* in _val){
					return X;
				}
			}
			return null;
		}
		public function get strong():Boolean{
			return _strong;
		}
	}
}