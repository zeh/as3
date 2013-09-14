package com.zehfernando.input.binding {
	import com.zehfernando.signals.SimpleSignal;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.GameInputEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.utils.getTimer;
	/**
	 * @author zeh fernando
	 */
	public class KeyActionBinder {

		// Provides universal input control for game controllers and keyboard
		// http://zehfernando.com/2013/abstracting-key-and-game-controller-inputs-in-adobe-air/

		// TODO:
		// * isActionActivated() must properly support time tolerance
		// * Allow sensitive controls to be treated as normal controls
		// * think of a way to avoid axis injecting button pressed
		// * Add gamepad index to return signals
		// * Use caching samples?
		// * Allow "any" gamepad key?
		// * Allow sensitive control activation with threshold?
		// * Some missing asdocs
		// * Error on initialization, devices missing - try workaround with static initializer: http://forums.adobe.com/message/5618821#5618821

		// Properties
		private var _isRunning:Boolean;
		private var alwaysPreventDefault:Boolean;						// If true, prevent action by other keys all the time (e.g. menu key)

		// Instances
		private var bindings:Vector.<BindingInfo>;						// Actual existing bindings, their action, and whether they're activated or not
		private var actionsActivations:Object;							// How many activations each action has (key string with ActivationInfo instance)

		private var _onActionActivated:SimpleSignal;					// Receives: action:String
		private var _onActionDeactivated:SimpleSignal;					// Receives: action:String
		private var _onSensitiveActionChanged:SimpleSignal;				// Receives: action:String, value:Number (0-1)

		private var stage:Stage;
		private var gameInputDevices:Vector.<GameInputDevice>;

		private static var gameInput:GameInput;

		private var ii:int;												// Internal i, for speed
		private var it:int;												// Internal t, for speed

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		{
			if (GameInput.isSupported) gameInput = new GameInput();
		}

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function KeyActionBinder(__stage:Stage) {
			stage = __stage;
			alwaysPreventDefault = true;
			bindings = new Vector.<BindingInfo>();
			actionsActivations = {};

			_onActionActivated = new SimpleSignal();
			_onActionDeactivated = new SimpleSignal();
			_onSensitiveActionChanged = new SimpleSignal();

			start();
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

//			debug("Devices: " + GameInput.numDevices);

			for (i = 0; i < GameInput.numDevices; i++) {
				device = GameInput.getDeviceAt(i);

//				debug("  Found device (" + i + "): " + device);

				// Some times the device is null because numDevices is updated before the added device event is dispatched
				if (device != null) {
//					debug("  Adding events to device (" + i + "): name = " + device.name + ", controls = " + device.numControls + ", sampleInterval = " + device.sampleInterval);
					device.enabled = true;
					for (j = 0; j < device.numControls; j++) {
//						debug("    Control id = " + device.getControlAt(j).id + ", val = " + device.getControlAt(j).minValue + " => " + device.getControlAt(j).maxValue);
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
//			debug("key down: " + __e);
			var filteredKeys:Vector.<BindingInfo> = filterKeyboardKeys(__e.keyCode, __e.keyLocation);
			for (var i:int = 0; i < filteredKeys.length; i++) {
				if (!filteredKeys[i].isActivated) {
					// Marks as pressed
					filteredKeys[i].isActivated = true;
					filteredKeys[i].lastActivatedTime = getTimer();

					// Add this activation to the list of current activations
					(actionsActivations[filteredKeys[i].action] as ActivationInfo).activations.push(filteredKeys[i]);

					// Dispatches signal
					if ((actionsActivations[filteredKeys[i].action] as ActivationInfo).activations.length == 1) _onActionActivated.dispatch(filteredKeys[i].action);
				}
			}

			if (alwaysPreventDefault) __e.preventDefault();
		}

		private function onKeyUp(__e:KeyboardEvent):void {
//			debug("key up: " + __e);
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

		private function onGameInputDeviceUnusable(__e:GameInputEvent):void {
			//debug("A Device is unusable; num devices = " + GameInput.numDevices);
			refreshGameInputDeviceList();
		}

		private function onGameInputDeviceChanged(__e:Event):void {
			var control:GameInputControl = __e.target as GameInputControl;

//			debug("onGameInputDeviceChanged: " + control.id + " = " + control.value + " (of " + control.minValue + " => " + control.maxValue + ")");

			var filteredControls:Vector.<BindingInfo> = filterGamepadControls(control.id, gameInputDevices.indexOf(control.device));
			var idx:int;
			var activations:Vector.<BindingInfo>;
			var isActivated:Boolean = control.value > control.minValue + (control.maxValue - control.minValue) / 2;

			for (var i:int = 0; i < filteredControls.length; i++) {

				if (filteredControls[i].binding is GamepadSensitiveBinding) {
					// A sensitive binding, send changed value signals instead

					// Dispatches signal
					(actionsActivations[filteredControls[i].action] as ActivationInfo).sensitiveValues[filteredControls[i].action] = (control.value - control.minValue) / (control.maxValue - control.minValue) * ((filteredControls[i].binding as GamepadSensitiveBinding).maxValue - (filteredControls[i].binding as GamepadSensitiveBinding).minValue) + (filteredControls[i].binding as GamepadSensitiveBinding).minValue;
					_onSensitiveActionChanged.dispatch(filteredControls[i].action, (actionsActivations[filteredControls[i].action] as ActivationInfo).value);
				} else {
					// A standard action binding, send activated/deactivated signals

					if (filteredControls[i].isActivated != isActivated) {
						// Value changed
						filteredControls[i].isActivated = isActivated;
						if (isActivated) {
							// Marks as pressed
							filteredControls[i].lastActivatedTime = getTimer();

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

		/**
		 * Starts listening for input events.
		 *
		 * <p>This happens by default when a KeyActionBinder object is instantiated; this method is only useful if
		 * called after <code>stop()</code> has been used.</p>
		 *
		 * <p>Calling this method when a KeyActionBinder instance is already running has no effect.</p>
		 *
		 * @see #isRunning
		 * @see #stop()
		 */
		public function start():void {
			if (!_isRunning) {
				// Starts listening to keyboard events
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

				// Starts listening to device addition events
				if (gameInput != null) {
					gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onGameInputDeviceAdded);
					gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onGameInputDeviceRemoved);
					gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, onGameInputDeviceUnusable);
				}

				refreshGameInputDeviceList();

				_isRunning = true;
			}
		}

		/**
		 * Stops listening for input events.
		 *
		 * <p>Action bindings are not lost when a KeyActionBinder instance is stopped; it merely starts ignoring
		 * all input events, until <code>start()<code> is called again.</p>
		 *
		 * <p>This method should always be called when you don't need a KeyActionBinder instance anymore, otherwise
		 * it'll be listening to events indefinitely.</p>
		 *
		 * <p>Calling this method when this a KeyActionBinder instance is already stopped has no effect.</p>
		 *
		 * @see #isRunning
		 * @see #start()
		 */
		public function stop():void {
			if (_isRunning) {
				// Stops listening to keyboard events
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);

				// Stops listening to device addition events
				if (gameInput != null) {
					gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, onGameInputDeviceAdded);
					gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, onGameInputDeviceRemoved);
				}

				gameInputDevices = null;
				removeGameInputDeviceEvents();

				_isRunning = false;
			}
		}

		/**
		 * Add an action bound to a keyboard key. When a key with the given <code>keyCode</code> is pressed, the
		 * desired action is activated. Optionally, keys can be restricted to a specific <code>keyLocation</code>.
		 *
		 * @param action		An arbritrary String id identifying the action that should be dispatched once this
		 *						key combination is detected.
		 * @param keyCode		The code of a key, as expressed in AS3's Keyboard constants.
		 * @param keyLocation	The code of a key's location, as expressed in AS3's KeyLocation constants. If a
		 *						value of -1 or <code>NaN</code> is passed, the key location is never taken into
		 *						consideration when detecting whether the passed action should be fired.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Left arrow key to move left
		 * addKeyboardActionBinding("move-left", Keyboard.LEFT);
		 *
		 * // SPACE key to jump
		 * addKeyboardActionBinding("jump", Keyboard.SPACE);
		 *
		 * // Any SHIFT key to shoot
		 * addKeyboardActionBinding("shoot", Keyboard.SHIFT);
		 *
		 * // Left SHIFT key to boost
		 * addKeyboardActionBinding("boost", Keyboard.SHIFT, KeyLocation.LEFT);
		 * </pre>
		 *
		 * @see flash.ui.Keyboard
		 */
		public function addKeyboardActionBinding(__action:String, __keyCode:int = -1, __keyLocation:int = -1):void {
			// TODO: use KeyActionBinder.KEY_LOCATION_ANY as default param? The compiler doesn't like constants.

			// Create a binding to be verified later
			bindings.push(new BindingInfo(__action, new KeyboardBinding(__keyCode >= 0 ? __keyCode : KeyboardBinding.KEY_CODE_ANY, __keyLocation >= 0 ? __keyLocation : KeyboardBinding.KEY_LOCATION_ANY)));
			prepareAction(__action);
		}

		/**
		 * Add an action bound to a game controller button, trigger, or axis. When a control of id
		 * <code>controlId</code> is pressed, the desired action is activated. Optionally, keys can be restricted
		 * to a specific game controller location.
		 *
		 * @param action		An arbritrary String id identifying the action that should be dispatched once this
		 *						input combination is detected.
		 * @param controlId		The id code of a GameInput contol, as an String. Use one of the constants from
		 *						<code>GamepadControls</code>, or a string related to the control you're expecting.
		 * @param gamepadIndex	The int of the gamepad that you want to restrict this action to. Use 0 for the
		 *						first gamepad (player 1), 1 for the second one, and so on. If a value of -1 or
		 *						<code>NaN</code> is passed, the gamepad index is never taken into consideration
		 *						when detecting whether the passed action should be fired.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Direction pad left to move left
		 * addGamepadActionBinding("move-left", GamepadControls.DPAD_LEFT);
		 *
		 * // Action button "down" (O in the OUYA, Cross in the PS3, A in the XBox 360) to jump
		 * addGamepadActionBinding("jump", GamepadControls.BUTTON_ACTION_DOWN);
		 *
		 * // L1 to shoot, on any controller
		 * addGamepadActionBinding("shoot", GamepadControls.L1);
		 *
		 * // L1 to shoot, on the first controller only
		 * addGamepadActionBinding("shoot-player-1", GamepadControls.L1, 0);
		 * </pre>
		 *
		 * @see GamepadControls
		 */
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

		/**
		 * Checks whether an action is currently activated (in practice, a button is pressed).
		 *
		 * @param action				An arbritrary String id identifying the action that should be checked.
		 * @param timeToleranceSeconds	Time tolerance, in seconds, before the action is assumed to be expired. If < 0, no time is checked.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Moves player right when right is pressed
		 * // Setup:
		 * addGamepadActionBinding("move-right", GamepadControls.DPAD_RIGHT);
		 * // In the game loop:
		 * if (isActionActivated("move-right")) {
		 *     player.moveRight();
		 * }
		 *
		 * // Check if a jump was activated (includes just before falling, for a more user-friendly control):
		 * if (isTouchingSurface && isActionActivated("jump"), 0.1) {
		 *     player.moveRight();
		 * }
		 * </pre>
		 */
		public function isActionActivated(__action:String, __timeToleranceSeconds:Number = 0):Boolean {
			if (actionsActivations.hasOwnProperty(__action) && (actionsActivations[__action] as ActivationInfo).activations.length > 0) {
				if (__timeToleranceSeconds <= 0) {
					// No need for time tolerance check
					return true;
				} else {
					// Needs to check the time
					var actionActivations:Vector.<BindingInfo> = (actionsActivations[__action] as ActivationInfo).activations;
					it = getTimer() - __timeToleranceSeconds * 1000;
					for (ii = 0; ii < actionActivations.length; ii++) {
						if (actionActivations[ii].lastActivatedTime >= it) return true;
					}
				}
			}

			return false;
		}

		public function consumeAction(__action:String):void {
			// Deactivates all current actions of an action (forcing a button to be pressed again)
			if (actionsActivations.hasOwnProperty(__action)) (actionsActivations[__action] as ActivationInfo).activations.length = 0;
		}


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

		public function get isRunning():Boolean {
			return _isRunning;
		}
	}
}
import flash.utils.Dictionary;
/**
 * Information listing all activated bindings of a given action
 */
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
		val = NaN;
		for (iis in sensitiveValues) {
			// NOTE: this will be a problem if two axis control the same action, since +1 is not necessarily better than -1
			if (isNaN(val) || sensitiveValues[iis] > val) val = sensitiveValues[iis];
		}
		return val;
	}
}

/**
 * Information linking an action to a binding, and whether it's activated
 */
class BindingInfo {

	// Properties
	public var action:String;
	public var binding:IBinding;
	public var isActivated:Boolean;
	public var lastActivatedTime:uint;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function BindingInfo(__action:String = "", __binding:IBinding = null) {
		action = __action;
		binding = __binding;
		isActivated = false;
		lastActivatedTime = 0;
	}
}

interface IBinding {
	function matchesKeyboardKey(__keyCode:uint, __keyLocation:uint):Boolean;
	function matchesGamepadControl(__controlId:String, __gamepadIndex:uint):Boolean;
}

/**
 * Information on a keyboard event filter
 */
class KeyboardBinding implements IBinding {

	// Constants
	public static var KEY_CODE_ANY:uint = 81653812;
	public static var KEY_LOCATION_ANY:uint = 8165381;

	// Properties
	public var keyCode:uint;
	public var keyLocation:uint;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function KeyboardBinding(__keyCode:uint, __keyLocation:uint) {
		super();

		keyCode = __keyCode;
		keyLocation = __keyLocation;
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function matchesKeyboardKey(__keyCode:uint, __keyLocation:uint):Boolean {
		return (keyCode == __keyCode || keyCode == KEY_CODE_ANY) && (keyLocation == __keyLocation || keyLocation == KEY_LOCATION_ANY);
	}

	// TODO: add modifiers?

	public function matchesGamepadControl(__controlId:String, __gamepadIndex:uint):Boolean {
		return false;
	}
}

/**
 * Information on a gamepad event filter
 */
class GamepadBinding implements IBinding {

	// Constants
	public static var GAMEPAD_INDEX_ANY:uint = 8165381;

	// Properties
	public var controlId:String;
	public var gamepadIndex:uint;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function GamepadBinding(__controlId:String, __gamepadIndex:uint) {
		super();

		controlId = __controlId;
		gamepadIndex = __gamepadIndex;
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function matchesGamepadControl(__controlId:String, __gamepadIndex:uint):Boolean {
		return controlId == __controlId && (gamepadIndex == __gamepadIndex || gamepadIndex == GAMEPAD_INDEX_ANY);
	}

	public function matchesKeyboardKey(__keyCode:uint, __keyLocation:uint):Boolean {
		return false;
	}

	// TODO: add option to restrict to a given gamepad based on name? (e.g. OUYA)
}

/**
 * Information on a gamepad event filter with sensitivity values
 */
class GamepadSensitiveBinding extends GamepadBinding {

	// Properties
	public var minValue:Number;
	public var maxValue:Number;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function GamepadSensitiveBinding(__controlId:String, __gamepadIndex:uint, __minValue:Number, __maxValue:Number) {
		super(__controlId, __gamepadIndex);

		minValue = __minValue;
		maxValue = __maxValue;
	}
}