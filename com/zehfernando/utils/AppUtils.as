package com.zehfernando.utils {
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class AppUtils {

		protected static var stage:Stage;
		protected static var root:DisplayObjectContainer;
		protected static var hasDeterminedDebugStatus:Boolean;
		protected static var _isDebuggingSWF:Boolean;

		protected static var zoomScale:Number = (isAndroid() || isIOS()) ? 1 : 2;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AppUtils() {
			// No constructor!
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		public static function init(__stage:Stage, __root:DisplayObjectContainer):void {
			stage = __stage;
			root = __root;
		}

		public static function getStage():Stage {
			return stage;
		}

		public static function getRoot():DisplayObjectContainer {
			return root;
		}

		public static function getFlashVar(__parameter:String):String {
			return LoaderInfo(root.loaderInfo).parameters[__parameter];
		}

		// localFileReadDisable
		// hasPrinting
		// avHardwareDisable
		// hasAudio
		// language - en, pt
		// manufacturer - "Adobe Windows"
		// os - "Windows XP"
		// version
		// screenResolutionX
		// playerType

		// http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/Capabilities.html#playerType
		//  "ActiveX" for the Flash Player ActiveX control used by Microsoft Internet Explorer
		//  "Desktop" for the Adobe AIR runtime (except for SWF content loaded by an HTML page, which has Capabilities.playerType set to "PlugIn")
		//  "External" for the external Flash Player or in test mode
		//  "PlugIn" for the Flash Player browser plug-in (and for SWF content loaded by an HTML page in an AIR application)
		//  "StandAlone" for the stand-alone Flash Player

		public static function isMac():Boolean {
			return Capabilities.os == "MacOS" || Capabilities.os.substr(0, 6) == "Mac OS";
		}

		public static function isLinux():Boolean {
			// Android: "Linux 3.1.10-g52027f9"
			return Capabilities.os == "Linux";
		}

		public static function isWindows():Boolean {
			//return Capabilities.os == "Windows" || Capabilities.os == "Windows 7" || Capabilities.os == "Windows XP" || Capabilities.os == "Windows 2000" || Capabilities.os == "Windows 98/ME" || Capabilities.os == "Windows 95" || Capabilities.os == "Windows CE";
			return Capabilities.manufacturer == "Adobe Windows";
		}

		public static function isAndroid():Boolean {
			// Android: "Android Linux"
			// TODO: this is true on Linux too?
			return Capabilities.manufacturer == "Android Linux";
		}

		public static function isIOS():Boolean {
			// iOS: "Adobe iOS"
			return Capabilities.manufacturer == "Adobe iOS";
		}

		public static function isAirPlayer():Boolean {
			// This returns true even if it's on android!
			return Capabilities.playerType == "Desktop";
		}

		public static function isWebPlayer():Boolean {
			return Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn";
		}

		public static function isStandalone():Boolean {
			// Desktop standalone
			return Capabilities.playerType == "StandAlone";
		}

		/**
		 * Tells whether this is being tested (ran on the IDE Flash player), or not.
		 * @return	TRUE if this is a test execution, false if otherwise.
		 */
		public static function isTestingFromFlashIDE():Boolean {
			return Capabilities.playerType == "External";
		}

		public static function isDebugSWF():Boolean {
			// Whether the SWF is compiled for debugging or not (only works on debug players)
			// http://michaelvandaniker.com/blog/2008/11/25/how-to-check-debug-swf/
			if (!hasDeterminedDebugStatus) {
				var stackTrace:String = new Error().getStackTrace();
				_isDebuggingSWF = stackTrace != null && stackTrace.indexOf("[") != -1;
				hasDeterminedDebugStatus = true;
			}
			return _isDebuggingSWF;
		}

		// Userlayer stuff
		public static function resetContextMenu():void {
			// Clears the menu
			root.contextMenu = new ContextMenu();
//			root.contextMenu.hideBuiltInItems();

			//var mi:ContextMenuItem = new ContextMenuItem("Toggle Fullscreen");
			//mi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleFullScreen);
			//root.contextMenu.customItems.push(mi);
		}

		public static function disableContextMenu():void {
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseClickDoNothing);
		}

		public static function isDebugPlayer():Boolean {
			return Capabilities.isDebugger;
		}

		public static function toggleFullScreen():void {
			setFullScreen(stage.displayState == StageDisplayState.NORMAL);
		}

		public static function setFullScreen(__fullScreen:Boolean):void {
			stage.displayState = __fullScreen ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
		}

		public static function isFullScreen():Boolean {
			return stage.displayState == StageDisplayState.FULL_SCREEN;
		}

		public static function getCentimetersInPixels(__centimeters:Number):Number {
			// Return a certain number of centimeters in pixels
			return getInchesInPixels(__centimeters / 2.54); // * 0.393701
		}

		public static function getInchesInPixels(__inches:Number):Number {
			// Return a certain number of inches in pixels
			//return __inches * Capabilities.screenDPI;
			return (__inches * 96) * getScreenDensityScale();
		}

		public static function getScreenDensityScale():Number {
			// Returns a density scale where 1 = 96dpi, 2 = 192dpi, etc

			if ((isWebPlayer() || isAirPlayer()) && !isAndroid() && !isIOS()) {
				// Normal player that always returns 96 as the dpi
				// Otherwise it'd return 72
				return 1;
			}

			// Everything else
			return Capabilities.screenDPI / 96;
		}

		public static function getScreenDensityScaleZoomed():Number {
			// Like getScreenDensityScale, but with a proper zoom
			return getScreenDensityScale() * zoomScale;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private static function onRightMouseClickDoNothing(__e:Event):void {
		}

	}
}
