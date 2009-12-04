package com.atticmedia.console {

	/**
	 * @author Lu
	 */
	public class CChannel {
		
		private var _c:Console;
		public var name:String;
		
		public function CChannel(n:String = null, c:Console = null){
			name = n;
			_c = c;
		}
		public function log(...args):void{
			(_c==null?C:_c).logch.apply(null, [name].concat(args));
		}
		public function info(...args):void{
			(_c==null?C:_c).infoch.apply(null, [name].concat(args));
		}
		public function debug(...args):void{
			(_c==null?C:_c).debugch.apply(null, [name].concat(args));
		}
		public function warn(...args):void{
			(_c==null?C:_c).warnch.apply(null, [name].concat(args));
		}
		public function error(...args):void{
			(_c==null?C:_c).errorch.apply(null, [name].concat(args));
		}
	}
}
