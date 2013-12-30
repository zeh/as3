package com.zehfernando.ld27.starling.templates {

	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import com.zehfernando.utils.console.warn;

	import flash.geom.Point;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class MultiTouchSprite extends Sprite {

		// Instances
		protected var touches:Vector.<TouchInfo>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function MultiTouchSprite() {

			// Initializes data
			touches = new Vector.<TouchInfo>();

			// Add events
			addEventListener(TouchEvent.TOUCH, onStarlingTouch);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function getTouchInfoById(__id:int):TouchInfo {
			// Based on a touch id, get the stored touch info
			var i:int;

			// Just use a direct named array? duh
			for (i = 0; i < touches.length; i++) {
				if (touches[i].id == __id) return touches[i];
			}
			return null;
		}

		protected function getEventTouchInfoById(__touches:Vector.<Touch>, __id:int):Touch {
			// Based on a touch id, get the stored touch info
			var i:int;

			// Just use a direct named array? duh
			for (i = 0; i < __touches.length; i++) {
				if (__touches[i].id == __id) return __touches[i];
			}
			return null;
		}

		protected function processTouches():void {
			// Process all touch info, moving stuff where they need to be moved to

				// Trying to do things a litte differently here.. hence the additional abstractions
			if (touches.length == 1) {
				// Once touch... simple drag

				var poriginalLength:Number = touches[0].startingLocalPoint.length;
				var poriginalRotation:Number = Math.atan2(touches[0].startingLocalPoint.y, touches[0].startingLocalPoint.x);

				var pnewLength:Number = poriginalLength * scaleX;
				var pnewRotation:Number = poriginalRotation + rotation;
				var pnp:Point = Point.polar(pnewLength, pnewRotation);

				x = touches[0].currentParentPoint.x - pnp.x;
				y = touches[0].currentParentPoint.y - pnp.y;

			} else if (touches.length >= 2) {
				// Two touches or more... drag plus scale/rotation (only uses the first two touches)

				// Find angle and does correct rotation
				var startingLocalAngle:Number = Math.atan2(touches[1].startingLocalPoint.y - touches[0].startingLocalPoint.y, touches[1].startingLocalPoint.x - touches[0].startingLocalPoint.x);
				var startingParentAngle:Number = Math.atan2(touches[1].startingParentPoint.y- touches[0].startingParentPoint.y, touches[1].startingParentPoint.x - touches[0].startingParentPoint.x);
				var currentParentAngle:Number = Math.atan2(touches[1].currentParentPoint.y- touches[0].currentParentPoint.y, touches[1].currentParentPoint.x - touches[0].currentParentPoint.x);
				var newAngle:Number = (currentParentAngle - startingParentAngle) + (startingParentAngle - startingLocalAngle);

				rotation = newAngle;

				// Find distance and does correct scaling
				var startingLocalDistance:Number = Point.distance(touches[0].startingLocalPoint, touches[1].startingLocalPoint);
				var startingParentDistance:Number = Point.distance(touches[0].startingParentPoint, touches[1].startingParentPoint);
				var currentParentDistance:Number = Point.distance(touches[0].currentParentPoint, touches[1].currentParentPoint);
				var newScale:Number = (currentParentDistance / startingParentDistance) * (startingParentDistance / startingLocalDistance);

				scaleX = scaleY = newScale;

				// Finally, moves everything to the correct position by re-projecting the corner
				var originalLength:Number = touches[0].startingLocalPoint.length;
				var originalRotation:Number = Math.atan2(touches[0].startingLocalPoint.y, touches[0].startingLocalPoint.x);

				var newLength:Number = originalLength * newScale;
				var newRotation:Number = originalRotation + rotation;
				var np:Point = Point.polar(newLength, newRotation);

				x = touches[0].currentParentPoint.x - np.x;
				y = touches[0].currentParentPoint.y - np.y;
			}
		}

		protected function restartTouches():void {
			// Resets the starting point of all touches, to allow for continuous switch between using different number of touch events
			var i:int;
			for (i = 0; i < touches.length; i++) {
				touches[i].startingParentPoint = touches[i].currentParentPoint.clone();
				touches[i].startingLocalPoint = touches[i].currentLocalPoint.clone();
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onStarlingTouch(event:TouchEvent):void {
			var i:int;
			var touchInfo:TouchInfo;
			//log (event.touches);
			for (i = 0; i < event.touches.length; i++) {
				switch (event.touches[i].phase) {
					case TouchPhase.BEGAN:
						// New touch event
						if (touches.length > 0) restartTouches();

						touchInfo = getTouchInfoById(event.touches[i].id);
						if (Boolean(touchInfo)) {
							// Another Starling bug: apparently touch events can start twice in a row
							// Only update the current touch point?
							warn("Touch event initialized twice!");
							touchInfo.startingParentPoint = touchInfo.currentParentPoint = event.touches[i].getLocation(parent);
							touchInfo.startingLocalPoint = touchInfo.currentLocalPoint = event.touches[i].getLocation(this);
						} else {
							touchInfo = new TouchInfo(event.touches[i].id, event.touches[i].getLocation(parent), event.touches[i].getLocation(this));
							touches.push(touchInfo);
						}
						//log("New touch: " + touchInfo.id);
						break;
					case TouchPhase.MOVED:
						// Moved one of the points
						touchInfo = getTouchInfoById(event.touches[i].id);
						if (Boolean(touchInfo)) {
							//log("Moved touch: " + touchInfo.id);

							touchInfo.currentParentPoint = event.touches[i].getLocation(parent);
							touchInfo.currentLocalPoint = event.touches[i].getLocation(this);

							processTouches();
						}
						break;
					case TouchPhase.ENDED:
						// Ended some touch event
						touchInfo = getTouchInfoById(event.touches[i].id);
						if (Boolean(touchInfo)) {
							//log("Ended touch: " + touchInfo.id);
							touches.splice(touches.indexOf(touchInfo), 1);
						}

						if (touches.length > 0) restartTouches();

						break;
					default:
						// Other event
						//log("OTHER EVENT!" + event.touches[i].phase);
				}
			}

			if (touches.length > 0) {
				// Starling bug: clicking outside of a container as a second touch when the first touch is
				// already inside the container properly creates a new touch (even if it's outside), but
				// if the first touch is released first, the second touch stops firing and never triggers
				// a "ended" event
				// Therefore, I manually check for all events to see if they exist
				for (i = 0; i < touches.length; i++) {
					if (!Boolean(getEventTouchInfoById(event.touches, touches[i].id))) {
						warn("Ghost touch event deleted!");
						touches.splice(i, 1);
						i--;
					}
				}
			}
		}
	}
}

import flash.geom.Point;

// ================================================================================================================
// AUXILIARY CLASSES ----------------------------------------------------------------------------------------------

class TouchInfo {

	// Properties
	public var id:int;

	public var startingLocalPoint:Point;
	public var currentLocalPoint:Point;

	public var startingParentPoint:Point;
	public var currentParentPoint:Point;

	// Constructor
	public function TouchInfo(__id:int, __startingParentPoint:Point, __startingLocalPoint:Point) {
		id = __id;
		startingParentPoint = __startingParentPoint;
		startingLocalPoint = __startingLocalPoint;

		currentParentPoint = startingParentPoint.clone();
		currentLocalPoint = startingLocalPoint.clone();
	}
}
