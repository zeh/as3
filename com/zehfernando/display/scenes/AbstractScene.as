package com.zehfernando.display.scenes {
	import com.zehfernando.display.abstracts.ResizableSprite;

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

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AbstractScene() {
			super();

			visible = false;
			alpha = 0;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			throw new Error("Error: the method redrawWidth() of ResizableSprite has to be overridden.");
		}

		override protected function redrawHeight():void {
			throw new Error("Error: the method redrawHeight() of ResizableSprite has to be overridden.");
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

			alpha = 1;
			visible = true;

			dispatchEvent(new Event(EVENT_FINISHED_SHOWING));
		}

		// Hides the scene. Classes that extend this one MUST dispatch the started hiding/finished hiding events
		public function hide():void {
			dispatchEvent(new Event(EVENT_STARTED_HIDING));

			alpha = 0;
			visible = false;

			dispatchEvent(new Event(EVENT_FINISHED_HIDING));
		}

		public function pause():void {

		}

		public function resume():void {

		}

		public function dispose():void {

		}
	}
}
