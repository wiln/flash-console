package com.atticmedia.console.panels {
	import flash.text.TextFieldAutoSize;	
	import flash.text.TextFormatAlign;	
	import flash.text.TextFormat;	
	import flash.text.TextField;	
	import flash.geom.Point;	
	import flash.display.DisplayObject;	
	import flash.events.Event;	
	import flash.events.MouseEvent;	
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	
	/**
	 * @author LuAye
	 */
	public class AbstractPanel extends Sprite {
		
		public static const STARTED_DRAGGING:String = "startedDragging";
		public static const STARTED_SCALING:String = "startedScaling";
		
		private var _snaps:Array;
		private var _dragOffset:Point;
		private var _resizeTxt:TextField;
		
		protected var bg:Sprite;
		protected var scaler:Sprite;
		protected var minimumWidth:int = 18;
		protected var minimumHeight:int = 18;
		public var snapping:uint = 3;
		
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
		// SIZE
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
		// MOVING
		//
		public function registerSnaps(X:Array, Y:Array):void{
			_snaps = [X,Y];
		}
		protected function registerDragger(mc:DisplayObject, dereg:Boolean = false):void{
			if(dereg){
				mc.removeEventListener(MouseEvent.MOUSE_DOWN, onDraggerMouseDown);
			}else{
				mc.addEventListener(MouseEvent.MOUSE_DOWN, onDraggerMouseDown, false, 0, true);
			}
		}
		private function onDraggerMouseDown(e:MouseEvent):void{
			if(!stage) return;
			//
			_resizeTxt = new TextField();
			_resizeTxt.y = -3;
			_resizeTxt.autoSize = TextFieldAutoSize.LEFT;
           	formatText(_resizeTxt, TextFormatAlign.LEFT);
			addChild(_resizeTxt);
			//
			_dragOffset = new Point(mouseX,mouseY); // using this way instead of startDrag, so that it can control snapping.
			_snaps = [[],[]];
			dispatchEvent(new Event(STARTED_DRAGGING));
			stage.addEventListener(MouseEvent.MOUSE_UP, onDraggerMouseUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onDraggerMouseMove, false, 0, true);
		}
		private function onDraggerMouseMove(e:MouseEvent):void{
			if(snapping==0) return;
			// YEE HA, SNAPPING!
			var p:Point = returnSnappedFor(parent.mouseX-_dragOffset.x, parent.mouseY-_dragOffset.y);
			x = p.x;
			y = p.y;
			_resizeTxt.text = p.x+","+p.y;
		}
		private function onDraggerMouseUp(e:MouseEvent):void{
			_snaps = null;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDraggerMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDraggerMouseMove);
			if(_resizeTxt && _resizeTxt.parent){
				_resizeTxt.parent.removeChild(_resizeTxt);
			}
			_resizeTxt = null;
		}
		//
		// SCALING
		//
		private function onScalerMouseDown(e:Event):void{
			_resizeTxt = new TextField();
			_resizeTxt.autoSize = TextFieldAutoSize.RIGHT;
			_resizeTxt.x = -8;
			_resizeTxt.y = -18;
           	formatText(_resizeTxt, TextFormatAlign.RIGHT);
			scaler.addChild(_resizeTxt);
			_dragOffset = new Point(scaler.mouseX,scaler.mouseY); // using this way instead of startDrag, so that it can control snapping.
			_snaps = [[],[]];
			dispatchEvent(new Event(STARTED_SCALING));
			scaler.stage.addEventListener(MouseEvent.MOUSE_UP,onScalerMouseUp, false, 0, true);
			scaler.stage.addEventListener(MouseEvent.MOUSE_MOVE,updateScale, false, 0, true);
		}
		private function updateScale(e:Event = null):void{
			var p:Point = returnSnappedFor(x+mouseX-_dragOffset.x, y+mouseY-_dragOffset.x);
			p.x-=x;
			p.y-=y;
			width = p.x<minimumWidth?minimumWidth:p.x;
			height = p.y<minimumHeight?minimumHeight:p.y;
			_resizeTxt.text = p.x+","+p.y;
		}
		private function onScalerMouseUp(e:Event):void{
			scaler.stage.removeEventListener(MouseEvent.MOUSE_UP,onScalerMouseUp);
			scaler.stage.removeEventListener(MouseEvent.MOUSE_MOVE,updateScale);
			updateScale();
			_snaps = null;
			if(_resizeTxt && _resizeTxt.parent){
				_resizeTxt.parent.removeChild(_resizeTxt);
			}
			_resizeTxt = null;
		}
		//
		//
		//
		private function formatText(txt:TextField, align:String):void{
			var format:TextFormat = new TextFormat();
            format.font = "Arial";
            format.size = 10;
            format.color = 0xFFFFFF;
            format.align = align;
			txt.defaultTextFormat = format;
			txt.mouseEnabled = false;
		}
		private function returnSnappedFor(X:Number,Y:Number):Point{
			var ex:Number = X+width;
			var Xs:Array = _snaps[0];
			for each(var Xi:Number in Xs){
				if(Math.abs(Xi-X)<snapping){
					X = Xi;
					break;
				}
				if(Math.abs(Xi-ex)<snapping){
					X = Xi-width;
					break;
				}
			}
			var ey:Number = Y+height;
			var Ys:Array = _snaps[1];
			for each(var Yi:Number in Ys){
				if(Math.abs(Yi-Y)<snapping){
					Y = Yi;
					break;
				}
				if(Math.abs(Yi-ey)<snapping){
					Y = Yi-height;
					break;
				}
			}
			return new Point(X,Y);
		}
	}
}
