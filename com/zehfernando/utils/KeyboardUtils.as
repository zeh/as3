package com.zehfernando.utils {
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class KeyboardUtils {

		// Poperties
		protected static var isInited:Boolean;

		protected static var controlDown:Boolean;
		protected static var shiftDown:Boolean;

		protected static var stage:Stage;

		//protected static var downLCONTROL:Boolean;
		//protected static var downRCONTROL:Boolean;
		//protected static var downALTGR:Boolean; // 18
		//protected static var downLSHIFT:Boolean;
		//protected static var downRSHIFT:Boolean;

		// ================================================================================================================
		// INITIALIZATION functions ---------------------------------------------------------------------------------------

		public static function init(__stage:Stage):void {
			if (!isInited) {
				stage = __stage;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				isInited = true;
			}
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected static function onKeyDown(e:KeyboardEvent):void {
			//Logger.getInstance().addMessage("Key down: "+e.keyCode+" @ "+e.keyLocation);
			//setKeyState(e.keyCode, e.keyLocation, true);
			shiftDown = e.shiftKey;
			controlDown = e.ctrlKey;
		}

		protected static function onKeyUp(e:KeyboardEvent):void {
			//Logger.getInstance().addMessage("Key up: "+e.keyCode+" @ "+e.keyLocation);
			//setKeyState(e.keyCode, e.keyLocation, false);
			shiftDown = e.shiftKey;
			controlDown = e.ctrlKey;
		}

		// ================================================================================================================
		// PUBLIC functions -----------------------------------------------------------------------------------------------

		public static function isShiftDown():Boolean {
			return shiftDown;
		}

		public static function isControlDown():Boolean {
			return controlDown;
		}

		// System-specific keys, as separate functions for easier modification if needed

		public static function isAdditionalSelectionModifierDown():Boolean {
			// Additional selection key
			return shiftDown;
		}

		public static function isMenuControlDown():Boolean {
			// CTRL on Windows, COMMAND on Mac (same for actionscript)
			return controlDown;
		}

		public static function isMenuShiftDown():Boolean {
			// SHIFT on all
			return shiftDown;
		}

		public static function getValidMenuKeys(): Vector.<String> {
			// Keys that are used on menus
			var keys:Vector.<String> = new Vector.<String>();
			keys.push("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");
			keys.push("0","1","2","3","4","5","6","7","8","9");
			keys.push("tab","del");
			keys.push("f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15");
			keys.push("[","]");
			return keys;
		}

		public static function getKeyCode(__key:String):Number {
			// Returns the char code of a key as determined by a getValidMenuKeys() string
			var keyCode:Number;
			switch (__key) {
				case "tab":
					keyCode = Keyboard.TAB;
					break;
				case "del":
					keyCode = Keyboard.DELETE;
					break;
				case "f1":
					keyCode = Keyboard.F1;
					break;
				case "f2":
					keyCode = Keyboard.F2;
					break;
				case "f3":
					keyCode = Keyboard.F3;
					break;
				case "f4":
					keyCode = Keyboard.F4;
					break;
				case "f5":
					keyCode = Keyboard.F5;
					break;
				case "f6":
					keyCode = Keyboard.F6;
					break;
				case "f7":
					keyCode = Keyboard.F7;
					break;
				case "f8":
					keyCode = Keyboard.F8;
					break;
				case "f9":
					keyCode = Keyboard.F9;
					break;
				case "f10":
					keyCode = Keyboard.F10;
					break;
				case "f11":
					keyCode = Keyboard.F11;
					break;
				case "f12":
					keyCode = Keyboard.F12;
					break;
				case "f13":
					keyCode = Keyboard.F13;
					break;
				case "f14":
					keyCode = Keyboard.F14;
					break;
				case "f15":
					keyCode = Keyboard.F15;
					break;
				case "[":
					keyCode = 219;
					break;
				case "]":
					keyCode = 221;
					break;
				default:
					keyCode = __key.toUpperCase().charCodeAt(0);
			}
			return keyCode;
		}

		public static function getKeyEquivalent(__key:String):String {
			return __key.length == 1 ? __key : "";
		}
	}
}
