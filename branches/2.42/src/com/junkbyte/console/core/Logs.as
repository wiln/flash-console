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
package com.junkbyte.console.core {
	import com.junkbyte.console.vos.Log;
	import com.junkbyte.console.ConsoleConfig;
	public class Logs{
		
		private var _channels:Array;
		private var _config:ConsoleConfig;
		private var _repeating:uint;
		private var _lastRepeat:Log;
		
		private var first:Log;
		public var last:Log;
		
		private var _length:uint;
		
		public function Logs(config:ConsoleConfig){
			_config = config;
			_channels = new Array(_config.globalChannel, _config.defaultChannel);
		}
		public function get channels():Array{
			return _channels;
		}
		
		public function tick():void{
			if(_repeating > 0) _repeating--;
		}
		public function add(line:Log, isRepeating:Boolean):Boolean{
			if(_channels.indexOf(line.c) < 0){
				_channels.push(line.c);
			}
			var added:Boolean = true;
			if(isRepeating){
				if(_repeating > 0 && _lastRepeat){
					added = false;
					remove(_lastRepeat);
				}else{
					_repeating = _config.maxRepeats; 
				}
				_lastRepeat = line;
			}
			push(line);
			if(_config.maxLines > 0 ){
				var off:int = _length - _config.maxLines;
				if(off > 0){
					shift(off);
				}
			}
			return added;
		}
		public function clear(channel:String = null):void{
			if(channel){
				var line:Log = first;
				while(line){
					if(line.c == channel){
						remove(line);
					}
					line = line.next;
				}
				var ind:int = _channels.indexOf(channel);
				if(ind>=0) _channels.splice(ind,1);
			}else{
				first = null;
				last = null;
				_length = 0;
				_channels.splice(0);
				_channels.push(_config.globalChannel, _config.defaultChannel);
			}
		}
		public function getLogsAsBytes():Array{
			var a:Array = [];
			var line:Log = first;
			while(line){
				a.push(line.toBytes());
				line = line.next;
			}
			return a;
		}
		public function getAllLog(splitter:String = "\r\n"):String{
			var str:String = "";
			var line:Log = first;
			while(line){
				str += (line.toString()+(line.next?splitter:""));
				line = line.next;
			}
			return str;
		}
		
		
		//
		// Log chain controls
		//
		private function push(v:Log):void{
			if(last==null) {
				first = v;
			}else{
				last.next = v;
				v.prev = last;
			}
			last = v;
			_length++;
		}
		/*private function pop():void{
			if(last) {
				if(last == _lastRepeat) _lastRepeat = null;
				last = last.prev;
				_length--;
			}
		}*/
		private function shift(count:uint = 1):void{
			while(first != null && count>0){
				if(first == _lastRepeat) _lastRepeat = null;
				first = first.next;
				count--;
				_length--;
			}
		}
		private function remove(log:Log):void{
			if(first == log) first = log.next;
			if(last == log) last = log.prev;
			if(log == _lastRepeat) _lastRepeat = null;
			if(log.next != null) log.next.prev = log.prev;
			if(log.prev != null) log.prev.next = log.next;
			_length--;
		}
	}
}