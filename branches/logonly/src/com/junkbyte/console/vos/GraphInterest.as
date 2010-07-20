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
*/package com.junkbyte.console.vos 
{

	public class GraphInterest {
		
		public var _prop:String;
		public var key:String;
		public var col:Number;
		public var v:Number;
		public var avg:Number;
		
		public function GraphInterest(keystr:String ="", color:Number = 0):void{
			col = color;
			key = keystr;
		}
		//
		//
		//
		public function setValue(val:Number, averaging:uint = 0):void{
			v = val;
			if(averaging>0) {
				if(isNaN(avg))
				{
					avg = v;
				}
				else
				{
					avg += ((v-avg)/averaging);
				}
			}
		}
		//
		//
		//
		public function toObject():Object{
			return {key:key, col:col, v:v, avg:avg};
		}
		public static function FromObject(o:Object):GraphInterest{
			var interest:GraphInterest = new GraphInterest(o.key, o.col);
			interest.v = o.v;
			interest.avg = o.avg;
			return interest;
		}
	}
}
