package com.atticmedia.console.panels {
	import flash.text.TextFormatAlign;	
	
	import com.atticmedia.console.core.Utils;	
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;	

	/**
	 * @author LuAye
	 */
	public class GraphingPanel extends AbstractPanel {
		private var _interests:Array = [];
		private var _history:Array = [];
		private var _updatedFrame:uint = 0;
		private var _drawnFrame:uint = 0;
		private var _needRedraw:Boolean;
		private var _isRunning:Boolean;
		//
		protected var fixed:Boolean;
		protected var graph:Shape;
		protected var lowTxt:TextField;
		protected var highTxt:TextField;
		protected var keyTxt:TextField;
		//
		public var updateEvery:uint = 1;
		public var drawEvery:uint = 1;
		public var lowest:Number;
		public var highest:Number;
		public var drawAverage:Boolean;
		//
		public function GraphingPanel(W:int = 0, H:int = 0, resizable:Boolean = true) {
			registerDragger(bg);
			minimumHeight = 26;
			//
			var format:TextFormat = new TextFormat();
            format.font = "Arial";
            format.size = 10;
            format.color = 0xAAAAAA;
			lowTxt = new TextField();
			lowTxt.mouseEnabled = false;
			lowTxt.defaultTextFormat = format;
			lowTxt.height = 14;
			addChild(lowTxt);
			highTxt = new TextField();
			highTxt.mouseEnabled = false;
			highTxt.defaultTextFormat = format;
			highTxt.height = 14;
			highTxt.y = 6;
			addChild(highTxt);
			//
			format.align = TextFormatAlign.RIGHT;
			keyTxt = new TextField();
			keyTxt.mouseEnabled = false;
			keyTxt.defaultTextFormat = format;
			keyTxt.height = 16;
			keyTxt.y = -4;
			addChild(keyTxt);
			//
			graph = new Shape();
			graph.y = 10;
			addChild(graph);
			//
			init(W?W:100,H?H:80,resizable);
		}
		
		public function get rand():Number{
			return Math.random();
		}
		public function add(obj:Object, prop:String, col:Number = -1, key:String=null):void{
			var cur:Number = obj[prop];
			if(isNaN(lowest) && !isNaN(cur)) lowest = cur;
			if(isNaN(highest) && !isNaN(cur)) highest = cur;
			if(isNaN(col) || col<0) col = Math.random()*0xFFFFFF;
			_interests.push([obj, prop, col, key, NaN]);
			updateKeyText();
			//
			start();
		}
		public function start():void{
			_isRunning = true;
			// Note that if has already started, it wont add another listener on top.
			addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
		}
		public function stop():void {
			_isRunning = false;
			removeEventListener(Event.ENTER_FRAME, onFrame);
		}
		public function get running():Boolean {
			return _isRunning;
		}
		public function fixRange(low:Number,high:Number):void{
			if(isNaN(low) || isNaN(high)) {
				fixed = false;
				return;
			}
			fixed = true;
			lowest = low;
			highest = high;
		}
		public function set showKeyText(b:Boolean):void{
			keyTxt.visible = b;
		}
		public function get showKeyText():Boolean{
			return keyTxt.visible;
		}
		public function set showBoundsText(b:Boolean):void{
			lowTxt.visible = b;
			highTxt.visible = b;
		}
		public function get showBoundsText():Boolean{
			return lowTxt.visible;
		}
		override public function set height(n:Number):void{
			super.height = n;
			lowTxt.y = n-13;
			_needRedraw = true;
		}
		override public function set width(n:Number):void{
			super.width = n;
			lowTxt.width = n;
			highTxt.width = n;
			keyTxt.width = n;
			graphics.clear();
			graphics.lineStyle(1,0xFFFFFF, 1);
			graphics.moveTo(0, graph.y);
			graphics.lineTo(n, graph.y);
			_needRedraw = true;
		}
		protected function getCurrentOf(i:int):Number{
			var values:Array = _history[_history.length-1];
			return values?values[i]:0;
		}
		protected function getAverageOf(i:int):Number{
			var interest:Array = _interests[i];
			return interest?interest[4]:0;
		}
		//
		//
		//
		protected function onFrame(e:Event):void{
			updateData();
			drawGraph();
		}
		private function updateData():void{
			_updatedFrame++;
			if(_updatedFrame < updateEvery) return;
			_updatedFrame= 0;
			var values:Array = [];
			for each(var interest in _interests){
				var v:Number = interest[0][interest[1]];
				if(isNaN(v)){
					v = 0;
				}else{
					if(isNaN(lowest)) lowest = v;
					if(isNaN(highest)) highest = v;
				}
				values.push(v);
				if(drawAverage){
					var avg:Number = interest[4];
					if(isNaN(avg)) {
						interest[4] = v;
					}else{
						interest[4] = Utils.averageOut(avg, v, 20);
					}
				}
				if(!fixed){
					if(v > highest) highest = v;
					if(v < lowest) lowest = v;
				}
			}
			_history.push(values);
			// clean up off screen data
			var maxLen:int = Math.floor(width)+10;
			var len:uint = _history.length;
			if(len > maxLen){
				_history.splice(0, (len-maxLen));
			}
		}
		private function drawGraph():void{
			_drawnFrame++;
			if(!_needRedraw && _drawnFrame < drawEvery) return;
			_needRedraw = false;
			_drawnFrame= 0;
			var W:Number = width;
			var H:Number = height-graph.y;
			graph.graphics.clear();
			var diffGraph:Number = highest-lowest;
			var numInterests:int = _interests.length;
			var len:int = _history.length;
			for(var j:int = 0;j<numInterests;j++){
				var interest:Array = _interests[j];
				var first:Boolean = true;
				for(var i:int = 1;i<W;i++){
					if(len < i) break;
					var values:Array = _history[len-i];
					if(first){
						graph.graphics.lineStyle(1,interest[2]);
					}
					var Y:Number = H-((diffGraph?((values[j]-lowest)/diffGraph):0.5)*H);
					if(Y<0)Y=0;
					if(Y>H)Y=H;
					graph.graphics[(first?"moveTo":"lineTo")]((W-i), Y);
					first = false;
				}
				if(drawAverage && diffGraph){
					Y = H-(((interest[4]-lowest)/diffGraph)*H);
					if(Y<-1)Y=-1;
					if(Y>H)Y=H+1;
					graph.graphics.lineStyle(1,interest[2], 0.3);
					graph.graphics.moveTo(0, Y);
					graph.graphics.lineTo(W, Y);
				}
			}
			lowTxt.text = String(lowest);
			highTxt.text = String(highest);
		}
		private function updateKeyText():void{
			var str:String = "";
			for each(var interest:Array in _interests){
				var n:String = interest[3];
				if(!n) n =  interest[1];
				var col:Number = interest[2];
				str += " <font color='#"+col.toString(16)+"'>"+n+"</font>";
			}
			keyTxt.htmlText = str;
		}
	}
}
