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
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.net.Socket;
	import com.junkbyte.console.Console;
	import com.junkbyte.console.vos.GraphGroup;
	import com.junkbyte.console.vos.Log;

	import flash.events.AsyncErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.system.Security;
	import flash.utils.ByteArray;

	public class Remoting extends ConsoleCore{
		
		public static const NONE:uint = 0;
		public static const SENDER:uint = 1;
		public static const RECIEVER:uint = 2;
		
		private var _client:Object;
		private var _mode:uint;
		private var _local:LocalConnection;
		private var _socket:Socket;
		private var _sendBuffer:ByteArray = new ByteArray();
		private var _recBuffer:ByteArray = new ByteArray();
		
		private var _lastLogin:String = "";
		private var _password:String;
		private var _loggedIn:Boolean;
		
		private var _uniqueID:uint; // TODO 
		
		public function Remoting(m:Console, pass:String) {
			super(m);
			_password = pass;
			_client = new Object();
			_client.login = function(bytes:ByteArray):void{
				login(bytes.readUTF());
			};
			_client.requestLogin = requestLogin;
			_client.loginFail = loginFail;
			_client.loginSuccess = loginSuccess;
			_client.log = function(bytes:ByteArray):void{
				readLog(bytes);
			};
		}
		
		public function queueLog(line:Log):void{
			if(_mode != SENDER || !_loggedIn) return;
			send("log", line.toBytes());
		}
		public function update():void{
			if(_sendBuffer.length){
				if(_socket && _socket.connected){
					_socket.writeBytes(_sendBuffer);
					_socket.flush();
					_sendBuffer = new ByteArray();
				}else{
					var packet:ByteArray = new ByteArray();
					_sendBuffer.position = 0;
					_sendBuffer.readBytes(packet, 0, Math.min(38000, _sendBuffer.bytesAvailable));
					
					var newbuffer:ByteArray = new ByteArray();
					_sendBuffer.readBytes(newbuffer);
					_sendBuffer = newbuffer;
					var target:String = config.remotingConnectionName+(remoting == Remoting.RECIEVER?SENDER:RECIEVER);
					_local.send(target, "sync", packet);
				}
			}
		}
		private function sync(obj:Object):void{
			if(!(obj is ByteArray)){
				report("Remoting sync error. Recieved non ByteArray:"+obj, 9);
				return;
			}
			var packet:ByteArray = obj as ByteArray;
			_recBuffer.position = _recBuffer.length;
			_recBuffer.writeBytes(packet);
			try{
				_recBuffer.position = 0;
				while(_recBuffer.bytesAvailable){
					var cmd:String = _recBuffer.readUTF();
					var blen:uint = _recBuffer.readUnsignedInt();
					if(blen){
						if(_recBuffer.bytesAvailable < blen){
							break;
						}
						var arg:ByteArray = new ByteArray();
						_recBuffer.readBytes(arg, 0, blen);
						_client[cmd](arg);
					}else{
						_client[cmd]();
					}
					var newbuffer:ByteArray = new ByteArray();
					_recBuffer.readBytes(newbuffer);
					_recBuffer = newbuffer;
				}
			}catch(err:Error){
				report("Remoting sync error: "+err, 9);
			}
		}
		private function readLog(bytes:ByteArray):void{
			var t:String = bytes.readUTFBytes(bytes.readUnsignedInt());
			var c:String = bytes.readUTF();
			var p:int = bytes.readInt();
			var r:Boolean = bytes.readBoolean();
			console.addLine(new Array(t), p, c, r, true);
		}
		public function send(command:String, arg:ByteArray = null):Boolean{
			_sendBuffer.position = _sendBuffer.length;
			_sendBuffer.writeUTF(command);
			if(arg && arg.length){
				_sendBuffer.writeUnsignedInt(arg.length);
				_sendBuffer.writeBytes(arg);
			}else{
				_sendBuffer.writeUnsignedInt(0);
			}
			return true;
		}
		public function get remoting():uint{
			return _mode;
		}
		public function get loggedIn():Boolean{
			return _loggedIn;
		}
		public function set remoting(newMode:uint):void{
			if(newMode == _mode) return;
			if(newMode == SENDER){
				if(!startSharedConnection(SENDER)){
					report("Could not create remoting client service. You will not be able to control this console with remote.", 10);
				}
				_sendBuffer = new ByteArray();
				_local.addEventListener(StatusEvent.STATUS, onRemotingStatus, false, 0, true);
				report("<b>Remoting started.</b> "+getInfo(),-1);
				_loggedIn = checkLogin("");
				if(_loggedIn){
					sendLoginSuccess();
				}else{
					send("requestLogin");
				}
			}else if(newMode == RECIEVER){
				if(startSharedConnection(RECIEVER)){
					_sendBuffer = new ByteArray();
					_local.addEventListener(AsyncErrorEvent.ASYNC_ERROR , onRemoteAsyncError, false, 0, true);
					_local.addEventListener(StatusEvent.STATUS, onRemoteStatus, false, 0, true);
					report("<b>Remote started.</b> "+getInfo(),-1);
					var sdt:String = Security.sandboxType;
					if(sdt == Security.LOCAL_WITH_FILE || sdt == Security.LOCAL_WITH_NETWORK){
						report("Untrusted local sandbox. You may not be able to listen for logs properly.", 10);
						printHowToGlobalSetting();
					}
					login(_lastLogin);
				}else{
					report("Could not create remote service. You might have a console remote already running.", 10);
				}
			}else{
				close();
			}
			console.panels.updateMenu();
		}
		public function set remotingPassword(str:String):void{
			_password = str;
			if(_mode == SENDER && !str) login();
		}
		public function remotingSocket(host:String, port:int = 0):void{
			if(_socket && _socket.connected){
				_socket.close();
				_socket = null;
			}
			if(host && port)
			{
				report("Connecting to socket " + host + ":" + port);
				_socket = new Socket();
		        _socket.addEventListener(Event.CLOSE, socketCloseHandler);
		        _socket.addEventListener(Event.CONNECT, socketConnectHandler);
		        _socket.addEventListener(IOErrorEvent.IO_ERROR, socketIOErrorHandler);
		        _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketSecurityErrorHandler);
		        _socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		        _socket.connect(host, port);
			}
		}

		private function socketCloseHandler(e:Event) : void {
			if(e.currentTarget == _socket){
				_socket = null;
			}
		}
		private function socketConnectHandler(e:Event) : void {
			report("Remoting socket connected.", -1);
			if(_loggedIn || checkLogin("")){
				sendLoginSuccess();
			}else{
				send("requestLogin");
			}
			// not needed yet
		}
		private function socketIOErrorHandler(e:Event) : void {
			report("Remoting socket error." + e, 9);
			remotingSocket(null);
		}
		private function socketSecurityErrorHandler(e:Event) : void {
			report("Remoting security error." + e, 9);
			remotingSocket(null);
		}
		private function socketDataHandler(e:Event) : void {
			handleSocket(e.currentTarget as Socket);
		}
		public function handleSocket(socket:Socket):void{
			if(socket != _socket) _socket = socket;
			try{
				while(socket.bytesAvailable)
				{
					var cmd:Function = _client[socket.readUTF()];
					var args:Object = socket.readObject();
					if(cmd != null) cmd.apply(null, args);
				}
			} catch(err:Error){
				report("Remoting socket data error." + err, 9);
			}
		}
		
		private function onRemotingStatus(e:StatusEvent):void{
			if(e.level == "error" && !(_socket && _socket.connected)) {
				_loggedIn = false;
			}
		}
		private function onRemotingSecurityError(e:SecurityErrorEvent):void{
			report("Remoting security error.", 9);
			printHowToGlobalSetting();
		}
		private function onRemoteAsyncError(e:AsyncErrorEvent):void{
			report("Problem with remote sync. [<a href='event:remote'>Click here</a>] to restart.", 10);
			remoting = NONE;
		}
		private function onRemoteStatus(e:StatusEvent):void{
			if(remoting == Remoting.RECIEVER && e.level=="error"){
				report("Problem communicating to client.", 10);
			}
		}
		
		private function getInfo():String{
			return "</p5>channel:<p5>"+config.remotingConnectionName+" ("+Security.sandboxType+")";
		}
		
		private function printHowToGlobalSetting():void{
			report("Make sure your flash file is 'trusted' in Global Security Settings.", -2);
			report("Go to Settings Manager [<a href='event:settings'>click here</a>] &gt; 'Global Security Settings Panel' (on left) &gt; add the location of the local flash (swf) file.", -2);
		}
		
		private function startSharedConnection(targetmode:uint):Boolean{
			close();
			_mode = targetmode;
			_local = new LocalConnection();
			_local.client = {sync:sync};
			if(config.allowedRemoteDomain){
				_local.allowDomain(config.allowedRemoteDomain);
				_local.allowInsecureDomain(config.allowedRemoteDomain);
			}
			_local.addEventListener(SecurityErrorEvent.SECURITY_ERROR , onRemotingSecurityError, false, 0, true);
			
			try{
				_local.connect(config.remotingConnectionName+_mode);
			}catch(err:Error){
				return false;
			}
			return true;
		}
		public function registerClient(key:String, fun:Function):void{
			_client[key] = fun;
		}
		private function loginFail():void{
			if(remoting != Remoting.RECIEVER) return;
			report("Login Failed", 10);
			console.panels.mainPanel.requestLogin();
		}
		private function sendLoginSuccess():void{
			_loggedIn = true;
			send("loginSuccess");
			var log:Log = console.logs.first;
			while(log){
				queueLog(log);
				log = log.next;
			}
			console.cl.sendCmdScope2Remote();
		}
		private function loginSuccess():void{
			console.setViewingChannels();
			report("Login Successful", -1);
		}
		private function requestLogin():void{
			if(remoting != Remoting.RECIEVER) return;
			if(_lastLogin){
				login(_lastLogin);
			}else{
				console.panels.mainPanel.requestLogin();
			}
		}
		public function login(pass:String = ""):void{
			if(remoting == Remoting.RECIEVER){
				_lastLogin = pass;
				report("Attempting to login...", -1);
				var bytes:ByteArray = new ByteArray();
				bytes.writeUTF(pass);
				send("login", bytes);
			}else{
				// once logged in, next login attempts will always be success
				if(_loggedIn || checkLogin(pass)){
					sendLoginSuccess();
				}else{
					send("loginFail");
				}
			}
		}
		private function checkLogin(pass:String):Boolean{
			return (!_password || _password == pass);
		}
		public function close():void{
			if(_local){
				try{
					_local.close();
				}catch(error:Error){
					report("Remote.close: "+error, 10);
				}
			}
			_mode = NONE;
			_sendBuffer = new ByteArray();
			_local = null;
		}
		//
		//
		//
		/*public static function get RemoteIsRunning():Boolean{
			var sCon:LocalConnection = new LocalConnection();
			try{
				sCon.allowInsecureDomain("*");
				sCon.connect(Console.RemotingConnectionName+REMOTE_PREFIX);
			}catch(error:Error){
				return true;
			}
			sCon.close();
			return false;
		}*/
	}
}