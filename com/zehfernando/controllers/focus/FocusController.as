package com.zehfernando.controllers.focus {
	import com.zehfernando.signals.SimpleSignal;

	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * @author zeh fernando
	 */
	public class FocusController {

		// Controller for buttons

		// Constants
		public static const COMMAND_ACTIVATE:String = "commandActivate";
		public static const COMMAND_ACTIVATION_TOGGLE:String = "commandActivationToggle";
		public static const COMMAND_DEACTIVATE:String = "commandDeactivate";
		public static const COMMAND_DEACTIVATE_SILENT:String = "commandDeactivateSilent";
		public static const COMMAND_MOVE_LEFT:String = "commandMoveFocusLeft";
		public static const COMMAND_MOVE_RIGHT:String = "commandMoveFocusRight";
		public static const COMMAND_MOVE_UP:String = "commandMoveFocusUp";
		public static const COMMAND_MOVE_DOWN:String = "commandMoveFocusDown";
		public static const COMMAND_MOVE_PREVIOUS:String = "commandMoveFocusPrevious";
		public static const COMMAND_MOVE_NEXT:String = "commandMoveFocusNext";
		public static const COMMAND_ENTER_DOWN:String = "commandEnterDown";
		public static const COMMAND_ENTER_UP:String = "commandEnterUp";

		private static const DIRECTION_LEFT:String = "left";
		private static const DIRECTION_RIGHT:String = "right";
		private static const DIRECTION_UP:String = "up";
		private static const DIRECTION_DOWN:String = "down";
		private static const DIRECTION_NEXT:String = "next";
		private static const DIRECTION_PREVIOUS:String = "previous";

		// Properties
		private var isKeyEnterDown:Boolean;

		private var _isActivated:Boolean;
		private var _enabled:Boolean;
		private var defaultElements:Vector.<IFocusable>;

		// Instances
		private var elements:Vector.<IFocusable>;
		private var stage:Stage;

		private var _currentElement:IFocusable;

		private var _onPressedEnter:SimpleSignal;
		private var _onReleasedEnter:SimpleSignal;
		private var _onMovedFocus:SimpleSignal;
		private var _onActivationChanged:SimpleSignal;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FocusController(__stage:Stage) {
			isKeyEnterDown = false;
			stage = __stage;
			defaultElements = new Vector.<IFocusable>;
			elements = new Vector.<IFocusable>();
			_onPressedEnter = new SimpleSignal();
			_onReleasedEnter = new SimpleSignal();
			_onMovedFocus = new SimpleSignal();
			_onActivationChanged = new SimpleSignal();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function keyEnterDown():void {
			if (!isKeyEnterDown) {
				isKeyEnterDown = true;
				_onPressedEnter.dispatch();

				if (_currentElement != null) _currentElement.simulateEnterDown();
			}
		}

		private function keyEnterUp(__cancel:Boolean = false):void {
			if (isKeyEnterDown) {
				isKeyEnterDown = false;
				_onReleasedEnter.dispatch();

				if (_currentElement != null) {
					if (__cancel) {
						_currentElement.simulateEnterCancel();
					} else {
						_currentElement.simulateEnterUp();
					}
				}
			}
		}

		private function showCurrentFocus():void {
//			log("==========> SHOWING FOCUS!");
			var changedFocus:Boolean = false;
			if (_currentElement == null || !_currentElement.canReceiveFocus()) {
				if (_currentElement != null) _currentElement.setFocused(false);
				_currentElement = getDefaultElement();
				changedFocus = true;
			}
			if (_currentElement != null) {
				_currentElement.setFocused(true);
				changedFocus = true;
			}
			_isActivated = true;
			_onActivationChanged.dispatch();
			if (changedFocus) _onMovedFocus.dispatch();
		}

		private function hideCurrentFocus(__silent:Boolean = false):void {
//			log("==========> HIDING FOCUS!");
			if (_isActivated) {
				if (_currentElement != null) _currentElement.setFocused(false);
				_isActivated = false;
				if (!__silent) _onActivationChanged.dispatch();
			}
		}

		private function moveFocus(__direction:String):void {
			if (isKeyEnterDown) keyEnterUp(true);

			// Use a default current focus if none
			if (_currentElement == null) _currentElement = getDefaultElement();

			var nextElement:IFocusable = _currentElement;
			var idx:int = elements.indexOf(_currentElement);

			if (idx > -1) {
				var pos:int = 0;
				if (__direction == DIRECTION_NEXT) {
					while (pos < elements.length && (nextElement == _currentElement || !nextElement.canReceiveFocus())) {
						pos++;
						nextElement = elements[(idx + pos) % elements.length];
					}
				} else if (__direction == DIRECTION_PREVIOUS) {
					while (pos < elements.length && (nextElement == _currentElement || !nextElement.canReceiveFocus())) {
						pos++;
						nextElement = elements[(idx - pos + elements.length) % elements.length];
					}
				} else {
					nextElement = findElementFromVisualDirection(_currentElement, __direction);
				}
			}

			if (!_isActivated) {
				_isActivated = true;
				_onActivationChanged.dispatch();
			}

			// Animate
			setCurrentElement(nextElement);
		}

		private function findElementFromVisualDirection(__element:IFocusable, __direction:String):IFocusable {
			// Finds the next item on any direcyion of the current one

			if (__element == null) return null;

			// Find next element to one of the sides, as close as possible
			var currentRect:Rectangle = _currentElement.getVisualBounds();
			var i:int;
			var currentNextElement:IFocusable;
			var currentNextElementDistance:Number;
			var distanceX:Number, distanceY:Number;
			var distance:Number; // Weighted ratio, not exactly distance - X = preferable over Y
			var newRect:Rectangle;
			var scaleDistanceX:Number = (__direction == DIRECTION_LEFT || __direction == DIRECTION_RIGHT) ? 1 : 2;
			var scaleDistanceY:Number = (__direction == DIRECTION_LEFT || __direction == DIRECTION_RIGHT) ? 2 : 1;
			var currentP:Point = new Point(currentRect.x + currentRect.width * 0.5, currentRect.y + currentRect.height * 0.5);
			for (i = 0; i < elements.length; i++) {
				if (elements[i] != _currentElement && elements[i].canReceiveFocus()) {
					newRect = elements[i].getVisualBounds();
					distanceX = ((newRect.x + newRect.width * 0.5) - currentP.x) * scaleDistanceX;
					distanceY = ((newRect.y + newRect.height * 0.5) - currentP.y) * scaleDistanceY;
					if ((__direction == DIRECTION_RIGHT && distanceX > 0) || (__direction == DIRECTION_LEFT && distanceX < 0) || (__direction == DIRECTION_DOWN && distanceY > 0) || (__direction == DIRECTION_UP && distanceY < 0)) {
						distance = Math.abs(distanceX) + Math.abs(distanceY);
						if (currentNextElement == null || distance < currentNextElementDistance) {
							currentNextElement = elements[i];
							currentNextElementDistance = distance;
						}
					}
				}
			}

			return currentNextElement;
		}

		private function getDefaultElement():IFocusable {
			// Finds whatever element is closer to the top left corner to be the first, default element

			var i:int;

			// Try to use the latest "default" element
			i = defaultElements.length - 1;
			while (i >= 0) {
				if (defaultElements[i].canReceiveFocus()) return defaultElements[i];
				i--;
			}

			// Try to use any from the list
			for each (var element:IFocusable in elements) {
				if (element.canReceiveFocus()) return element;
			}

			// None found!
			return null;

//			var element:IFocusable = null;
//			var elementRect:Rectangle = null;
//			var newRect:Rectangle;
//			for (var i:int = 0; i < elements.length; i++) {
//				if (elements[i].canReceiveFocus()) {
//					newRect = elements[i].getVisualBounds();
//					if (element == null || newRect.y < elementRect.y || (newRect.y == elementRect.y && newRect.x < elementRect.x)) {
//						element = elements[i];
//						elementRect = newRect;
//					}
//				}
//			}
//			return element;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function disableNativeTabInterface(__stage:Stage, __root:DisplayObjectContainer):void {
			__stage.stageFocusRect = false;
			__root.focusRect = false;
			__root.tabEnabled = false;
		}

		public function addElement(__element:IFocusable, __isDefault:Boolean = false):void {
			if (elements.indexOf(__element) < 0) elements.push(__element);
			if (__isDefault) defaultElements.push(__element);
			if (_isActivated && _currentElement == null) {
				setCurrentElement(__element, true);
			}
		}

		public function removeElement(__element:IFocusable):void {
			if (elements.indexOf(__element) > -1) {
				// Remove from list
				elements.splice(elements.indexOf(__element), 1);

				// Remove from default elements if needed
				if (defaultElements.indexOf(__element) > -1) defaultElements.splice(defaultElements.indexOf(__element), 1);

				// Remove if current
				if (_currentElement == __element) {
					_currentElement = null;
					_onMovedFocus.dispatch();
				}
			}
		}

		public function setCurrentElement(__element:IFocusable, __immediate:Boolean = false):void {
			if (_currentElement != __element && __element != null) {
				if (_currentElement != null) _currentElement.setFocused(false, __immediate);
				__element.setFocused(true, __immediate);
				_currentElement = __element;
				_onMovedFocus.dispatch();
			}
		}

		public function unsetCurrentElement(__immediate:Boolean = false):void {
			// Resets the currently selected element (next time it is activated, it will use the default)
			if (_currentElement != null) {
				_currentElement.setFocused(false, __immediate);
				_currentElement = null;
				_onMovedFocus.dispatch();
			}
		}

		public function resetCurrentElement(__immediate:Boolean = false):void {
			// Switches to what should be the current element
			setCurrentElement(getDefaultElement(), __immediate);
		}


		public function hasElement(__element:IFocusable):Boolean {
			return elements.indexOf(__element) > -1;
		}

		public function executeCommand(__command:String):void {
			//log("command ==> " + __command);
			if (__command == COMMAND_ACTIVATE)					showCurrentFocus();
			if (__command == COMMAND_DEACTIVATE)				hideCurrentFocus();
			if (__command == COMMAND_DEACTIVATE_SILENT)			hideCurrentFocus(true);
			if (__command == COMMAND_ACTIVATION_TOGGLE)			_isActivated ? hideCurrentFocus() : showCurrentFocus();
			if (__command == COMMAND_MOVE_LEFT)					moveFocus(DIRECTION_LEFT);
			if (__command == COMMAND_MOVE_RIGHT)				moveFocus(DIRECTION_RIGHT);
			if (__command == COMMAND_MOVE_UP)					moveFocus(DIRECTION_UP);
			if (__command == COMMAND_MOVE_DOWN)					moveFocus(DIRECTION_DOWN);
			if (__command == COMMAND_MOVE_PREVIOUS)				moveFocus(DIRECTION_PREVIOUS);
			if (__command == COMMAND_MOVE_NEXT)					moveFocus(DIRECTION_NEXT);
			if (__command == COMMAND_ENTER_DOWN)				keyEnterDown();
			if (__command == COMMAND_ENTER_UP)					keyEnterUp();
		}

		public function updateCurrentElement(__immediate:Boolean = false):void {
			// Forces an update to the current element if it is focused
			if (_currentElement != null) _currentElement.setFocused(true, __immediate);
		}

		public function checkValidityOfCurrentElement(__immediate:Boolean = false):void {
			// Checks if the current element can still be selected
			if (_currentElement != null && !_currentElement.canReceiveFocus()) {
				if (_isActivated) _currentElement.setFocused(false, __immediate);
				_currentElement = getDefaultElement();
				if (_isActivated && _currentElement != null) _currentElement.setFocused(true, __immediate);
				_onMovedFocus.dispatch();
			}
		}

//		private function getId(__element:IFocusable):String {
//			if (__element == null) return null;
//			var name:String = "";
//			name = String(__element);
//			if (__element is BlobSpritesInfo) name = "BlobSpritesInfo: focus = " + (__element as BlobSpritesInfo).keyboardFocused + ", " + (__element as BlobSpritesInfo).beverage.id;
//			if (__element is BlobButton) name = "BlobButton: ?, focus = " + (__element as BlobButton).keyboardFocused;
//			return "[" + name + ", canReceiveFocus = " + __element.canReceiveFocus() + "]";
//		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get numElements():int {
			return elements.length;
		}

		public function get currentFocusedElement():IFocusable {
			return _currentElement;
		}

		public function get isActivated():Boolean {
			return _isActivated;
		}

		public function get onPressedEnter():SimpleSignal {
			return _onPressedEnter;
		}

		public function get onReleasedEnter():SimpleSignal {
			return _onReleasedEnter;
		}

		public function get onMovedFocus():SimpleSignal {
			return _onMovedFocus;
		}

		public function get onActivationChanged():SimpleSignal {
			return _onActivationChanged;
		}

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled(__value:Boolean):void {
			if (_enabled != __value) {
				_enabled = __value;
			}
		}
	}
}
