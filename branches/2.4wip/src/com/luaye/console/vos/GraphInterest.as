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
		public var v:Number;
		public var avg:Number;
		
		public var values:Array = [];
		
		public function GraphInterest(keystr:String ="", color:Number = 0):void{
			col = color;
			key = keystr;
		}
		public function setObject(object:Object, property:String):Number{
			_ref = new WeakRef(object);
			_prop = property;
			useExec = _prop.search(/[^\w\d]/) >= 0;
			//
			var v:Number = getCurrentValue();
			values = [v];
			avg = v;
			return v;
		}
		public function get obj():Object{
			return _ref!=null?_ref.reference:undefined;
		}
		public function get prop():String{
			return _prop;
		}
		//
		//
		//
		public function getCurrentValue():Number{
			return useExec?CommandExec.Exec(obj, _prop):obj[_prop];
		}
		public function addValue(val:Number, averaging:uint = 0, stack:Boolean = false):void{
			v = val;
			if(stack) values.push(v);
			else values = [v];
			//
			if(averaging>0) {
				avg += ((v-avg)/averaging);
			}
				
		}
	}
}
