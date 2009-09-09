/*
* 
* Copyright (c) 2008 Atticmedia
* 
* @author 		Lu Aye Oo
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
* 
* 
*/
package com.atticmedia.console.panels {
	import com.atticmedia.console.core.Central;	
	import com.atticmedia.console.core.Style;	
	
	import flash.events.TextEvent;	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;		

	public class RollerPanel extends AbstractPanel{
		
		public static const NAME:String = "roller";
		
		private var _txtField:TextField;
		private var _base:DisplayObjectContainer;
		
		
		public function RollerPanel(refs:Central) {
			super(refs);
			name = NAME;
			init(60,100,false);
			_txtField = new TextField();
			_txtField.name = "rollerprints";
			_txtField.multiline = true;
			_txtField.autoSize = TextFieldAutoSize.LEFT;
			_txtField.styleSheet = style.css;
			_txtField.addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
			_txtField.selectable = false;
			registerDragger(_txtField);
			addChild(_txtField);
		}
		public function start(base:DisplayObjectContainer):void{
			_base = base;
			addEventListener(Event.ENTER_FRAME, _onFrame, false, 0, true);
		}
		
		private function _onFrame(e:Event):void{
			if(!_base.stage){
				close();
				return;
			}
			var stg:Stage = _base.stage;
			var str:String = "<y>";
			var objs:Array = stg.getObjectsUnderPoint(new Point(stg.mouseX, stg.mouseY));
			var stepMap:Dictionary = new Dictionary(true);
			if(objs.length == 0){
				objs.push(stg);// if nothing at least at stage.
			}
			for each(var child:DisplayObject in objs){
				var chain:Array = new Array(child);
				var par:DisplayObjectContainer = child.parent;
				while(par){
					chain.unshift(par);
					par = par.parent;
				}
				var len:uint = chain.length;
				for (var i:uint=0; i<len; i++){
					var obj:DisplayObject = chain[i];
					if(stepMap[obj] == undefined){
						stepMap[obj] = i;
						for(var j:uint = i;j>0;j--){
							str += j==1?" ∟":" -";
						}
						if(obj == stg){
							str +=  "<menu><a href=\"event:close\"><b>X</b></a></menu> <i>Stage</i> ["+stg.mouseX+","+stg.mouseY+"]<br/>";
						}else if(i == len-1){
							str +=  "<y2>"+obj.name+"("+getQualifiedClassName(obj).split("::").pop()+")</y2>";
						}else {
							str +=  "<i>"+obj.name+"("+getQualifiedClassName(obj).split("::").pop()+")</i><br/>";
						}
					}
				}
			}
			str += "</y>";
			_txtField.htmlText = str;
			_txtField.autoSize = TextFieldAutoSize.LEFT;
			width = _txtField.width+4;
			height = _txtField.height;
		}
		
		public override function close():void {
			removeEventListener(Event.ENTER_FRAME, _onFrame);
			_base = null;
			super.close();
		}
		protected function linkHandler(e:TextEvent):void{
			if(e.text == "close"){
				close();
			}
			e.stopPropagation();
		}
	}
}