package com.zehfernando.input {
	import com.zehfernando.signals.SimpleSignal;
	import com.zehfernando.utils.console.log;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.GameInputEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	/**
	 * @author zeh fernando
	 */
	public class UniversalBinder {

		// Provides universal input control, especially for game and keyboard

		// A proxy class: http://pastebin.com/BQQGH34H

		// Properties
		private var _isStarted:Boolean;

		// Instances
		private var bindings:Vector.<Binding>;						// Actual bindings
		private var commandsActivations:Object;						// How many activations each command has (key string with value uint)

		private var _onCommandPressed:SimpleSignal;
		private var _onCommandFired:SimpleSignal;
		private var _onCommandReleased:SimpleSignal;

		private var stage:Stage;
		private var gameInput:GameInput;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function UniversalBinder(__stage:Stage) {
			stage = __stage;
			gameInput = new GameInput();
			bindings = new Vector.<Binding>();
			commandsActivations = {};

			_onCommandPressed = new SimpleSignal();
			_onCommandFired = new SimpleSignal();
			_onCommandReleased = new SimpleSignal();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function filterKeys(__keyCode:uint, __keyLocation:uint):Vector.<Binding> {
			// Returns a list of all key bindings that fit a filter

			var filteredKeys:Vector.<Binding> = new Vector.<Binding>();

			for (var i:int = 0; i < bindings.length; i++) {
				if (bindings[i].keyCode == __keyCode && bindings[i].keyLocation == __keyLocation) {
					filteredKeys.push(bindings[i]);
				}
			}

			return filteredKeys;
		}
		
		private function addGameInputDeviceEvents():void {
			// Add events to all devices currently attached
			// http://www.adobe.com/devnet/air/articles/game-controllers-on-air.html

			var device:GameInputDevice;
			var i:int, j:int;

			for (i = 0; i < GameInput.numDevices; i++) {
                device = GameInput.getDeviceAt(i);
				device.enabled = true;
				for (j = 0; j < device.numControls; j++) {
					device.getControlAt(i).addEventListener(Event.CHANGE, onGameInputDeviceChanged, false, 0, true);
				}
			}
		}

		private function removeGameInputDeviceEvents():void {
			// Remove events from all devices currently attached

			var device:GameInputDevice;
			var i:int, j:int;

			for (i = 0; i < GameInput.numDevices; i++) {
                device = GameInput.getDeviceAt(i);
				for (j = 0; j < device.numControls; j++) {
					device.getControlAt(i).removeEventListener(Event.CHANGE, onGameInputDeviceChanged);
				}
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onKeyDown(__e:KeyboardEvent):void {
			//	log("key down: " + __e);
			var filteredKeys:Vector.<Binding> = filterKeys(__e.keyCode, __e.keyLocation);
			for (var i:int = 0; i < filteredKeys.length; i++) {
				if (!filteredKeys[i].isPressed) {
					// Marks as pressed
					filteredKeys[i].isPressed = true;
					
					// Counts as one press of that command, creating if needed
					if (!commandsActivations.hasOwnProperty(filteredKeys[i].command)) commandsActivations[filteredKeys[i].command] = 0;
					commandsActivations[filteredKeys[i].command]++;
					
					// Dispatches signal
					_onCommandPressed.dispatch(filteredKeys[i].command);
				}

				_onCommandFired.dispatch(filteredKeys[i].command);
			}
		}

		private function onKeyUp(__e:KeyboardEvent):void {
			var filteredKeys:Vector.<Binding> = filterKeys(__e.keyCode, __e.keyLocation);
			for (var i:int = 0; i < filteredKeys.length; i++) {
				// Marks as released
				filteredKeys[i].isPressed = false;

				// Removes the press count
				commandsActivations[filteredKeys[i].command]--;

				// Dispatches signal
				_onCommandReleased.dispatch(filteredKeys[i].command);
			}
		}
		
		private function onGameInputDeviceAdded(__e:GameInputEvent):void {
			removeGameInputDeviceEvents();
			addGameInputDeviceEvents();
		}

		private function onGameInputDeviceRemoved(__e:GameInputEvent):void {
			removeGameInputDeviceEvents();
		}

		private function onGameInputDeviceChanged(__e:Event):void {
			var control:GameInputControl = __e.target as GameInputControl;
			
			if (control.value > control.minValue + (control.maxValue - control.minValue) / 2) {
				// It is activated
				log("control activated => " + control);
				// TODO:
				// * register command as activated
				// * register command value
			} else {
				log("control deactivated => " + control);
			}
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function start():void {
			if (!_isStarted) {
				// Starts listening to keyboard events
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				
				// Starts listening to device addition events
				gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onGameInputDeviceAdded);
                gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onGameInputDeviceRemoved);
				

				_isStarted = true;
			}
		}

		public function stop():void {
			if (_isStarted) {
				// Stops listening to keyboard events
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);

				// Stops listening to device addition events
				gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, onGameInputDeviceAdded);
                gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, onGameInputDeviceRemoved);

				_isStarted = false;
			}
		}

		public function addCommandBinding(__keyCode:int, __keyLocation:int):void {
			var binding:Binding = new Binding();
			binding.keyCode = __keyCode;
			binding.keyLocation = __keyLocation;
			bindings.push(binding);
		}
		
		public function isCommandPressed(__command:String):Boolean {
			return commandsActivations.hasOwnProperty(__command) && commandsActivations[__command] > 0;
		}

//		public function setFromXML(__xmlData:XML):void {
//			// Set items from a list of <key> nodes
//
//			var keyDatas:XMLList = __xmlData.child("key");
//
//			for (var i:int = 0; i < keyDatas.length(); i++) {
//				keys.push(Binding.fromXML(keyDatas[i]));
//			}
//		}


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

class Binding {

	// Properties
	public var keyCode:uint;
	public var keyLocation:uint;
	public var command:String;
	public var isPressed:Boolean;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function Binding() {
		keyCode = 0;
		keyLocation = 0;
		command = "";
		isPressed = false;
	}

	// TODO: add modifiers

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

//	public static function fromXML(__keyData:XML):Binding {
//		// Based on a <key> node, returns a key binding instance
//		// E.g.: <key code="8" shift="true">focus_prev</key>
//
//		var binding:Binding = new Binding();
//
//		binding.keyCode			= XMLUtils.getAttributeAsInt(__keyData, "code");
//		binding.modifierShift	= XMLUtils.getAttributeAsBoolean(__keyData, "shift");
//		binding.command			= __keyData.toString();
//
//		return binding;
//	}
}