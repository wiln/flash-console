package com.atticmedia.console.view {
	import com.atticmedia.console.view.GraphingPanel;
	import com.atticmedia.console.Console;	
	import com.atticmedia.console.core.Style;	
	
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.events.TextEvent;

	/**
	 * @author LuAye
	 */
	public class FPSPanel extends GraphingPanel {
		
		public static const NAME:String = "FPSPanel";
		
		private var _previousTime:Number;
		private var _fps:Number;
		private var _mspf:Number;
		//
		public function FPSPanel(m:Console) {
			name = NAME;
			super(m, 80,40);
			lowest = 0;
			averaging = 10;
			minimumWidth = 32;
			add(this, "current", 0xFF3333, "FPS");
		}
		public override function reset():void {
			_fps = NaN;
			_previousTime = NaN;
			super.reset();
		}
		public function get current():Number {
			return _fps;
		}
		public function get mspf():Number {
			return _mspf;
		}
		public override function stop():void {
			super.stop();
			reset();
		}
		protected override function updateKeyText():void{
			keyTxt.htmlText = "<r><s>"+_fps.toFixed(1)+" | "+getAverageOf(0).toFixed(1)+" <menu><a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></r></s>";
		}
		protected override function onFrame(e:Event):void{
			if (_previousTime) {
				var time:int = getTimer();
				_mspf = time-_previousTime;
				_fps = 1000/_mspf;
				updateKeyText();
				if(stage){
					fixed = true;
					highest = stage.frameRate;
					var frames:int = Math.floor(_mspf/(1000/highest));
					if(frames>30) frames = 30; // Don't add too many
					while(frames>1){
						// this is to try add the frames that have been lagged
						updateData();
						frames--;
					}
				}
				super.onFrame(e);
			}
			_previousTime = getTimer();
		}
	}
}
