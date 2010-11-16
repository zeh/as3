package com.zehfernando.controllers {
	import flash.events.EventDispatcher;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class ValueAttenuator extends EventDispatcher {
		
		// Events
		public static const EVENT_TICK:String = "onTick";
		public static const EVENT_CHANGED:String = "onChanged";
		
		// Properties
		protected var _divisor:Number;
		protected var _isRunning:Boolean;
		
		protected var _minimumChange:Number = 0; 
		
		protected var _current:Number;
		protected var _target:Number;

		protected var _prevValue:Number;
		
		// Instances
		protected var container:Sprite;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ValueAttenuator(__divisor:Number = 2, __targetValue:Number = NaN, __currentValue:Number = NaN) {
			// 1 = no attenuation
			_divisor = __divisor;
			_isRunning = false;
			
			_current = !isNaN(__currentValue) ? __currentValue : __targetValue;
			_target = __targetValue;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
		
		protected function tick(): void {
			// Updates all values
			
			_current += (_target - _current) / _divisor;
		}
		
		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onEnterFrameTick(e:Event): void {
			_prevValue = _current;
			tick();
			dispatchEvent(new Event(EVENT_TICK));
			
			if (Math.abs(_current - _prevValue) > _minimumChange) dispatchEvent(new Event(EVENT_CHANGED));
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function start(): void {
			if (!_isRunning) {
				container = new Sprite();
				container.addEventListener(Event.ENTER_FRAME, onEnterFrameTick);
				_isRunning = true;
			}
		}
		
		public function stop(): void {
			if (_isRunning) {
				container.removeEventListener(Event.ENTER_FRAME, onEnterFrameTick);
				container = null;
				_isRunning = false;
			}
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

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
