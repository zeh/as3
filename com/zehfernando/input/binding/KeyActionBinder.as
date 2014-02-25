package com.zehfernando.input.binding {
	import com.zehfernando.signals.SimpleSignal;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.GameInputEvent;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.ui.GameInput;
	import flash.ui.GameInputControl;
	import flash.ui.GameInputDevice;
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	/**
	 * @author zeh fernando
	 */
	public class KeyActionBinder {

		// Provides universal input control for game controllers and keyboard

		// More info: https://github.com/zeh/key-action-binder

		// Constants
		public static const VERSION:String = "1.8.6";

		[Embed(source = "controllers.json", mimeType='application/octet-stream')]
		private static const JSON_CONTROLLERS:Class;

		// List of all auto-configurable gamepads
		private static var knownGamepadPlatforms:Vector.<AutoPlatformInfo>;

		private static var stage:Stage;

		// Properties
		private var _isRunning:Boolean;
		private var _alwaysPreventDefault:Boolean;						// If true, prevent action by other keys all the time (e.g. menu key)
		private var _maintainPlayerPositions:Boolean;					// Whether it tries to keep player positions or not

		// Instances
		private var bindings:Vector.<BindingInfo>;						// Actual existing bindings, their action, and whether they're activated or not
		private var actionsActivations:Object;							// How many activations each action has (key string with ActivationInfo instance)

		private var _onActionActivated:SimpleSignal;					// Receives: action:String
		private var _onActionDeactivated:SimpleSignal;					// Receives: action:String
		private var _onActionValueChanged:SimpleSignal;					// Receives: action:String, value:Number (0-1)
		private var _onDevicesChanged:SimpleSignal;

		private var gameInputDevices:Vector.<GameInputDevice>;
		private var gameInputDeviceIds:Vector.<String>;
		private var gameInputDeviceDefinitions:Vector.<AutoGamepadInfo>;

		private static var gameInput:GameInput;

		// Properties to avoid allocations
		private var mi:Number;											// Used in map()

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		/**
		 * Initializes the KeyActionBinder class. This is necessary to allocate global references needed by
		 * KeyActionBinder instances.
		 *
		 * <p>Due to bugs in Flash's GameInput API (especially on OUYA and Android), this initialization should be
		 * done in the first frame of your SWF, preferably in the root class of your movie.</p>
		 *
		 * @param stage		Flash's global stage, used for adding event listeners.
		 *
		 * @see #KeyActionBinder()
		 */
		public static function init(__stage:Stage):void  {
			stage = __stage;

//			var ti:int = getTimer();

			if (GameInput.isSupported) gameInput = new GameInput();

			// Loads the list of all known gamepads via a more readable/editable initializer
			var controllersData:Object = JSON.parse(String(new JSON_CONTROLLERS()).replace(/\/\*.*?\*\//sg, ""));
			var allPlatforms:Object = controllersData["platforms"];

			// Parse the platformObj into a proper, faster AutoPlatformInfo list
			knownGamepadPlatforms = new Vector.<AutoPlatformInfo>();

			var platformInfo:AutoPlatformInfo, gamepadInfo:AutoGamepadInfo, controlInfo:AutoGamepadControlInfo, controlKeyInfo:AutoGamepadControlKeyInfo;
			var iis:String, jjs:String, kks:String, kjs:String;
			var platformObj:Object, gamepadObj:Object, controlObj:Object, keyObj:Object, controlObjSplit:Object;
			var manufacturerFilters:Vector.<String>, osFilters:Vector.<String>, versionFilters:Vector.<String>;

			for (iis in allPlatforms) {
				platformObj = allPlatforms[iis];

				manufacturerFilters = arrayToStringVector(platformObj["filters"]["manufacturer"]);
				osFilters           = arrayToStringVector(platformObj["filters"]["os"]);
				versionFilters      = arrayToStringVector(platformObj["filters"]["version"]);

				// Only keep items in memory if the version passes the filters
				if ((manufacturerFilters.length == 0 || searchFromStringVector(manufacturerFilters, Capabilities.manufacturer)) &&
					(osFilters.length == 0           || searchFromStringVector(osFilters, Capabilities.os)                    ) &&
					(versionFilters.length == 0      || searchFromStringVector(versionFilters, Capabilities.version)          )) {
					// Add this platform (same as current platform)

					platformInfo = new AutoPlatformInfo();
					platformInfo.id                 = iis;
					platformInfo.manufacturerFilter = manufacturerFilters;
					platformInfo.osFilter           = osFilters;
					platformInfo.versionFilter      = versionFilters;

					knownGamepadPlatforms.push(platformInfo);

					// Add possible gamepads
					for (jjs in platformObj["gamepads"]) {
						gamepadObj = platformObj["gamepads"][jjs];

						gamepadInfo = new AutoGamepadInfo();
						gamepadInfo.id          = jjs;
						gamepadInfo.platformId  = iis;
						gamepadInfo.nameFilter  = arrayToStringVector(gamepadObj["filters"]["name"]);

						platformInfo.gamepads.push(gamepadInfo);

						// Add possible controls
						for (kks in gamepadObj["controls"]) {
							controlObj = gamepadObj["controls"][kks];

							if (controlObj.hasOwnProperty("target")) {
								// Single control: control min-max mapped to the target min-max
								controlInfo = new AutoGamepadControlInfo();
								controlInfo.id	= controlObj["target"];
								controlInfo.minOutput	= controlObj["min"];
								controlInfo.maxOutput	= controlObj["max"];

								gamepadInfo.controls[kks] = controlInfo;
							} else if (controlObj.hasOwnProperty("targets")) {
								// Multiple targets: split control where min-max ranges get clampped and mapped to the target min-max

								gamepadInfo.controlsSplit[kks] = new Vector.<AutoGamepadControlInfo>();

								for (kjs in controlObj["targets"]) {
									controlObjSplit = controlObj["targets"][kjs];

									controlInfo = new AutoGamepadControlInfo();
									controlInfo.id	= controlObjSplit["target"];
									controlInfo.minInput	= controlObjSplit["min"];
									controlInfo.maxInput	= controlObjSplit["max"];
									controlInfo.minOutput	= controlObj["min"];
									controlInfo.maxOutput	= controlObj["max"];

									(gamepadInfo.controlsSplit[kks] as Vector.<AutoGamepadControlInfo>).push(controlInfo);
								}
							}

						}

						// Add keyboard injections (keys that double as gamepad controls)
						for (kks in gamepadObj["keys"]) {
							keyObj = gamepadObj["keys"][kks];

							controlKeyInfo = new AutoGamepadControlKeyInfo();
							controlKeyInfo.keyCode		= Keyboard[keyObj["code"]];
							controlKeyInfo.keyLocation	= KeyLocation[keyObj["location"]];
							controlKeyInfo.id			= keyObj["target"];
							controlKeyInfo.min			= keyObj["min"];
							controlKeyInfo.max			= keyObj["max"];

							gamepadInfo.keys.push(controlKeyInfo);
						}
					}
				}
			}

//			trace("Took " + (getTimer() - ti) + "ms to initialize.");
		}

		// Utilitarian parsing functions

		private static function arrayToStringVector(__strings:Array):Vector.<String> {
			// Convert a JSON array to a string Vector
			var v:Vector.<String> = new Vector.<String>();
			if (__strings != null) {
				for (var i:int = 0; i < __strings.length; i++) v.push(__strings[i]);
			}
			return v;
		}

		private static function searchFromStringVector(__stringsToFind:Vector.<String>, __stringToSearchIn:String):Boolean {
			// Search a list of strings in another string, returning true if any found (simple match)
			for (var i:int = 0; i < __stringsToFind.length; i++) {
				if (__stringToSearchIn.indexOf(__stringsToFind[i]) > -1) return true;
			}
			return false;
		}

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		/**
		 * Create a new KeyActionBinder instance.
		 *
		 * <p>Each instance has its own input bindings and actions.</p>
		 *
		 * <p>More than one KeyActionBinder instance can exist and be active at the same time.</p>
		 *
		 * @see #init()
		 */
		public function KeyActionBinder() {
			_alwaysPreventDefault = true;
			_maintainPlayerPositions = false;
			bindings = new Vector.<BindingInfo>();
			actionsActivations = {};

			_onActionActivated = new SimpleSignal();
			_onActionDeactivated = new SimpleSignal();
			_onActionValueChanged = new SimpleSignal();
			_onDevicesChanged = new SimpleSignal();

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

			// Check if there was any actual change to the list
			// This is necessary because some versions of Flash keep firing the changed event every second (Windows 7 + Firefox using Flash Player 12.0.0.44)
			var i:int;
			var hasChanged:Boolean = false;

			if ((gameInputDevices == null && GameInput.numDevices > 0) || (gameInputDevices != null && GameInput.numDevices != gameInputDevices.length)) {
				hasChanged = true;
			} else {
				for (i = 0; i < GameInput.numDevices; i++) {
					if (gameInputDevices[i] != GameInput.getDeviceAt(i)) {
						hasChanged = true;
						break;
					}
				}
			}

			if (hasChanged) {
				// List has actually changed
				removeGameInputDeviceEvents();
				addGameInputDeviceEvents();

				if (_maintainPlayerPositions && gameInputDeviceIds != null) {
					// Will try to maintain player positions:
					// * A removed device will continue to exist in the list (as a null device), unless it's the latest device
					// * An added device will try to be added to its previously existing position, if one can be found
					// * If a previously existing position cannot be found, the device takes the first available position

					var gamepadPosition:int;

					// Creates a list of all the new ids
					var newGamepadIds:Vector.<String> = new Vector.<String>();
					var newGamepads:Vector.<GameInputDevice> = new Vector.<GameInputDevice>();
					for (i = 0; i < GameInput.numDevices; i++) {
						if (GameInput.getDeviceAt(i) != null) {
							newGamepadIds.push(GameInput.getDeviceAt(i).id);
							newGamepads.push(GameInput.getDeviceAt(i));
						}
					}

					// Create a list of available slots for insertion
					var availableSlots:Vector.<int> = new Vector.<int>();

					// First, check for removed items
					// Goes backward, so it can remove items from the list
					var isEndPure:Boolean = true;
					i = gameInputDeviceIds.length-1;
					while (i >= 0) {
						gamepadPosition = newGamepadIds.indexOf(gameInputDeviceIds[i]);
						if (gamepadPosition < 0) {
							// This device id doesn't exist in the new list, therefore it's removed
							if (isEndPure) {
								// But since it's in the end of the list, actually remove it
								gameInputDeviceIds.splice(i, 1);
							} else {
								// It's in the middle of the list, so just mark that spot as available
								availableSlots.push(i);
							}
						} else {
							// This device id exists in the list, so ignore and assume it's not in the end anymore
							isEndPure = false;
						}
						i--;
					}

					// Now, add new items that are not in the list
					for (i = 0; i < newGamepadIds.length; i++) {
						gamepadPosition = gameInputDeviceIds.indexOf(newGamepadIds[i]);
						if (gamepadPosition < 0) {
							// This gamepad is not in the list, so add it
							if (availableSlots.length > 0) {
								// Add it in the first available slot
								gameInputDeviceIds.push(newGamepadIds[availableSlots[0]]);
								availableSlots.splice(0, 1);
							} else {
								// No more slots availabloe, add it at the end
								gameInputDeviceIds.push(newGamepadIds[i]);
							}
						}
					}

					// Now that gameInputDeviceIds is correct, just create the list of references
					gameInputDevices = new Vector.<GameInputDevice>(gameInputDeviceIds.length);
					gameInputDeviceDefinitions = new Vector.<AutoGamepadInfo>(gameInputDeviceIds.length);
					for (i = 0; i < gameInputDeviceIds.length; i++) {
						gamepadPosition = newGamepadIds.indexOf(gameInputDeviceIds[i]);
						if (gamepadPosition < 0) {
							// A spot for a gamepad that was just removed
							gameInputDevices[i] = null;
							gameInputDeviceDefinitions[i] = null;
						} else {
							// A normal game input device
							gameInputDevices[i] = newGamepads[gamepadPosition];
							gameInputDeviceDefinitions[i] = findGamepadInfo(newGamepads[gamepadPosition]);
						}
					}
				} else {
					// Full refresh: create a new list of devices
					gameInputDevices = new Vector.<GameInputDevice>();
					gameInputDeviceIds = new Vector.<String>();
					gameInputDeviceDefinitions = new Vector.<AutoGamepadInfo>();
					for (i = 0; i < GameInput.numDevices; i++) {
						gameInputDevices.push(GameInput.getDeviceAt(i));
						if (gameInputDevices[i] != null) {
							gameInputDeviceIds.push(gameInputDevices[i].id);
							gameInputDeviceDefinitions.push(findGamepadInfo(gameInputDevices[i]));
						} else {
							gameInputDeviceIds.push(null);
							gameInputDeviceDefinitions.push(null);
						}
					}
				}

				// Dispatch the signal
				_onDevicesChanged.dispatch();
			}
		}

		private function findGamepadInfo(__gameInputDevice:GameInputDevice):AutoGamepadInfo {
			// Based on a Game InputDevice, find the internal GamepadInfo that describes this Gamepad
			if (__gameInputDevice == null) return null;

			var i:int, j:int;
			for (i = 0; i < knownGamepadPlatforms.length; i++) {
				for (j = 0; j < knownGamepadPlatforms[i].gamepads.length; j++) {
					if (knownGamepadPlatforms[i].gamepads[j].nameFilter.length == 0 || searchFromStringVector(knownGamepadPlatforms[i].gamepads[j].nameFilter, __gameInputDevice.name)) {
						return knownGamepadPlatforms[i].gamepads[j];
					}
				}
			}
			trace("Error! Gamepad definition not found for GameInputDevice [" + __gameInputDevice.name + "]!");
			trace("Data about this controller needs to be added to controller.json.");
			trace("Please read: https://github.com/zeh/key-action-binder#Contributing");
			return null;
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
						device.getControlAt(j).addEventListener(Event.CHANGE, onGameInputControlChanged, false, 0, true);
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
//					debug("  Removing events from device (" + i + "): name = " + device.name + ", controls = " + device.numControls + ", sampleInterval = " + device.sampleInterval);
					for (j = 0; j < device.numControls; j++) {
						device.getControlAt(j).removeEventListener(Event.CHANGE, onGameInputControlChanged);
					}
				}
			}
		}

		private function interpretGameInputControlChanges(__mappedId:String, __mappedValue:Number, __mappedMin:Number, __mappedMax:Number, __gamepadIndex:int):void {
			// Decides what to do once the value of a game input device control has changed

			var filteredControls:Vector.<BindingInfo> = filterGamepadControls(__mappedId, __gamepadIndex);
			var activationInfo:ActivationInfo;

			// Considers activated if past the middle threshold between min/max values (allows analog controls to be treated as digital)
			var isActivated:Boolean = __mappedValue > __mappedMin + (__mappedMax - __mappedMin) / 2;

			for (var i:int = 0; i < filteredControls.length; i++) {
				activationInfo = actionsActivations[filteredControls[i].action] as ActivationInfo;

				// Treating as a sensitive binding: send changed value signals

				// Dispatches signal
				activationInfo.addSensitiveValue(filteredControls[i].action, __mappedValue, __gamepadIndex);
				_onActionValueChanged.dispatch(filteredControls[i].action, activationInfo.getValue());

				// Treating as a standard action binding: send activated/deactivated signals

				if (filteredControls[i].isActivated != isActivated) {
					// Value changed
					filteredControls[i].isActivated = isActivated;
					if (isActivated) {
						// Marks as pressed
						filteredControls[i].lastActivatedTime = getTimer();

						// Add this activation to the list of current activations
						activationInfo.addActivation(filteredControls[i], __gamepadIndex);

						// Dispatches signal
						if (activationInfo.getNumActivations() == 1) _onActionActivated.dispatch(filteredControls[i].action);
					} else {
						// Marks as released

						// Removes this activation from the list of current activations
						activationInfo.removeActivation(filteredControls[i]);

						// Dispatches signal
						if (activationInfo.getNumActivations() == 0) _onActionDeactivated.dispatch(filteredControls[i].action);
						}
					}
			}
		}

		// Aux functions
		private function map(__value:Number, __oldMin:Number, __oldMax:Number, __newMin:Number = 0, __newMax:Number = 1, __clamp:Boolean = false):Number {
			// Same as map, but without allocations
			if (__oldMin == __oldMax) return __newMin;
			mi = ((__value-__oldMin) / (__oldMax-__oldMin) * (__newMax-__newMin)) + __newMin;
			if (__clamp) mi = __newMin < __newMax ? clamp(mi, __newMin, __newMax) : clamp(mi, __newMax, __newMin);
			return mi;
		}

		private function clamp(__value:Number, __min:Number = 0, __max:Number = 1):Number {
			return __value < __min ? __min : __value > __max ? __max : __value;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onKeyDown(__e:KeyboardEvent):void {
//			debug("key down: " + __e);
			var i:int, j:int;
			var filteredKeys:Vector.<BindingInfo> = filterKeyboardKeys(__e.keyCode, __e.keyLocation);
			for (i = 0; i < filteredKeys.length; i++) {
				if (!filteredKeys[i].isActivated) {
					// Marks as pressed
					filteredKeys[i].isActivated = true;
					filteredKeys[i].lastActivatedTime = getTimer();

					// Add this activation to the list of current activations
					(actionsActivations[filteredKeys[i].action] as ActivationInfo).addActivation(filteredKeys[i]);

					// Dispatches signal
					if ((actionsActivations[filteredKeys[i].action] as ActivationInfo).getNumActivations() == 1) _onActionActivated.dispatch(filteredKeys[i].action);
				}
			}

			if (_alwaysPreventDefault) __e.preventDefault();

			// Check all current game input devices for a key injection definition that matches
			for (i = 0; i < gameInputDeviceDefinitions.length; i++) {
				if (gameInputDeviceDefinitions[i] != null) {
					for (j = 0; j < gameInputDeviceDefinitions[i].keys.length; j++) {
						if (gameInputDeviceDefinitions[i].keys[j].keyCode == __e.keyCode && (gameInputDeviceDefinitions[i].keys[j].keyLocation == -1 || gameInputDeviceDefinitions[i].keys[j].keyLocation == __e.keyLocation)) {
							// This key's code and location matches the pressed key, inject the press event
							interpretGameInputControlChanges(gameInputDeviceDefinitions[i].keys[j].id, gameInputDeviceDefinitions[i].keys[j].max, gameInputDeviceDefinitions[i].keys[j].min, gameInputDeviceDefinitions[i].keys[j].max, i);
							return;
						}
					}
				}
			}
		}

		private function onKeyUp(__e:KeyboardEvent):void {
//			debug("key up: " + __e);
			var i:int, j:int;
			var filteredKeys:Vector.<BindingInfo> = filterKeyboardKeys(__e.keyCode, __e.keyLocation);
			for (i = 0; i < filteredKeys.length; i++) {
				// Marks as released
				filteredKeys[i].isActivated = false;

				// Removes this activation from the list of current activations
				(actionsActivations[filteredKeys[i].action] as ActivationInfo).removeActivation(filteredKeys[i]);

				// Dispatches signal
				if ((actionsActivations[filteredKeys[i].action] as ActivationInfo).getNumActivations() == 0) _onActionDeactivated.dispatch(filteredKeys[i].action);
			}

			if (_alwaysPreventDefault) __e.preventDefault();

			// Check all current game input devices for a key injection definition that matches
			for (i = 0; i < gameInputDeviceDefinitions.length; i++) {
				if (gameInputDeviceDefinitions[i] != null) {
					for (j = 0; j < gameInputDeviceDefinitions[i].keys.length; j++) {
						if (gameInputDeviceDefinitions[i].keys[j].keyCode == __e.keyCode && (gameInputDeviceDefinitions[i].keys[j].keyLocation == -1 || gameInputDeviceDefinitions[i].keys[j].keyLocation == __e.keyLocation)) {
							// This key's code and location matches the pressed key, inject the release event
							interpretGameInputControlChanges(gameInputDeviceDefinitions[i].keys[j].id, gameInputDeviceDefinitions[i].keys[j].min, gameInputDeviceDefinitions[i].keys[j].min, gameInputDeviceDefinitions[i].keys[j].max, i);
							return;
						}
					}
				}
			}
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

		private function onGameInputControlChanged(__e:Event):void {
			var control:GameInputControl = __e.target as GameInputControl;

			// Find the re-mapped control id
			var deviceIndex:int = gameInputDevices.indexOf(control.device);

			if (deviceIndex > -1 && gameInputDeviceDefinitions[deviceIndex] != null) {
				// Find single controls, where one control has one binding
				if (gameInputDeviceDefinitions[deviceIndex].controls.hasOwnProperty(control.id)) {
					var deviceControlInfo:AutoGamepadControlInfo = gameInputDeviceDefinitions[deviceIndex].controls[control.id];
					interpretGameInputControlChanges(deviceControlInfo.id, map(control.value, isNaN(deviceControlInfo.minInput) ? control.minValue : deviceControlInfo.minInput, isNaN(deviceControlInfo.maxInput) ? control.maxValue : deviceControlInfo.maxInput, deviceControlInfo.minOutput, deviceControlInfo.maxOutput, true), deviceControlInfo.minOutput, deviceControlInfo.maxOutput, deviceIndex);
				}

				// Find "split" controls, where one control has more than one binding
				if (gameInputDeviceDefinitions[deviceIndex].controlsSplit.hasOwnProperty(control.id)) {
					var deviceControlInfos:Vector.<AutoGamepadControlInfo> = gameInputDeviceDefinitions[deviceIndex].controlsSplit[control.id];
					var i:uint;
					for (i = 0; i < deviceControlInfos.length; i++) {
						interpretGameInputControlChanges(deviceControlInfos[i].id, map(control.value, isNaN(deviceControlInfos[i].minInput) ? control.minValue : deviceControlInfos[i].minInput, isNaN(deviceControlInfos[i].maxInput) ? control.maxValue : deviceControlInfos[i].maxInput, deviceControlInfos[i].minOutput, deviceControlInfos[i].maxOutput, true), deviceControlInfos[i].minOutput, deviceControlInfos[i].maxOutput, deviceIndex);
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
				gameInputDeviceDefinitions = null;
				removeGameInputDeviceEvents();

				_isRunning = false;
			}
		}

		/**
		 * Adds an action bound to a keyboard key. When a key with the given <code>keyCode</code> is pressed, the
		 * desired action is activated. Optionally, keys can be restricted to a specific <code>keyLocation</code>.
		 *
		 * @param action		An arbitrary String id identifying the action that should be dispatched once this
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
		 * myBinder.addKeyboardActionBinding("move-left", Keyboard.LEFT);
		 *
		 * // SPACE key to jump
		 * myBinder.addKeyboardActionBinding("jump", Keyboard.SPACE);
		 *
		 * // Any SHIFT key to shoot
		 * myBinder.addKeyboardActionBinding("shoot", Keyboard.SHIFT);
		 *
		 * // Left SHIFT key to boost
		 * myBinder.addKeyboardActionBinding("boost", Keyboard.SHIFT, KeyLocation.LEFT);
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
		 * Adds an action bound to a game controller button, trigger, or axis. When a control of id
		 * <code>controlId</code> is pressed, the desired action can be activated, and its value changes.
		 * Optionally, keys can be restricted to a specific game controller location.
		 *
		 * @param action		An arbitrary String id identifying the action that should be dispatched once this
		 *						input combination is detected.
		 * @param controlId		The id code of a GameInput contol, as an String. Use one of the constants from
		 *						<code>GamepadControls</code>.
		 * @param gamepadIndex	The int of the gamepad that you want to restrict this action to. Use 0 for the
		 *						first gamepad (player 1), 1 for the second one, and so on. If a value of -1 or
		 *						<code>NaN</code> is passed, the gamepad index is never taken into consideration
		 *						when detecting whether the passed action should be fired.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Direction pad left to move left
		 * myBinder.addGamepadActionBinding("move-left", GamepadControls.DPAD_LEFT);
		 *
		 * // Action button "down" (O in the OUYA, Cross in the PS3, A in the XBox 360) to jump
		 * myBinder.addGamepadActionBinding("jump", GamepadControls.ACTION_DOWN);
		 *
		 * // L1/LB to shoot, on any controller
		 * myBinder.addGamepadActionBinding("shoot", GamepadControls.LB);
		 *
		 * // L1/LB to shoot, on the first controller only
		 * myBinder.addGamepadActionBinding("shoot-player-1", GamepadControls.LB, 0);
		 *
		 * // L2/LT to shoot, regardless of whether it is sensitive or not
		 * myBinder.addGamepadActionBinding("shoot", GamepadControls.LT);
		 *
		 * // L2/LT to accelerate, depending on how much it is pressed (if supported)
		 * myBinder.addGamepadActionBinding("accelerate", GamepadControls.LT);
		.*
		 * // Direction pad left to move left or right
		 * myBinder.addGamepadActionBinding("move-sides", GamepadControls.STICK_LEFT_X);
		 * </pre>
		 *
		 * @see GamepadControls
		 * @see #isActionActivated()
		 * @see #getActionValue()
		 */
		public function addGamepadActionBinding(__action:String, __controlId:String, __gamepadIndex:int = -1):void {
			// Create a binding to be verified later
			bindings.push(new BindingInfo(__action, new GamepadBinding(__controlId, __gamepadIndex >= 0 ? __gamepadIndex : GamepadBinding.GAMEPAD_INDEX_ANY)));
			prepareAction(__action);
		}

		/**
		 * Reads the current value of an action.
		 *
		 * @param action		The id of the action you want to read the value of.
		 * @param controlId		The id code of a GameInput contol, as an String. Use one of the constants from
		 *						<code>GamepadControls</code>.
		 * @param gamepadIndex	The int of the gamepad that you want to restrict this action to. Use 0 for the
		 *						first gamepad (player 1), 1 for the second one, and so on. If a value of -1 or
		 *						<code>NaN</code> is passed, the gamepad index is never taken into consideration
		 *						when detecting whether the passed action should be fired.
		 * @return				A numeric value based on the bindings that might have activated this action.
		 *						The maximum and minimum values returned depend on the kind of control passed
		 *						via <code>addGamepadActionBinding()</code>.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Direction pad left to move left or right
		 * var speedX:Number = myBinder.getActionValue("move-sides"); // Generally between -1 and 1
		 *
		 * // L2/LT to accelerate, depending on how much it is pressed
		 * var acceleration:Number = myBinder.getActionValue("accelerate"); // Generally between 0 and 1
		 * </pre>
		 *
		 * @see GamepadControls
		 * @see #addGamepadActionBinding()
		 * @see #isActionActivated()
		 */
		public function getActionValue(__action:String, __gamepadIndex:int = -1):Number {
			return actionsActivations.hasOwnProperty(__action) ? (actionsActivations[__action] as ActivationInfo).getValue(__gamepadIndex) : 0;
		}

		/**
		 * Checks whether an action is currently activated.
		 *
		 * @param action				An arbitrary String id identifying the action that should be checked.
		 * @param timeToleranceSeconds	Time tolerance, in seconds, before the action is assumed to be expired. If &lt; 0, no time is checked.
		 * @return						True if the action is currently activated (i.e., its button is pressed), false if otherwise.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Moves player right when right is pressed
		 * // Setup:
		 * myBinder.addGamepadActionBinding("move-right", GamepadControls.DPAD_RIGHT);
		 * // In the game loop:
		 * if (myBinder.isActionActivated("move-right")) {
		 *     player.moveRight();
		 * }
		 *
		 * // Check if a jump was activated (includes just before falling, for a more user-friendly control):
		 * // Setup:
		 * myBinder.addGamepadActionBinding("jump", GamepadControls.ACTION_DOWN);
		 * // In the game loop:
		 * if (isTouchingSurface && myBinder.isActionActivated("jump"), 0.1) {
		 *     player.performJump();
		 * }
		 * </pre>
		 *
		 * @see GamepadControls
		 * @see #addGamepadActionBinding()
		 * @see #getActionValue()
		 * @see http://zehfernando.com/2013/keyactionbinder-updates-time-sensitive-activations-new-constants/
		 */
		public function isActionActivated(__action:String, __timeToleranceSeconds:Number = 0, __gamepadIndex:int = -1):Boolean {
			return actionsActivations.hasOwnProperty(__action) && (actionsActivations[__action] as ActivationInfo).getNumActivations(__timeToleranceSeconds, __gamepadIndex) > 0;
		}

		/**
		 * Consumes an action, causing all current activations and values attached to it to be reset. This is
		 * the same as simulating the player releasing the button that activates an action. It is useful to
		 * force players to re-activate some actions, such as a jump action (otherwise keeping the jump button
		 * pressed would allow the player to jump nonstop).
		 *
		 * @param action		The id of the action you want to consume.
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // On jump, consume the jump
		 * if (isTouchingSurface && myBinder.isActionActivated("jump")) {
		 *     myBinder.consumeAction("jump");
		 *     player.performJump();
		 * }
		 * </pre>
		 *
		 * @see GamepadControls
		 * @see #isActionActivated()
		 */
		public function consumeAction(__action:String):void {
			// Deactivates all current actions of an action (forcing a button to be pressed again)
			if (actionsActivations.hasOwnProperty(__action)) (actionsActivations[__action] as ActivationInfo).resetActivations();
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get onActionActivated():SimpleSignal {
			return _onActionActivated;
		}

		public function get onActionDeactivated():SimpleSignal {
			return _onActionDeactivated;
		}

		public function get onActionValueChanged():SimpleSignal {
			return _onActionValueChanged;
		}

		public function get onDevicesChanged():SimpleSignal {
			return _onDevicesChanged;
		}

		/**
		 * Toggles whether KeyActionBinder tries to maintain each player's gamepad index based on the unique id of each
		 * device.
		 *
		 * <p>When this is set to <code>false</code>, the list of connected devices (via <code>getNumDevices()</code>
		 * and others) will always reflect Flash's list of connected GameInputDevices. This means that the connected
		 * gamepads can be shuffled around when a device is added or removed, potentially causing players on a
		 * multi-player game to have their respective gamepad references swapped.</p>
		 *
		 * <p>When this is set to <code>true</code>, KeyActionBinder uses the device ids to keep a more consistent list
		 * of devices, avoiding shuffling them around. This has several implications:</p>
		 *
		 * <p> * When removed, a device will continue to exist in the list as a <code>null</code> device (unless it's
		 * the last device in the GameInputDevice list, in which case it gets removed entirely)</p>
		 * <p> * An added device will try to be re-added to its previously existing position, if one can be found (that
		 * is, if it was present before and then removed)</p>
		 * <p> * If a previously existing position cannot be found for a new device, the device takes the first available
		 * (<code>null</code>) position if one can be found, or is added to the end of the list of devices otherwise</p>
		 *
		 * <p>In general, you should set the value of this property before gameplay starts.</p>
		 *
		 * <p>If you set this to <code>false</code> after it was set to <code>true</code>, it will cause a refresh of
		 * the gamepad order, potentially shuffling player positions around if devices were added or removed previously.</p>
		 *
		 * <p>The default is <code>false</code>.</p>
		 *
		 * <p>Examples:</p>
		 *
		 * <pre>
		 * // Test 1
		 * binder.maintainPlayerPositions = false;
		 *
		 * // Add controller XBOX1; List is [XBOX1]
		 * // Add controller XBOX2; List is [XBOX1, XBOX2]
		 * // Remove controller XBOX1; List is [XBOX2]
		 * // Add controller XBOX1; List is [XBOX2, XBOX1]
		 * // Remove controller XBOX2; List is [XBOX1]
		 * // Remove controller XBOX1; List is []
		 *
		 * // Test 2
		 * binder.maintainPlayerPositions = true;
		 *
		 * // Add controller XBOX1; List is [XBOX1]
		 * // Add controller XBOX2; List is [XBOX1, XBOX2]
		 * // Remove controller XBOX1; List is [null, XBOX2]
		 * // Add controller XBOX1; List is [XBOX1, XBOX2]
		 * // Remove controller XBOX2; List is [XBOX1]
		 * // Remove controller XBOX1; List is []
		 * </pre>
		 *
		 * @see #getNumDevices()
		 * @see #getDeviceAt()
		 * @see #getDeviceTypeAt()
		 */
		public function get maintainPlayerPositions():Boolean {
			return _maintainPlayerPositions;
		}
		public function set maintainPlayerPositions(__value:Boolean):void {
			if (_maintainPlayerPositions != __value) {
				_maintainPlayerPositions = __value;
				if (!_maintainPlayerPositions) refreshGameInputDeviceList();
			}
		}

		/**
		 * Whether this KeyActionBinder instance is running, or not. This property is read-only.
		 *
		 * @see #start()
		 * @see #stop()
		 */
		public function get isRunning():Boolean {
			return _isRunning;
		}

		/**
		 * Whether to run <code>preventDefault()</code> on Keyboard events or not.
		 *
		 * <p>When this is set to <code>false</code>, KeyActionBinder doesn't try stopping the propagation of
		 * standard Keyboard behavior. In general, this is a bad idea, as certain keys (such as A on the OUYA)
		 * tend to trigger a <code>Keyboard.BACK</code> key event, potentially closing your application. Only
		 * set this to <code>false</code> if you are handling Keyboard events in your own code.</p>
		 *
		 * <p>The default is <code>true</code>.</p>
		 */
		public function get alwaysPreventDefault():Boolean {
			return _alwaysPreventDefault;
		}
		public function set alwaysPreventDefault(__value:Boolean):void {
			// TODO: this is a dumb getter/setter just for ASDocs reasons
			_alwaysPreventDefault = __value;
		}

		/**
		 * Returns the number of devices currently connected, regardless of whether they're valid or not.
		 *
		 * @see #maintainPlayerPositions
		 * @see #getDeviceAt()
		 * @see #getDeviceTypeAt()
		 */
		public function getNumDevices():uint {
			return gameInputDevices.length;
		}

		/**
		 * Returns the <code>GameInputDevice</code> associated with a player index, if any.
		 *
		 * <p>The value returned from this function can be <code>null</code>, especially if <code>maintainPlayerPositions</code>
		 * is set to <code>true</code> and the index refers to a gamepad that has been removed.</p>
		 *
		 * @see #maintainPlayerPositions
		 * @see #getNumDevices()
		 * @see #getDeviceTypeAt()
		 */
		public function getDeviceAt(__index:uint):GameInputDevice {
			return gameInputDevices.length > __index && gameInputDevices[__index] != null ? gameInputDevices[__index] : null;
		}

		/**
		 * Returns the built-in id of the gamepad type at a certain position.
		 *
		 * <p>The value returned from this function can be <code>null</code> if <code>maintainPlayerPositions</code>
		 * is set to <code>true</code> and the index refers to a gamepad that has been removed, or if the gamepad at that
		 * location has not been properly identified by KeyActionBinder.</p>
		 *
		 * <p>Check the controllers.json file for a list of supported gamepads, and their ids.</p>
		 *
		 * @see #maintainPlayerPositions
		 * @see #getNumDevices()
		 * @see #getDeviceAt()
		 */
		public function getDeviceTypeAt(__index:uint):String {
			return gameInputDeviceDefinitions.length > __index && gameInputDeviceDefinitions[__index] != null ? gameInputDeviceDefinitions[__index].getType() : null;
		}

		/**
		 * Returns the current identified platform. This is a list of strings that can contain more than one platform id.
		 *
		 * <p>Check the controllers.json file for a list of supported platforms, and their ids.</p>
		 */
		public function getPlatformTypes():Vector.<String> {
			var platforms:Vector.<String> = new Vector.<String>();
			for (var i:int = 0; i < knownGamepadPlatforms.length; i++) {
				platforms.push(knownGamepadPlatforms[i].id);
			}
			return platforms;
		}
	}
}
import flash.utils.Dictionary;
import flash.utils.getTimer;
/**
 * Information listing all activated bindings of a given action
 */
class ActivationInfo {

	private var activations:Vector.<BindingInfo>;			// All activated bindings
	private var activationGamepadIndexes:Vector.<int>;		// Gamepad that activated that binding
	private var sensitiveValues:Dictionary;					// Dictionary with IBinding
	private var sensitiveValuesGamepadIndexes:Dictionary;	// Gamepad int that activated that sensitive value

	// Temp vars to avoid garbage collection
	private var iiv:Number;									// Value buffer
	private var iix:int;									// Search index
	private var iis:Object;									// Object iterator
	private var iit:int;									// Time
	private var iii:int;									// Iterator
	private var iic:int;									// Count

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function ActivationInfo() {
		activations = new Vector.<BindingInfo>();
		activationGamepadIndexes = new Vector.<int>();
		sensitiveValues = new Dictionary();
		sensitiveValuesGamepadIndexes = new Dictionary();
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function addActivation(__bindingInfo:BindingInfo, __gamepadIndex:int = -1):void {
		activations.push(__bindingInfo);
		activationGamepadIndexes.push(__gamepadIndex);
	}

	public function removeActivation(__bindingInfo:BindingInfo):void {
		iix = activations.indexOf(__bindingInfo);
		if (iix > -1) {
			activations.splice(iix, 1);
			activationGamepadIndexes.splice(iix, 1);
		}
	}

	public function getNumActivations(__timeToleranceSeconds:Number = 0, __gamepadIndex:int = -1):int {
		// If not time-sensitive, just return it
		if ((__timeToleranceSeconds <= 0 && __gamepadIndex < 0) || activations.length == 0) return activations.length;
		// Otherwise, actually check for activation time and gamepad index
		iit = getTimer() - __timeToleranceSeconds * 1000;
		iic = 0;
		for (iii = 0; iii < activations.length; iii++) {
			if ((__timeToleranceSeconds <= 0 || activations[iii].lastActivatedTime >= iit) && (__gamepadIndex < 0 || activationGamepadIndexes[iii] == __gamepadIndex)) iic++;
		}
		return iic;
	}

	public function resetActivations():void {
		activations.length = 0;
		activationGamepadIndexes.length = 0;
	}

	public function addSensitiveValue(__actionId:String, __value:Number, __gamepadIndex:int = -1):void {
		sensitiveValues[__actionId] = __value;
		sensitiveValuesGamepadIndexes[__actionId] = __gamepadIndex;
	}

	public function getValue(__gamepadIndex:int = -1):Number {
		iiv = NaN;
		for (iis in sensitiveValues) {
			// NOTE: this may be a problem if two different axis control the same action, since -1 is not necessarily better than +0.5
			if ((__gamepadIndex < 0 || sensitiveValuesGamepadIndexes[iis] == __gamepadIndex) && (isNaN(iiv) || Math.abs(sensitiveValues[iis]) > Math.abs(iiv))) iiv = sensitiveValues[iis];
		}
		if (isNaN(iiv)) return getNumActivations(0, __gamepadIndex) == 0 ? 0 : 1;
		return iiv;
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
}

/**
 * Information on platforms that are automatically mapped
 */
class AutoPlatformInfo {

	// Properties
	public var id:String;

	public var manufacturerFilter:Vector.<String>;							// Filter for Capabilities.manufacturer
	public var osFilter:Vector.<String>;									// Filter for Capabilities.os
	public var versionFilter:Vector.<String>;								// Filter for Capabilities.version

	public var gamepads:Vector.<AutoGamepadInfo>;


	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function AutoPlatformInfo() {
		manufacturerFilter = new Vector.<String>();
		osFilter = new Vector.<String>();
		versionFilter = new Vector.<String>();
		gamepads = new Vector.<AutoGamepadInfo>();
	}
}

/**
 * Information on gamepads that are automatically mapped
 */
class AutoGamepadInfo {

	// Properties
	public var id:String;
	public var platformId:String;

	public var nameFilter:Vector.<String>;									// Filter for device.name

	public var controls:Object;												// AutoGamepadControlInfo, key is the control.id
	public var controlsSplit:Object;										// Vector.<AutoGamepadControlInfo>, key is the control.id
	public var keys:Vector.<AutoGamepadControlKeyInfo>;						// List of keys that double as controls


	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function AutoGamepadInfo() {
		controls = {};
		controlsSplit = {};
		keys = new Vector.<AutoGamepadControlKeyInfo>();
	}

	public function getType():String {
		return platformId + "/" + id;
	}
}

/**
 * Information on gamepads controls that are automatically mapped
 */
class AutoGamepadControlInfo {

	// Properties
	public var id:String;
	public var minInput:Number;
	public var maxInput:Number;
	public var minOutput:Number;
	public var maxOutput:Number;


	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function AutoGamepadControlInfo() {
	}
}

/**
 * Information on keyboard keys that get mapped to gamepad controls
 */
class AutoGamepadControlKeyInfo {

	// Properties
	public var id:String;
	public var keyCode:int;
	public var keyLocation:int;
	public var min:Number;
	public var max:Number;


	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function AutoGamepadControlKeyInfo() {
	}
}

