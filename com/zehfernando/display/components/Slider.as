package com.zehfernando.display.components {
	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.display.shapes.Box;
	import com.zehfernando.utils.AppUtils;
	import com.zehfernando.utils.MathUtils;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author zeh
	 */
	public class Slider extends ResizableSprite {

		// Events
		public static const EVENT_POSITION_CHANGED_BY_USER:String = "onPositionChangedByUser";

		// Properties
		protected var _backgroundColor:int;
		protected var _pickerColor:int;

		protected var _position:Number;
		protected var _minimumPickerHeight:Number;
		protected var _maximumPickerHeight:Number;
		protected var _pickerScale:Number;

		protected var _hitMargin:Number;

		protected var _isDragging:Boolean;
		protected var _enabled:Boolean;
		protected var draggingOffset:Number;
		protected var _wheelDeltaScale:Number;

		// Instances
		protected var background:Box;
		protected var picker:Box;
		protected var hitter:Box;
		protected var pickerContainer:Sprite;
		protected var wheelTarget:DisplayObject;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Slider(__wheelTarget:DisplayObject = null) {
			wheelTarget = __wheelTarget;

			super();

			setDefaultData();
			createAssets();

			// End
			enabled = true;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function setDefaultData(): void {
			_width = 20;
			_position = 0;

			_hitMargin = 2;
			_pickerScale = 0.1;
			_minimumPickerHeight = 10;
			_maximumPickerHeight = 10000;

			_wheelDeltaScale = 0.01;

			_pickerColor = 0xffffff;
			_backgroundColor = 0x333333;
		}

		protected function createAssets(): void {
			background = new Box(100, 100, _backgroundColor);
			addChild(background);

			picker = new Box(100, 100, _pickerColor);
			addChild(picker);

			pickerContainer = new Sprite();
			addChild(pickerContainer);

			hitter = new Box(100, 100, 0xff0000);
			hitter.alpha = 0;
			hitter.buttonMode = true;
			hitter.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

			addChild(hitter);

			if (Boolean(wheelTarget)) AppUtils.getStage().addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel, false, 0, true);
		}

		override protected function redrawWidth(): void {
			background.width = _width;
			picker.width = _width;
			hitter.x = -_hitMargin;
			hitter.width = _width + _hitMargin * 2;
		}

		override protected function redrawHeight(): void {
			background.height = _height;

			redrawPosition();
		}

		protected function redrawPosition(): void {
			var ph:Number = Math.min(MathUtils.clamp(_pickerScale * _height, _minimumPickerHeight, _maximumPickerHeight), _height);
			picker.height = ph;
			picker.y = MathUtils.map(_position, 0, 1, 0, _height - ph);
			pickerContainer.y = picker.y;

			hitter.y = picker.y - _hitMargin;
			hitter.height = ph + _hitMargin * 2;
		}

		protected function startDragging(): void {
			// Starts dragging the head
			if (!_isDragging && enabled) {
				draggingOffset = mouseY - picker.y;

				AppUtils.getStage().addEventListener(MouseEvent.MOUSE_MOVE, onDraggingMouseMove);
				AppUtils.getStage().addEventListener(MouseEvent.MOUSE_UP, onDraggingMouseUp);

				_isDragging = true;
			}
		}

		protected function continueDragging(): void {
			if (_isDragging) {
				var newPos:Number = MathUtils.map(mouseY - draggingOffset, 0, _height - picker.height, 0, 1, true);
				if(newPos != _position) {
					position = newPos;
					dispatchEvent(new Event(EVENT_POSITION_CHANGED_BY_USER));
				}
			}
		}

		protected function stopDragging(): void {
			if (_isDragging) {
				continueDragging();

				AppUtils.getStage().removeEventListener(MouseEvent.MOUSE_MOVE, onDraggingMouseMove);
				AppUtils.getStage().removeEventListener(MouseEvent.MOUSE_UP, onDraggingMouseUp);

				_isDragging = false;
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onMouseDown(e:MouseEvent): void {
			startDragging();
		}

		protected function onDraggingMouseMove(e:MouseEvent): void {
			continueDragging();
		}

		protected function onDraggingMouseUp(e:MouseEvent): void {
			stopDragging();
		}

		protected function onStageMouseWheel(e:MouseEvent): void {
			if (_enabled) {
				position -= _wheelDeltaScale * e.delta;
				dispatchEvent(new Event(EVENT_POSITION_CHANGED_BY_USER));
			}
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

//		public function getPickerContainer(): Sprite {
//			return pickerContainer;
//		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get position(): Number {
			return _position;
		}
		public function set position(__value:Number): void {
			if (_position != __value) {
				_position = MathUtils.clamp(__value);
				redrawPosition();
			}
		}

		public function get enabled(): Boolean {
			return _enabled;
		}
		public function set enabled(__value:Boolean): void {
			_enabled = hitter.mouseEnabled = __value;
		}

		public function get isDragging(): Boolean {
			return _isDragging;
		}

		public function get wheelDeltaScale(): Number {
			return _wheelDeltaScale;
		}
		public function set wheelDeltaScale(__value:Number): void {
			if (_wheelDeltaScale != __value) {
				_wheelDeltaScale = __value;
			}
		}

		public function get backgroundColor(): int {
			return _backgroundColor;
		}
		public function set backgroundColor(__value:int): void {
			if (_backgroundColor != __value) {
				_backgroundColor = __value;
				background.color = _backgroundColor;
			}
		}

		public function get pickerColor(): int {
			return _pickerColor;
		}
		public function set pickerColor(__value:int): void {
			if (_pickerColor != __value) {
				_pickerColor = __value;
				picker.color = _pickerColor;
			}
		}

		public function get pickerScale(): Number {
			return _pickerScale;
		}
		public function set pickerScale(__value:Number): void {
			if (_pickerScale != __value) {
				_pickerScale = __value;
				redrawPosition();
			}
		}
	}
}
