package com.atticmedia.console.view {
	import com.atticmedia.console.Console;
	import com.atticmedia.console.view.GraphingPanel;
	
	import flash.events.Event;
	import flash.utils.getTimer;	

	/**
	 * @author LuAye
	 */
	public class FPSPanel extends GraphingPanel {
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
		public function get current():Number {
			return master.fps;
		}
		public override function stop():void {
			super.stop();
			reset();
		}
		protected override function updateKeyText():void{
			keyTxt.htmlText = "<r><s>"+master.fps.toFixed(1)+" | "+getAverageOf(0).toFixed(1)+" <menu><a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></r></s>";
		}
		protected override function onFrame(e:Event):void{
			var mspf:Number = master.mspf;
			if (!isNaN(mspf)) {
				updateKeyText();
				if(stage){
					fixed = true;
					highest = stage.frameRate;
					var frames:int = Math.floor(mspf/(1000/highest));
					//if(_fps < lowest) lowest = _fps;
					if(frames>30) frames = 30; // Don't add too many
					while(frames>1){
						// this is to try add the frames that have been lagged
						updateData();
						frames--;
					}
				}
				super.onFrame(e);
			}
		}
	}
}
