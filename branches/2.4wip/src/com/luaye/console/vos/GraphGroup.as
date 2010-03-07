package com.luaye.console.vos {

	/**
	 * @author LuAye
	 */
	public class GraphGroup {
		public var type:uint;
		public var name:String;
		public var lowest:Number;
		public var highest:Number;
		public var averaging:uint;
		public var inverse:Boolean;
		public var interests:Array = [];
		
		public function GraphGroup(n:String){
			name = n;
		}
	}
}
