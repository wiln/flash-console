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
			drawAverage = true;
			minimumWidth = 32;
			keyTxt.selectable = false;
			keyTxt.mouseEnabled = true;
			keyTxt.addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
			registerDragger(keyTxt);
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
		protected override function onFrame(e:Event):void{
			if (_previousTime) {
				var time:int = getTimer();
				_mspf = time-_previousTime;
				_fps = 1000/_mspf;
				keyTxt.htmlText = _fps.toFixed(1)+" | "+getAverageOf(0).toFixed(1)+" <font color='#C04444'><a href=\"event:reset\">R</a></font>";
				if(stage){
					fixed = true;
					highest = stage.frameRate;
				}
				super.onFrame(e);
			}
			_previousTime = getTimer();
		}
		private function linkHandler(e:TextEvent):void{
			if(e.text == "reset"){
				reset();
			}
			e.stopPropagation();
		}
		
		/*public function getInFormat(preset:Number = 0):String{
			switch(preset){
				case 2:
					return Math.round(min)+"-<b>"+current.toFixed(1) +"</b>-"+ Math.round(max);
				break;
				case 3:
					return Math.round(min)+"-<b>"+current.toFixed(1)+"</b>-"+ Math.round(max) + ": <b>" + Math.round(averageFPS)+ "</b>";
				break;
				case 4:
					var stageFrameRate:String = "";
					return Math.round(min)+"-<b>"+current.toFixed(1)+stageFrameRate+"</b>-"+ Math.round(max) + ": <b>" + Math.round(averageFPS) + "</b> " + Math.round(averageMsPF)+"ms-"+Math.round(mspf)+"ms";
				break;
				case 5:
					var stageMS:String = "";
					return Math.round(averageMsPF)+"ms-"+Math.round(mspf)+"ms "+stageMS;
				break;
				default:
					return current.toFixed(1);
				break;
			}
		}*/
	}
}
