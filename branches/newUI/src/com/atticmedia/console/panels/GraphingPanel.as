package com.atticmedia.console.panels {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;	

	/**
	 * @author LuAye
	 */
	public class GraphingPanel extends AbstractPanel {
		private var _interests:Array = [];
		private var _history:Array = [];
		private var _fixedGraph:Boolean;
		private var _updatedFrame:uint = 0;
		private var _drawnFrame:uint = 0;
		private var _needRedraw:Boolean;
		//
		protected var graph:Shape;
		protected var lowTxt:TextField;
		protected var highTxt:TextField;
		//
		public var updateEvery:uint = 1;
		public var drawEvery:uint = 1;
		public var lowest:Number;
		public var highest:Number;
		//public var drawAverage:Boolean;
		//
		public function GraphingPanel() {
			registerDragger(bg);
			//
			var format:TextFormat = new TextFormat();
            format.font = "Arial";
            format.size = 10;
            format.color = 0xCCCCCC;
			lowTxt = new TextField();
			lowTxt.mouseEnabled = false;
			lowTxt.defaultTextFormat = format;
			addChild(lowTxt);
			highTxt = new TextField();
			highTxt.mouseEnabled = false;
			highTxt.defaultTextFormat = format;
			highTxt.y = -4;
			addChild(highTxt);
			//
			graph = new Shape();
			addChild(graph);
			//
			init(100,100,true);
		}
		
		public function get rand():Number{
			return Math.random();
		}
		public function add(obj:Object, prop:String, col:Number = -1):void{
			if(isNaN(lowest)) lowest = obj[prop];
			if(isNaN(highest)) highest = obj[prop];
			if(isNaN(col) || col<0) col = Math.random()*0xFFFFFF;
			_interests.push([obj, prop, col]);
			// start printing
			// Note that if has already started, it wont add another listener on top.
			addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
		}
		public function fixGraph(low:Number,high:Number):void{
			if(isNaN(low) || isNaN(high)) {
				_fixedGraph = false;
				return;
			}
			_fixedGraph = true;
			lowest = low;
			highest = high;
		}
		public function set showBoundsText(b:Boolean):void{
			lowTxt.visible = b;
			highTxt.visible = b;
		}
		public function get showBoundsText():Boolean{
			return lowTxt.visible
		}
		override public function set height(n:Number):void{
			super.height = n;
			lowTxt.y = n-14;
			_needRedraw = true;
		}
		override public function set width(n:Number):void{
			super.width = n;
			lowTxt.width = n;
			highTxt.width = n;
			_needRedraw = true;
		}
		//
		//
		//
		private function onFrame(e:Event):void{
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
				v = isNaN(v)?0:v;
				values.push(v);
				if(!_fixedGraph){
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
			var H:Number = height;
			graph.graphics.clear();
			var diffGraph:Number = highest-lowest;
			
			var numInterests:int = _interests.length;
			var len:int = _history.length;
			for(var j:int = 0;j<numInterests;j++){
				var first:Boolean = true;
				for(var i:int = 1;i<W;i++){
					if(len < i) break;
					var values:Array = _history[len-i];
					if(first){
						graph.graphics.lineStyle(1,_interests[j][2]);
					}
					var v:Number = values[j];
					var p:Number = diffGraph?((v-lowest)/diffGraph):0.5;
					graph.graphics[(first?"moveTo":"lineTo")]((W-i), H-(p*H));
					first = false;
				}
			}
			if(!isNaN(lowest)) lowTxt.text = lowest;
			if(!isNaN(highest)) highTxt.text = highest;
		}
	}
}
