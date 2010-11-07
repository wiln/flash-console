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
	import com.junkbyte.console.vos.WeakObject;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.getQualifiedClassName;

	public class DisplayMapper {
		
		private var _master:Console;
		
		private var _mapBases:WeakObject;
		private var _mapBaseIndex:uint = 1;
		
		public function DisplayMapper(m:Console) {
			_master = m;
			_mapBases = new WeakObject();
		}
		public function report(obj:*, priority:Number = 0, skipSafe:Boolean = true, ch:String = null):void{
			_master.addLine([obj], priority, ch?ch:_master.config.consoleChannel, false, skipSafe, 0);
		}
		public function map(base:DisplayObjectContainer, maxstep:uint = 0):void{
			if(!base){
				report("It is not a DisplayObjectContainer", 10);
				return;
			}
			_mapBases[_mapBaseIndex] = base;
			var basestr:String = _mapBaseIndex+Console.REMAPSPLIT;
			
			var list:Array = new Array();
			var index:int = 0;
			list.push(base);
			while(index<list.length){
				var mcDO:DisplayObject = list[index];
				if(mcDO is DisplayObjectContainer){
					var mc:DisplayObjectContainer = mcDO as DisplayObjectContainer;
					var numC:int = mc.numChildren;
					for(var i:int = 0;i<numC;i++){
						var child:DisplayObject = mc.getChildAt(i);
						list.splice((index+i+1),0,child);
					}
				}
				index++;
			}
			
			var steps:int = 0;
			var lastmcDO:DisplayObject = null;
			var indexes:Array = new Array();
			var wasHiding:Boolean;
			for (var X:String in list){
				mcDO = list[X];
				if(lastmcDO){
					if(lastmcDO is DisplayObjectContainer && (lastmcDO as DisplayObjectContainer).contains(mcDO)){
						steps++;
						//indexes.push((lastmcDO as DisplayObjectContainer).getChildIndex(mcDO));
						indexes.push(mcDO.name);
					}else{
						while(lastmcDO){
							lastmcDO = lastmcDO.parent;
							if(lastmcDO is DisplayObjectContainer){
								if(steps>0){
									indexes.pop();
									steps--;
								}
								if((lastmcDO as DisplayObjectContainer).contains(mcDO)){
									steps++;
									indexes.push(mcDO.name);
									break;
								}
							}
						}
					}
				}
				var str:String = "";
				for(i=0;i<steps;i++){
					str += (i==steps-1)?" ∟ ":" - ";
				}
				if(maxstep<=0 || steps<=maxstep){
					wasHiding = false;
					var n:String = "<a href='event:clip_"+basestr+indexes.join(Console.REMAPSPLIT)+"'>"+mcDO.name+"</a>";
					if(mcDO is DisplayObjectContainer){
						n = "<b>"+n+"</b>";
					}else{
						n = "<i>"+n+"</i>";
					}
					str += n+" ("+getQualifiedClassName(mcDO)+")";
					report(str,mcDO is DisplayObjectContainer?5:2);
				}else if(!wasHiding){
					wasHiding = true;
					report(str+"...",5);
				}
				lastmcDO = mcDO;
			}
			_mapBaseIndex++;
			report(base.name+":"+getQualifiedClassName(base)+" has "+list.length+" children/sub-children.", 10);
			report("Click on the name to return a reference to the child clip. <br/>Note that clip references will be broken when display list is changed",-2);
		}
		public function reMap(path:String, mc:DisplayObjectContainer):DisplayObject{
			var pathArr:Array = path.split(Console.REMAPSPLIT);
			var first:String = pathArr.shift();
			if(first != "0") mc = _mapBases[first];
			var child:DisplayObject = mc as DisplayObject;
			try{
				for each(var nn:String in pathArr){
					if(!nn) break;
					child = mc.getChildByName(nn);
					if(child is DisplayObjectContainer){
						mc = child as DisplayObjectContainer;;
					}else{
						// assume it reached to end since there can no longer be a child
						break;
					}
				}
				return child;
			} catch (e:Error) {
				report("Problem getting the clip reference. Display list must have changed since last map request",10);
				//debug(e.getStackTrace());
			}
			return null;
		}
	}
}