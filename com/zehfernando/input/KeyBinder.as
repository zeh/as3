package com.zehfernando.input {
	import com.zehfernando.signals.SimpleSignal;

	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	/**
	 * @author zeh fernando
	 */
	public class KeyBinder {

		/**
		 * Binds keys to commands
		 */

		// Properties
		private var _isStarted:Boolean;

		// Instances
		private var keys:Vector.<KeyBinding>;

		private var _onCommandPressed:SimpleSignal;
		private var _onCommandFired:SimpleSignal;
		private var _onCommandReleased:SimpleSignal;

		private var stage:Stage;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function KeyBinder() {
			keys = new Vector.<KeyBinding>();

			_onCommandPressed = new SimpleSignal();
			_onCommandFired = new SimpleSignal();
			_onCommandReleased = new SimpleSignal();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function filterKeys(__keyCode:uint, __modifierShift:Boolean):Vector.<KeyBinding> {
			// Returns a list of all key bindings that fit a filter

			var filteredKeys:Vector.<KeyBinding> = new Vector.<KeyBinding>();

			for (var i:int = 0; i < keys.length; i++) {
				if (keys[i].keyCode == __keyCode && keys[i].modifierShift == __modifierShift) {
					filteredKeys.push(keys[i]);
				}
			}

			return filteredKeys;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onKeyDown(__e:KeyboardEvent):void {
			//	log("key down: " + __e);
			var filteredKeys:Vector.<KeyBinding> = filterKeys(__e.keyCode, __e.shiftKey);
			for (var i:int = 0; i < filteredKeys.length; i++) {
				if (!filteredKeys[i].isPressed) {
					filteredKeys[i].isPressed = true;
					_onCommandPressed.dispatch(filteredKeys[i].command);
				}

				//log(i + ") Filtering keys presses for " + __e.keyCode, __e.shiftKey, "  ====> " + filteredKeys[i].command);
				_onCommandFired.dispatch(filteredKeys[i].command);
			}
		}

		private function onKeyUp(__e:KeyboardEvent):void {
			var filteredKeys:Vector.<KeyBinding> = filterKeys(__e.keyCode, __e.shiftKey);
			for (var i:int = 0; i < filteredKeys.length; i++) {
				filteredKeys[i].isPressed = false;
				_onCommandReleased.dispatch(filteredKeys[i].command);
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function start(__stage:Stage):void {
			if (!_isStarted) {
				stage = __stage;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);

				_isStarted = true;
			}
		}

		public function stop():void {
			if (_isStarted) {
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
				stage = null;

				_isStarted = false;
			}
		}

		public function setFromXML(__xmlData:XML):void {
			// Set items from a list of <key> nodes

			var keyDatas:XMLList = __xmlData.child("key");

			for (var i:int = 0; i < keyDatas.length(); i++) {
				keys.push(KeyBinding.fromXML(keyDatas[i]));
			}
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get onCommandPressed():SimpleSignal {
			return _onCommandPressed;
		}

		public function get onCommandFired():SimpleSignal {
			return _onCommandFired;
		}

		public function get onCommandReleased():SimpleSignal {
			return _onCommandReleased;
		}

	}
}
import com.zehfernando.utils.XMLUtils;
class KeyBinding {

	// Properties
	public var keyCode:uint;
	public var modifierShift:Boolean;
	public var command:String;
	public var isPressed:Boolean;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function KeyBinding() {
		keyCode = 0;
		modifierShift = false;
		command = "";
		isPressed = false;
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public static function fromXML(__keyData:XML):KeyBinding {
		// Based on a <key> node, returns a key binding instance
		// E.g.: <key code="8" shift="true">focus_prev</key>

		var binding:KeyBinding = new KeyBinding();

		binding.keyCode			= XMLUtils.getAttributeAsInt(__keyData, "code");
		binding.modifierShift	= XMLUtils.getAttributeAsBoolean(__keyData, "shift");
		binding.command			= __keyData.toString();

		return binding;
	}
}