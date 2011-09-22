package com.junkbyte.console.addons.displaymap
{
	import com.junkbyte.console.Console;
	import com.junkbyte.console.core.LogReferences;
	import com.junkbyte.console.view.ConsolePanel;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class DisplayMapPanel extends ConsolePanel
	{
		
		public static const NAME:String = "displayMapPanel";
		
		private var rootDisplay:DisplayObject;
		private var mapIndex:uint;
		private var indexToDisplayMap:Object;
		private var openings:Array;
		
		public function DisplayMapPanel(m:Console)
		{
			super(m);
			name = NAME;
			init(60,100,false);
			txtField = makeTF("mapPrints");
			txtField.multiline = true;
			txtField.autoSize = TextFieldAutoSize.LEFT;
			registerTFRoller(txtField, onMenuRollOver, linkHandler);
			registerDragger(txtField);
			addChild(txtField);
		}
		
		public function start(container:DisplayObject):void
		{
			rootDisplay = container;
			openings = new Array(rootDisplay);
			update();
		}
		
		private function update():void
		{
			mapIndex = 0;
			indexToDisplayMap = new Object();
			
			var string:String = "<p><p3>";
			
			if(rootDisplay == null)
			{
				string += "null";
			}
			else
			{
				string += "<menu> <a href=\"event:close\"><b>X</b></a></menu><br/>";
				
				var rootParent:DisplayObjectContainer = rootDisplay.parent;
				if(rootParent)
				{
					string += makeLink(rootParent, " ^ ", "focus")+makeName(rootParent)+"<br/>";
					string += printChild(rootDisplay, 1);
				}
				else
				{
					string += printChild(rootDisplay, 0);
				}
			}
			
			txtField.htmlText = string+"</p3></p>";
			
			width = txtField.width+4;
			height = txtField.height;
		}
		
		private function printChild(display:DisplayObject, currentStep:uint):String
		{
			if(display is DisplayObjectContainer)
			{
				var string:String;
				var container:DisplayObjectContainer = display as DisplayObjectContainer;
				if(openings.indexOf(display) >= 0)
				{
					string = "<p5>"+generateSteps(display, currentStep)+makeLink(display, "-", "minimize")+makeName(display)+"</p5><br/>";
					string += printChildren(container, currentStep + 1);
				}
				else
				{
					string = "<p4>"+generateSteps(display, currentStep)+makeLink(display, "+", "expand")+makeName(display)+"</p4><br/>";
				}
				return string;
			}
			return "<p3>"+generateSteps(display, currentStep)+makeName(display)+"</p3><br/>";
		}
		
		private function printChildren(container:DisplayObjectContainer, currentStep:uint):String
		{
			var string:String = "";
			var len:uint = container.numChildren;
			for (var i:uint = 0; i<len; i++)
			{
				string += printChild(container.getChildAt(i), currentStep);
			}
			return string;
		}
			
		
		private function generateSteps(display:Object, steps:uint):String
		{
			var str:String = "";
			for(var i:uint=0;i<steps;i++){
				if(i==steps-1)
				{
					if(display is DisplayObjectContainer)
					{
						str += makeLink(display, "<b> ∟ </b>", "focus");
					}
					else
					{
						str += " ∟ ";
					}
				}
				else
				{
					str += " - ";
				}
			}
			return str;
		}
		
		private function onMenuRollOver(e:TextEvent):void{
			var txt:String = e.text?e.text.replace("event:",""):"";
			if(txt == "close"){
				txt = "Close";
			}else if(txt == "cancel"){
				txt = "Cancel assign key";
			}else{
				txt = null;
			}
			console.panels.tooltip(txt, this);
		}
		
		private function makeName(display:Object):String
		{
			return display.name+" ("+LogReferences.ShortClassName(display)+")";
		}
		
		private function makeLink(display:Object, text:String, event:String):String
		{
			mapIndex++;
			indexToDisplayMap[mapIndex] = display;
			return "<a href='event:"+event+"_"+mapIndex+"'>"+text+"</a> ";
		}
		
		private function getDisplay(string:String):DisplayObject
		{
			var split:Array = string.split("_");
			return indexToDisplayMap[split[split.length-1]];
		}
		
		protected function linkHandler(e:TextEvent):void{
			TextField(e.currentTarget).setSelection(0, 0);
			console.panels.tooltip(null);
			if(e.text == "close"){
				close();
			}else if(e.text.indexOf("expand") == 0){
				addToOpening(getDisplay(e.text));
			}else if(e.text.indexOf("minimize") == 0){
				removeFromOpening(getDisplay(e.text));
			}else if(e.text.indexOf("focus") == 0){
				focus(getDisplay(e.text) as DisplayObjectContainer);
			}
			e.stopPropagation();
		}
		
		public function focus(container:DisplayObjectContainer):void
		{
			rootDisplay = container;
			addToOpening(container);
			update();
		}
		
		public function addToOpening(display:DisplayObject):void
		{
			if(openings.indexOf(display) < 0 )
			{
				openings.push(display);
				update();
			}
		}
		
		public function removeFromOpening(display:DisplayObject):void
		{
			var index:int = openings.indexOf(display);
			if(index >= 0)
			{
				openings.splice(index, 1);
				update();
			}
		}
	}
}