package com.atticmedia.console {

	/**
	 * @author Lu
	 */
	public class CChannel {
		
		private var _c:*;
		public var name:String;
		
		public function CChannel(n:String = null, c:Console = null){
			name = n;
			_c = c?c:C;
		}
		public function log(...args):void{
			_c.logch.apply(null, [name].concat(args));
		}
		public function info(...args):void{
			_c.infoch.apply(null, [name].concat(args));
		}
		public function debug(...args):void{
			_c.debugch.apply(null, [name].concat(args));
		}
		public function warn(...args):void{
			_c.warnch.apply(null, [name].concat(args));
		}
		public function error(...args):void{
			_c.errorch.apply(null, [name].concat(args));
		}
		public function clear():void{
			_c.clear(name);
		}
	}
}
