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
		
		public function GraphGroup(n:String){
			name = n;
		}
	}
}
