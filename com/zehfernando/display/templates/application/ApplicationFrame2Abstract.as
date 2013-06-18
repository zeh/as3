package com.zehfernando.display.templates.application {

	import com.zehfernando.display.templates.application.events.ApplicationFrame2Event;
	import com.zehfernando.utils.RenderUtils;

	import flash.display.MovieClip;
	/**
	 * @author Zeh
	 */
	public class ApplicationFrame2Abstract extends MovieClip {

		// Instances
		protected var _width:Number;
		protected var _height:Number;

		protected var inited:Boolean;
		protected var _initPhase:Number;

		public var userSpeedBytesPerSecond:Number;						// Measured user speed
		public var userSpeedBitsPerSecond:Number;						// Measured user speed
		public var userLoadingTime:Number;								// Complete data loading time, in seconds

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ApplicationFrame2Abstract() {

			_width = 100;
			_height = 100;

			inited = false;
			_initPhase = 0;

			requestRedraw();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function init():void {
			// Start loading stuff
			inited = true;
			requestRedraw();

			_initPhase = 1;
			dispatchEvent(new ApplicationFrame2Event(ApplicationFrame2Event.INIT_PROGRESS));
			dispatchEvent(new ApplicationFrame2Event(ApplicationFrame2Event.INIT_COMPLETE));
		}

		public function show():void {
			// Finished, shows itself
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function requestRedraw():void {
			RenderUtils.addFunction(redrawWidth);
			RenderUtils.addFunction(redrawHeight);
		}

		protected function redrawWidth():void {
			// EXTEND THIS!
		}

		protected function redrawHeight():void {
			// EXTEND THIS!
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return _width;
		}
		override public function set width(__value:Number):void {
			if (_width != __value) {
				_width = __value;
				redrawWidth();
			}
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				redrawHeight();
			}
		}

		public function getInitPhase():Number {
			return _initPhase;
		}

	}
}
