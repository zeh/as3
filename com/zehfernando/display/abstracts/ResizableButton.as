package com.zehfernando.display.abstracts {
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * @author zeh
	 */
	public class ResizableButton extends ResizableSprite {

		// Constants
		public static const EVENT_CLICK:String = "ResizableButton.onButtonClick";
		public static const EVENT_MOUSE_DOWN:String = "ResizableButton.onMouseDown";
		public static const EVENT_MOUSE_UP:String = "ResizableButton.onMouseUp";

		// Properties
		private var _isMouseOverButton:Boolean;
		private var _isMousePressed:Boolean;

		protected var _enabled:Number;
		protected var _visibility:Number;
		protected var _pressed:Number;
		protected var _focused:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ResizableButton() {
			super();

			_enabled = 1;
			_visibility = 1;
			_pressed = 0;
			_focused = 0;
			_isMouseOverButton = false;
			_isMousePressed = false;

			mouseChildren = false;
			buttonMode = true;

			addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownInternal, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUpInternal, false, 0, true);
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function redrawState():void {
			throw new Error("Error: the method redrawState() of ButtonSprite has to be overridden.");
		}

		protected function redrawVisibility():void {
			alpha = _visibility;
			visible = _visibility > 0;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			redrawState();
			redrawVisibility();
		}

		protected function onButtonDownInternal():void {
			if (_enabled) {
				pressed = 1;
				dispatchEvent(new Event(EVENT_MOUSE_DOWN));
			}
		}

		protected function onButtonUpInternal(__canceled:Boolean = false):void {
			pressed = 0;
			if (_enabled) {
				if (!__canceled) dispatchEvent(new Event(EVENT_CLICK));
				dispatchEvent(new Event(EVENT_MOUSE_UP));
			}
		}

		protected function onMouseDownInternal(__e:MouseEvent):void {
			if (!_isMousePressed) {
				_isMousePressed = true;
				onButtonDownInternal();
			}
		}

		protected function onMouseUpInternal(__e:MouseEvent):void {
			if (_isMousePressed) {
				_isMousePressed = false;
				onButtonUpInternal();
			}
		}

		protected function onRollOver(e:MouseEvent):void {
			_isMouseOverButton = true;
		}

		protected function onRollOut(e:MouseEvent):void {
			if (_isMousePressed) {
				_isMousePressed = false;
				onButtonUpInternal(true);
			}
			_isMouseOverButton = false;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get focused():Number {
			return _focused;
		}
		public function set focused(__value:Number):void {
			if (_focused != __value) {
				_focused = __value;
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

		public function get pressed():Number {
			return _pressed;
		}
		public function set pressed(__value:Number):void {
			if (_pressed != __value) {
				_pressed = __value;
				redrawState();
			}
		}
	}
}
