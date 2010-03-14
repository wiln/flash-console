package com.luaye.console.vos {
	import com.luaye.console.core.CommandExec;
	import com.luaye.console.utils.WeakRef;

	/**
	 * @author LuAye
	 */
	public class GraphInterest {
		
		private var _ref:WeakRef;
		public var _prop:String;
		private var useExec:Boolean;
		public var key:String;
		public var col:Number;
		public var avg:Number;
		public var values:Array = [];
		public function GraphInterest(keystr:String ="", color:Number = 0):void{
			col = color;
			key = keystr;
		}
		public function setObject(object:Object, property:String):void{
			_ref = new WeakRef(object);
			_prop = property;
			useExec = _prop.search(/[^\w\d]/) >= 0;
		}
		public function getValue():Number{
			return useExec?CommandExec.Exec(obj, _prop):obj[_prop];
		}
		public function get obj():Object{
			return _ref!=null?_ref.reference:undefined;
		}
		public function get prop():String{
			return _prop;
		}
	}
}
