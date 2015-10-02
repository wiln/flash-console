# Introduction #

  * Remoting sends log data for a remote console to use
  * The advantages are:
    * You dont need to keep console open in your working flash project
    * Logs stays in remote afer closing your working flash project
    * You can use commandline, view FPS and memory from remote
  * AIR version of remote is in [bin/ConsoleRemote.air](http://flash-console.googlecode.com/svn/trunk/bin/ConsoleRemote.air)
  * EXE and APP version can be published using `samples/remote_air/ConsoleRemoteAIR.as`

## DEMO ##
  * Client (sender): http://console.junkbyte.com/sample.html
  * Remote (receiver): http://console.junkbyte.com/remote.html

Remote may prompt for password if you have password set up on client.

You may disable this by setting `Cc.config.remotingPassword = "";`. - **Must be set before** starting remoting.

There can be confusion with FPS and memory monitor if you have more than one flash client sending to remote

# Communication options #

## Local Connection ##
Default option.
It can connects to another flash instance on the same machine.

#### How to ####
Start from client code:
`Cc.remoting = true;`

Start from commandLine:
`$C.remoting = true`

## Socket ##
Can connect using Socket connection to another FlashConsole on another computer.

Data is in simple binaries, so you can even write your own remote on any platform.

#### How to ####
  1. Must use ConsoleRemote.air AIR app for receiving (remote). _This is because socket server is only supported in AIR and there is no way to do p2p connection otherwise._
  1. In the remote air app, type in command line: `/listen <your ip on local network> <port>`. Example `/listen 192.168.1.2 99`, do not use localhost or 127.0.0.1
  1. Run client (sender) flash file (may not work on HTML page).
  1. Make sure that swf file is inside local trusted files list. Right click > Global Settings > Advanced > Trusted Location Settings… > add your dev folder where your swf files live. Restart swf after setting this up for first time.
  1. Type in commandline: `/remotingSocket <host ip> <port>`. Example `/remotingSocket 192.168.1.2 99` Alternatively set up in code Cc.remotingSocket()…
  1. Remote should now show logs from client. Due to a few variables involved in the setup, you may not get it working straight away.

#### Known problems ####
If you have flash security issues, you will get a ton of “Remoting sync error: Error: Error #2030″ on AIR app and ‘SecurityErrorEvent’ on client side after several seconds.
This happens if you haven’t set up trusted local files settings or connecting from inaccessible security sandbox.

Does not work from HTML embed clients, tho it may depend on sandbox security.