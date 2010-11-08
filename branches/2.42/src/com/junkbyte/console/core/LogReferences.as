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
	import com.junkbyte.console.Console;
	import com.junkbyte.console.vos.WeakObject;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class LogReferences 
	{
		private static const MAX_VAL_LENGTH:uint = 100;
		
		public static const INSPECTING_CHANNEL:String = "⌂";
		
		private var _master:Console;
		private var _refMap:WeakObject;
		private var _refRev:Dictionary;
		private var _refIndex:uint = 1;
		
		private var _dofull:Boolean;
		private var _current:*;// current will be kept as hard reference so that it stays...
		
		private var _history:Array;
		private var _hisIndex:uint;
		
		public function LogReferences(m:Console) {
			_master = m;
			
			_refMap = new WeakObject();
			_refRev = new Dictionary(true);
		}
		public function setLogRef(o:*):uint{
			if(!_master.config.useObjectLinking) return 0;
			var ind:uint = _refRev[o];
			if(!ind){
				ind = _refIndex;
				_refMap[ind] = o;
				_refRev[o] = ind;
				_refIndex++;
			}
			return ind;
		}
		public function getRefId(o:*):uint{
			return _refRev[o];
		}
		public function getRefById(ind:uint):*{
			return _refMap[ind];
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
				return shortenString(EscHTML(v.toXMLString()), maxlen, o, prop);
			}else if(v is Array || getQualifiedClassName(v).indexOf("__AS3__.vec::Vector.") == 0){
				// note: using getQualifiedClassName for vector for backward compatibility
				// Need to specifically cast to string in array to produce correct results
				// e.g: new Array("str",null,undefined,0).toString() // traces to: str,,,0, SHOULD BE: str,null,undefined,0
				var str:String = "[";
				var len:int = v.length;
				var hasmaxlen:Boolean = maxlen>=0;
				for(var i:int = 0; i < len; i++){
					var strpart:String = makeString(v[i], null, false, maxlen);
					str += (i?", ":"")+strpart;
					maxlen -= strpart.length;
					if(hasmaxlen && maxlen<=0 && i<len-1){
						str += ", "+genLinkString(o, prop, "...");
						break;
					}
				}
				return str+"]";
			}else if(v && typeof v == "object") {
				var add:String = "";
				if(v is ByteArray){
					add = " position:"+ByteArray(v).position+" length:"+ByteArray(v).length;
				}
				txt = "{"+genLinkString(o, prop, ShortClassName(v))+add+"}";
			}else{
				txt = String(v);
				if(!html){
					return shortenString(EscHTML(txt), maxlen, o, prop);
				}
			}
			return txt;
		}
		private function genLinkString(o:*, prop:String, str:String):String{
			var ind:uint = setLogRef(o);
			if(ind){
				return "<l><a href='event:ref_"+ind+(prop?("_"+prop):"")+"'>"+str+"</a></l>";
			}else{
				return str;
			}
		}
		private function shortenString(str:String, maxlen:int, o:*, prop:String = null):String{
			if(maxlen>=0 && str.length > maxlen) {
				str = str.substring(0, maxlen);
				return str+genLinkString(o, prop, " ...");
			}
			return str;
		}
		public function makeRefTyped(v:*):String
		{
			if(v && typeof v == "object")
			{
				return "{"+genLinkString(v, null, ShortClassName(v))+"}";
			}
			return "{"+ShortClassName(v)+"}";
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
			_master.clear(LogReferences.INSPECTING_CHANNEL);
			_master.viewingChannels = [LogReferences.INSPECTING_CHANNEL];
			
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
			_master.clear(LogReferences.INSPECTING_CHANNEL);
		}
		
		private function report(obj:* = "", priority:Number = 3, skipSafe:Boolean = true):void{
			_master.report(obj, priority, skipSafe);
		}
		
		
		
		public function inspect(obj:*, viewAll:Boolean= true):void {
			if(!obj){
				report(obj, -2, true);
				return;
			}
			var refIndex:uint = setLogRef(obj);
			var menuStr:String;
			if(_history){
				menuStr = "<b>[<a href='event:channel_"+_master.config.globalChannel+ "'>Exit</a>]";
				if(_hisIndex>0){
					menuStr += " [<a href='event:refprev'>Previous</a>]";
				}
				if(_history && _hisIndex < _history.length-1){
					menuStr += " [<a href='event:reffwd'>Forward</a>]";
				}
				menuStr += "</b> || [<a href='event:ref_"+refIndex+"'>refresh</a>]";
				menuStr += "</b> [<a href='event:refe_"+refIndex+"'>explode</a>]";
				if(_master.config.commandLineAllowed){
					menuStr += " [<a href='event:cl_"+refIndex+"'>Set scope</a>]";
				}
				
				if(viewAll) menuStr += " [<a href='event:refi'>Hide inherited</a>]";
				else menuStr += " [<a href='event:refi'>Show inherited</a>]";
				report(menuStr, -1, true);
				report();
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
			nodes = V.extendsClass;
			if(nodes.length()){
				props = [];
				for each (var extendX:XML in nodes) {
					props.push(makeValue(getDefinitionByName(extendX.@type.toString())));
					if(!viewAll) break;
				}
				report("<p10>Extends:</p10> "+props.join(" &gt; "));
			}
			//
			// implements...
			//
			nodes = V.implementsInterface;
			if(nodes.length()){
				props = [];
				for each (var implementX:XML in nodes) {
					props.push(makeValue(getDefinitionByName(implementX.@type.toString())));
				}
				report("<p10>Implements:</p10> "+props.join(", "));
			}
			report();
			//
			// events
			// metadata name="Event"
			props = [];
			nodes = V.metadata.(@name == "Event");
			if(nodes.length()){
				for each (var metadataX:XML in nodes) {
					var mn:XMLList = metadataX.arg;
					var en:String = mn.(@key=="name").@value;
					var et:String = mn.(@key=="type").@value;
					props.push("<a href='event:cl_"+refIndex+"_dispatchEvent(new "+et+"(\""+en+"\"))'>"+en+"</a><p0>("+et+")</p0>");
				}
				report("<p10>Events:</p10> "+props.join("<p-1>; </p-1>"));
				report();
			}
			//
			// display's parents and direct children
			//
			if (obj is DisplayObject) {
				var disp:DisplayObject = obj as DisplayObject;
				var theParent:DisplayObjectContainer = disp.parent;
				if (theParent) {
					props = new Array("@"+theParent.getChildIndex(disp));
					while (theParent) {
						var pr:DisplayObjectContainer = theParent;
						theParent = theParent.parent;
						var indstr:String = theParent?"@"+theParent.getChildIndex(pr):"";
						props.push("<b>"+pr.name+"</b>"+indstr+makeValue(pr));
					}
					report("<p10>Parents:</p10> "+props.join("<p-1> -> </p-1>")+"<br/>", 1, true);
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
				if(clen){
					report("<p10>Children:</p10> "+props.join("<p-1>; </p-1>")+"<br/>", 1, true);
				}
			}
			//
			// constants...
			//
			props = [];
			nodes = clsV..constant;
			for each (var constantX:XML in nodes) {
				report(" const <p3>"+constantX.@name+"</p3>:"+constantX.@type+" = "+makeValue(cls, constantX.@name)+"</p0>", 1);
			}
			if(nodes.length()){
				report("");
			}
			var inherit:uint = 0;
			var hasstuff:Boolean;
			var isstatic:Boolean;
			//
			// methods
			//
			props = [];
			nodes = clsV..method; // '..' to include from <factory>
			for each (var methodX:XML in nodes) {
				if(viewAll || self==methodX.@declaredBy){
					hasstuff = true;
					isstatic = methodX.parent().name()!="factory";
					str = " "+(isstatic?"static ":"")+"function ";
					var params:Array = [];
					var mparamsList:XMLList = methodX.parameter;
					for each(var paraX:XML in mparamsList){
						params.push(paraX.@optional=="true"?("<i>"+paraX.@type+"</i>"):paraX.@type);
					}
					str += "<a href='event:cl_"+refIndex+"_"+methodX.@name+"()'><p3>"+methodX.@name+"</p3></a>(<i>"+params.join(",")+"</i>):"+methodX.@returnType;
					report(str, 1);
				}else{
					inherit++;
				}
			}
			if(inherit){
				report("   \t + "+inherit+" inherited methods.", 1);
			}else if(hasstuff){
				report();
			}
			//
			// accessors
			//
			hasstuff = false;
			inherit = 0;
			props = [];
			nodes = clsV..accessor; // '..' to include from <factory>
			for each (var accessorX:XML in nodes) {
				if(viewAll || self==accessorX.@declaredBy){
					hasstuff = true;
					isstatic = accessorX.parent().name()!="factory";
					str = " ";
					if(isstatic) str += "static ";
					var access:String = accessorX.@access;
					if(access == "readonly") str+= "get";
					else if(access == "writeonly") str+= "set";
					else str += "assign";
					str += " <a href='event:cl_"+refIndex+"_"+accessorX.@name+"'><p3>"+accessorX.@name+"</p3></a>:"+accessorX.@type;
					if(access != "writeonly" && (isstatic || !(obj is Class))){
						var t:Object = isstatic?cls:obj;
						str += " = "+makeValue(t, accessorX.@name);
					}
					report(str, 1);
				}else{
					inherit++;
				}
			}
			if(inherit){
				report("   \t + "+inherit+" inherited accessors.", 1);
			}else if(hasstuff){
				report();
			}
			//
			// variables
			//
			nodes = clsV..variable;
			for each (var variableX:XML in nodes) {
				if(variableX.parent().name()=="factory"){
					report(" var <a href='event:cl_"+refIndex+"_"+variableX.@name+" = '><p3>"+variableX.@name+"</p3></a>:"+variableX.@type+" = "+makeValue(obj, variableX.@name), 1);
				}else{
					report(" static var <a href='event:cl_"+refIndex+"_"+variableX.@name+" = '><p3>"+variableX.@name+"</p3></a>:"+variableX.@type+" = "+makeValue(cls, variableX.@name), 1);
				}
			}
			//
			// dynamic values
			// - It can sometimes fail if we are looking at proxy object which havnt extended nextNameIndex, nextName, etc.
			try{
				props = [];
				for (var X:String in obj) {
					report(" dynamic var <a href='event:cl_"+refIndex+"_"+X+" = '><p3>"+X+"</p3></a> = "+makeValue(obj, X), 1);
				}
			}catch(e:Error){
				report("Could not get values due to: "+e, 9);
			}
			if(obj is String){
				report();
				report("String", 10);
				report(EscHTML(obj));
			}else if(obj is XML || obj is XMLList){
				report();
				report("XMLString", 10);
				report(EscHTML(obj.toXMLString()));
			}
			if(menuStr){
				report();
				report(menuStr, -1, true);
			}
		}
		private function makeValue(obj:*, prop:String = null):String{
			return makeString(obj, prop, false, MAX_VAL_LENGTH);
		}
		public function explode(obj:Object, depth:int = 3, p:int = 9):String{
			var t:String = typeof obj;
			if(obj == null){ 
				// could be null, undefined, NaN, 0, etc. all should be printed as is
				return "<p-2>"+obj+"</p-2>";
			}else if(obj is String){
				return '"'+EscHTML(obj as String)+'"';
			}else if(t != "object" || depth == 0 || obj is ByteArray){
				return makeString(obj);
			}
			if(p<0) p = 0;
			var V:XML = describeType(obj);
			var nodes:XMLList, n:String;
			var list:Array = [];
			//
			nodes = V["accessor"];
			for each (var accessorX:XML in nodes) {
				n = accessorX.@name;
				if(accessorX.@access!="writeonly"){
					try{
						list.push(stepExp(obj, n, depth, p));
					}catch(e:Error){}
				}else{
					list.push(n);
				}
			}
			//
			nodes = V["variable"];
			for each (var variableX:XML in nodes) {
				n = variableX.@name;
				list.push(stepExp(obj, n, depth, p));
			}
			//
			try{
				for (var X:String in obj) {
					list.push(stepExp(obj, X, depth, p));
				}
			}catch(e:Error){}
			return "<p"+p+">{"+ShortClassName(obj)+"</p"+p+"> "+list.join(", ")+"<p"+p+">}</p"+p+">";
		}
		private function stepExp(o:*, n:String, d:int, p:int):String{
			return n+":"+explode(o[n], d-1, p-1);
		}	
		
		public static function EscHTML(str:String):String{
			str = str.replace(/</gm, "&lt;");
	 		return str.replace(new RegExp(">", "gm"), "&gt;");
		}
		/** 
		 * Produces class name without package path
		 * e.g: flash.display.Sprite => Sprite
		 */	
		public static function ShortClassName(cls:Object):String{
			var str:String = getQualifiedClassName(cls);
			var ind:int = str.lastIndexOf("::");
			return str.substring(ind>=0?(ind+2):0);
		}
	}
}
