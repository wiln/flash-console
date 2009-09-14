package com.atticmedia.console.events {
	import flash.events.Event;
	
	/**
	 * @author lu
	 */
	public class TextFieldRollOver extends Event {
		
		public static const ROLLOVER:String = "TextFieldRollOver";
		
		public var url:String;
		public var text:String;
		
		public function TextFieldRollOver(lnk:String  = null, txt:String = null) {
			url = lnk;
			text = txt;
			super(ROLLOVER, false, false);
		}
		override public function clone():Event{
			var e:TextFieldRollOver = super.clone() as TextFieldRollOver;
			e.url = url;
			e.text = text;
			return e;
		}
	}
}
