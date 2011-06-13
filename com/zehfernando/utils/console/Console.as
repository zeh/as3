package com.zehfernando.utils.console {

	import com.zehfernando.utils.AppUtils;
	import com.zehfernando.utils.DebugUtils;

	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	/**
	 * @author zeh
	 */
	public class Console {

		// Constants
		public static const PARAM_PACKAGE_NAME:String = "[[package]]";
		public static const PARAM_CLASS_NAME:String = "[[class]]";
		public static const PARAM_FUNCTION_NAME:String = "[[function]]";
		public static const PARAM_OUTPUT:String = "[[output]]";
		public static const PARAM_TIME_NAME:String = "[[time-name]]";
		public static const PARAM_TIME_VALUE:String = "[[time-value]]";
		public static const PARAM_GROUP_NAME:String = "[[group]]";
		
		public static const ECHO_FORMAT_FULL:String = PARAM_PACKAGE_NAME + "." + PARAM_CLASS_NAME + "." + PARAM_FUNCTION_NAME + "() :: " + PARAM_OUTPUT;
		public static const ECHO_FORMAT_SHORT:String = PARAM_CLASS_NAME + "." + PARAM_FUNCTION_NAME + "() :: " + PARAM_OUTPUT;

		public static const TIME_FORMAT:String = PARAM_TIME_NAME + ": " + PARAM_TIME_VALUE + "ms";
		
		public static const GROUP_START_FORMAT:String = PARAM_GROUP_NAME + " \\\\\\ -------";
		public static const GROUP_END_FORMAT:String = PARAM_GROUP_NAME + " //// -------";
		
		public static var globalPrefix:String = "### ";
		public static var groupPrefix:String = "  ";
		
		public static var echoFormat:String = ECHO_FORMAT_SHORT;
		public static var timeFormat:String = TIME_FORMAT;
		public static var groupStartFormat:String = GROUP_START_FORMAT;
		public static var groupEndFormat:String = GROUP_END_FORMAT;

		protected static const JS_FUNCTION_LOG:String = "console.log";
		protected static const JS_FUNCTION_DEBUG:String = "console.debug";
		protected static const JS_FUNCTION_INFO:String = "console.info";
		protected static const JS_FUNCTION_WARNING:String = "console.warn";
		protected static const JS_FUNCTION_ERROR:String = "console.error";

		// Internal enums
		protected static const LOG_TYPE_LOG:String = "log";
		protected static const LOG_TYPE_DEBUG:String = "debug";
		protected static const LOG_TYPE_INFO:String = "info";
		protected static const LOG_TYPE_WARNING:String = "warning";
		protected static const LOG_TYPE_ERROR:String = "error";
		
		
		protected static var _useTrace:Boolean;
		protected static var _useScreen:Boolean;
		protected static var _useJS:Boolean;
		
		protected static var textField:TextField;
		
		protected static var timeTable:Object;						// Named array of ints
		protected static var groups:Vector.<String>;

		// http://getfirebug.com/logging
		
		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------
		
		{
			_useTrace = true;
			_useScreen = false;
			_useJS = false;
			
			timeTable = {};
			groups = new Vector.<String>();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
		
		protected static function createTextField(): void {
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

		protected static function removeTextField(): void {
			textField = new TextField();
			
			AppUtils.getStage().removeChild(textField);
			AppUtils.getStage().removeEventListener(Event.RESIZE, onScreenResizeResizeTextField);
			
			textField = null;
		}
		
		protected static function echo(__output:String, __type:String = null): void {
			// Raw writes something to the required outputs
			
			// Adds group spacing
			
			__output = getGroupsPrefix() + __output;
			__output = globalPrefix + __output;

			if (_useTrace) {
				trace (__output);
			}

			if (_useScreen) {
				textField.text = textField.text + __output + "\n"; // do not use append()
				textField.scrollV = textField.maxScrollV;
			}
			
			if (_useJS) {
				var jsFunction:String;
				switch (__type) {
					case LOG_TYPE_DEBUG:
						jsFunction = JS_FUNCTION_DEBUG;
						break;
					case LOG_TYPE_INFO:
						jsFunction = JS_FUNCTION_INFO;
						break;
					case LOG_TYPE_WARNING:
						jsFunction = JS_FUNCTION_WARNING;
						break;
					case LOG_TYPE_ERROR:
						jsFunction = JS_FUNCTION_ERROR;
						break;
					case LOG_TYPE_LOG:
					case null:
						jsFunction = JS_FUNCTION_LOG;
						break;
				}

				if (ExternalInterface.available) {
					try {
						ExternalInterface.call("function(__message) { if(typeof(console) !== 'undefined' && console != null) { " + jsFunction + "(__message); } }", __output);
					} catch (e:Error) {
						trace ("Log.echo error: Tried calling console.log(), but ExternalInterface is not available! Error: " + e);
					}
				} else {
					trace ("Log.echo error: Tried calling console.log(), but ExternalInterface is not available!");
				}
			}
		}
		
		protected static function getGroupsPrefix(): String {
			var str:String = "";
			var l:int = groups.length;
			while (l > 0) {
				str += groupPrefix;
				l--;
			}
			return str;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		// console.debug, console.info [i], console.warn [!], console.error [!!!]

		public static function log(__args:Array): void {
			// Logs something
			
			// TODO: organize this better. move all to echo()?
			
			var currCall:Vector.<String> = DebugUtils.getCurrentCallStack()[2]; // Package, class, function
			
			var output:String = echoFormat;
			output = output.split(PARAM_PACKAGE_NAME).join(currCall[0]);
			output = output.split(PARAM_CLASS_NAME).join(currCall[1]);
			output = output.split(PARAM_FUNCTION_NAME).join(currCall[2]);
			output = output.split(PARAM_OUTPUT).join(__args.join(" "));
			
			echo(output, LOG_TYPE_LOG);
		}
		
		public static function time(__name:String): void {
			timeTable[__name] = getTimer();
		}

		public static function timeEnd(__name:String): void {
			if (timeTable.hasOwnProperty(__name)) {
				var timePassed:int = timeTable[__name] - getTimer();
				var output:String = timeFormat;
				output = output.split(PARAM_TIME_NAME).join(__name);
				output = output.split(PARAM_TIME_VALUE).join(timePassed);
				echo(output);
				delete timeTable[__name];
			}
		}
		
		public static function group(__groupName:String = ""): void {
			var output:String = groupStartFormat;
			output = output.split(PARAM_GROUP_NAME).join(__groupName);

			echo(output);
			
			groups.push(__groupName);
		}

		public static function groupEnd(): void {
			if (groups.length > 0) {
				var groupName:String = groups.pop();

				var output:String = groupEndFormat;
				output = output.split(PARAM_GROUP_NAME).join(groupName);
	
				echo(output);
			}
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

		public static function get useJS(): Boolean {
			return _useJS;
		}
		public static function set useJS(__value:Boolean): void {
			_useJS = __value;
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

