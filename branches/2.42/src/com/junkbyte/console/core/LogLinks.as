/*
* 
* Copyright (c) 2008-2010 Lu Aye Oo
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

package com.junkbyte.console.core 
{
	import flash.utils.ByteArray;
	import com.junkbyte.console.utils.ShortClassName;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import com.junkbyte.console.vos.WeakObject;
	import com.junkbyte.console.Console;

	public class LogLinks 
	{
		private static const MAX_VAL_LENGTH:uint = 100;
		
		private var _master:Console;
		private var _linksMap:WeakObject;
		private var _linksRev:Dictionary;
		private var _linkIndex:uint = 1;
		
		private var _dofull:Boolean;
		private var _current:*;// current will be kept as hard reference so that it stays...
		
		private var _history:Array;
		private var _hisIndex:uint;
		
		public function LogLinks(m:Console) {
			_master = m;
			
			_linksMap = new WeakObject();
			_linksRev = new Dictionary(true);
		}
		public function setLogRef(o:*):uint{
			if(!_master.config.useObjectLinking) return 0;
			var ind:uint = _linksRev[o];
			if(!ind){
				ind = _linkIndex;
				_linksMap[ind] = o;
				_linksRev[o] = ind;
				_linkIndex++;
			}
			return ind;
		}
		public function getRefId(o:*):uint{
			return _linksRev[o];
		}
		public function getRefById(ind:uint):*{
			return _linksMap[ind];
		}
		public function makeString(o:*, prop:String = null, html:Boolean = false, maxlen:int = -1):String{
			var txt:String;
			try{
				var v:* = prop?o[prop]:o;
			}catch(err:Error){
				return "<p0><i>"+err.toString()+"</i></p0>";
			}
			if(v is Error) {
				var err:Error = v as Error;
				// err.getStackTrace() is not supported in non-debugger players...
				var stackstr:String = err.hasOwnProperty("getStackTrace")?err.getStackTrace():err.toString();		
				if(stackstr){
					return stackstr;
				}
				return err.toString();
			}else if(v is XML || v is XMLList){
				return safeString(shortenString(v.toXMLString(), maxlen, o, prop));
			}else if(v is Array || getQualifiedClassName(v).indexOf("__AS3__.vec::Vector.") == 0){
				// note: using getQualifiedClassName for vector for backward compatibility
				// Need to specifically cast to string in array to produce correct results
				// e.g: new Array("str",null,undefined,0).toString() // traces to: str,,,0, SHOULD BE: str,null,undefined,0
				var str:String = "[";
				var len:int = v.length;
				for(var i:int = 0; i < len; i++){
					str += (i?", ":"")+makeString(v[i]);
				}
				return str+"]";
			}else if(v && typeof v == "object") {
				var add:String = "";
				if(v is ByteArray){
					add = " position:"+ByteArray(v).position+" length:"+ByteArray(v).length;
				}
				var ind:uint = setLogRef(o);
				if(ind){
					txt = "{<l><a href='event:ref_"+ind+(prop?("_"+prop):"")+"'>"+ShortClassName(v)+"</a></l>"+add+"}";
				}else{
					txt = "{"+ShortClassName(v)+add+"}";
				}
			}else{
				txt = String(v);
				if(!html){
					return safeString(shortenString(txt, maxlen, o, prop));
				}
			}
			return txt;
		}
		private function shortenString(str:String, maxlen:int, refid:uint, prop:String = null):String{
			if(maxlen>=0 && str.length > maxlen) {
				str = str.substring(0, maxlen);
				if(refid){
					str += "<l><a href='event:ref_"+refid+(prop?("_"+prop):"")+"'> ...</a></l>";
				}else{
					str += " ...";
				}
				return str;
			}
			return str;
		}
		public function makeRefTyped(v:*):String
		{
			if(v && typeof v == "object")
			{
				var ind:uint = setLogRef(v);
				if(ind){
					return "{<l><a href='event:ref_"+ind+"'>"+ShortClassName(v)+"</a></l>}";
				}
			}
			return "{"+ShortClassName(v)+"}";
		}
		private function safeString(str:String):String{
			str = str.replace(/</gm, "&lt;");
	 		return str.replace(new RegExp(">", "gm"), "&gt;");
		}
		private function historyInc(i:int):void{
			_hisIndex+=i;
			var v:* = _history[_hisIndex];
			if(v){
				focus(v, _dofull);
			}
		}
		public function handleRefEvent(str:String):void{
			if(_master.remote){
				_master.remoter.send(Remoting.REF, str);
			}else{
				handleString(str);
			}
		}
		public function handleString(str:String):void{
			if(str == ""){
				exitFocus();
			}else if(str == "refprev"){
				historyInc(-2);
			}else if(str == "reffwd"){
				historyInc(0);
			}else if(str == "refi"){
				_dofull = !_dofull;
				historyInc(-1);
			}else{
				var ind1:int = str.indexOf("_")+1;
				if(ind1>0){
					var id:uint;
					var prop:String = "";
					var ind2:int = str.indexOf("_", ind1);
					if(ind2>0){
						id = uint(str.substring(ind1, ind2));
						prop = str.substring(ind2+1);
					}else{
						id = uint(str.substring(ind1));
					}
					var o:Object = getRefById(id);
					if(prop) o = o[prop];
					if(o){
						if(str.indexOf("refe_")==0){
							_master.explode(o);
						}else{
							focus(o, _dofull);
						}
						return;
					}
				}
				report("Reference no longer exist.", -2);
			}
		}
		public function focus(o:*, full:Boolean = false):void{
			_master.clear(Console.INSPECTING_CHANNEL);
			_master.viewingChannels = [Console.INSPECTING_CHANNEL];
			
			if(!_history) _history = new Array();
			
			_dofull = full;
			inspect(o, _dofull);
			if(_current != o){
				_current = o; // current is kept as hard reference so that it stays...
				if(_history.length <= _hisIndex) _history.push(o);
				else _history[_hisIndex] = o;
				_hisIndex++;
			}
		}
		
		public function exitFocus():void{
			_current = null;
			_dofull = false;
			_history = null;
			_hisIndex = 0;
			if(_master.remote){
				_master.remoter.send(Remoting.REF, "");
			}
			_master.clear(Console.INSPECTING_CHANNEL);
		}
		
		private function report(obj:*, priority:Number = 0, skipSafe:Boolean = true):void{
			_master.report(obj, priority, skipSafe);
		}
		
		
		
		public function inspect(obj:*, viewAll:Boolean= true):void {
			if(!obj){
				report(obj, -2, true);
				return;
			}
			var linkIndex:uint = setLogRef(obj);
			var menuStr:String;
			if(_history){
				menuStr = "<b>[<a href='event:channel_"+_master.config.globalChannel+ "'>Exit</a>]";
				if(_hisIndex>0){
					menuStr += " [<a href='event:refprev'>Previous</a>]";
				}
				if(_history && _hisIndex < _history.length-1){
					menuStr += " [<a href='event:reffwd'>Forward</a>]";
				}
				menuStr += "</b> || [<a href='event:ref_"+linkIndex+"'>refresh</a>]";
				menuStr += "</b> [<a href='event:refe_"+linkIndex+"'>explode</a>]";
				if(_master.config.commandLineAllowed){
					menuStr += " [<a href='event:cl_"+linkIndex+"'>Set scope</a>]";
				}
				
				if(viewAll) menuStr += " [<a href='event:refi'>Hide inherited</a>]";
				else menuStr += " [<a href='event:refi'>Show inherited</a>]";
				report(menuStr, -1, true);
				report("", -1);
			}
			//
			// Class extends... extendsClass
			// Class implements... implementsInterface
			// constant // statics
			// methods
			// accessors
			// varaibles
			// values
			// EVENTS .. metadata name="Event"
			//
			var V:XML = describeType(obj);
			var cls:Object = obj is Class?obj:obj.constructor;
			var clsV:XML = describeType(cls);
			var self:String = V.@name;
			var str:String = "<b>"+self+"</b>";
			var props:Array = [];
			var props2:Array = [];
			var nodes:XMLList;
			if(V.@isDynamic=="true"){
				props.push("dynamic");
			}
			if(V.@isFinal=="true"){
				props.push("final");
			}
			if(V.@isStatic=="true"){
				props.push("static");
			}
			if(props.length > 0){
				str += " <p-1>"+props.join(" | ")+"</p-1>";
			}
			report(str, -2, true);
			//
			// extends...
			//
			props = [];
			nodes = V.extendsClass;
			for each (var extendX:XML in nodes) {
				props.push(makeValue(getDefinitionByName(extendX.@type.toString())));
				if(!viewAll) break;
			}
			if(props.length){
				report("<p10>Extends:</p10> "+props.join("<p-1> &gt; </p-1>"), 5, true);
			}
			//
			// implements...
			//
			props = [];
			nodes = V.implementsInterface;
			for each (var implementX:XML in nodes) {
				props.push(makeValue(getDefinitionByName(implementX.@type.toString())));
			}
			if(props.length){
				report("<p10>Implements:</p10> "+props.join(" "), 5, true);
			}
			report("");
			//
			// events
			// metadata name="Event"
			props = [];
			nodes = V.metadata.(@name == "Event");
			for each (var metadataX:XML in nodes) {
				var mn:XMLList = metadataX.arg;
				var en:String = mn.(@key=="name").@value;
				var et:String = mn.(@key=="type").@value;
				props.push("<a href='event:cl_"+linkIndex+"_dispatchEvent(new "+et+"(\""+en+"\"))'>"+en+"</a><p0>("+et+")</p0>");
			}
			if(props.length){
				report("<p10>Events:</p10> "+props.join("<p-1>; </p-1>")+"<br/>", 5, true);
			}
			//
			// display's parents and direct children
			//
			if (obj is DisplayObject) {
				var disp:DisplayObject = obj as DisplayObject;
				var theParent:DisplayObjectContainer = disp.parent;
				if (theParent) {
					props = ["@"+theParent.getChildIndex(disp)];
					while (theParent) {
						var pr:DisplayObjectContainer = theParent;
						theParent = theParent.parent;
						var indstr:String = theParent?"@"+theParent.getChildIndex(pr):"";
						props.push("<b>"+pr.name+"</b>"+indstr+makeValue(pr));
					}
					if(props.length){
						report("<p10>Parents:</p10> "+props.join("<p-1> -> </p-1>")+"<br/>", 1, true);
					}
				}
			}
			if (obj is DisplayObjectContainer) {
				props = [];
				var cont:DisplayObjectContainer = obj as DisplayObjectContainer;
				var clen:int = cont.numChildren;
				for (var ci:int = 0; ci<clen; ci++) {
					var child:DisplayObject = cont.getChildAt(ci);
					props.push("<b>"+child.name+"</b>@"+ci+makeValue(child));
				}
				if(props.length){
					report("<p10>Children:</p10> "+props.join("<p-1>; </p-1>")+"<br/>", 1, true);
				}
			}
			//
			// constants...
			//
			props = [];
			nodes = clsV..constant;
			for each (var constantX:XML in nodes) {
				str = "<p1> const </p1>"+constantX.@name+"<p0>:"+constantX.@type+" = "+makeValue(cls, constantX.@name)+"</p0>";
				report(str, 3, true);
			}
			if(nodes.length()>0){
				report("", 3, true);
			}
			var inherit:uint = 0;
			var isstatic:Boolean;
			//
			// methods
			//
			props = [];
			props2 = [];
			nodes = clsV..method; // '..' to include from <factory>
			for each (var methodX:XML in nodes) {
				if(viewAll || self==methodX.@declaredBy){
					isstatic = methodX.parent().name()!="factory";
					str = "<p1> "+(isstatic?"static ":"")+"function </p1>";
					var params:Array = [];
					var mparamsList:XMLList = methodX.parameter;
					for each(var paraX:XML in mparamsList){
						params.push(paraX.@optional=="true"?("<i>"+paraX.@type+"</i>"):paraX.@type);
					}
					str += "<a href='event:cl_"+linkIndex+"_"+methodX.@name+"()'>"+methodX.@name+"</a><p1>(<i>"+params.join(",")+"</i>):"+methodX.@returnType+"</p1>";
					report(str, 3, true);
				}else{
					inherit++;
				}
			}
			if(inherit){
				report("   \t + "+inherit+" inherited methods.", 1, true);
			}else if(nodes.length()){
				report("", 3, true);
			}
			//
			// accessors
			//
			inherit = 0;
			props = [];
			props2 = [];
			nodes = clsV..accessor; // '..' to include from <factory>
			for each (var accessorX:XML in nodes) {
				if(viewAll || self==accessorX.@declaredBy){
					isstatic = accessorX.parent().name()!="factory";
					str = "<p1> "+(isstatic?"static ":"");
					var access:String = accessorX.@access;
					if(access == "readonly") str+= "get";
					else if(access == "writeonly") str+= "set";
					else str += "assign";
					str+= "</p1> <a href='event:cl_"+linkIndex+"_"+accessorX.@name+"'>"+accessorX.@name+"</a><p1>:"+accessorX.@type+"</p1>";
					if(access != "writeonly" && (isstatic || !(obj is Class))){
						var t:Object = isstatic?cls:obj;
						str+="<p1> = "+makeValue(t, accessorX.@name)+"</p1>";
					}
					report(str, 3, true);
				}else{
					inherit++;
				}
			}
			if(inherit){
				report("   \t + "+inherit+" inherited accessors.", 1, true);
			}else if(nodes.length()){
				report("", 3, true);
			}
			//
			// variables
			//
			props = [];
			nodes = clsV..variable;
			for each (var variableX:XML in nodes) {
				if(variableX.parent().name()=="factory"){
					str = "<p0> var </p0><a href='event:cl_"+linkIndex+"_"+variableX.@name+" = '>"+variableX.@name+"</a>:<p1>"+variableX.@type+" = "+makeValue(obj, variableX.@name)+"</p1>";
				}else{
					str = "<p0> <i>static var</i></p0><a href='event:cl_"+linkIndex+"_"+variableX.@name+" = '>"+variableX.@name+"</a>:<p1>"+variableX.@type+" = "+makeValue(cls, variableX.@name)+"</p1>";
				}
				props.push(str);
			}
			if(props.length){
				report(props.join("<br/>"), 3, true);
			}
			//
			// dynamic values
			// - It can sometimes fail if we are looking at proxy object which havnt extended nextNameIndex, nextName, etc.
			try{
				props = [];
				for (var X:String in obj) {
					report("<p0> dynamic var </p0><a href='event:cl_"+linkIndex+"_"+X+" = '>"+X+"</a><p1> = "+makeValue(obj, X)+"</p1>", 3, true);
				}
			}catch(e:Error){
				report("Could not get values due to: "+e, 9, true);
			}
			if(obj is String){
				report("");
				report("String", 10);
				report(safeString(obj));
			}else if(obj is XML || obj is XMLList){
				report("");
				report("XMLString", 10);
				report(safeString(obj.toXMLString()));
			}
			if(menuStr){
				report("", -1);
				report(menuStr, -1, true);
			}
		}
		private function makeValue(obj:*, prop:String = null):String{
			return makeString(obj, prop, false, MAX_VAL_LENGTH);
		}
	}
}
