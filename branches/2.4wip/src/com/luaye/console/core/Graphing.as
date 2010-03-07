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
package com.luaye.console.core {
	import flash.system.System;
	import flash.utils.getTimer;

	import com.luaye.console.vos.GraphInterest;
	import com.luaye.console.vos.GraphGroup;

	import flash.geom.Rectangle;

	public class Graphing {
		
		private var _map:Object = {};
		private var _fpsMonitor:Boolean;
		private var _memoryMonitor:Boolean;
		
		private var _mspfs:Array = [];
		private var _previousTime:Number;
		private var _mem:Array = [];
		
		public function Graphing(){
			
		}
		// WINDOW name lowest highest averaging inverse
		// GRAPH key color values
		public function add(n:String, obj:Object, prop:String, col:Number = -1, key:String = null, rect:Rectangle = null, inverse:Boolean = false):void{
			var group:Group = _map[n];
			if(!group) {
				group = new Group();
				_map[n] = group;
			}
			if(rect) group.rect = rect;
			if(inverse) group.inverse = inverse;
			var interest:Interest = new Interest(obj, prop, col, key);
			group.interests.push(interest);
		}

		public function fixRange(n:String, low:Number = NaN, high:Number = NaN):void{
			var group:Group = _map[n];
			if(!group) return;
			group.lowest = low;
			group.highest = high;
		}
		public function remove(n:String, obj:Object = null, prop:String = null):void{
			var group:Group = _map[n];
			if(!group) return;
			if(obj==null&&prop==null){
				delete _map[n];
			}else{
				var interests:Array = group.interests;
				for(var i:int = interests.length-1;i>=0;i--){
					var interest:Interest = interests[i];
					if((obj == null || interest.obj == obj) && (prop == null || interest.prop == prop)){
						interests.splice(i, 1);
					}
				}
				if(interests.length==0){
					delete _map[n];
				}
			}
		}
		public function get fpsMonitor():Boolean{
			return _fpsMonitor;
		}
		public function set fpsMonitor(b:Boolean):void{
			_fpsMonitor = b;
		}
		//
		public function get memoryMonitor():Boolean{
			return _memoryMonitor;
		}
		public function set memoryMonitor(b:Boolean):void{
			_memoryMonitor = b;
		}
		public function update(stack:Boolean = false):void{
			if(_fpsMonitor){
				var time:int = getTimer();
				var mspf:Number = time-_previousTime;
				if(stack) _mspfs.push(mspf);
				else _mspfs = [mspf];
			}
			if(_memoryMonitor){
				var mem:uint = System.totalMemory;
				if(stack) _mem.push(mem);
				else _mem = [mem];
			}
			for(var X:String in _map){
				var group:Group = _map[X];
				for each(var interest:Interest in group.interests){
					try{
						var v:Number = interest.getValue();
						if(stack) interest.values.push(v);
						else interest.values = [v];
					}catch(e:Error){
						remove(X, interest.obj, interest.prop);
					}
				}
			}
		}
		public function fetch():Array{
			var result:Array = [];
			var gi:GraphInterest;
			if(_fpsMonitor){
				gi = new GraphInterest();
				gi.key = GraphInterest.KEY_FPS;
				gi.values = _mspfs;
				result.push(gi);
			}
			if(_memoryMonitor){
				gi = new GraphInterest();
				gi.key = GraphInterest.KEY_MEM;
				gi.values = _mem;
				result.push(gi);
			}
			for(var X:String in _map){
				var group:Group = _map[X];
				var gg:GraphGroup = new GraphGroup(X);
				gg.inverse = group.inverse;
				gg.lowest = group.lowest;
				gg.highest = group.highest;
				result.push(gg);
				var gis:Array = gg.interests;
				for each(var interest:Interest in group.interests){
					gi = new GraphInterest();
					gis.push(gi);
					gi.key = interest.key;
					gi.col = interest.col;
					gi.values = interest.values;
				}
			}
			return result;
		}
	}
}

import flash.geom.Rectangle;
class Group{
	public var interests:Array = [];
	public var rect:Rectangle;
	public var inverse:Boolean;
	public var lowest:Number;
	public var highest:Number;
}
import com.luaye.console.core.CommandExec;
import com.luaye.console.utils.WeakRef;

class Interest{
	private var _ref:WeakRef;
	public var prop:String;
	public var col:Number;
	public var key:String;
	public var avg:Number;
	private var useExec:Boolean;
	public var values:Array = [];
	public function Interest(object:Object, property:String, color:Number, keystr:String):void{
		_ref = new WeakRef(object);
		prop = property;
		col = color;
		key = keystr;
		useExec = prop.search(/[^\w\d]/) >= 0;
	}
	public function getValue():Number{
		return useExec?CommandExec.Exec(obj, prop):obj[prop];
	}
	public function get obj():Object{
		return _ref.reference;
	}
}