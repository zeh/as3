package com.zehfernando.display.components.text {

	import com.zehfernando.display.shapes.Box;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author zeh
	 */
	public class Caret extends Sprite {

		// Constants
		protected static const BLINKING_INTERVAL:Number = 500;

		// Properties
		protected var _height:Number;
		protected var _color:int;

		protected var blinkingTimer:Timer;

		// Instances
		protected var rect:Box;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Caret() {
			_color = 0x000000;
			_height = 10;

			rect = new Box (1);
			addChild(rect);

			redrawColor();
			redrawHeight();

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function redrawColor():void {
			rect.color = _color;
		}

		protected function redrawHeight():void {
			rect.height = _height;
		}

		protected function startBlinking():void {
			 if (!Boolean(blinkingTimer)) {
			 	restartVisibilityCycle();

			 	blinkingTimer = new Timer(BLINKING_INTERVAL);
			 	blinkingTimer.addEventListener(TimerEvent.TIMER, onBlinkingTimer);
			 	blinkingTimer.start();
			 }
		}

		protected function stopBlinking():void {
			 if (Boolean(blinkingTimer)) {
			 	blinkingTimer.removeEventListener(TimerEvent.TIMER, onBlinkingTimer);
			 	blinkingTimer.stop();
			 	blinkingTimer = null;
			 }
		}

		public function restartVisibilityCycle():void {
			rect.visible = true;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void {
			startBlinking();
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}

		protected function onRemovedFromStage(e:Event):void {
			stopBlinking();
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}

		protected function onBlinkingTimer(e:Event):void {
			rect.visible = !rect.visible;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				redrawHeight();
			}
		}

		public function get color():int {
			return _color;
		}
		public function set color(__value:int):void {
			if (_color != __value) {
				_color = __value;
				redrawColor();
			}
		}

	}
}
