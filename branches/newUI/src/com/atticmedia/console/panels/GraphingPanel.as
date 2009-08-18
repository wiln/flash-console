package com.atticmedia.console.panels {
	import flash.display.Sprite;
	import flash.events.Event;	

	/**
	 * @author LuAye
	 */
	public class GraphingPanel extends AbstractPanel {

		private var _interests:Array = [];
		private var _history:Array = [];
		public var lowGraph:Number;
		public var highGraph:Number;
		private var _fixedGraph:Boolean;
		
		private var _updatedFrame:uint = 0;
		private var _drawnFrame:uint = 0;
		public var updateEvery:uint = 25;
		public var drawEvery:uint = 25;
		
		protected var graph:Sprite;
		
		public function GraphingPanel() {
			init(100,100,true);
			registerDragger(bg);
			graph = new Sprite();
			addChild(graph);
		}
		
		public function get rand():Number{
			return Math.random();
		}
		
		public function add(obj:Object, prop:String, col:Number = -1):void{
			if(isNaN(lowGraph)) lowGraph = obj[prop];
			if(isNaN(highGraph)) highGraph = obj[prop];
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
			lowGraph = low;
			highGraph = high;
		}
		private function onFrame(e:Event):void{
			var doupdate:Boolean = true;
			if(updateEvery > 1){
				_updatedFrame++;
				if(_updatedFrame >= updateEvery){
					_updatedFrame= 0;
				}else{
					doupdate = false;
				}
			}
			if(doupdate){
				var values:Array = [];
				for each(var interest in _interests){
					var v:Number = interest[0][interest[1]];
					v = isNaN(v)?0:v;
					values.push(v);
					if(!_fixedGraph){
						if(v > highGraph) highGraph = v;
						if(v < lowGraph) lowGraph = v;
					}
				}
				_history.push(values);
			}
			drawGraph();
		}
		
		private function drawGraph():void{
			if(drawEvery > 1){
				_drawnFrame++;
				if(_drawnFrame >= drawEvery){
					_drawnFrame= 0;
				}else{
					return;
				}
			}
			var W:Number = width;
			var H:Number = height;
			graph.graphics.clear();
			var diffGraph:Number = highGraph-lowGraph;
			var first:Boolean = true;
			var len:int = _history.length;
			for(var i:int = 1;i<W;i++){
				if(len < i) break;
				var values:Array = _history[len-i];
				var vlen:int = values.length;
				for(var j:int = 0;j<vlen;j++){
					if(first){
						graph.graphics.lineStyle(1,_interests[j][2]);
					}
					var v:Number = values[j];
					var p:Number = (v-lowGraph)/diffGraph;
					graph.graphics[(first?"moveTo":"lineTo")]((W-i), H-(p*H));
				}
				first = false;
			}
		}
	}
}
