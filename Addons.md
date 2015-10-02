Addons are located in samples/addons/com/junkbyte/console/addons
These add functionality on top of base console.
They are not compiled as part of SWC package at the moment as some may require additional libraries.


## Display Map ##
  * Displays a panel mapping the display tree/map.
  * Start from code: `DisplayMapAddon.start();`
  * Add to menu: `DisplayMapAddon.addToMenu();`
  * Register to commandLine: `DisplayMapAddon.registerCommand();` use /mapdisplay, starts mapping from current command scope.


## HTML Export ##
  * Export console logs to a HTML file. preserves channels and priorities.
  * It also have all those filtering features in HTML page.
  * Add to menu: `ConsoleHtmlExportAddon.addToMenu();`
  * sample: http://console.junkbyte.com/addons/htmlexport/export.html
  * blog: http://junkbyte.com/wp/as3/console/console-logs-to-html-export-addon/
  * Requires flash player 11 OR com.adobe.serialization.json.JSON.
    * If you are using com.adobe.serialization.json.JSON, make sure you reference the class somewhere so that it get compiled.


## Command Prompt ##
  * Simulates 'command prompt' style user input.
  * Ask to choose from a selection of input, user enter into command line to choose a selection.
  * Could be useful for 'utility' sort of app where there is no GUI to represent user options.
  * Demo: http://console.junkbyte.com/addons/commandprompt/
  * Blog with demo source: http://junkbyte.com/wp/as3/console/console-command-prompt-addon-demo/



## `CommandLine` Auto focus ##
  * Sets focus to commandLine input field whenever Console becomes visible, e.g after entering password key.