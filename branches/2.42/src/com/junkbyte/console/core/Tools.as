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
package com.junkbyte.console.core {
	import flash.utils.getDefinitionByName;
	import com.junkbyte.console.utils.ShortClassName;
	import com.junkbyte.console.Console;
	import com.junkbyte.console.vos.WeakObject;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;import com.junkbyte.console.utils.CastToString;	

	public class Tools {
		
		private var _master:Console;
		
		private var _mapBases:WeakObject;
		private var _mapBaseIndex:uint = 1;
		
		public function Tools(m:Console) {
			_master = m;
			_mapBases = new WeakObject();
		}
		public function report(obj:*, priority:Number = 0, skipSafe:Boolean = true, ch:String = null):void{
			_master.addLine([obj], priority, ch?ch:_master.config.consoleChannel, false, skipSafe, 0);
		}
		
		public function inspect(obj:*, viewAll:Boolean= true, ch:String = null):void {
			if(!obj){
				report(obj, -2, true, ch);
				return;
			}
			var linkIndex:uint = _master.setLogLink(obj);
			var menuStr:String = "[<a href='event:channel_"+_master.config.globalChannel+ "'>Exit</a>] [Previous] [<a href='event:cl_"+linkIndex+"'>Set scope</a>]";
			menuStr += " [<a href='event:"+(viewAll?"reff_":"ref_")+linkIndex+"'>refresh</a>]";
			if(!viewAll) menuStr += " [<a href='event:reff_"+linkIndex+"'>Show inherited</a>]";
			report(menuStr, -1, true, ch);
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
			report(str, -2, true, ch);
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
				report("<p10>Extends:</p10> "+props.join("<p-1> &gt; </p-1>"), 5, true, ch);
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
				report("<p10>Implements:</p10> "+props.join(" "), 5, true, ch);
			}
			//
			// constants...
			//
			props = [];
			nodes = clsV..constant;
			for each (var constantX:XML in nodes) {
				str = "<p1>const </p1>"+constantX.@name+"<p0>:"+constantX.@type+" = "+makeValue(cls[constantX.@name])+"</p0>";
				report(str, 3, true, ch);
			}
			if(nodes.length()>0){
				report("", 3, true, ch);
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
					str = "<p1>"+(isstatic?"static ":"")+"function </p1>";
					var params:Array = [];
					var mparamsList:XMLList = methodX.parameter;
					for each(var paraX:XML in mparamsList){
						params.push(paraX.@optional=="true"?("<i>"+paraX.@type+"</i>"):paraX.@type);
					}
					str += "<a href='event:cl_"+linkIndex+"_"+methodX.@name+"()'>"+methodX.@name+"</a><p1>(<i>"+params.join(",")+"</i>):"+methodX.@returnType+"</p1>";
					report(str, 3, true, ch);
				}else{
					inherit++;
				}
			}
			if(inherit){
				report("  + "+inherit+" inherited methods.", 1, true, ch);
			}else if(nodes.length()){
				report("", 3, true, ch);
			}
			//
			// accessors
			//
			inherit = 0;
			var arr:Array = new Array();
			props = [];
			props2 = [];
			nodes = clsV..accessor; // '..' to include from <factory>
			for each (var accessorX:XML in nodes) {
				if(viewAll || self==accessorX.@declaredBy){
					isstatic = accessorX.parent().name()!="factory";
					str = "<p1>"+(isstatic?"static ":"");
					var access:String = accessorX.@access;
					if(access == "readonly") str+= "get";
					else if(access == "writeonly") str+= "set";
					else str += "assign";
					str+= "</p1> <a href='event:cl_"+linkIndex+"_"+accessorX.@name+"'>"+accessorX.@name+"</a><p1>:"+accessorX.@type+"</p1>";
					if(access != "writeonly"){
						var t:Object = isstatic?cls:obj;
						str+="<p1> = "+makeValue(t, accessorX.@name)+"</p1>";
					}
					report(str, 3, true, ch);
				}else{
					inherit++;
				}
			}
			if(inherit){
				report("  + "+inherit+" inherited accessors.", 1, true, ch);
			}else if(nodes.length()){
				report("", 3, true, ch);
			}
			//
			// variables
			//
			props = [];
			nodes = clsV..variable;
			for each (var variableX:XML in nodes) {
				str = "<p0>var </p0>";
				if(variableX.parent().name()=="factory"){
					str = "<p0>var </p0>"+variableX.@name+":<p1>"+variableX.@type+" = "+makeValue(obj, variableX.@name)+"</p1>";
				}else{
					str = "<p0><i>static var</i></p0>"+variableX.@name+":<p1>"+variableX.@type+" = "+makeValue(cls, variableX.@name)+"</p1>";
				}
				props.push(str);
			}
			if(props.length){
				report(props.join("<br/>"), 3, true, ch);
			}
			//
			// dynamic values
			// - It can sometimes fail if we are looking at proxy object which havnt extended nextNameIndex, nextName, etc.
			try{
				props = [];
				for (var X:String in obj) {
					report("<p0>dynamic var </p0>"+X+"<p1> = "+makeValue(obj, X)+"</p1>", 3, true, ch);
				}
			}catch(e:Error){
				report("Could not get values due to: "+e, 9, true, ch);
			}
			//
			// events
			// metadata name="Event"
			props = [];
			nodes = V.metadata;
			for each (var metadataX:XML in nodes) {
				if(metadataX.@name=="Event"){
					var mn:XMLList = metadataX.arg;
					props.push(mn.(@key=="name").@value+"<p0>("+mn.(@key=="type").@value+")</p0>");
				}
			}
			if(props.length){
				report("<p10>Events:</p10> "+props.join("<p-1>; </p-1>")+"<br/>", 5, true, ch);
			}
			//
			// display's parents and direct children
			//
			if (viewAll && obj is DisplayObjectContainer) {
				props = [];
				var mc:DisplayObjectContainer = obj as DisplayObjectContainer;
				var clen:int = mc.numChildren;
				for (var ci:int = 0; ci<clen; ci++) {
					var child:DisplayObject = mc.getChildAt(ci);
					props.push("<b>"+child.name+"</b>:("+ci+")"+getQualifiedClassName(child));
				}
				if(props.length){
					report("<p10>Children:</p10> "+props.join("<p-1>; </p-1>")+"<br/>", 5, true, ch);
				}
			}
			if (viewAll && obj is DisplayObject) {
				var theParent:DisplayObjectContainer = mc.parent;
				if (theParent) {
					props = ["("+theParent.getChildIndex(mc)+")"];
					while (theParent) {
						var pr:DisplayObjectContainer = theParent;
						theParent = theParent.parent;
						props.push("<b>"+pr.name+"</b>:("+(theParent?theParent.getChildIndex(pr):"")+")"+getQualifiedClassName(pr));
					}
					if(props.length){
						report("<p10>Parents:</p10> "+props.join("<p-1>; </p-1>")+"<br/>", 5, true, ch);
					}
				}
			}
			report(menuStr, -1, true, ch);
		}
		private function makeValue(obj:*, prop:String = null):String{
			try{
				if(prop) obj = obj[prop];
				var str:String = _master.makeLogLink(obj);
				if(str.length > 100){
					str = str.substring(0, 100)+"...";
				}
			}catch(err:Error){
				return "<p0><i>"+err.toString()+"</i></p0>";
			}
			return str;
		}
		public static function explode(obj:Object, depth:int = 3, p:int = 9):String{
			if(!obj) return "explode() target is empty.";
			var t:String = typeof obj;
			if(t != "object" || depth == 0){
				return CastToString(obj);
			}else if(obj == null){ 
				// could be null, undefined, NaN, etc. all should be printed as is
				return "<p-2>"+obj+"</p-2>";
			}
			if(p<0) p = 0;
			var V:XML = describeType(obj);
			var nodes:XMLList, n:String;
			var list:Array = [];
			//
			nodes = V.accessor;
			for each (var accessorX:XML in nodes) {
				n = accessorX.@name;
				if(accessorX.@access!="writeonly"){
					try{
						list.push(n+":"+explode(obj[n], depth-1, p-1));
					}catch(e:Error){}
				}else{
					list.push(n);
				}
			}
			//
			nodes = V.variable;
			for each (var variableX:XML in nodes) {
				n = variableX.@name;
				list.push(n+":"+explode(obj[n], depth-1, p-1));
			}
			//
			try{
				for (var X:String in obj) {
					list.push(X+":"+explode(obj[X], depth-1, p-1));
				}
			}catch(e:Error){}
			return "<p"+p+">{"+ShortClassName(obj)+"</p"+p+"> "+list.join(", ")+"<p"+p+">}</p"+p+">";
		}
		public function map(base:DisplayObjectContainer, maxstep:uint = 0):void{
			if(!base){
				report("It is not a DisplayObjectContainer", 10);
				return;
			}
			_mapBases[_mapBaseIndex] = base;
			var basestr:String = _mapBaseIndex+Console.REMAPSPLIT;
			
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
			var wasHiding:Boolean;
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
				if(maxstep<=0 || steps<=maxstep){
					wasHiding = false;
					var n:String = "<a href='event:clip_"+basestr+indexes.join(Console.REMAPSPLIT)+"'>"+mcDO.name+"</a>";
					if(mcDO is DisplayObjectContainer){
						n = "<b>"+n+"</b>";
					}else{
						n = "<i>"+n+"</i>";
					}
					str += n+" ("+getQualifiedClassName(mcDO)+")";
					report(str,mcDO is DisplayObjectContainer?5:2);
				}else if(!wasHiding){
					wasHiding = true;
					report(str+"...",5);
				}
				lastmcDO = mcDO;
			}
			_mapBaseIndex++;
			report(base.name+":"+getQualifiedClassName(base)+" has "+list.length+" children/sub-children.", 10);
			report("Click on the name to return a reference to the child clip. <br/>Note that clip references will be broken when display list is changed",-2);
		}
		public function reMap(path:String, mc:DisplayObjectContainer):DisplayObject{
			var pathArr:Array = path.split(Console.REMAPSPLIT);
			var first:String = pathArr.shift();
			if(first != "0") mc = _mapBases[first];
			var child:DisplayObject = mc as DisplayObject;
			try{
				for each(var nn:String in pathArr){
					if(!nn) break;
					child = mc.getChildByName(nn);
					if(child is DisplayObjectContainer){
						mc = child as DisplayObjectContainer;;
					}else{
						// assume it reached to end since there can no longer be a child
						break;
					}
				}
				return child;
			} catch (e:Error) {
				report("Problem getting the clip reference. Display list must have changed since last map request",10);
				//debug(e.getStackTrace());
			}
			return null;
		}
	}
}