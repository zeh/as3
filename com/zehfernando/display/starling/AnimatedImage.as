package com.zehfernando.display.starling {
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;

	import com.zehfernando.signals.SimpleSignal;
	import com.zehfernando.utils.console.warn;
	import com.zehfernando.utils.getTimerUInt;
	/**
	 * @author zeh fernando
	 */
	public class AnimatedImage extends Image {

		// Properties
		private var _tileWidth:int;
		private var _tileHeight:int;
		private var _cropMargin:Number;

		private var _frame:int;
		private var _totalFrames:int;
		private var _position:Number;

		private var _fps:Number;

		private var rows:int;
		private var cols:int;

		private var _isPlaying:Boolean;
		private var _loop:Boolean;

		private var timeStartedPlaying:uint;
		private var frameStartedPlaying:int;
		private var _internalScale:Number;

		// Instances
		private var _onFinished:SimpleSignal;

		// Temporary properties for avoiding garbage collection
		private var row:int, col:int;
		private var l:Number, r:Number, t:Number, b:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AnimatedImage(__texture:Texture, __tileWidth:int, __tileHeight:int, __totalFrames:int = -1, __fps:Number = 30, __cropMargin:Number = 0) {
			super(__texture);

			_tileWidth = __tileWidth;
			_tileHeight = __tileHeight;
			_fps = __fps;
			_frame = -1;
			_internalScale = 1;
			_position = 0;
			_cropMargin = __cropMargin;

			_onFinished = new SimpleSignal();

			cols = Math.floor(__texture.nativeWidth / __tileWidth);
			rows = Math.floor(__texture.nativeHeight / __tileHeight);
			_totalFrames = __totalFrames > -1 ? __totalFrames : rows * cols;

			setFrame(0, false, true);

			super.width = _tileWidth;
			super.height = _tileHeight;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function setFrame(__newFrame:int, __checkProgress:Boolean = false, __resetPosition:Boolean = false):void {
			var nf:int = __newFrame % _totalFrames;
			var mustStop:Boolean = false;
			if (nf != _frame) {
				if (__checkProgress && (nf < _frame || nf >= totalFrames-1) && !_loop) {
					// Must end
					nf = totalFrames-1;
					mustStop = true;
				}

				_frame = nf;

				updateTextureCoordinates();

				if (mustStop) {
					pause();
					_onFinished.dispatch(this);
				}
			}
		}

		private function updateTextureCoordinates():void {
			row = int(_frame / cols);
			col = _frame % cols;

			l = col * _tileWidth + _cropMargin;
			r = (col + 1) * _tileWidth - _cropMargin;
			t = row * _tileHeight + _cropMargin;
			b = (row + 1) * _tileHeight - _cropMargin;

			l /= texture.nativeWidth;
			r /= texture.nativeWidth;
			t /= texture.nativeHeight;
			b /= texture.nativeHeight;

			setTexCoordsTo(0, l, t);
			setTexCoordsTo(1, r, t);
			setTexCoordsTo(2, l, b);
			setTexCoordsTo(3, r, b);
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onEnterFramePlay(__e:Event):void {
			setFrame(frameStartedPlaying + Math.floor(((getTimerUInt() - timeStartedPlaying) / 1000) * _fps), true);
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function play():void {
			if (!_isPlaying) {
				_isPlaying = true;
				frameStartedPlaying = _frame;
				timeStartedPlaying = getTimerUInt();
				addEventListener(Event.ENTER_FRAME, onEnterFramePlay);
			}
		}

		public function stop():void {
			setFrame(0, false, true);
			pause();
		}

		public function pause():void {
			if (_isPlaying) {
				_isPlaying = false;
				removeEventListener(Event.ENTER_FRAME, onEnterFramePlay);
			}
		}

		override public function dispose():void {
			pause();

			_onFinished.removeAll();
			_onFinished = null;

			super.dispose();
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get frame():int {
			return _frame;
		}
		public function set frame(__value:int):void {
			setFrame(__value, false, true);
		}

		public function get totalFrames():int {
			return _totalFrames;
		}

		public function get loop():Boolean {
			return _loop;
		}
		public function set loop(__value:Boolean):void {
			if (_loop != __value) {
				_loop = __value;
			}
		}

		public function get onFinished():SimpleSignal {
			return _onFinished;
		}

		override public function get width():Number {
			return _tileWidth;
		}

		override public function set width(__value:Number):void {
			warn("set width ==> " + __value);
			//super.width = value;
		}

		override public function get height():Number {
			return _tileHeight;
		}

		override public function set height(__value:Number):void {
			warn("set height ==> " + __value);
			//super.height = value;
		}

		override public function get scaleX():Number {
			return 1;
		}

		override public function set scaleX(__value:Number):void {
			super.scaleX = __value * _internalScale * (_tileWidth / texture.nativeWidth);
		}

		override public function get scaleY():Number {
			return super.scaleY;
		}

		override public function set scaleY(__value:Number):void {
			super.scaleY = __value * _internalScale * (_tileHeight / texture.nativeHeight);
		}

		public function get position():Number {
			return _position;
		}

		public function get fps():Number {
			return _fps;
		}

		public function get cropMargin():Number {
			return _cropMargin;
		}
		public function set cropMargin(__value:Number):void {
			if (_cropMargin != __value) {
				_cropMargin = __value;
				updateTextureCoordinates();
			}
		}
	}
}