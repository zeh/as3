package com.zehfernando.input.binding {
	import com.zehfernando.signals.SimpleSignal;
	import com.zehfernando.utils.MathUtils;

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

		// Provides universal input control for game controllers and keyboard

		// Properties
		private var _isStarted:Boolean;

		// Instances
		private var bindings:Vector.<BindingInfo>;						// Actual existing bindings, their action, and whether they're activated or not
		private var actionsActivations:Object;							// How many activations each action has (key string with ActivationInfo instance)

		private var _onActionActivated:SimpleSignal;					// Receives: action:String
		private var _onActionDeactivated:SimpleSignal;					// Receives: action:String
		private var _onSensitiveActionChanged:SimpleSignal;				// Receives: action:String, value:Number (0-1)

		// TODO: use caching samples?

		private var stage:Stage;
		private var gameInput:GameInput;

		private var alwaysPreventDefault:Boolean;								// If true, prevent action by other keys all the time (e.g. menu key)

		private var gameInputDevices:Vector.<GameInputDevice>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function KeyActionBinder(__stage:Stage) {
			stage = __stage;
			alwaysPreventDefault = true;
			bindings = new Vector.<BindingInfo>();
			actionsActivations = {};

			if (GameInput.isSupported) gameInput = new GameInput();

			_onActionActivated = new SimpleSignal();
			_onActionDeactivated = new SimpleSignal();
			_onSensitiveActionChanged = new SimpleSignal();

			refreshGameInputDeviceList();
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

		private function filterGamepadControls(__controlId:String, __gamepad:uint):Vector.<BindingInfo> {
			// Returns a list of all gamepad control bindings that fit a filter
			// This is faster than using Vector.<T>.filter()! With 10000 actions bound, this takes ~10ms, as opposed to ~13ms using filter()

			var filteredControls:Vector.<BindingInfo> = new Vector.<BindingInfo>();

			for (var i:int = 0; i < bindings.length; i++) {
				if (bindings[i].binding.matchesGamepadControl(__controlId, __gamepad)) filteredControls.push(bindings[i]);
			}

			return filteredControls;
		}

		private function prepareAction(__action:String):void {
			// Pre-emptively creates the list of activations for this action
			if (!actionsActivations.hasOwnProperty(__action)) actionsActivations[__action] = new ActivationInfo();
		}

		private function refreshGameInputDeviceList():void {
			// The list of game devices has changed
			removeGameInputDeviceEvents();
			addGameInputDeviceEvents();

			// Create a list of devices for easy identification
			gameInputDevices = new Vector.<GameInputDevice>();
			for (var i:int = 0; i < GameInput.numDevices; i++) {
				gameInputDevices.push(GameInput.getDeviceAt(i));
			}
		}

		private function addGameInputDeviceEvents():void {
			// Add events to all devices currently attached
			// http://www.adobe.com/devnet/air/articles/game-controllers-on-air.html

			var device:GameInputDevice;
			var i:int, j:int;

			for (i = 0; i < GameInput.numDevices; i++) {
                device = GameInput.getDeviceAt(i);

				// Some times the device is null because numDevices is updated before the added device event is dispatched
				if (device != null) {
					//debug("  Adding events to device (" + i + "): name = " + device.name + ", controls = " + device.numControls + ", sampleInterval = " + device.sampleInterval);
					device.enabled = true;
					for (j = 0; j < device.numControls; j++) {
						//debug("    Control id = " + device.getControlAt(j).id + ", val = " + device.getControlAt(j).minValue + " => " + device.getControlAt(j).maxValue);
						device.getControlAt(j).addEventListener(Event.CHANGE, onGameInputDeviceChanged, false, 0, true);
					}
				}
			}
		}

		private function removeGameInputDeviceEvents():void {
			// Remove events from all devices currently attached

			var device:GameInputDevice;
			var i:int, j:int;

			for (i = 0; i < GameInput.numDevices; i++) {
                device = GameInput.getDeviceAt(i);
				if (device != null) {
					for (j = 0; j < device.numControls; j++) {
						device.getControlAt(j).removeEventListener(Event.CHANGE, onGameInputDeviceChanged);
					}
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

			if (alwaysPreventDefault) __e.preventDefault();
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

			if (alwaysPreventDefault) __e.preventDefault();
		}

		private function onGameInputDeviceAdded(__e:GameInputEvent):void {
			//debug("Device added; num devices = " + GameInput.numDevices);
			refreshGameInputDeviceList();
		}

		private function onGameInputDeviceRemoved(__e:GameInputEvent):void {
			//debug("Device removed; num devices = " + GameInput.numDevices);
			refreshGameInputDeviceList();
		}

		private function onGameInputDeviceChanged(__e:Event):void {
			var control:GameInputControl = __e.target as GameInputControl;

			//debug("onGameInputDeviceChanged: " + control.id + " = " + control.value + " (of " + control.minValue + " => " + control.maxValue + ")");

			var filteredControls:Vector.<BindingInfo> = filterGamepadControls(control.id, gameInputDevices.indexOf(control.device));
			var idx:int;
			var activations:Vector.<BindingInfo>;
			var isActivated:Boolean = control.value > control.minValue + (control.maxValue - control.minValue) / 2;

			for (var i:int = 0; i < filteredControls.length; i++) {

				if (filteredControls[i].binding is GamepadSensitiveBinding) {
					// A sensitive binding, send changed value signals instead

					// Dispatches signal
					(actionsActivations[filteredControls[i].action] as ActivationInfo).sensitiveValues[filteredControls[i].action] = MathUtils.map(control.value, control.minValue, control.maxValue, (filteredControls[i].binding as GamepadSensitiveBinding).minValue, (filteredControls[i].binding as GamepadSensitiveBinding).maxValue);
					_onSensitiveActionChanged.dispatch(filteredControls[i].action, (actionsActivations[filteredControls[i].action] as ActivationInfo).value);
				} else {
					// A standard action binding, send activated/deactivated signals

					if (filteredControls[i].isActivated != isActivated) {
						// Value changed
						filteredControls[i].isActivated = isActivated;
						if (isActivated) {
							// Marks as pressed

							// Add this activation to the list of current activations
							(actionsActivations[filteredControls[i].action] as ActivationInfo).activations.push(filteredControls[i]);

							// Dispatches signal
							if ((actionsActivations[filteredControls[i].action] as ActivationInfo).activations.length == 1) _onActionActivated.dispatch(filteredControls[i].action);
						} else {
							// Marks as released

							// Removes this activation from the list of current activations
							activations = (actionsActivations[filteredControls[i].action] as ActivationInfo).activations;
							idx = activations.indexOf(filteredControls[i]);
							if (idx > -1) activations.splice(idx, 1);

							// Dispatches signal
							if (activations.length == 0) _onActionDeactivated.dispatch(filteredControls[i].action);
						}
					}
				}
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

			// Create a binding to be verified later
			bindings.push(new BindingInfo(__action, new KeyboardBinding(__keyCode, __keyLocation >= 0 ? __keyLocation : KeyboardBinding.KEY_LOCATION_ANY)));
			prepareAction(__action);
		}

		public function addGamepadActionBinding(__action:String, __controlId:String, __gamepadIndex:int = -1):void {
			// Create a binding to be verified later
			bindings.push(new BindingInfo(__action, new GamepadBinding(__controlId, __gamepadIndex >= 0 ? __gamepadIndex : GamepadBinding.GAMEPAD_INDEX_ANY)));
			prepareAction(__action);
		}

		public function addGamepadSensitiveActionBinding(__action:String, __controlId:String, __gamepadIndex:int = -1, __minValue:Number = 0, __maxValue:Number = 1):void {
			// Create a binding to be verified later
			bindings.push(new BindingInfo(__action, new GamepadSensitiveBinding(__controlId, __gamepadIndex >= 0 ? __gamepadIndex : GamepadBinding.GAMEPAD_INDEX_ANY, __minValue, __maxValue)));
			prepareAction(__action);
		}

		public function getActionValue(__action:String):Number {
			return actionsActivations.hasOwnProperty(__action) ? (actionsActivations[__action] as ActivationInfo).value : 0;
		}

		public function isActionActivated(__action:String):Boolean {
			return actionsActivations.hasOwnProperty(__action) && (actionsActivations[__action] as ActivationInfo).activations.length > 0;
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

		public function get onSensitiveActionChanged():SimpleSignal {
			return _onSensitiveActionChanged;
		}
	}
}
import com.zehfernando.input.binding.IBinding;

import flash.utils.Dictionary;
class ActivationInfo {

	public var activations:Vector.<BindingInfo>;			// All activated bindings
	public var sensitiveValues:Dictionary;					// Dictionary with IBinding

	// Temp
	private var val:Number;
	private var iis:Object;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function ActivationInfo() {
		activations = new Vector.<BindingInfo>();
		sensitiveValues = new Dictionary();
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function get value():Number {
		val = 0;
		for (iis in sensitiveValues) {
			if (sensitiveValues[iis] > val) val = sensitiveValues[iis];
		}
		return val;
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