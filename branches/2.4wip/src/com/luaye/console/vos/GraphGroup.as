package com.luaye.console.vos {
	import flash.geom.Rectangle;

	/**
	 * @author LuAye
	 */
	public class GraphGroup {
		
		public static const TYPE_FPS:uint = 1;
		public static const TYPE_MEM:uint = 2;
	
		public var type:uint;
		public var name:String;
		public var freq:int = 1; // update every n number of frames.
		public var lowest:Number;
		public var highest:Number;
		public var fixed:Boolean;
		public var averaging:uint;
		public var inverse:Boolean;
		public var interests:Array = [];
		public var rect:Rectangle;
		//
		//
		public var idle:int;
		
		public function GraphGroup(n:String){
			name = n;
		}
		public function updateMinMax(v:Number):void{
			if(!isNaN(v) && !fixed){
				if(isNaN(lowest)) {
					lowest = v;
					highest = v;
				}
				if(v > highest) highest = v;
				if(v < lowest) lowest = v;
			}
		}
		//
		//
		//
		public function toObject():Object{
			var gis:Array = [];
			for each(var gi:GraphInterest in interests) gis.push(gi.toObject());
			return {type:type, name:name, freq:freq, lowest:lowest, highest:highest, fixed:fixed, averaging:averaging, inverse:inverse, interests:gis, rect:rect};
		}
		public static function fromObject(o:Object):GraphGroup{
			var g:GraphGroup = new GraphGroup(o.name);
			g.type = o.type;
			g.freq = o.freq;
			g.lowest = o.lowest;
			g.highest = o.highest;
			g.averaging = o.averaging;
			g.inverse = o.inverse;
			//g.rect = o.rect;
			g.freq = -1;
			for each(var io:Object in o.interests) g.interests.push(GraphInterest.fromObject(io));
			return g;
		}
	}
}
