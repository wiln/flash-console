package com.atticmedia.console.panels {
	import com.atticmedia.console.Console;	
	
	import flash.events.TextEvent;	
	import flash.text.TextFieldType;	
	import flash.text.TextField;	
	import flash.text.TextFormat;	
	import flash.geom.Rectangle;	
	import flash.display.Shape;	
	import flash.display.Sprite;
	
	/**
	 * @author LuAye
	 */
	public class MainPanel extends AbstractPanel {
		
		private var _traceField:TextField;
		private var _menuField:TextField;
		private var _commandField:TextField;
		private var _commandBackground:Shape;
		private var _txtFormat:TextFormat;
		private var _bottomLine:Shape;
		
		
		private var _isMinimised:Boolean;
		private var _master:Console;
		
		
		public function MainPanel(master:Console) {
			_master = master;
			name = "mainPanel";
			minimumWidth = 50;
			minimumHeight = 18;
			
			var format:TextFormat = new TextFormat();
            format.font = "Arial";
            format.size = 11;
			_traceField = new TextField();
			_traceField.name = "traceField";
			_traceField.wordWrap = true;
			_traceField.background  = false;
			_traceField.multiline = true;
			_traceField.defaultTextFormat = format;
			_traceField.y = 12;
			addChild(_traceField);
			//
			_txtFormat = new TextFormat();
            _txtFormat.font = "Arial";
            _txtFormat.size = 12;
			_menuField = new TextField();
			_menuField.name = "menuField";
			_menuField.defaultTextFormat = _txtFormat;
			_menuField.height = 18;
			_menuField.y = -2;
			addChild(_menuField);
			//
			_commandBackground = new Shape();
			_commandBackground.name = "commandBackground";
			_commandBackground.graphics.beginFill(0xFFFFFF,0.1);
			_commandBackground.graphics.drawRoundRect(0, 0, 100, 18,12,12);
			_commandBackground.scale9Grid = new Rectangle(9, 9, 80, 1);
			//_commandBackground.visible = false;
			addChild(_commandBackground);
			//
			_commandField = new TextField();
			_commandField.name = "commandField";
			_commandField.type  = TextFieldType.INPUT;
			_commandField.height = 18;
			//_commandField.addEventListener(KeyboardEvent.KEY_DOWN, commandKeyDown, false, 0, true);
			//_commandField.addEventListener(KeyboardEvent.KEY_UP, commandKeyUp, false, 0, true);
			//_commandField.visible = false;
			addChild(_commandField);
			//
			_bottomLine = new Shape();
			_bottomLine.name = "blinkLine";
			_bottomLine.alpha = 0.2;
			addChild(_bottomLine);
			//
			init(420,100,true);
			registerDragger(_menuField);
			updateMenu();
			//
			addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
			//
			//
			
			_traceField.htmlText = "Happy bug fixing!<br/>Hows the new Console so far?";
		}
		override public function set width(n:Number):void{
			super.width = n;
			_traceField.width = n;
			_menuField.width = n;
			_commandField.width = n-10;
			_commandBackground.width = n;
			
			_bottomLine.graphics.clear();
			_bottomLine.graphics.lineStyle(1, 0xFF0000);
			_bottomLine.graphics.moveTo(10, -1);
			_bottomLine.graphics.lineTo(n-10, -1);
		}
		override public function set height(n:Number):void{
			super.height = n;
			var minimize:Boolean = false;
			if(n<(_commandField.visible?42:24)){
				minimize = true;
			}
			if(_isMinimised != minimize){
				registerDragger(_menuField, minimize);
				registerDragger(_traceField, !minimize);
				_isMinimised = minimize;
			}
			_menuField.visible = !minimize;
			_traceField.y = minimize?0:12;
			_traceField.height = n-(_commandField.visible?18:0)-(minimize?0:12);
			var cmdy:Number = n-18;
			_commandField.y = cmdy;
			_commandBackground.y = cmdy;
			_bottomLine.y = _commandField.visible?cmdy:n;
			_traceField.scrollV = _traceField.maxScrollV;
		}
		//
		//
		//
		private function updateMenu():void{
			var str:String = "<p align=\"right\"><font color=\"#DDDDDD\">";
			str += "<font color=\"#FF8800\">[";
			//if(_fps.running){
			//	_menuText += "<a href=\"event:resetFPS\">R</a> ";
			//}
			str += "<a href=\"event:fps\">F</a> <a href=\"event:memory\">M</a> <a href=\"event:gc\">G</a> ";
			str += doBold("<a href=\"event:command\">CL</a>", commandLine);
			//_menuText += (_ruler?"<b>":"")+"<a href=\"event:ruler\">RL</a> "+(_ruler?"</b>":"");
			//_menuText += (_roller?"<b>":"")+"<a href=\"event:roller\">Ro</a> "+(_roller?"</b>":"");
			//_menuText += "<a href=\"event:clear\">C</a> <a href=\"event:trace\">T</a> <a href=\"event:priority\">P"+_priority+"</a> <a href=\"event:alpha\">A</a> <a href=\"event:pause\">P</a> <a href=\"event:help\">H</a> <a href=\"event:close\">X</a>] </font>";
			str += "]</font> ";
			str += "<font color=\"#77D077\"><b><a href=\"event:menu\">@</a></b></font>";
			if(_traceField.scrollV > 1){
				str += " <a href=\"event:scrollUp\">^</a>";
			}else{
				str += " -";
			}
			if(_traceField.scrollV< _traceField.maxScrollV){
				str += " <a href=\"event:scrollDown\">v</a>";
			}else{
				str += " -";
			}
			str += "</p>";
			_menuField.htmlText = str;
			_menuField.setTextFormat(_txtFormat);
			_menuField.scrollH = _menuField.maxScrollH;
		}
		private function doBold(str:String, b:Boolean):String{
			if(b) return "<b>"+str+"</b>";
			return str;
		}
		private function linkHandler(e:TextEvent):void{
			stopDrag();
			if(e.text == "scrollUp"){
				_traceField.scrollV -= 3;
			}else if(e.text == "scrollDown"){
				_traceField.scrollV += 3;
			}else if(e.text == "close"){
				visible = false;
			}else if(e.text == "command"){
				commandLine = !commandLine;
			}
			e.stopPropagation();
		}
		//
		// COMMAND LINE
		//
		public function set commandLine (b:Boolean):void{
			if(b){
				_commandField.visible = true;
				_commandBackground.visible = true;
			}else{
				_commandField.visible = false;
				_commandBackground.visible = false;
			}
			this.height = height;
			updateMenu();
		}
		public function get commandLine ():Boolean{
			return _commandField.visible;
		}
	}
}
