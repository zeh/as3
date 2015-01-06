package com.zehfernando.data.types {
	import com.zehfernando.utils.getTimerUInt;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * @author zeh
	 */
	public class AutoAttenuatedNumber extends EventDispatcher {

		// Events
		public static const EVENT_TICK:String = "onTick";					// Every frame
		public static const EVENT_CHANGED:String = "onChanged";				// Every frame, IF there's a change on the value (of minimum _minimumChange)

		// Properties
		protected var _divisor:Number;
		protected var _isRunning:Boolean;

		protected var _minimumChange:Number = 0;			// Minimum change for EVENT_CHANGED dispatch

		protected var _current:Number;
		protected var _target:Number;

		protected var _tickRate:Number;						// Number of ticks per second (if NaN, uses the normal framerate)

		protected var _prevValue:Number;

		protected var lastTickTime:uint;					// Time last tick occured

		// Instances
		protected var container:Sprite;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AutoAttenuatedNumber(__divisor:Number = 2, __targetValue:Number = 0, __currentValue:Number = NaN, __paused:Boolean = false, __tickRate:Number = NaN) {
			// 1 = no attenuation
			_divisor = __divisor;
			_isRunning = false;

			_tickRate = __tickRate;

			_current = !isNaN(__currentValue) ? __currentValue : __targetValue;
			_target = __targetValue;

			if (!__paused) start();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function tick():void {
			// Updates all values
			_prevValue = _current;
			_current += (_target - _current) / _divisor;
			dispatchEvent(new Event(EVENT_TICK));
			if (Math.abs(_current - _prevValue) > _minimumChange) dispatchEvent(new Event(EVENT_CHANGED));
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onEnterFrameTick(e:Event):void {

			if (isNaN(_tickRate)) {
				// Always update, ignore time
				tick();
			} else {
				// Update if needed, as many times as needed
				var now:uint = getTimerUInt();
				var tickFrameTime:Number = 1000/_tickRate;

				while (now > lastTickTime + tickFrameTime) {
					tick();
					lastTickTime += tickFrameTime;
				}
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function start():void {
			if (!_isRunning) {
				container = new Sprite();
				container.addEventListener(Event.ENTER_FRAME, onEnterFrameTick, false, 0, true);
				_isRunning = true;
				lastTickTime = getTimerUInt();
			}
		}

		public function stop():void {
			if (_isRunning) {
				container.removeEventListener(Event.ENTER_FRAME, onEnterFrameTick);
				container = null;
				_isRunning = false;
			}
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get divisor():Number {
			return _divisor;
		}

		public function set divisor(__value:Number):void {
			if (_divisor != __value) {
				_divisor = __value;
			}
		}

		public function get current():Number {
			return _current;
		}

		public function set current(__value:Number):void {
			_current = __value;
		}

		public function get target():Number {
			return _target;
		}

		public function set target(__value:Number):void {
			_target = __value;
		}

		public function get minimumChange():Number {
			return _minimumChange;
		}

		public function set minimumChange(__value:Number):void {
			_minimumChange = __value;
		}
	}
}
