package com.zehfernando.display {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * @author Zeh Fernando
	 */
	public class PointSprite extends Sprite {

		// Instance properties ----------------------------------------------------------------

		protected var _registrationX:Number;		// Registration point X
		protected var _registrationY:Number;		// Registration point Y
		protected var _x:Number;					// User-defined X
		protected var _y:Number;					// User-defined Y

		protected var setToUpdate:Boolean;			// Whether this instance is already set to update on the next Event.RENDER

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function PointSprite() {
			super();

			// Reads the current __values to keep them
			_x = super.x;
			_y = super.y;
			_registrationX = 0;
			_registrationY = 0;
			fixPosition();
		}

		// ================================================================================================================
		// INTERNAL INSTANCE functions ------------------------------------------------------------------------------------

		protected function fixPosition():void {
			// Using localToGlobal/globalToLocal is less precise than doing it mathematically, but the end result is more accurate inside Flash because it's in sync with Flash's positioning and rotating limitations
			var op:Point = new Point(0, 0);
			var rp:Point = new Point(_registrationX, _registrationY);
			rp = parent.globalToLocal(localToGlobal(rp));
			op = parent.globalToLocal(localToGlobal(op));
			super.x = _x - (rp.x - op.x);
			super.y = _y - (rp.y - op.y);
		}

		protected function requestPositionFix():void {
			if (Boolean(stage) && !setToUpdate) {
				setToUpdate = true;
				stage.addEventListener(Event.RENDER, onRender, false, 0, true);
				stage.invalidate();
			}
		}

		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		protected function onRender(e:Event):void {
			stage.removeEventListener(Event.RENDER, onRender);
			setToUpdate = false;
			fixPosition();
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		override public function get x():Number {
			return _x;
		}
		override public function set x(__value:Number):void {
			_x = __value;
			requestPositionFix();
		}

		override public function get y():Number {
			return _y;
		}
		override public function set y(__value:Number):void {
			_y = __value;
			requestPositionFix();
		}

		override public function set rotation(__value:Number):void {
			super.rotation = __value;
			requestPositionFix();
		}
		override public function set scaleX(__value:Number):void {
			super.scaleX = __value;
			requestPositionFix();
		}
		override public function set scaleY(__value:Number):void {
			super.scaleY = __value;
			requestPositionFix();
		}

		public function get registrationX():Number {
			return _registrationX;
		}
		public function set registrationX(__value:Number):void {
			_registrationX = __value;
			requestPositionFix();
		}

		public function get registrationY():Number {
			return _registrationY;
		}
		public function set registrationY(__value:Number):void {
			_registrationY = __value;
			requestPositionFix();
		}

	}
}
