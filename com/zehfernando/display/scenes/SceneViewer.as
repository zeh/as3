package com.zehfernando.display.scenes {
	import com.zehfernando.display.abstracts.ResizableSprite;

	import flash.events.Event;
	import flash.system.System;

	/**
	 * @author zeh fernando
	 */
	public class SceneViewer extends ResizableSprite {

		// Properties
		private var isHidingScene:Boolean;
		private var isShowingScene:Boolean;

		private var mustHideCurrentScene:Boolean;				// Must hide current scene after it's done showing

		// Instances
		private var currentScene:AbstractScene;
		private var nextScene:AbstractScene;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function SceneViewer() {
			super();
			currentScene = null;
			nextScene = null;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			if (currentScene != null) currentScene.width = _width;
			if (nextScene != null) nextScene.width = _width;
		}

		override protected function redrawHeight():void {
			if (currentScene != null) currentScene.height = _height;
			if (nextScene != null) nextScene.height = _height;
		}

		private function showCurrentScene():void {
			isShowingScene = true;
			currentScene.show();
		}

		private function hideCurrentScene():void {
			isHidingScene = true;
			currentScene.hide();
		}

		private function addScene(__scene:AbstractScene):void {
			__scene.setSceneViewer(this);
			__scene.width = _width;
			__scene.height = _height;
			__scene.addEventListener(AbstractScene.EVENT_STARTED_SHOWING, onStartedShowingScene, false, 0, true);
			__scene.addEventListener(AbstractScene.EVENT_FINISHED_SHOWING, onFinishedShowingScene, false, 0, true);
			__scene.addEventListener(AbstractScene.EVENT_STARTED_HIDING, onStartedHidingScene, false, 0, true);
			__scene.addEventListener(AbstractScene.EVENT_FINISHED_HIDING, onFinishedHidingScene, false, 0, true);
			addChild(__scene);
		}

		private function removeScene(__scene:AbstractScene):void {
			__scene.dispose();
			removeChild(__scene);
			__scene.setSceneViewer(null);
			__scene.removeEventListener(AbstractScene.EVENT_STARTED_SHOWING, onStartedShowingScene);
			__scene.removeEventListener(AbstractScene.EVENT_FINISHED_SHOWING, onFinishedShowingScene);
			__scene.removeEventListener(AbstractScene.EVENT_STARTED_HIDING, onStartedHidingScene);
			__scene.removeEventListener(AbstractScene.EVENT_FINISHED_HIDING, onFinishedHidingScene);
		}

		private function waitAndShowCurrentScene():void {
			addEventListener(Event.ENTER_FRAME, onEnterFrameCheckIfCurrentSceneCanBeShown);
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onStartedShowingScene(__e:Event):void {
		}

		private function onFinishedShowingScene(__e:Event):void {
			isShowingScene = false;
			if (mustHideCurrentScene) {
				mustHideCurrentScene = false;
				hideCurrentScene();
			}
		}

		private function onStartedHidingScene(__e:Event):void {

		}

		private function onFinishedHidingScene(__e:Event):void {
			isHidingScene = false;
			removeScene(currentScene);
			currentScene = null;

			System.pauseForGCIfCollectionImminent(0);
			if (nextScene != null) {
				// Has a scene queued up, show it
				var newScene:AbstractScene = nextScene;
				nextScene = null;
				showScene(newScene);
			}
		}

		private function onEnterFrameCheckIfCurrentSceneCanBeShown(__e:Event):void {
			if (currentScene.canShow()) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrameCheckIfCurrentSceneCanBeShown);
				showCurrentScene();
			}
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function showScene(__scene:AbstractScene):void {
			if (isHidingScene) {
				// Already hiding, simply swaps the queued scene
				if (nextScene != null) nextScene.dispose();
				nextScene = __scene;
			} else if (isShowingScene) {
				// A scene is being shown already, queue to hide it immediately after it's done showing
				mustHideCurrentScene = true;
				nextScene = __scene;
			} else if (currentScene == null) {
				// No scene at all, just show the new one
				currentScene = __scene;
				addScene(currentScene);
				if (currentScene.canShow()) {
					showCurrentScene();
				} else {
					waitAndShowCurrentScene();
				}
			} else {
				// Has scene, so must hide current first
				nextScene = __scene;
				hideCurrentScene();
			}
		}

		public function pause():void {
			if (currentScene != null) currentScene.pause();
		}

		public function resume():void {
			if (currentScene != null) currentScene.resume();
		}

		public function dispose():void {
			if (currentScene != null) {
				removeScene(currentScene);
				currentScene = null;
			}
			if (nextScene != null) {
				nextScene.dispose();
				nextScene = null;
			}
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function getCurrentScene():AbstractScene {
			return currentScene;
		}
	}
}
