package com.atticmedia.console.view {
	import com.atticmedia.console.view.AbstractPanel;
	import flash.text.TextFieldAutoSize;	
	import flash.geom.Rectangle;	
	import flash.text.TextField;
	import com.atticmedia.console.Console;
	
	import flash.events.Event;		

	/**
	 * @author LuAye
	 */
	public class PanelsManager{
		
		private var _master:Console;
		
		private var _tooltipField:TextField;
		
		public function PanelsManager(master:Console) {
			_master = master;
			
			_tooltipField = new TextField();
			_tooltipField.autoSize = TextFieldAutoSize.CENTER;
			_tooltipField.multiline = true;
			_tooltipField.background = true;
			_tooltipField.backgroundColor = _master.style.tooltipBackgroundColor;
			_tooltipField.styleSheet = _master.style.css;
			_tooltipField.mouseEnabled = false;
		}
		public function addPanel(panel:AbstractPanel):void{
			_master.addChild(panel);
			panel.addEventListener(AbstractPanel.STARTED_DRAGGING, onPanelStartDragScale, false,0, true);
			panel.addEventListener(AbstractPanel.STARTED_SCALING, onPanelStartDragScale, false,0, true);
		}
		public function removePanel(n:String):void{
			var panel:AbstractPanel = _master.getChildByName(n) as AbstractPanel;
			if(panel){
				// this removes it self from parent. this way each individual panel can clean up before closing.  
				panel.close();
			}
		}
		public function getPanel(n:String):AbstractPanel{
			return _master.getChildByName(n) as AbstractPanel;
		}
		public function panelExists(n:String):Boolean{
			return (_master.getChildByName(n) as AbstractPanel)?true:false;
		}
		public function tooltip(str:String = null, panel:AbstractPanel = null):void{
			if(str){
				_master.addChild(_tooltipField);
				_tooltipField.wordWrap = false;
				_tooltipField.htmlText = "<tooltip>"+str+"</tooltip>";
				_tooltipField.x = _master.mouseX-(_tooltipField.width/2);
				_tooltipField.y = _master.mouseY+20;
				if(_tooltipField.width>120){
					_tooltipField.width = 120;
					_tooltipField.wordWrap = true;
				}
				if(panel){
					var txtRect:Rectangle = _tooltipField.getBounds(_master);
					var panRect:Rectangle = new Rectangle(panel.x,panel.y,panel.width,panel.height);
					var doff:Number = txtRect.bottom - panRect.bottom;
					if(doff>0){
						_tooltipField.y -= doff;
					}
					var loff:Number = txtRect.left - panRect.left;
					var roff:Number = txtRect.right - panRect.right;
					if(loff<0){
						_tooltipField.x -= loff;
					}else if(roff>0){
						_tooltipField.x -= roff;
					}
				}
			}else if(_master.contains(_tooltipField)){
				_master.removeChild(_tooltipField);
			}
		}
		private function onPanelStartDragScale(e:Event):void{
			var target:AbstractPanel = e.currentTarget as AbstractPanel;
			if(target.snapping){
				var X:Array = [0];
				var Y:Array = [0];
				if(_master.stage){
					// this will only work if stage size is not changed or top left aligned
					X.push(_master.stage.stageWidth);
					Y.push(_master.stage.stageHeight);
				}
				var numchildren:int = _master.numChildren;
				for(var i:int = 0;i<numchildren;i++){
					var panel:AbstractPanel = _master.getChildAt(i) as AbstractPanel;
					if(panel && panel.visible){
						X.push(panel.x);
						X.push(panel.x+panel.width);
						Y.push(panel.y);
						Y.push(panel.y+panel.height);
					}
				}
				target.registerSnaps(X, Y);
			}
		}
		
	}
}
