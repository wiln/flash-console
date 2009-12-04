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
package com.atticmedia.console.utils {
	
	public class Chain{
		
		public var first:ChainItem;
		public var last:ChainItem;
		
		private var _length:uint;
		
		public function Chain() {
			
		}
		public function clear():void{
			first = null;
			last = null;
			_length = 0;
		}
		public function get length():uint{
			return _length;
		}
		// add to the last of chain
		public function push(v:ChainItem):void{
			if(last) {
				last.next = v;
				v.prev = last;
			}else{
				first = v;
			}
			last = v;
			_length++;
		}
		// add to the front of chain
		public function unshift(v:ChainItem):void{
			if(first) {
				first.prev = v;
				v.next = first;
			}else{
				last = v;
			}
			first = v;
			_length++;
		}
		// remove last item of chain
		public function pop():void{
			if(last) {
				last = last.prev;
				_length--;
			}
		}
		// remove first item of chain
		public function shift():void{
			if(first) {
				first = first.next;
				_length--;
			}
		}
		// remove the item
		public function remove(v:ChainItem):void{
			if(v.prev) v.prev.next = v.next;
			if(v.next) v.next.prev = v.prev;
			_length--;
		}
	}
}