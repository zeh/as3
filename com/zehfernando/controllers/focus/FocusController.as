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

		// Instances
		private var elements:Vector.<IFocusable>;
		private var stage:Stage;

		private var _currentElement:IFocusable;

		private var _onPressedEnter:SimpleSignal;
		private var _onReleasedEnter:SimpleSignal;
		private var _onMovedFocus:SimpleSignal;

		private var _isActivated:Boolean;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FocusController(__stage:Stage) {
			isKeyEnterDown = false;
			stage = __stage;
			elements = new Vector.<IFocusable>();
			_onPressedEnter = new SimpleSignal();
			_onReleasedEnter = new SimpleSignal();
			_onMovedFocus = new SimpleSignal();
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
			if (_currentElement == null) _currentElement = getDefaultElement();
			if (_currentElement != null) _currentElement.setFocused(true);
			_isActivated = true;
		}

		private function hideCurrentFocus():void {
			if (_currentElement != null) _currentElement.setFocused(false);
			_isActivated = false;
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

			// Animate
			if (_currentElement != nextElement && nextElement != null) {
				if (_currentElement != null) _currentElement.setFocused(false);
				if (nextElement != null) nextElement.setFocused(true);
				_currentElement = nextElement;
			}

			_isActivated = true;

			// End
			_onMovedFocus.dispatch();
		}

		private function findElementFromVisualDirection(__element:IFocusable, __direction:String):IFocusable {
			// Finds the next item on any direcyion of the current one

			if (__element == null) return null;

			// Find next element to one of the sides, as close as possible
			var currentRect:Rectangle = _currentElement.getBounds(stage);
			var i:int;
			var currentNextElement:IFocusable;
			var currentNextElementDistance:Number;
			var distanceX:Number, distanceY:Number;
			var distance:Number; // Weighted ration, not exactly distance - X = preferable over Y
			var newRect:Rectangle;
			var scaleDistanceX:Number = (__direction == DIRECTION_LEFT || __direction == DIRECTION_RIGHT) ? 1 : 2;
			var scaleDistanceY:Number = (__direction == DIRECTION_LEFT || __direction == DIRECTION_RIGHT) ? 2 : 1;
			var currentP:Point = new Point(currentRect.x + currentRect.width * 0.5, currentRect.y + currentRect.height * 0.5);
			for (i = 0; i < elements.length; i++) {
				if (elements[i] != _currentElement && elements[i].canReceiveFocus()) {
					newRect = elements[i].getBounds(stage);
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
			var element:IFocusable = null;
			var elementRect:Rectangle = null;

			var newRect:Rectangle;

			for (var i:int = 0; i < elements.length; i++) {
				newRect = elements[i].getBounds(stage);
				if (element == null || newRect.y < elementRect.y || (newRect.y == elementRect.y && newRect.x < elementRect.x)) {
					element = elements[i];
					elementRect = newRect;
				}
			}

			return element;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function disableNativeTabInterface(__stage:Stage, __root:DisplayObjectContainer):void {
			__stage.stageFocusRect = false;
			__root.focusRect = false;
			__root.tabEnabled = false;
		}

		public function addElement(__element:IFocusable):void {
			if (elements.indexOf(__element) < 0) elements.push(__element);
			if (_currentElement == null) _currentElement = __element;
			if (_isActivated) _currentElement.setFocused(true, true);
		}

		public function removeElement(__element:IFocusable):void {
			if (elements.indexOf(__element) > -1) {
				elements.splice(elements.indexOf(__element), 1);
				if (_currentElement == __element) _currentElement = null;
			}
		}

		public function executeCommand(__command:String):void {
			if (__command == COMMAND_ACTIVATE)					showCurrentFocus();
			if (__command == COMMAND_DEACTIVATE)				hideCurrentFocus();
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


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

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
	}
}
