package com.zehfernando.display.starling.scenes {
	import starling.display.Sprite;
	import starling.events.Event;

	import com.zehfernando.signals.SimpleSignal;

	import flash.display.Stage;

	/**
	 * @author zeh fernando
	 */
	public class StarlingScene extends Sprite {

		// Properties
		private var _visibility:Number;
		private var _width:Number;
		private var _height:Number;

		// Instances
		private var _sceneViewer:StarlingSceneViewer;
		private var _legacyStage:Stage;
		private var _onStartedShowing:SimpleSignal = new SimpleSignal();
		private var _onFinishedShowing:SimpleSignal = new SimpleSignal();
		private var _onStartedHiding:SimpleSignal = new SimpleSignal();
		private var _onFinishedHiding:SimpleSignal = new SimpleSignal();


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StarlingScene(__width:Number, __height:Number) {
			_width = __width;
			_height = __height;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			_visibility = 0;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function redrawVisibility():void {
			alpha = _visibility;
			visible = _visibility > 0;
			//blendMode = _visibility < 1 ? BlendMode.LAYER : BlendMode.NORMAL;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onAddedToStage(__e:Event):void {
			redrawVisibility();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		// Shows the scene. Classes that extend this one MUST dispatch the started showing/finished showing events
		public function show():void {
			_onStartedShowing.dispatch(this);
			visibility = 1;
			_onFinishedShowing.dispatch(this);
		}

		// Hides the scene. Classes that extend this one MUST dispatch the started hiding/finished hiding events
		public function hide():void {
			_onStartedHiding.dispatch(this);
			visibility = 0;
			_onFinishedHiding.dispatch(this);
		}

		public function pause():void {

		}

		public function resume():void {

		}

		override public function dispose():void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_sceneViewer = null;
			_legacyStage = null;

			_onStartedShowing.removeAll();
			_onStartedShowing = null;

			_onFinishedShowing.removeAll();
			_onFinishedShowing = null;

			_onStartedHiding.removeAll();
			_onStartedHiding = null;

			_onFinishedHiding.removeAll();
			_onFinishedHiding = null;

			super.dispose();
		}

		public function canShow():Boolean {
			// Returns true if everything is loaded and it is ready to be shown
			return true;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public final function get sceneViewer():StarlingSceneViewer {
			return _sceneViewer;
		}

		public final function set sceneViewer(__sceneViewer:StarlingSceneViewer):void {
			_sceneViewer = __sceneViewer;
		}

		public final function get legacyStage():Stage {
			return _legacyStage;
		}

		final public function set legacyStage(__legacyStage:Stage):void {
			_legacyStage = __legacyStage;
		}

		public function get visibility():Number {
			return _visibility;
		}
		public function set visibility(__value:Number):void {
			if (_visibility != __value) {
				_visibility = __value;
				redrawVisibility();
			}
		}

		public function get onStartedShowing():SimpleSignal {
			return _onStartedShowing;
		}

		public function get onFinishedShowing():SimpleSignal {
			return _onFinishedShowing;
		}

		public function get onStartedHiding():SimpleSignal {
			return _onStartedHiding;
		}

		public function get onFinishedHiding():SimpleSignal {
			return _onFinishedHiding;
		}

		override public function get width():Number {
			return _width;
		}

		override public function get height():Number {
			return _height;
		}
	}
}