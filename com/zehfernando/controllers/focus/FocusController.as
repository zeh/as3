package com.zehfernando.controllers.focus {
	import com.zehfernando.transitions.ZTween;
	import com.zehfernando.utils.console.log;

	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * @author zeh fernando
	 */
	public class FocusController {

		// Constants
		public static const EVENT_ENTER_DOWN:String = "FocusController.onEnterDown";
		public static const EVENT_ENTER_UP:String = "FocusController.onEnterUp";
		public static const EVENT_MOVED_FOCUS:String = "FocusController.onMovedFocus";
		public static const EVENT_USER_INPUT:String = "FocusController.onUserInput";

		private static const TIME_ANIMATION:Number = 0.1;

		private static const DIRECTION_LEFT:String = "left";
		private static const DIRECTION_RIGHT:String = "right";
		private static const DIRECTION_UP:String = "up";
		private static const DIRECTION_DOWN:String = "down";
		private static const DIRECTION_NEXT:String = "next";
		private static const DIRECTION_PREVIOUS:String = "previous";

		// Properties
		private static var keyLeft:uint;
		private static var keyRight:uint;
		private static var keyUp:uint;
		private static var keyDown:uint;
		private static var keyEnter:uint;
		private static var keyNext:uint;
		private static var keyPrev:uint;

		private static var isKeyEnterDown:Boolean;

		// Instances
		private static var eventDispatcher:EventDispatcher;
		private static var elements:Vector.<IFocusable>;
		private static var stage:Stage;

		private static var currentElement:IFocusable;


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function init(__stage:Stage, __root:DisplayObjectContainer):void {
			stage = __stage;
			stage.stageFocusRect = false;
			__root.tabEnabled = false;
			eventDispatcher = new EventDispatcher();
			elements = new Vector.<IFocusable>();

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		public static function addElement(__element:IFocusable):void {
			if (elements.indexOf(__element) < 0) elements.push(__element);
			if (currentElement == null) currentElement = __element;
		}

		public static function removeElement(__element:IFocusable):void {
			if (elements.indexOf(__element) > -1) {
				elements.splice(elements.indexOf(__element), 1);
				if (currentElement == __element) currentElement = null;
			}
		}

		public static function addEventListener(__type:String, __listener:Function, __useCapture:Boolean = false, __priority:int = 0, __useWeakReference:Boolean = false):void {
			eventDispatcher.addEventListener(__type, __listener, __useCapture, __priority, __useWeakReference);
		}

		public static function removeEventListener(__type:String, __listener:Function, __useCapture:Boolean = false):void {
			eventDispatcher.removeEventListener(__type, __listener, __useCapture);
		}

		public static function setKeys(__up:uint, __right:uint, __down:uint, __left:uint, __prev:uint, __next:uint, __enter:uint):void {
			keyUp = __up;
			keyRight = __right;
			keyDown = __down;
			keyLeft = __left;
			keyPrev = __prev;
			keyNext = __next;
			keyEnter = __enter;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private static function keyEnterDown():void {
			if (!isKeyEnterDown) {
				log("focus action => enter down");

				isKeyEnterDown = true;
				eventDispatcher.dispatchEvent(new Event(EVENT_USER_INPUT));
				eventDispatcher.dispatchEvent(new Event(EVENT_ENTER_DOWN));

				if (currentElement != null) {
					currentElement.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
					currentElement.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
					currentElement.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
				}
			}
		}

		private static function keyEnterUp(__cancel:Boolean = false):void {
			if (isKeyEnterDown) {
				log("focus action => enter up");

				isKeyEnterDown = false;
				eventDispatcher.dispatchEvent(new Event(EVENT_USER_INPUT));
				eventDispatcher.dispatchEvent(new Event(EVENT_ENTER_UP));

				if (currentElement != null) {
					if (__cancel) {
						currentElement.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
						currentElement.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
					}
					currentElement.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
				}
			}
		}

		private static function moveFocus(__direction:String):void {
			log("focus move => " + __direction);

			if (isKeyEnterDown) keyEnterUp(true);

			// Use a default current focus if none
			if (currentElement == null) currentElement = getDefaultElement();

			var nextElement:IFocusable = currentElement;
			var idx:int = elements.indexOf(currentElement);

			if (idx > -1) {
				if (__direction == DIRECTION_NEXT) {
					nextElement = elements[(idx + 1) % elements.length];
				} else if (__direction == DIRECTION_PREVIOUS) {
					nextElement = elements[(idx - 1 + elements.length) % elements.length];
				} else {
					nextElement = findElementFromVisualDirection(currentElement, __direction);
				}
			}

			log("    current => " + currentElement + " [" + elements.indexOf(currentElement) + "/" + elements.length + "], new = " + nextElement + " [" + elements.indexOf(nextElement) + "]");

			// Animate
			if (currentElement != nextElement && nextElement != null) {
				if (currentElement != null) {
					ZTween.remove(currentElement, "focused");
					ZTween.add(currentElement, {focused:0}, {time:FocusController.TIME_ANIMATION});
				}
				if (nextElement != null) {
					ZTween.remove(nextElement, "focused");
					ZTween.add(nextElement, {focused:1}, {time:FocusController.TIME_ANIMATION});
				}
				currentElement = nextElement;
			}

			// End
			eventDispatcher.dispatchEvent(new Event(EVENT_USER_INPUT));
			eventDispatcher.dispatchEvent(new Event(EVENT_MOVED_FOCUS));
		}

		private static function findElementFromVisualDirection(__element:IFocusable, __direction:String):IFocusable {
			// Finds the next item on any direcyion of the current one

			if (__element == null) return null;

			// Find next element to one of the sides, as close as possible
			var currentRect:Rectangle = currentElement.getBounds(stage);
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
				if (elements[i] != currentElement) {
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

		private static function getDefaultElement():IFocusable {
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
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private static function onKeyDown(__e:KeyboardEvent):void {
			if (__e.keyCode == keyLeft)		moveFocus(DIRECTION_LEFT);
			if (__e.keyCode == keyRight)	moveFocus(DIRECTION_RIGHT);
			if (__e.keyCode == keyUp)		moveFocus(DIRECTION_UP);
			if (__e.keyCode == keyDown)		moveFocus(DIRECTION_DOWN);
			if (__e.keyCode == keyPrev)		moveFocus(DIRECTION_PREVIOUS);
			if (__e.keyCode == keyNext)		moveFocus(DIRECTION_NEXT);
			if (__e.keyCode == keyEnter)	keyEnterDown();
		}

		private static function onKeyUp(__e:KeyboardEvent):void {
			if (__e.keyCode == keyEnter)	keyEnterUp();
		}
	}
}
