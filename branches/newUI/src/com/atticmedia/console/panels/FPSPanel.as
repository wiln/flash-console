package com.atticmedia.console.panels {
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.events.TextEvent;

	/**
	 * @author LuAye
	 */
	public class FPSPanel extends GraphingPanel {
		
		private var _previousTime:Number;
		private var _fps:Number;
		private var _mspf:Number;
		//
		public function FPSPanel() {
			name = "FPSPanel";
			super(80,40);
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
		public function destory():void{
			stop();
			reset();
		}
		protected override function updateKeyText():void{
			keyTxt.htmlText = _fps.toFixed(1)+" | "+getAverageOf(0).toFixed(1)+" <font color='#C04444'><a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></font>";
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
						// this is to try add the frames that have been lagged due to script run time/lag.
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
