/**
 * An object that continuously loops ("ticks") on every rendering frame, dispatching SimpleSignal calls every time
 * it does so.
 *
 * More information: http://zehfernando.com/2013/a-gamelooper-class-for-actionscript-3-projects/
 *
 * Using GameLooper is similar to creating an ENTER_FRAME event and watching for it, but with these differences:
 *  . Actual "tick" call rate is flexible: it can execute more than one call per frame, or skip frames as needed
 *  . It keeps track of relative time, so it gets passed time and frame data (for correct position calculation)
 *  . Time is flexible, so it can be multiplied/scaled, paused, and resumed
 *
 *
 * How to use:
 *
 * 1. Create a new instance of GameLooper. This will make the looper's onTicked() signal be fired once per frame
 * (same as ENTER_FRAME):
 *
 *     var looper:GameLooper = new GameLooper(); // Create and start
 *
 *     var looper:GameLooper = new GameLooper(true); // Creates and pauses
 *
 * 2. Create function callbacks to receive the signal (signals are like events, but simpler):
 *
 *     looper.onTicked.add(onTick);
 *
 *     private function onTick(currentTimeSeconds:Number, tickDeltaTimeSeconds:Number, currentTick:int):void {
 *         var speed:Number = 10; // Speed of the box, in pixels per seconds
 *         box.x += speed * tickDeltaTimeSeconds;
 *     }
 *
 *
 * You can also:
 *
 * 1. Pause/resume the looper to pause/resume the game loop:
 *
 *     looper.pause();
 *     looper.resume();
 *
 *
 * 2. Change the time scale to make time go "faster" (currentTimeSeconds, and tickDeltaTimeSeconds):
 *
 *     looper.timeScale = 2; // 2x original speed (faster motion)
 *     looper.timeScale = 0.5; // 0.5x original speed (slower motion)
 *
 * 3. Specify a minimum FPS as a parameter. When the minFPS parameter is used, the looper is always dispatched at
 * least that amount of times per second, regardless of the number of frames:
 *
 *     var looper:GameLooper = new GameLooper(false, 8);
 *
 * In the above example, on a SWF with 4 frames per second, onTicked would be fired twice per frame. On a SWF with
 * 6 frames per second, it would be fired once, and then twice every other frame.
 *
 * 4. Specify a maximum FPS as a parameter. When the maxFPS parameter is used, the looper is not dispatched more
 * that number of times per second:
 *
 *     var looper:GameLooper = new GameLooper(false, NaN, 10);
 *
 * In the above example, on a SWF with 30 frames per second, onTicked would be fired once every 3 frames.
 *
 */

package com.zehfernando.models {
	import com.zehfernando.signals.SimpleSignal;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	/**
	 * @author zeh fernando
	 */
	public class GameLooper {

		// Properties
		private var _isRunning:Boolean;
		private var _timeScale:Number;
		private var _currentTick:int;				// Current absolute frame
		private var _currentTime:int;				// Current absolute time, in ms
		private var _tickDeltaTime:int;				// Time since last tick, in ms
		private var _minFPS:Number;
		private var _maxFPS:Number;

		private var lastTimeUpdated:uint;
		private var minInterval:Number;				// Min time to wait (in ms) between updates; causes skips (NaN = never enforces)
		private var maxInterval:Number;				// Max time to wait (in ms) between updates; causes repetitions (NaN = never enforces)

		// Temp stuff to reduce garbage collection
		private var now:uint;
		private var frameDeltaTime:int;
		private var interval:int;

		// Instances
		private var sprite:Sprite;

		private var _onResumed:SimpleSignal;
		private var _onPaused:SimpleSignal;
		private var _onTicked:SimpleSignal;							// Receives: currentTimeSeconds:Number, tickDeltaTimeSeconds:Number, currentTick:int
		private var _onTickedOncePerVisualFrame:SimpleSignal;		// Only fired once per frame. Receives: currentTimeSeconds:Number, tickDeltaTimeSeconds:Number, currentTick:int

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		/**
		 * Creates a new GameLooper instance.
		 *
		 * @param paused Starts in paused state if true. Default is false, which means it starts looping right
		 *               away.
		 *
		 * @param minFPS Minimum amount of ticks to dispatch per second. This can cause frames to dispatch more
		 *               than one onTicked event. Default is NaN, which means there's no minimum (synchronizes
		 *               with ENTER_FRAME).
		 *
		 * @param maxFPS Maximum amount of ticks to dispatch per second. This can cause frames to skip dispatching
		 *               onTicked events. Default is NaN, which means there's no maximum (synchronizes to
		 *               ENTER_FRAME).
		 */
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
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onSpriteEnterFrame(__e:Event):void {
			now = getTimerUInt();
			frameDeltaTime = now - lastTimeUpdated;

			if (isNaN(minInterval) || frameDeltaTime >= minInterval) {
				if (!isNaN(maxInterval)) {
					// Needs several updates
					interval = Math.min(frameDeltaTime, maxInterval);
					while (now >= lastTimeUpdated + interval) {
						update(interval * _timeScale, now <= lastTimeUpdated + maxInterval * 2); // Only dispatches visual frame update on the last call
						lastTimeUpdated += interval;
					}
				} else {
					// Just a single simple update
					update(frameDeltaTime * _timeScale, true);
					lastTimeUpdated = now; // TODO: not perfect? drifting for ~1 frame every 20 seconds or so when minInterval is used
				}
			}
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function update(__timePassedMS:int, __newVisualFrame:Boolean = true):void {
			_currentTick++;
			_currentTime += __timePassedMS;
			_tickDeltaTime = __timePassedMS;
			_onTicked.dispatch(currentTimeSeconds, tickDeltaTimeSeconds, currentTick);

			if (__newVisualFrame) _onTickedOncePerVisualFrame.dispatch(currentTimeSeconds, tickDeltaTimeSeconds, currentTick);
		}

		private function getTimerUInt():uint {
			// A safe getTimer() - runs for ~1192 hours instead of ~596
			var v:int = getTimer();
			return v < 0 ? int.MAX_VALUE + 1 + v - int.MIN_VALUE : v;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function updateOnce(__callback:Function):void {
			__callback(currentTimeSeconds, tickDeltaTimeSeconds, currentTick);
		}

		/**
		 * Resumes running this instance, if it's in a paused state.
		 *
		 * <p>Calling this method when this instance is already running has no effect.</p>
		 *
		 * @see #isRunning
		 */
		public function resume():void {
			if (!_isRunning) {
				_isRunning = true;

				lastTimeUpdated = getTimerUInt();

				_onResumed.dispatch();

				if (sprite == null) {
					sprite = new Sprite();
					sprite.addEventListener(Event.ENTER_FRAME, onSpriteEnterFrame);
				}
			}
		}

		/**
		 * Pauses this instance, if it's in a running state. All time- and tick-related property values are also
		 * paused.
		 *
		 * <p>Calling this method when this instance is already paused has no effect.</p>
		 *
		 * @see #isRunning
		 */
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

		/**
		 * Prepares this instance for disposal, by pausing it and removing all signal callbacks.
		 *
		 * <p>Calling this method is not strictly necessary, but a good practice unless you're pausing it and
		 * clearing all signals manually.</p>
		 */
		public function dispose():void {
			pause();
			_onResumed.removeAll();
			_onPaused.removeAll();
			_onTicked.removeAll();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		/**
		 * The index of the tick (an "internal frame") executed last.
		 */
		public function get currentTick():int {
			return _currentTick;
		}

		/**
		 * The current internal time of the looper, in seconds. This is aligned to the last tick executed.
		 */
		public function get currentTimeSeconds():Number {
			return _currentTime / 1000;
		}

		/**
		 * How much time has been spent between the last and the previous tick, in seconds.
		 */
		public function get tickDeltaTimeSeconds():Number {
			return _tickDeltaTime / 1000;
		}

		/**
		 * The time scale for the internal loop time. Changing this has an impact on the time used by the looper,
		 * and can have the effect of make objects that depend on it slower or faster.
		 *
		 * <p>The actual number of signal callbacks dispatched per second do not change.</p>
		 */
		public function get timeScale():Number {
			return _timeScale;
		}

		/**
		 * The time scale for the internal loop time. Changing this has an impact on the time used by the looper,
		 * and can have the effect of make objects that depend on it slower or faster.
		 *
		 * <p>The actual number of signal callbacks dispatched per second do not change.</p>
		 */
		public function set timeScale(__value:Number):void {
			if (_timeScale != __value) {
				_timeScale = __value;
			}
		}

		/**
		 * A signal that sends callbacks for when the looper resumes running. Sends no parameters.
		 *
		 * <p>Usage:</p>
		 *
		 * <pre>
		 * private function myOnResumed():void {
		 *     trace("Looper has resumed");
		 * }
		 *
		 * myGameLooper.onResumed.add(myOnResumed);
		 * </pre>
		 */
		public function get onResumed():SimpleSignal {
			return _onResumed;
		}

		/**
		 * A signal that sends callbacks for when the looper pauses execution. Sends no parameters.
		 *
		 * <p>Usage:</p>
		 *
		 * <pre>
		 * private function myOnPaused():void {
		 *     trace("Looper has paused");
		 * }
		 *
		 * myGameLooper.onPaused.add(myOnPaused);
		 * </pre>
		 */
		public function get onPaused():SimpleSignal {
			return _onPaused;
		}

		/**
		 * A signal that sends callbacks for when the looper instance loops (that is, it "ticks"). It sends the
		 * current time (absolute and delta, as seconds) and current tick (as an int) as parameters.
		 *
		 * <p>Usage:</p>
		 *
		 * <pre>
		 * private function myOnTicked(currentTimeSeconds:Number, tickDeltaTimeSeconds:Number, currentTick:int):void {
		 *     trace("A loop happened.");
		 *     trace("Time since it started executing:" + currentTimeSeconds + " seconds");
		 *     trace("           Time since last tick:" + tickDeltaTimeSeconds + " seconds");
		 *     trace("        Tick/frame count so far:" + currentTick);
		 * }
		 *
		 * myGameLooper.onTicked.add(myOnTicked);
		 * </pre>
		 */
		public function get onTicked():SimpleSignal {
			return _onTicked;
		}

		/**
		 * A signal that sends callbacks for when the looper instance loops (that is, it "ticks") only once per
		 * frame (basically ignoring the <code>minFPS</code> parameter). It sends the current time (absolute and
		 * delta, as seconds) and current tick (as an int) as parameters.
		 *
		 * <p>This is useful when using <code>minFPS</code> because you can use the <code>onTicked</code> callback
		 * to do any state changes your game needs, but then only perform visual updates after a
		 * <code>onTickedOncePerVisualFrame()</code> call. If you need to enforce a minimum number of frames per
		 * second but did all visual updates on <code>onTicked()</code>, you could potentially be repeating useless
		 * visual updates.
		 *
		 * <p>Usage:</p>
		 *
		 * <pre>
		 * private function myOnTickedOncePerVisualFrame(currentTimeSeconds:Number, tickDeltaTimeSeconds:Number, currentTick:int):void {
		 *     trace("At least one loop happened in this frame.");
		 *     trace("Time since it started executing:" + currentTimeSeconds + " seconds");
		 *     trace("           Time since last tick:" + tickDeltaTimeSeconds + " seconds");
		 *     trace("        Tick/frame count so far:" + currentTick);
		 * }
		 *
		 * myGameLooper.onTickedOncePerVisualFrame.add(myOnTickedOncePerVisualFrame);
		 * </pre>
		 */
		public function get onTickedOncePerVisualFrame():SimpleSignal {
			return _onTickedOncePerVisualFrame;
		}

		/**
		 * Returns <code>true</code> if the GameLooper instance is running, <code>false</code> if it is paused.
		 *
		 * @see #pause()
		 * @see #resume()
		 */
		public function get isRunning():Boolean {
			return _isRunning;
		}
	}
}
