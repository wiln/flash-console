package com.atticmedia.console.panels {
	import flash.display.DisplayObject;	
	import flash.events.Event;	
	import flash.events.MouseEvent;	
	import flash.geom.Rectangle;	
	import flash.display.Shape;	
	import flash.display.Sprite;
	
	/**
	 * @author LuAye
	 */
	public class AbstractPanel extends Sprite {
		
		protected var bg:Sprite;
		protected var scaler:Sprite;
		protected var minimumWidth:int = 18;
		protected var minimumHeight:int = 18;
		
		public function AbstractPanel() {
			bg = new Sprite();
			bg.name = "background";
			addChild(bg);
		}
		protected function drawBG(col:Number = 0, a:Number = 0.6, rounding:int = 10):void{
			bg.graphics.clear();
			bg.graphics.beginFill(col, a);
			var size:int = 100;
			var roundSize:int = 100-(rounding*2);
			bg.graphics.drawRoundRect(0, 0, size, size,rounding,rounding);
			var grid:Rectangle = new Rectangle(rounding, rounding, roundSize, roundSize);
			bg.scale9Grid = grid;
		}
		
		
		public function init(w:Number,h:Number,resizable:Boolean = false, col:Number = 0, a:Number = 0.6, rounding:int = 10):void{
			drawBG(col, a, rounding);
			if(resizable){
				scaler = new Sprite();
				scaler.name = "scaler";
				scaler.graphics.beginFill(0x000000, 0.6);
	            scaler.graphics.lineTo(-10, 0);
	            scaler.graphics.lineTo(0, -10);
	            scaler.graphics.endFill();
				scaler.buttonMode = true;
				scaler.doubleClickEnabled = true;
				scaler.addEventListener(MouseEvent.MOUSE_DOWN,onScalerMouseDown, false, 0, true);
	            addChild(scaler);
			}
			width = w;
			height = h;
		}
		//
		//
		override public function set width(n:Number):void{
			if(n < minimumWidth) n = minimumWidth;
			if(scaler) scaler.x = n;
			bg.width = n;
		}
		override public function set height(n:Number):void{
			if(n < minimumHeight) n = minimumHeight;
			if(scaler) scaler.y = n;
			bg.height = n;
		}
		override public function get width():Number{
			return bg.width;
		}
		override public function get height():Number{
			return bg.height;
		}
		//
		// DRAGGING
		//
		protected function registerDragger(mc:DisplayObject, dereg:Boolean = false):void{
			if(dereg){
				mc.removeEventListener(MouseEvent.MOUSE_DOWN, onDraggerMouseDown);
			}else{
				mc.addEventListener(MouseEvent.MOUSE_DOWN, onDraggerMouseDown, false, 0, true);
			}
		}
		private function onDraggerMouseDown(e:MouseEvent):void{
			if(!stage) return;
			stage.addEventListener(MouseEvent.MOUSE_UP, onDraggerMouseUp, false, 0, true);
			startDrag();
		}
		private function onDraggerMouseUp(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDraggerMouseUp);
			stopDrag();
		}
		//
		// SCALING
		//
		private function onScalerMouseDown(e:Event):void{
			scaler.startDrag(false, new Rectangle(minimumWidth, minimumHeight, 1280, 1280));
			scaler.stage.addEventListener(MouseEvent.MOUSE_UP,onScalerMouseUp, false, 0, true);
			scaler.stage.addEventListener(MouseEvent.MOUSE_MOVE,updateScale, false, 0, true);
		}
		private function updateScale(e:Event = null):void{
			width = scaler.x;
			height = scaler.y;
		}
		private function onScalerMouseUp(e:Event):void{
			scaler.stage.removeEventListener(MouseEvent.MOUSE_UP,onScalerMouseUp);
			scaler.stage.removeEventListener(MouseEvent.MOUSE_MOVE,updateScale);
			stopDrag();
			updateScale();
		}
		//
		//
		//
	}
}
