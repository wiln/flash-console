package com.atticmedia.console.panels {
	import com.atticmedia.console.core.Styles;	
	import com.atticmedia.console.Console;
	
	import flash.events.Event;		

	/**
	 * @author LuAye
	 */
	public class PanelsManager{
		
		private var _master:Console;
		
		public function PanelsManager(master:Console) {
			_master = master;
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
					if(panel){
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
