package com.atticmedia.console.panels {
	import com.atticmedia.console.panels.prop.Grapher;	
	
	import flash.events.Event;
	import flash.geom.Rectangle;	
	import flash.display.Shape;	
	import flash.display.Sprite;
	
	/**
	 * @author LuAye
	 */
	public class GraphingPanel extends AbstractPanel {

		private var _interests:Array = [];
		private var _history:Array = [];
		protected var lowGraph:Number;
		protected var highGraph:Number;
		protected var graph:Sprite;
		
		public function GraphingPanel() {
			init(100,100,true);
			registerDragger(bg);
			graph = new Sprite();
			addChild(graph);
			add(this,"rand",0);
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
		
		private function onFrame(e:Event):void{
			
			var values:Array = [];
			for each(var interest in _interests){
				var v:Number = interest[0][interest[1]];
				v = isNaN(v)?0:v;
				values.push(v);
				if(v > highGraph) highGraph = v;
				if(v < lowGraph) lowGraph = v;
			}
			_history.push(values);
			drawGraph();
		}
		
		private function drawGraph():void{
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
					graph.graphics[(first?"moveTo":"lineTo")]((W-i), p*H);
				}
				first = false;
			}
		}
	}
}
