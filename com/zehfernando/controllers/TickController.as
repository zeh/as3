package com.zehfernando.controllers {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class TickController extends EventDispatcher {
		
		/* Forces a tick to be dispatched n times per second */
		
		// Event enums
		public static const EVENT_TICK:String = "onTick";
		public static const EVENT_STOP:String = "onStop";
		public static const EVENT_START:String = "onStart";
		
		// Properties
		protected var _desiredFPS:Number;
		protected var _isRunning:Boolean;
		protected var _allowMultipleCallsPerFrame:Boolean;			// If true, multiple calls may be made per frame, to try and stay within the desired FPS; if not, it may go below the desired fps

		protected var lastTimeFired:int;
		
		protected var container:Sprite;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TickController(__desiredFPS:Number = NaN, __paused:Boolean = false, __allowMultipleCallsPerFrame:Boolean = true) {
			super();
			
			_desiredFPS = __desiredFPS;
			_isRunning = false;
			_allowMultipleCallsPerFrame = __allowMultipleCallsPerFrame;
		
			if (!__paused) start();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
		
		protected function tick(): void {
			// Updates all values
			dispatchEvent(new Event(EVENT_TICK));
		}
		
		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onEnterFrameTick(e:Event): void {
			
			if (isNaN(_desiredFPS)) {
				// Always update, ignore time
				tick();
			} else {
				// Update if needed, as many times as needed
				var now:int = getTimer();
				var tickFrameTime:Number = 1000/_desiredFPS;

				if (_allowMultipleCallsPerFrame) {
					while (now > lastTimeFired + tickFrameTime) {
						tick();
						lastTimeFired += tickFrameTime;
					}
				} else {
					if (now > lastTimeFired + tickFrameTime) {
						tick();
						lastTimeFired = now;
					}
				}
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function start(): void {
			if (!_isRunning) {
				container = new Sprite();
				container.addEventListener(Event.ENTER_FRAME, onEnterFrameTick, false, 0, true);
				_isRunning = true;
				lastTimeFired = getTimer();
				dispatchEvent(new Event(EVENT_START));
			}
		}
		
		public function stop(): void {
			if (_isRunning) {
				container.removeEventListener(Event.ENTER_FRAME, onEnterFrameTick);
				container = null;
				_isRunning = false;
				dispatchEvent(new Event(EVENT_STOP));
			}
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// TODO: add ability to call a minimum of X times per second too
	}
}
