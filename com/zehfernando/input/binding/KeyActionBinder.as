package com.zehfernando.input.binding {
	import com.zehfernando.signals.SimpleSignal;
	import com.zehfernando.utils.console.debug;

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
	public class KeyActionBinder {

		// Provides universal input control, especially for game and keyboard

		// A proxy class: http://pastebin.com/BQQGH34H
		// http://www.adobe.com/devnet/air/articles/game-controllers-on-air.html

		// Properties
		private var _isStarted:Boolean;

		// Instances
		private var bindings:Vector.<BindingInfo>;						// Actual bindings, their action, and whether they're activated or not
		private var actionsActivations:Object;							// How many activations each action has (key string with ActivationInfo instance)

		private var _onActionActivated:SimpleSignal;					// Receives: action:String
		private var _onActionDeactivated:SimpleSignal;					// Receives: action:String

		// TODO: use caching samples?

		private var stage:Stage;
		private var gameInput:GameInput;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function KeyActionBinder(__stage:Stage) {
			stage = __stage;
			if (GameInput.isSupported) gameInput = new GameInput();
			bindings = new Vector.<BindingInfo>();
			actionsActivations = {};

			_onActionActivated = new SimpleSignal();
			_onActionDeactivated = new SimpleSignal();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function filterKeyboardKeys(__keyCode:uint, __keyLocation:uint):Vector.<BindingInfo> {
			// Returns a list of all key bindings that fit a filter
			// This is faster than using Vector.<T>.filter()! With 10000 actions bound, this takes ~10ms, as opposed to ~13ms using filter()

			var filteredKeys:Vector.<BindingInfo> = new Vector.<BindingInfo>();

			for (var i:int = 0; i < bindings.length; i++) {
				if (bindings[i].binding.matchesKeyboardKey(__keyCode, __keyLocation)) filteredKeys.push(bindings[i]);
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
				debug("  Device (" + i + "): name = " + device.name + ", controls = " + device.numControls + ", sampleInterval = " + device.sampleInterval);
				device.enabled = true;
				for (j = 0; j < device.numControls; j++) {
					debug("    Control id = " + device.getControlAt(j).id + ", val = " + device.getControlAt(j).minValue + " => " + device.getControlAt(j).maxValue);
					device.getControlAt(j).addEventListener(Event.CHANGE, onGameInputDeviceChanged, false, 0, true);
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
			//debug("key down: " + __e);
			var filteredKeys:Vector.<BindingInfo> = filterKeyboardKeys(__e.keyCode, __e.keyLocation);
			for (var i:int = 0; i < filteredKeys.length; i++) {
				if (!filteredKeys[i].isActivated) {
					// Marks as pressed
					filteredKeys[i].isActivated = true;

					// Add this activation to the list of current activations
					(actionsActivations[filteredKeys[i].action] as ActivationInfo).activations.push(filteredKeys[i]);
					
					// Dispatches signal
					if ((actionsActivations[filteredKeys[i].action] as ActivationInfo).activations.length == 1) _onActionActivated.dispatch(filteredKeys[i].action);
				}
			}
		}

		private function onKeyUp(__e:KeyboardEvent):void {
			//debug("key up: " + __e);
			var filteredKeys:Vector.<BindingInfo> = filterKeyboardKeys(__e.keyCode, __e.keyLocation);
			var idx:int;
			var activations:Vector.<BindingInfo>;
			for (var i:int = 0; i < filteredKeys.length; i++) {
				// Marks as released
				filteredKeys[i].isActivated = false;

				// Removes this activation from the list of current activations
				activations = (actionsActivations[filteredKeys[i].action] as ActivationInfo).activations;
				idx = activations.indexOf(filteredKeys[i]);
				if (idx > -1) activations.splice(idx, 1);
				
				// Dispatches signal
				if (activations.length == 0) _onActionDeactivated.dispatch(filteredKeys[i].action);
			}
		}

		private function onGameInputDeviceAdded(__e:GameInputEvent):void {
			debug("Device added; num devices = " + GameInput.numDevices);
			removeGameInputDeviceEvents();
			addGameInputDeviceEvents();
		}

		private function onGameInputDeviceRemoved(__e:GameInputEvent):void {
			debug("Device removed; num devices = " + GameInput.numDevices);
			removeGameInputDeviceEvents();
		}

		private function onGameInputDeviceChanged(__e:Event):void {
			var control:GameInputControl = __e.target as GameInputControl;

			debug("onGameInputDeviceChanged: " + control.id + " = " + control.value + " (of " + control.minValue + " => " + control.maxValue + ")");

			if (control.value > control.minValue + (control.maxValue - control.minValue) / 2) {
				// It is activated
				debug("control activated => " + control);
				// TODO:
				// * register action as activated
				// * register action value
			} else {
				debug("control deactivated => " + control);
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
				if (gameInput != null) {
					gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onGameInputDeviceAdded);
					gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onGameInputDeviceRemoved);
				}

				_isStarted = true;
			}
		}

		public function stop():void {
			if (_isStarted) {
				// Stops listening to keyboard events
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);

				// Stops listening to device addition events
				if (gameInput != null) {
					gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, onGameInputDeviceAdded);
					gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, onGameInputDeviceRemoved);
				}

				_isStarted = false;
			}
		}

		public function addKeyboardActionBinding(__action:String, __keyCode:uint, __keyLocation:int = -1):void {
			// TODO: use  KeyActionBinder.KEY_LOCATION_ANY as default param?
			// TODO: support gamepads

			// Create a binding to be verified later
			bindings.push(new BindingInfo(__action, new KeyboardBinding(__keyCode, __keyLocation >= 0 ? __keyLocation : KeyboardBinding.KEY_LOCATION_ANY)));

			// Pre-emptively creates the list of activations fcor this action
			if (!actionsActivations.hasOwnProperty(__action)) actionsActivations[__action] = new ActivationInfo();

		}

		public function isActionPressed(__action:String):Boolean {
			return actionsActivations.hasOwnProperty(__action) && actionsActivations[__action] > 0;
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

		public function get onActionActivated():SimpleSignal {
			return _onActionActivated;
		}

		public function get onActionDeactivated():SimpleSignal {
			return _onActionDeactivated;
		}
	}
}
import com.zehfernando.input.binding.IBinding;
class ActivationInfo {
	
	public var activations:Vector.<BindingInfo>;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function ActivationInfo() {
		activations = new Vector.<BindingInfo>();
	}
}

class BindingInfo {

	// Properties
	public var action:String;
	public var binding:IBinding;
	public var isActivated:Boolean;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function BindingInfo(__action:String = "", __binding:IBinding = null) {
		action = __action;
		binding = __binding;
		isActivated = false;
	}
}