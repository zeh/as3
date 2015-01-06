package com.zehfernando.controllers {
	import com.zehfernando.utils.getTimerUInt;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * @author zeh
	 */
	public class TimelineController extends EventDispatcher {

		// Constants
		public static var EVENT_LOOPED:String = "onLooped";
		public static var EVENT_FINISHED:String = "onFinished";

		// Properties
		protected var _isPlaying:Boolean;
		protected var _loop:Boolean;
		protected var _fps:Number;

		protected var lastFrameUpdateTime:uint;

		protected var _movieClip:MovieClip;
		protected var _actualFrame:Number;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TimelineController(__movieClip:MovieClip, __fps:Number = 30) {
			super(null);

			_movieClip = __movieClip;
			_fps = __fps;

			_movieClip.gotoAndStop(1);
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onEnterFrame(e:Event):void {
			// Move playhead

			var now:uint = getTimerUInt();
			var newFrame:Number = _actualFrame + ((now - lastFrameUpdateTime) / 1000) * _fps;

			if (Math.round(newFrame) > _movieClip.totalFrames) {
				if (_loop) {
					// Looping
					newFrame -= _movieClip.totalFrames;
					dispatchEvent(new Event(EVENT_LOOPED));
				} else {
					// Finished
					newFrame = _movieClip.totalFrames;
					stop();
					dispatchEvent(new Event(EVENT_FINISHED));
				}
			}

			_actualFrame = newFrame;
			_movieClip.gotoAndStop(Math.round(newFrame));
			lastFrameUpdateTime = now;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function play(__loop:Boolean = true):void {
			if (!_isPlaying) {
				// Start playing
				lastFrameUpdateTime = getTimerUInt();
				if (Boolean(_movieClip)) {
					_movieClip.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
				}

				_actualFrame = _movieClip.currentFrame;
				_movieClip.stop();

				_loop = __loop;
				_isPlaying = true;
			}
		}

		public function stop():void {
			if (_isPlaying) {
				if (Boolean(_movieClip)) {
					_movieClip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				}
				_isPlaying = false;
			}
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get fps():Number {
			return _fps;
		}
		public function set fps(__value:Number):void {
			if (_fps != __value) {
				_fps = __value;
			}
		}

		public function get frame():Number {
			return _movieClip.currentFrame;
		}
		public function set frame(__value:Number):void {
			if (_movieClip.currentFrame != __value) {
				_movieClip.gotoAndStop(Math.round(__value));
				_actualFrame = __value;
			}
		}

		public function get totalFrames():int {
			return _movieClip.totalFrames;
		}

		public function get isPlaying():Boolean {
			return _isPlaying;
		}
	}
}
