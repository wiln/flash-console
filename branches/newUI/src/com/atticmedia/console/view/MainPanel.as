package com.atticmedia.console.view {
	import com.atticmedia.console.core.LogLineVO;	
	import com.atticmedia.console.Console;
	import com.atticmedia.console.events.TextFieldRollOver;
	
	import flash.display.Shape;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;		

	/**
	 * @author LuAye
	 */
	public class MainPanel extends AbstractPanel {
		
		private static const CHANNELS_IN_MENU:int = 5;
		
		private static const _ToolTips:Object = {
				fps:"Frames Per Second",
				mm:"Memory Monitor",
				roller:"Display Roller::Map the display list under your mouse",
				ruler:"Screen Ruler::Measure the distance and angle between two points on screen.",
				command:"Command Line",
				clear:"Clear log",
				trace:"Trace",
				pause:"Pause logging",
				resume:"Resume logging",
				close:"Close",
				viewall:"View all channels"
		};
		
		private var _traceField:TextField;
		private var _menuField:TextField;
		private var _commandField:TextField;
		private var _commandBackground:Shape;
		private var _bottomLine:Shape;
		private var _isMinimised:Boolean;
		private var _priority:int;
		
		private var _channels:Array;
		private var _lines:Array;
		
		private var _needUpdateMenu:Boolean;
		
		public function MainPanel(m:Console, lines:Array, channels:Array) {
			super(m);
			_channels = channels;
			_lines = lines;
			name = Console.PANEL_MAIN;
			minimumWidth = 50;
			minimumHeight = 18;
			
			_traceField = new TextField();
			_traceField.name = "traceField";
			_traceField.wordWrap = true;
			_traceField.background  = false;
			_traceField.multiline = true;
			_traceField.styleSheet = style.tracecss;
			_traceField.y = 12;
			addChild(_traceField);
			//
			_menuField = new TextField();
			_menuField.name = "menuField";
			_menuField.styleSheet = style.css;
			_menuField.height = 18;
			_menuField.y = -2;
			registerRollOverTextField(_menuField);
			_menuField.addEventListener(TextFieldRollOver.ROLLOVER, onMenuRollOver, false, 0, true);
			addChild(_menuField);
			//
			_commandBackground = new Shape();
			_commandBackground.name = "commandBackground";
			_commandBackground.graphics.beginFill(style.panelBackgroundColor, 0.1);
			_commandBackground.graphics.drawRoundRect(0, 0, 100, 18,12,12);
			_commandBackground.scale9Grid = new Rectangle(9, 9, 80, 1);
			addChild(_commandBackground);
			//
			_commandField = new TextField();
			_commandField.name = "commandField";
			_commandField.type  = TextFieldType.INPUT;
			_commandField.height = 18;
			_commandField.addEventListener(KeyboardEvent.KEY_DOWN, commandKeyDown, false, 0, true);
			_commandField.addEventListener(KeyboardEvent.KEY_UP, commandKeyUp, false, 0, true);
			_commandField.defaultTextFormat = style.textFormat;
			addChild(_commandField);
			//
			_bottomLine = new Shape();
			_bottomLine.name = "blinkLine";
			_bottomLine.alpha = 0.2;
			addChild(_bottomLine);
			//
			init(420,100,true);
			registerDragger(_menuField);
			//
			addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
			//
			//
			_traceField.htmlText = "<p><l1>Happy bug fixing!</l1></p><p><p0>Hows the new Console so far?</p0></p>";
		}
		public function update(changed:Boolean):void{
			if(visible){
				if(_bottomLine.alpha>0){
					_bottomLine.alpha -= 0.25;
				}
				if(changed){
					_bottomLine.alpha = 1;
					_needUpdateMenu = true;
					refresh();
				}
				if(_needUpdateMenu){
					_needUpdateMenu = false;
					_updateMenu();
				}
			}
		}
		public function refresh():void{
			var str:String = "";
			for each (var line:LogLineVO in _lines ){
				if((master.viewingChannels.indexOf(Console.FILTERED_CHANNEL)>=0 || line.c!=Console.FILTERED_CHANNEL) && ((master.cl.searchTerm && line.c != Console.CONSOLE_CHANNEL && line.c != Console.FILTERED_CHANNEL && line.text.toLowerCase().indexOf(master.cl.searchTerm.toLowerCase())>=0 ) || (master.viewingChannels.indexOf(line.c)>=0 || master.viewingChannels.indexOf(Console.GLOBAL_CHANNEL)>=0) && (line.p >= _priority || _priority == 0) )){
					str += makeLine(line);
				}
			}
			var sd:Boolean = _traceField.scrollV == _traceField.maxScrollV;
			_traceField.htmlText = str;
			if(sd){
				_traceField.scrollV = _traceField.maxScrollV;
			}
		}
		private function makeLine(line:LogLineVO):String{
			var str:String = "";
			var txt:String = line.text;
			if(master.prefixChannelNames && (master.viewingChannels.indexOf(Console.GLOBAL_CHANNEL)>=0 || master.viewingChannels.length>1) && line.c != master.defaultChannel){
				txt = "[<a href=\"event:channel_"+line.c+"\">"+line.c+"</a>] "+txt;
			}
			var ptag:String = "p"+line.p;
			str += "<p><"+ptag+">" + txt + "</"+ptag+"></p>";
			return str;
		}
		override public function set width(n:Number):void{
			super.width = n;
			_traceField.width = n;
			_menuField.width = n;
			_commandField.width = n-10;
			_commandBackground.width = n;
			
			_bottomLine.graphics.clear();
			_bottomLine.graphics.lineStyle(1, style.bottomLineColor);
			_bottomLine.graphics.moveTo(10, -1);
			_bottomLine.graphics.lineTo(n-10, -1);
			updateMenu();
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
			updateMenu();
		}
		//
		//
		//
		public function updateMenu(instant:Boolean = false):void{
			if(instant){
				_updateMenu();
			}else{
				_needUpdateMenu = true;
			}
		}
		private function _updateMenu():void{
			var str:String = "<r><w>";
			if(!master.channelsPanel){
				for(var ci:int = 0; (ci<_channels.length && ci<= CHANNELS_IN_MENU);  ci++){
					var channel:String = _channels[ci];
					var channelTxt:String = (master.viewingChannels.indexOf(channel)>=0) ? "<ch><b>"+channel+"</b></ch>" : channel;
					channelTxt = channel==master.defaultChannel? "<i>"+channelTxt+"</i>" : channelTxt;
					str += "<a href=\"event:channel_"+channel+"\">["+channelTxt+"]</a> ";
				}
				str += "<ch><a href=\"event:channels\"><b>"+(_channels.length>CHANNELS_IN_MENU?"...":"")+"</b>^ </a></ch> ";
			}
			str += "<menu>[<b>";
			str += doActive("<a href=\"event:fps\">F</a>", master.fpsMonitor>0);
			str += doActive(" <a href=\"event:mm\">M</a>", master.memoryMonitor>0);
			str += doActive(" <a href=\"event:roller\">Ro</a>", master.displayRoller);
			str += doActive(" <a href=\"event:command\">CL</a>", commandLine);
			str += doActive(" <a href=\"event:ruler\">RL</a>", master.panels.rulerActive);
			str += " ¦</b> <a href=\"event:clear\">C</a> <a href=\"event:trace\">T</a> <a href=\"event:priority\">P"+_priority+"</a> <a href=\"event:pause\">P</a> <a href=\"event:close\">X</a>";
			str += "]</menu> ";
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
			str += "</w></r>";
			_menuField.htmlText = str;
			_menuField.scrollH = _menuField.maxScrollH;
		}
		private function doActive(str:String, b:Boolean):String{
			if(b) return "<y>"+str+"</y>";
			return str;
		}
		private function onMenuRollOver(e:TextFieldRollOver):void{
			var txt:String = e.url?e.url.replace("event:",""):"";
			if(txt == "channel_"+Console.GLOBAL_CHANNEL){
				txt = _ToolTips["viewall"];
				// TODO: also have tip on current channel and default channel
			}if(txt == "pause"){
				if(master.paused)
					txt = _ToolTips["resume"];
				else
					txt = _ToolTips["pause"];
			}else{
				txt = _ToolTips[txt];
			}
			master.panels.tooltip(txt, this);
		}
		private function linkHandler(e:TextEvent):void{
			stopDrag();
			if(e.text == "scrollUp"){
				_traceField.scrollV -= 3;
			}else if(e.text == "scrollDown"){
				_traceField.scrollV += 3;
			}else if(e.text == "pause"){
				if(master.paused){
					master.paused = false;
					master.panels.tooltip(_ToolTips["pause"], this);
				}else{
					master.paused = true;
					master.panels.tooltip(_ToolTips["resume"], this);
				}
			}else if(e.text == "trace"){
				master.tracing = !master.tracing;
				if(master.tracing){
					report("Tracing turned [<b>On</b>]",-1);
				}else{
					report("Tracing turned [<b>Off</b>]",-1);
				}
			}else if(e.text == "close"){
				master.panels.tooltip();
				visible = false;
			}else if(e.text == "channels"){
				master.channelsPanel = !master.channelsPanel;
			}else if(e.text == "fps"){
				master.fpsMonitor = master.fpsMonitor>0?0:1;
			}else if(e.text == "priority"){
				if(_priority<10){
					_priority++;
				}else{
					_priority = 0;
				}
				refresh();
				updateMenu();
			}else if(e.text == "mm"){
				master.memoryMonitor = master.memoryMonitor>0?0:1;
			}else if(e.text == "roller"){
				master.displayRoller = !master.displayRoller;
			}else if(e.text == "ruler"){
				master.panels.tooltip();
				master.panels.startRuler();
			}else if(e.text == "command"){
				commandLine = !commandLine;
			}else if(e.text == "clear"){
				master.clear();
			}
			e.stopPropagation();
		}
		//
		// COMMAND LINE
		//
		private function commandKeyDown(e:KeyboardEvent):void{
			
		}
		private function commandKeyUp(e:KeyboardEvent):void{
			
		}
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
