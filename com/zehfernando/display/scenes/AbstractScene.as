package com.zehfernando.display.scenes {
	import com.zehfernando.display.abstracts.ResizableSprite;

	import flash.display.BlendMode;
	import flash.events.Event;

	/**
	 * @author zeh fernando
	 */
	public class AbstractScene extends ResizableSprite {

		// Constant enums
		public static var EVENT_STARTED_SHOWING:String = "sceneStartedShowing";
		public static var EVENT_FINISHED_SHOWING:String = "sceneFinioshedShowing";
		public static var EVENT_STARTED_HIDING:String = "sceneStartedShowing";
		public static var EVENT_FINISHED_HIDING:String = "sceneFinishedShowing";

		// Instances
		private var sceneViewer:SceneViewer;

		// Properties
		protected var _visibility:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AbstractScene() {
			super();

			_visibility = 0;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			throw new Error("Error: the method redrawWidth() of AbstractScene has to be overridden.");
		}

		override protected function redrawHeight():void {
			throw new Error("Error: the method redrawHeight() of AbstractScene has to be overridden.");
		}

		protected function redrawVisibility():void {
			alpha = _visibility;
			visible = _visibility > 0;
			blendMode = _visibility < 1 ? BlendMode.LAYER : BlendMode.NORMAL;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onAddedToStage(__e:Event):void {
			super.onAddedToStage(__e);
			redrawVisibility();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		final public function getSceneViewer():SceneViewer {
			return sceneViewer;
		}

		final public function setSceneViewer(__sceneViewer:SceneViewer):void {
			sceneViewer = __sceneViewer;
		}

		// Shows the scene. Classes that extend this one MUST dispatch the started showing/finished showing events
		public function show():void {
			dispatchEvent(new Event(EVENT_STARTED_SHOWING));
			visibility = 1;
			dispatchEvent(new Event(EVENT_FINISHED_SHOWING));
		}

		// Hides the scene. Classes that extend this one MUST dispatch the started hiding/finished hiding events
		public function hide():void {
			dispatchEvent(new Event(EVENT_STARTED_HIDING));
			visibility = 0;
			dispatchEvent(new Event(EVENT_FINISHED_HIDING));
		}

		public function pause():void {

		}

		public function resume():void {

		}

		public function dispose():void {

		}

		public function canShow():Boolean {
			// Returns true if everything is loaded and it is ready to be shown
			return true;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get visibility():Number {
			return _visibility;
		}
		public function set visibility(__value:Number):void {
			if (_visibility != __value) {
				_visibility = __value;
				redrawVisibility();
			}
		}
	}
}
