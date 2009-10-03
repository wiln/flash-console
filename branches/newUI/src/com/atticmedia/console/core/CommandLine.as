/*
* 
* Copyright (c) 2008-2009 Lu Aye Oo
* 
* @author 		Lu Aye Oo
* 
* http://code.google.com/p/flash-console/
* 
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
*/
package com.atticmedia.console.core {
	import com.atticmedia.console.Console;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;		

	public class CommandLine extends EventDispatcher {

		private var _saved:WeakObject;
		
		private var _returned:WeakRef;
		private var _returned2:WeakRef;
		private var _lastMapBase:WeakRef;
		private var _reserved:Array;
		
		private var _master:Console;
		
		public var useStrong:Boolean;

		public function CommandLine(m:Console) {
			_master = m;
			_saved = new WeakObject();
			_returned = new WeakRef(m);
			_saved.set("C", m);
			_reserved = new Array("base", "C");
		}
		public function set base(obj:Object):void {
			if (base) {
				report("Set new commandLine base from "+base+ " to "+ obj, 10);
			}else{
				_returned = new WeakRef(obj, useStrong);
			}
			_saved.set("base", obj, useStrong);
		}
		public function get base():Object {
			return _saved.get("base");
		}
		public function destory():void {
			_saved = null;
			_master = null;
			_reserved = null;
		}
		public function store(n:String, obj:Object, strong:Boolean = false):String {
			n = n.replace(/[^\w]*/g, "");
			if(_reserved.indexOf(n)>=0){
				report("ERROR: The name ["+n+"] is reserved",10);
				return null;
			}else{
				// if it is a function it needs to be strong reference atm, 
				// otherwise it fails if the function passed is from a dynamic class/instance
				_saved.set(n, obj, strong?true:(obj is Function?true:useStrong));
			}
			return n;
		}
		public function run(str:String):Object {
			report("&gt; "+str, -1);
			var returned:Object;
			var line:Array = str.split(" ");
			if(line[0].charAt(0)=="/"){
				if (line[0] == "/help") {
					printHelp();
				} else if (line[0] == "/remap") {
					// this is a special case... no user will be able to do this command
					line.shift();
					reMap(line.join(""));
				} else if (line[0] == "/strong") {
					if(line[1] == "true"){
						useStrong = true;
						report("Now using STRONG referencing.", 10);
					}else if (line[1] == "false"){
						useStrong = false;
						report("Now using WEAK referencing.", 10);
					}else if(useStrong){
						report("Using STRONG referencing. '/strong false' to use weak", -2);
					}else{
						report("Using WEAK referencing. '/strong true' to use strong", -2);
					}
				} else if (line[0] == "/save") {
					if (_returned.reference) {
						if(!line[1]){
							report("ERROR: Give a name to save.",10);
						}else if(_reserved.indexOf(line[1])>=0){
							report("ERROR: The name ["+line[1]+ "] is reserved",10);
						}else{
							_saved.set(line[1], _returned.reference,useStrong);
							report("SAVED "+getQualifiedClassName(_returned.reference) + " at "+ line[1]);
						}
					} else {
						report("Nothing to save", 10);
					}
				} else if (line[0] == "/string") {
					if(line.length>1){
						var savestring:String = line.slice(1).join(" ");
						report("String with "+savestring.length+" chars stored. Use /save <i>(name)</i> to save.", -2);
						_returned = new WeakRef(savestring, useStrong);
					}
				} else if (line[0] == "/saved") {
					report("Saved vars: ", -1);
					var sii:uint = 0;
					var sii2:uint = 0;
					for(var X:String in _saved){
						var sao:* = _saved[X];
						sii++;
						if(sao==null) sii2++;
						report("<b>$"+X+"</b> = "+(sao==null?"null":getQualifiedClassName(sao)), -2);
					}
					report("Found "+sii+" item(s), "+sii2+" empty (or garbage collected).", -1);
				} else if (line[0] == "/filter") {
					_master.filterText = str.substring(8);
				} else if (line[0] == "/inspect" || line[0] == "/inspectfull") {
					if (_returned.reference) {
						var viewAll:Boolean = (line[0] == "/inspectfull")? true: false;
						report(inspect(_returned.reference,viewAll), 5);
					} else {
						report("Empty", 10);
					}
				} else if (line[0] == "/map") {
					if (_returned.reference) {
						map(_returned.reference as DisplayObjectContainer);
					} else {
						report("Empty", 10);
					}
				} else if (line[0] == "/base" || line[0] == "//") {
					var o:Object = line[0] == "//"?(_returned2?_returned2.reference:null):base;
					_returned2 = new WeakRef(_returned.reference, useStrong);
					_returned = new WeakRef(o, useStrong);
					
					report("+ Returned "+ getQualifiedClassName(o) +": "+o,10);
				} else{
					report("Undefined commandLine syntex <b>/help</b> for info.",10);
				}
			
			}else {
				
				try {
					
					// Get objects and values before operation, such as (, ), =
					var names:Array = new Array();
					var values:Array = new Array();
					line = str.split(/( |=|;)/);
					var lineLen:int = line.length;
					for (var i:int = 0;i<lineLen;i++){
						var strPart:String = line[i];
						if(!strPart || strPart==" " || strPart=="" || strPart==";"){
							// ignore
						}else if(strPart=="="){
							names.push(strPart);
							values.push(strPart);
						} else{
							var arr:Array = getPartData(line[i]);
							if(arr == null) return null; // had error and already done stack trace
							names.push(arr[0]);
							values.push(arr[1]);
						}
					}
					
					// APPLY operation
					for(i = 0;i<names.length;i++){
						strPart = names[i];
						if(strPart == "="){
							var tarValArr:Array = values[i-1];
							var tarNameArr:Array = names[i-1];
							var srcValueArr:Object = values[i+1];
							
							tarValArr[1][tarNameArr[0]] = srcValueArr[0];
							i++;
							report("SET "+getQualifiedClassName(tarValArr[1])+"."+tarNameArr[0]+" = "+srcValueArr[0], 10);
							returned = null;
						}else{
							returned = values[i][0];
						}
					}
					
					if (returned == null) {
						report("Ran successfully.",1);
					}else{
						var newb:Boolean = false;
						if(typeof(returned) == "object" && !(returned is Array) && !(returned is Date)){
							newb = true;
							_returned2 = new WeakRef(_returned.reference, useStrong);
							_returned = new WeakRef(returned, useStrong);
						}
						report((newb?"+ ":"")+"Returned "+ getQualifiedClassName(returned) +": "+returned,10);
					}
				}catch (e:Error) {
					reportStackTrace(e.getStackTrace());
				}
			}
			return returned;
		}
		private function reportStackTrace(str:String):void{
			var lines:Array = str.split(/\n\s*/);
			var p:int = 10;
			var block:String = "";
			for each(var line:String in lines){
				block += "<p"+p+">&gt;&nbsp;"+line.replace(/\s/, "&nbsp;")+"</p"+p+"><br/>";
				if(p>6) p--;
			}
			report(block, 9);
			
		}
		private function getPartData(strPart:String):Array{
			try{
				var base:Object = _returned.reference;
				var partNames:Array = new Array();
				var partValues:Array = new Array();
				
				if(strPart.charAt(0)=="*"){
					partNames.push(strPart.substring(1));
					partValues.push(getDefinitionByName(strPart.substring(1)));
				}else if(isTypeable(strPart)){
					partNames.push(strPart);
					partValues.push(reType(strPart));
				}else{
					var dotParts:Array = strPart.split(/(\.|\(|\)|\,)/);
					var dotLen:int = dotParts.length;
							
					var obj:Object = null;
					
					for(var j:int = 0;j<dotLen;j++){
						var dotPart:String = dotParts[j];
						if(dotPart.charAt(0)=="."){
							dotPart = null;
						}else if(dotPart.charAt(0)=="("){
							var funArr:Array = new Array();
							var endIndex:int = dotParts.indexOf(")", j);
							
							for(var jj:int = (j+1);jj<endIndex;jj++){
								if(dotParts[jj] && dotParts[jj] != ","){
									var data:Array = getPartData(dotParts[jj]);
									if(data == null) return null; // had error and already done stack trace
									funArr.push(data[1][0]);
								}
							}
							obj = (obj as Function).apply(base,funArr);
							j = endIndex+1;
						}else if(dotPart.charAt(0)==","){
							dotPart = null;
						}else if(dotPart.charAt(0)==")"){
							dotPart = null;
						}else if(dotPart.charAt(0)=="$"){
							obj = _saved.get(dotPart.substring(1));
						}else if(dotLen == 1 && !base.hasOwnProperty(dotPart)){
							// this could be a string without '...'
							partNames.unshift(dotPart);
							partValues.unshift(dotPart);
							report("Assumed "+dotPart+" is a String as "+getQualifiedClassName(base)+" do not have this property.", 7);
							break;
						}else if(!obj){
							partNames.unshift(base);
							partValues.unshift(base);
							obj = base[dotPart];
						}else{
							obj = obj[dotPart];
						}
						if(dotPart){
							partNames.unshift(dotPart);
							partValues.unshift(obj);
						}
					}
				}
				if(partNames.length>0){
					return [partNames,partValues];
				}
			}catch(e:Error){
				reportStackTrace(e.getStackTrace());
				return null;
			}
			return [strPart,strPart];
		}
		private function isTypeable(str:String):Boolean{
			if (str == "true" || str == "false" || str == "this" || str == "null" || str == "NaN" || !isNaN(Number(str))) {
				return true;
			}
			if(str.charAt(0) == "'" && str.charAt(str.length-1) == "'"){
				return true;
			}
			return false;
		}
		private function reType(str:String):Object{
			if (str == "true") {
				return true;
			}else if (str == "false") {
				return false;
			}else if (str == "this") {
				return _returned.reference;
			}else if (!isNaN(Number(str))) {
				return Number(str);
			}else if (str == "null") {
				return null;
			}else if (str == "NaN") {
				return NaN;
			}else if(str.charAt(0) == "'" && str.charAt(str.length-1) == "'"){
				return str.substring(1,(str.length-1));
			}
			return str;
		}
		public function inspect(obj:Object, viewAll:Boolean= true):String {
			var typeStr:String = getQualifiedClassName(obj);
			var str:String = "<font color=\"#FF6600\"><b>"+obj+" => "+typeStr+"</b></font><br>";
			var suptypeStr:String = getQualifiedSuperclassName(obj);
			str += "<font color=\"#FF6600\">"+suptypeStr+"</font><br>";

			if ( typeof(obj) == "object") {
				var V:XML = describeType(obj);
				str += "<font color=\"#FF0000\"><b>Methods:</b></font> ";
				var nodes:XMLList = V..method;
				for each (var method:XML in nodes) {
					if ( typeStr == method.@declaredBy || viewAll) {
						str += "<b>"+method.@name+"</b>(<i>"+method.children().length()+"</i>):"+method.@returnType+"; ";
					}
				}
				str += "<br><font color=\"#FF0000\"><b>Accessors:</b></font> ";
				nodes = V..accessor;
				var s:String;
				for each (var accessor:XML  in nodes) {
					if ( typeStr == accessor.@declaredBy || viewAll) {
						s = (accessor.@access=="readonly") ? "<i>"+accessor.@name+"</i>" : accessor.@name;
						if(viewAll){
							try {
								str += "<br><b>"+s+"</b>="+ obj[accessor.@name];
							}catch (e:Error){
								str += "<br><b>"+s+"</b>; ";
							}
						}else{
							str += s+"; ";
						}
					}
				}
				str += "<br><font color=\"#FF0000\"><b>Variables:</b></font> ";
				nodes = V..variable;
				for each (var variable:XML in nodes) {
					s = variable.@name+"("+variable.@type+")";
					if(viewAll){
						try {
							str += "<br><b>"+s+"</b>="+ obj[variable.@name];
						}catch (e:Error){
							str += "<br><b>"+s+"</b>; ";
						}
					}else{
						str += s+"; ";
					}
				}
				var vals:String = "";
				for (var X:String in obj) {
					vals += X +"="+obj[X]+"; ";
				}
				if (vals) {
					str += "<br><font color=\"#FF0000\"><b>Values:</b></font> ";
					str += vals;
				}
				if (obj is DisplayObjectContainer) {
					var mc:DisplayObjectContainer = obj as DisplayObjectContainer;
					str += "<br><font color=\"#FF0000\"><b>Children:</b></font> ";
					var clen:int = mc.numChildren;
					for (var ci:int = 0; ci<clen; ci++) {
						var child:DisplayObject = mc.getChildAt(ci);
						str += "<b>"+child.name+"</b>:("+ci+")"+getQualifiedClassName(child)+"; ";
					}
					var theParent:DisplayObjectContainer = mc.parent;
					if (theParent) {
						str += "<br><font color=\"#FF0000\"><b>Parents:</b></font> ("+theParent.getChildIndex(mc)+"), ";
						while (theParent) {
							var pr:DisplayObjectContainer = theParent;
							theParent = theParent.parent;
							str += "<b>"+pr.name+"</b>:("+(theParent?theParent.getChildIndex(pr):"")+")"+getQualifiedClassName(pr)+"; ";
						}
					}
				}
			} else {
				str += String(obj);
			}
			return str;
		}
		public function map(base:DisplayObjectContainer):void{
			if(!base){
				report("It is not a DisplayObjectContainer", 10);
				return;
			}
			_lastMapBase = new WeakRef(base,useStrong);
			
			var list:Array = new Array();
			var index:int = 0;
			list.push(base);
			while(index<list.length){
				var mcDO:DisplayObject = list[index];
				if(mcDO is DisplayObjectContainer){
					var mc:DisplayObjectContainer = mcDO as DisplayObjectContainer;
					var numC:int = mc.numChildren;
					for(var i:int = 0;i<numC;i++){
						var child:DisplayObject = mc.getChildAt(i);
						list.splice((index+i+1),0,child);
					}
				}
				index++;
			}
			
			var steps:int = 0;
			var lastmcDO:DisplayObject = null;
			var indexes:Array = new Array();
			for (var X:String in list){
				mcDO = list[X];
				if(lastmcDO){
					if(lastmcDO is DisplayObjectContainer && (lastmcDO as DisplayObjectContainer).contains(mcDO)){
						steps++;
						//indexes.push((lastmcDO as DisplayObjectContainer).getChildIndex(mcDO));
						indexes.push(mcDO.name);
					}else{
						while(lastmcDO){
							lastmcDO = lastmcDO.parent;
							if(lastmcDO is DisplayObjectContainer){
								if(steps>0){
									indexes.pop();
									steps--;
								}
								if((lastmcDO as DisplayObjectContainer).contains(mcDO)){
									steps++;
									indexes.push(mcDO.name);
									break;
								}
							}
						}
					}
				}
				var str:String = "";
				for(i=0;i<steps;i++){
					str += (i==steps-1)?" ∟ ":" - ";
				}
				var n:String = "<a href='event:clip_"+indexes.join("|")+"'>"+mcDO.name+"</a>";
				if(mcDO is DisplayObjectContainer){
					n = "<b>"+n+"</b>";
				}else{
					n = "<i>"+n+"</i>";
				}
				str += n+" ("+getQualifiedClassName(mcDO)+")";
				report(str,mcDO is DisplayObjectContainer?5:2);
				lastmcDO = mcDO;
			}
			
			report(base.name+":"+getQualifiedClassName(base)+" has "+list.length+" children/sub-children.", 10);
			report("Click on the name to return a reference to the child clip. <br/>Note that clip references will be broken when display list is changed",-2);
		}
		public function reMap(path:String, mc:DisplayObjectContainer = null):void{
			if(!mc){
				mc = _lastMapBase?(_lastMapBase.reference as DisplayObjectContainer):null;
			}
			var pathArr:Array = path.split("|");
			var child:DisplayObject = mc as DisplayObject;
			try{
				if(path.length>0){
					for each(var ind:String in pathArr){
						child = mc.getChildByName(ind);
						if(child is DisplayObjectContainer){
							//mc = mc.getChildAt(ind) as DisplayObjectContainer;
							mc = child as DisplayObjectContainer;;
						}else{
							// assume it reached to end since there can no longer be a child
							break;
						}
					}
				}
				_returned = new WeakRef(child, useStrong);
				report("+ Returned "+ child.name +": "+getQualifiedClassName(child),10);
			} catch (e:Error) {
				report("Problem getting the clip reference. Display list must have changed since last map request",10);
				reportStackTrace(e.getStackTrace());
			}
		}
		private function printHelp():void {
			report("____Command Line Help___",10);
			report("Gives you limited ability to read/write/execute properties and methods of anything in stage or to static classes",0);
			report("__Example: ",10);
			report("root.mc => <b>root.mc</b>",5);
			report("(save mc's reference) => <b>/save mc</b>",5);
			report("(load mc's reference) => <b>$mc</b>",5);
			report("root.mc.myProperty => <b>$mc.myProperty</b>",5);
			report("root.mc.myProperty = \"newProperty\" => <b>$mc.myProperty = 'newProperty'</b>",5);
			report("(view info) => <b>/inspect</b>",5);
			report("(view all info) => <b>/inspectfull</b>",5);
			report("(see display map) => <b>/map</b>",5);
			report("__Use * to access static classes",10);
			report("com.atticmedia.console.C => <b>*com.atticmedia.console.C</b>",5);
			report("(save reference) => <b>/save c</b>",5);
			report("com.atticmedia.console.C.add('test',10) => <b>$C.add('test',10)</b>",5);
			report("Strings can not have spaces...",7);
			report("__Filtering:",10);
			report("/filter &lt;text you want to filter&gt;",5);
			report("This will create a new channel called filtered with all matching lines",5);
			report("__Other useful examples:",10);
			report("<b>stage.width</b>",5);
			report("<b>stage.scaleMode = noScale</b>",5);
			report("<b>stage.frameRate = 12</b>",5);
			report("__________",10);
		}
		public function report(obj:*,priority:Number = 0):void{
			_master.report(obj, priority);
		}
	}
}