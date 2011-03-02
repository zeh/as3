package com.zehfernando.utils {

	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * @author zeh
	 */
	public class Log {

		// Constants
		public static const PACKAGE_NAME:String = "[[package]]";
		public static const CLASS_NAME:String = "[[class]]";
		public static const FUNCTION_NAME:String = "[[function]]";
		public static const ECHO_TEXT:String = "[[text]]";
		
		public static const ECHO_FORMAT_FULL:String = "### " + PACKAGE_NAME + "." + CLASS_NAME + "." + FUNCTION_NAME + "() :: " + ECHO_TEXT;
		public static const ECHO_FORMAT_SHORT:String = "### " + CLASS_NAME + "." + FUNCTION_NAME + "() :: " + ECHO_TEXT;
		
		public static var echoFormat:String = ECHO_FORMAT_SHORT;
		
		protected static var _useTrace:Boolean;
		protected static var _useScreen:Boolean;
		protected static var _useJavascriptConsole:Boolean;
		
		protected static var textField:TextField;
		
		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------
		
		{
			_useTrace = true;
			_useScreen = false;
			_useJavascriptConsole = false;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------
		
		public static function echo(... __args:Array): void {
			// Logs something
			
			//var className:String = DebugUtils.
			
			var currCall:Vector.<String> = DebugUtils.getCurrentCallStack()[1]; // Package, class, function
			
			var output:String = echoFormat;
			output = output.split(PACKAGE_NAME).join(currCall[0]);
			output = output.split(CLASS_NAME).join(currCall[1]);
			output = output.split(FUNCTION_NAME).join(currCall[2]);
			output = output.split(ECHO_TEXT).join(__args.join(" "));
			
			if (_useTrace) {
				trace (output);
			}

			if (_useScreen) {
				textField.text = textField.text + output + "\n"; // do not use append
				textField.scrollV = textField.maxScrollV;
			}
			
			if (_useJavascriptConsole) {
				ExternalInterface.call("function(__message) { if(typeof(console) !== 'undefined' && console != null) { console.log(__message); } }", output);
			}

		}
		
		public static function createTextField(): void {
			textField = new TextField();
			textField.mouseEnabled = false;
			textField.embedFonts = false;
			
			var fmt:TextFormat = new TextFormat("_sans", 10, 0xffffff);
			textField.defaultTextFormat = fmt;
			textField.setTextFormat(fmt);
			
			AppUtils.getStage().addChild(textField);
			AppUtils.getStage().addEventListener(Event.RESIZE, onScreenResizeResizeTextField);
			
			onScreenResizeResizeTextField(null);
		}

		public static function removeTextField(): void {
			textField = new TextField();
			
			AppUtils.getStage().removeChild(textField);
			AppUtils.getStage().removeEventListener(Event.RESIZE, onScreenResizeResizeTextField);
			
			textField = null;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected static function onScreenResizeResizeTextField(e:Event): void {
			textField.x = AppUtils.getStage().stageWidth * 0.5;
			textField.width = AppUtils.getStage().stageWidth * 0.5;
			textField.height = AppUtils.getStage().stageHeight;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public static function get useTrace(): Boolean {
			return _useTrace;
		}
		public static function set useTrace(__value:Boolean): void {
			_useTrace = __value;
		}

		public static function get useJavascriptConsole(): Boolean {
			return _useJavascriptConsole;
		}
		public static function set useJavascriptConsole(__value:Boolean): void {
			_useJavascriptConsole = __value;
		}

		public static function get useScreen(): Boolean {
			return _useScreen;
		}
		public static function set useScreen(__value:Boolean): void {
			if (_useScreen != __value) {
				_useScreen = __value;
				if (_useScreen) createTextField();
				if (!_useScreen) removeTextField();
			}
		}
	}
}

