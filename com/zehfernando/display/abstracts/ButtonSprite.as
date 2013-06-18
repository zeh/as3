package com.zehfernando.display.abstracts {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author zeh
	 */
	public class ButtonSprite extends Sprite {

		// Properties
		protected var _mouseFocus:Number;
		protected var _enabled:Number;
		protected var _visibility:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ButtonSprite() {
			_mouseFocus = 0;
			_enabled = 1;
			_visibility = 1;

			mouseChildren = false;
			buttonMode = true;

			addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function redrawState():void {
			throw new Error("Error: the method redrawState() of ButtonSprite has to be overridden.");
		}

		protected function redrawVisibility():void {
			alpha = _visibility;
			visible = _visibility > 0;

			mouseEnabled = mouseChildren = _visibility == 1;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void {
			redrawState();
			redrawVisibility();
		}

		protected function onRollOver(e:MouseEvent):void {
			if (enabled >= 1) mouseFocus = 1;
		}

		protected function onRollOut(e:MouseEvent):void {
			mouseFocus = 0;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get mouseFocus():Number {
			return _mouseFocus;
		}
		public function set mouseFocus(__value:Number):void {
			if (_mouseFocus != __value) {
				_mouseFocus = __value;
				redrawState();
			}
		}

		public function get enabled():Number {
			return _enabled;
		}
		public function set enabled(__value:Number):void {
			if (_enabled != __value) {
				_enabled = __value;
				redrawState();
			}
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
	}
}
