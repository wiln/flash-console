package com.atticmedia.console.view {
	import com.atticmedia.console.Console;
	import com.atticmedia.console.view.GraphingPanel;
	
	import flash.events.Event;

	/**
	 * @author LuAye
	 */
	public class FPSPanel extends GraphingPanel {
		//
		public static const MAX_LAG_FRAMES:uint = 25;
		private var _cachedCurrent:Number;
		//
		public function FPSPanel(m:Console) {
			super(m, 80,40);
			name = Console.PANEL_FPS;
			lowest = 0;
			averaging = 10;
			minimumWidth = 32;
			add(this, "current", 0xFF3333, "FPS");
		}
		public override function reset():void {
			//lowest = NaN;
			super.reset();
		}
		public override function stop():void {
			super.stop();
			reset();
		}
		public override function updateKeyText():void{
			keyTxt.htmlText = "<r><s>"+master.fps.toFixed(1)+" | "+getAverageOf(0).toFixed(1)+" <menu><a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></r></s>";
		}
		public function get current():Number{
			if(isNaN(_cachedCurrent))
				return master.fps;
			var mspf:Number = _cachedCurrent;
			_cachedCurrent = NaN;
			return mspf;
		}
		public function addCurrent(n:Number):void{
			_cachedCurrent = n;
			updateData();
		}
		protected override function onFrame(e:Event):void{
			if(master.isRemote) return;
			var mspf:Number = master.mspf;
			if (!isNaN(mspf)) {
				updateKeyText();
				if(stage){
					fixed = true;
					highest = stage.frameRate;
					var frames:int = Math.floor(mspf/(1000/highest));
					// this is to try add the frames that have been lagged
					if(frames>MAX_LAG_FRAMES) frames = MAX_LAG_FRAMES; // Don't add too many
					while(frames>1){
						updateData();
						frames--;
					}
				}
				super.onFrame(e);
			}
		}
	}
}
