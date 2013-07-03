package com.zehfernando.models {
	import com.zehfernando.signals.SimpleSignal;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * @author zeh fernando
	 */
	public class GameLooper {

		/**
		 * Dispatches events, controlling the main game loop
		 */

		// Properties
		private var _isRunning:Boolean;
		private var _timeScale:Number;
		private var _currentTick:int;				// Current absolute frame
		private var _currentTime:int;				// Current absolute time, in ms
		private var _tickDeltaTime:int;				// Time since last tick, in ms
		private var _minFPS:Number;
		private var _maxFPS:Number;

		private var lastTimeUpdated:int;
		private var minInterval:Number;				// Min time to wait (in ms) between updates; causes skips (NaN = never enforces)
		private var maxInterval:Number;				// Max time to wait (in ms) between updates; causes repetitions (NaN = never enforces)

		// Temp stuff
		private var now:int;
		private var frameDeltaTime:int;

		// Instances
		private var sprite:Sprite;

		private var _onResumed:SimpleSignal;
		private var _onPaused:SimpleSignal;
		private var _onTicked:SimpleSignal;					// Receives: currentTimeSeconds:Number, tickDeltaTimeSeconds:Number, currentTick:int
		private var _onTickedOncePerVisualFrame:SimpleSignal;		// Only fired once per frame. Receives: currentTimeSeconds:Number, tickDeltaTimeSeconds:Number, currentTick:int

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GameLooper(__paused:Boolean = false, __minFPS:Number = NaN, __maxFPS:Number = NaN) {
			_minFPS = __minFPS;
			_maxFPS = __maxFPS;
			_timeScale = 1;
			_currentTick = 0;
			_currentTime = 0;
			_tickDeltaTime = 0;
			_isRunning = false;

			maxInterval = isNaN(_minFPS) ? NaN : (1000 / _minFPS);
			minInterval = isNaN(_maxFPS) ? NaN : (1000 / _maxFPS);

			_onResumed = new SimpleSignal();
			_onPaused = new SimpleSignal();
			_onTicked = new SimpleSignal();
			_onTickedOncePerVisualFrame = new SimpleSignal();

			if (!__paused) resume();

		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------



		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onSpriteEnterFrame(__e:Event):void {
			now = getTimer();
			frameDeltaTime = now - lastTimeUpdated;

			if (isNaN(minInterval) || frameDeltaTime >= minInterval) {
				if (!isNaN(maxInterval)) {
					// Needs several updates
					while (now > lastTimeUpdated + maxInterval) {
						update(maxInterval * _timeScale, now <= lastTimeUpdated + maxInterval * 2); // Only dispatches visual frame update on the last call
						lastTimeUpdated += maxInterval;
					}
				} else {
					// Just a single simple update
					update(frameDeltaTime * _timeScale, true);
					lastTimeUpdated = now; // TODO: not perfect? drifting for ~1 frame every 20 seconds or so when minInterval is used
				}
			}
		}

		private function update(__timePassedMS:int, __newVisualFrame:Boolean = true):void {
			_currentTick++;
			_currentTime += __timePassedMS;
			_tickDeltaTime = __timePassedMS;
			_onTicked.dispatch(currentTimeSeconds, tickDeltaTimeSeconds, currentTick);

			if (__newVisualFrame) _onTickedOncePerVisualFrame.dispatch(currentTimeSeconds, tickDeltaTimeSeconds, currentTick);
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function resume():void {
			if (!_isRunning) {
				_isRunning = true;

				lastTimeUpdated = getTimer();

				_onResumed.dispatch();

				if (sprite == null) {
					sprite = new Sprite();
					sprite.addEventListener(Event.ENTER_FRAME, onSpriteEnterFrame);
				}
			}
		}

		public function pause():void {
			if (_isRunning) {
				_isRunning = false;

				_onPaused.dispatch();

				if (sprite != null) {
					sprite.removeEventListener(Event.ENTER_FRAME, onSpriteEnterFrame);
					sprite = null;
				}
			}
		}

		public function dispose():void {
			pause();
			_onResumed.removeAll();
			_onPaused.removeAll();
			_onTicked.removeAll();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get currentTick():int {
			return _currentTick;
		}

		public function get currentTimeSeconds():Number {
			return _currentTime / 1000;
		}

		public function get tickDeltaTimeSeconds():Number {
			return _tickDeltaTime / 1000;
		}

		public function get timeScale():Number {
			return _timeScale;
		}

		public function set timeScale(__value:Number):void {
			if (_timeScale != __value) {
				_timeScale = __value;
			}
		}

		public function get onResumed():SimpleSignal {
			return _onResumed;
		}

		public function get onPaused():SimpleSignal {
			return _onPaused;
		}

		public function get onTicked():SimpleSignal {
			return _onTicked;
		}

		public function get onTickedOncePerVisualFrame():SimpleSignal {
			return _onTickedOncePerVisualFrame;
		}
	}
}
