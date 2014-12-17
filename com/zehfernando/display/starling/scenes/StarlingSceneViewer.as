package com.zehfernando.display.starling.scenes {
	import starling.display.Sprite;
	import starling.events.Event;

	import flash.display.Stage;
	import flash.system.System;

	/**
	 * @author zeh fernando
	 */
	public class StarlingSceneViewer extends Sprite {

		// Properties
		private var _width:Number;
		private var _height:Number;

		private var isHidingScene:Boolean;
		private var isShowingScene:Boolean;

		private var mustHideCurrentScene:Boolean;				// Must hide current scene after it's done showing

		// Instances
		private var _legacyStage:Stage;

		private var currentScene:StarlingScene;
		private var nextScene:StarlingScene;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StarlingSceneViewer(__width:Number, __height:Number) {
			_width = __width;
			_height = __height;

			currentScene = null;
			nextScene = null;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function showCurrentScene():void {
			isShowingScene = true;
			currentScene.show();
		}

		private function hideCurrentScene():void {
			isHidingScene = true;
			currentScene.hide();
		}

		private function addScene(__scene:StarlingScene):void {
			__scene.sceneViewer = this;
			__scene.legacyStage = legacyStage;
			__scene.width = _width;
			__scene.height = _height;
			__scene.onStartedShowing.add(onStartedShowingScene);
			__scene.onFinishedShowing.add(onFinishedShowingScene);
			__scene.onStartedHiding.add(onStartedHidingScene);
			__scene.onFinishedHiding.add(onFinishedHidingScene);
			addChild(__scene);
		}

		private function removeScene(__scene:StarlingScene):void {
			__scene.onStartedShowing.remove(onStartedShowingScene);
			__scene.onFinishedShowing.remove(onFinishedShowingScene);
			__scene.onStartedHiding.remove(onStartedHidingScene);
			__scene.onFinishedHiding.remove(onFinishedHidingScene);
			__scene.dispose();
			removeChild(__scene);
		}

		private function waitAndShowCurrentScene():void {
			addEventListener(Event.ENTER_FRAME, onEnterFrameCheckIfCurrentSceneCanBeShown);
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onStartedShowingScene(__scene:StarlingScene):void {
		}

		private function onFinishedShowingScene(__scene:StarlingScene):void {
			isShowingScene = false;
			if (mustHideCurrentScene) {
				mustHideCurrentScene = false;
				hideCurrentScene();
			}
		}

		private function onStartedHidingScene(__scene:StarlingScene):void {

		}

		private function onFinishedHidingScene(__scene:StarlingScene):void {
			isHidingScene = false;
			removeScene(currentScene);
			currentScene = null;

			System.pauseForGCIfCollectionImminent(0);
			if (nextScene != null) {
				// Has a scene queued up, show it
				var newScene:StarlingScene = nextScene;
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

		public function showScene(__scene:StarlingScene):void {
			if (isHidingScene) {
				// Already hiding some scene, simply swaps the queued scene
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

		override public function dispose():void {
			if (currentScene != null) {
				removeScene(currentScene);
				currentScene = null;
			}
			if (nextScene != null) {
				nextScene.dispose();
				nextScene = null;
			}

			super.dispose();
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function getCurrentScene():StarlingScene {
			return currentScene;
		}

		override public function get width():Number {
			return _width;
		}

		override public function get height():Number {
			return _height;
		}

		public function get legacyStage():Stage {
			return _legacyStage;
		}

		public function set legacyStage(__value:Stage):void {
			_legacyStage = __value;
		}
	}
}
