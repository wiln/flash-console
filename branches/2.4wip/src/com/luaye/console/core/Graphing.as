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
		
		private var _groups:Array = [];
		private var _map:Object = {};
		
		private var _fpsGroup:GraphGroup;
		private var _memGroup:GraphGroup;
		
		private var _previousTime:Number = -1;
		
		public function Graphing(){
			
		}
		// WINDOW name lowest highest averaging inverse
		// GRAPH key color values
		public function add(n:String, obj:Object, prop:String, col:Number = -1, key:String = null, rect:Rectangle = null, inverse:Boolean = false):void{
			var group:GraphGroup = _map[n];
			if(!group) {
				group = new GraphGroup(n);
				_map[n] = group;
				_groups.push(group);
			}
			if(rect) group.rect = rect;
			if(inverse) group.inverse = inverse;
			var interest:GraphInterest = new GraphInterest(key, col);
			interest.setObject(obj, prop);
			group.interests.push(interest);
		}

		public function fixRange(n:String, low:Number = NaN, high:Number = NaN):void{
			var group:GraphGroup = _map[n];
			if(!group) return;
			group.lowest = low;
			group.highest = high;
		}
		public function remove(n:String, obj:Object = null, prop:String = null):void{
			var group:GraphGroup = _map[n];
			if(!group) return;
			if(obj==null&&prop==null){	
				removeGroup(n);
			}else{
				var interests:Array = group.interests;
				for(var i:int = interests.length-1;i>=0;i--){
					var interest:GraphInterest = interests[i];
					if((obj == null || interest.obj == obj) && (prop == null || interest.prop == prop)){
						interests.splice(i, 1);
					}
				}
				if(interests.length==0){
					removeGroup(n);
				}
			}
		}
		private function removeGroup(n:String):void{
			var g:GraphGroup = _map[n];
			var index:int = _groups.indexOf(g);
			if(index>=0) _groups.splice(index, 1);
			delete _map[n];
		}
		public function get fpsMonitor():Boolean{
			return _fpsGroup!=null;
		}
		public function set fpsMonitor(b:Boolean):void{
			if(b != fpsMonitor){
				if(b) _fpsGroup = addSpecialGroup(GraphGroup.TYPE_FPS);
				else{
					_previousTime = -1;
					var index:int = _groups.indexOf(_fpsGroup);
					if(index>=0) _groups.splice(index, 1);
				}
			}
		}
		//
		public function get memoryMonitor():Boolean{
			return _memGroup!=null;
		}
		public function set memoryMonitor(b:Boolean):void{
			if(b != memoryMonitor){
				if(b) _memGroup = addSpecialGroup(GraphGroup.TYPE_MEM);
				else{
					var index:int = _groups.indexOf(_memGroup);
					if(index>=0) _groups.splice(index, 1);
				}
			}
		}
		private function addSpecialGroup(type:int):GraphGroup{
			var group:GraphGroup = new GraphGroup("special");
			group.type = type;
			_groups.push(group);
			var graph:GraphInterest = new GraphInterest();
			group.interests.push(graph);
			return group;
		}
		public function update(stack:Boolean = false, fps:Number = 0):Array{
			var interest:GraphInterest;
			var v:Number;
			for each(var group:GraphGroup in _groups){
				if(group.type == GraphGroup.TYPE_FPS){
					group.highest = fps;
					interest = group.interests[0];
					var time:int = getTimer();
					if(_previousTime >= 0){
						var mspf:Number = time-_previousTime;
						v = 1000/mspf;
						if(stack) interest.values.push(v);
						else interest.values = [v];
					}
					_previousTime = time;
				}else if(group.type == GraphGroup.TYPE_MEM){
					interest = group.interests[0];
					v = System.totalMemory;
					if(stack) interest.values.push(v);
					else interest.values = [v];
				}else{
					for each(interest in group.interests){
						try{
							v = interest.getValue();
							if(stack) interest.values.push(v);
							else interest.values = [v];
						}catch(e:Error){
							// TODO: Maybe report in console of the error and removal.
							remove(group.name, interest.obj, interest.prop);
						}
					}
				}
			}
			return _groups;
		}
	}
}