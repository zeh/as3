package com.zehfernando.controllers.gamecontroller {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	/**
	 * @author zeh fernando
	 */
	public class GameTicker extends EventDispatcher {

		/**
		 * Controls instances of game objects
		 */

		// Constants
		public static const EVENT_TICK:String = "onTick";

		// Properties
		private var totalTime:int;
		private var lastTimeRan:int;
		private var isRunning:Boolean;
		private var isUpdating:Boolean;
		private var minInterval:Number;			// Minimum interval, in ms, to wait for each update

		private var _timeScale:Number;

		private var timeDelta:int;
		private var now:int;

		// Temp stuff
		private var idx:int;
		private var iu:int;

		// Instances
		private var gameObjects:Vector.<IGameObject>;
		private var sprite:Sprite;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GameTicker(__minInterval:Number = 0) {
			minInterval = __minInterval;
			gameObjects = new Vector.<IGameObject>();
			totalTime = 0;
			_timeScale = 1;
			isRunning = false;
			isUpdating = false;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function removeGameObjectByIndex(__index:int, __avoidDispose:Boolean = false):void {
			var go:IGameObject = gameObjects[__index];
			gameObjects[__index] = null;
			//gameObjects.splice(__index, 1);
			if (!__avoidDispose && go != null) go.dispose();
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onSpriteEnterFrame(__e:Event):void {
			now = flash.utils.getTimer();
			timeDelta = now - lastTimeRan;
			if (timeDelta > minInterval) {
				update(timeDelta * _timeScale);
				lastTimeRan = now;
				dispatchEvent(new Event(EVENT_TICK));
			}
		}

		private function update(__timePassedMS:int):void {
			totalTime += __timePassedMS;
			isUpdating = true;
			for (iu = 0; iu < gameObjects.length; iu++) {
				if (gameObjects[iu] == null) {
					gameObjects.splice(iu, 1);
					iu--;
				} else {
					gameObjects[iu].update(__timePassedMS, totalTime);
				}
			}
			isUpdating = false;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function pause():void {
			if (isRunning) {
				isRunning = false;

				for (var i:int = 0; i < gameObjects.length; i++) {
					if (gameObjects[i] != null) gameObjects[i].pause();
				}

				if (sprite != null) {
					sprite.removeEventListener(Event.ENTER_FRAME, onSpriteEnterFrame);
					sprite = null;
				}
			}
		}

		public function resume():void {
			if (!isRunning) {
				isRunning = true;

				lastTimeRan = flash.utils.getTimer();

				for (var i:int = 0; i < gameObjects.length; i++) {
					if (gameObjects[i] != null) gameObjects[i].resume();
				}

				if (sprite == null) {
					sprite = new Sprite();
					sprite.addEventListener(Event.ENTER_FRAME, onSpriteEnterFrame, false, 0, true);
				}
			}
		}

		public function addGameObject(__gameObject:IGameObject):void {
			if (gameObjects.indexOf(__gameObject) == -1) {
				gameObjects.push(__gameObject);
				if (!isUpdating) __gameObject.update(0, totalTime);
				//if (!isUpdating) __gameObject.update(timeDelta, totalTime);
			}
		}

		public function removeGameObject(__gameObject:IGameObject, __avoidDispose:Boolean = false):void {
			idx = gameObjects.indexOf(__gameObject);
			if (idx > -1) removeGameObjectByIndex(idx, __avoidDispose);
		}

		public function dispose():void {
			pause();
			for (var i:int = 0; i < gameObjects.length; i++) {
				if (gameObjects[i] != null) removeGameObjectByIndex(i);
			}
			gameObjects.length = 0;
		}

		public function getTimer():int {
			return totalTime;
		}

		public function getNumObjects():Number {
			return gameObjects.length;
		}

		public function getDeltaTime():int {
			return timeDelta;
		}

		public function get timeScale():Number {
			return _timeScale;
		}

		public function set timeScale(__value:Number):void {
			if (_timeScale != __value) {
				_timeScale = __value;
			}
		}
	}
}
