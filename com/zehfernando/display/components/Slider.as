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
		public static const EVENT_POSITION_CHANGED:String = "onPositionChangedValue";

		// Properties
		protected var _backgroundColor:int;
		protected var _backgroundAlpha:Number;
		protected var _pickerColor:int;
		protected var _pickerAlpha:Number;

		protected var _position:Number;						// 0-1
		protected var _minPickerSize:Number;				// In pixels
		protected var _maxPickerSize:Number;				// In pixels
		protected var _pickerScale:Number;					// 0-1 of total
		protected var _roundPickerPosition:Boolean;

		protected var _hitMargin:Number;					// For picker

		protected var _minValue:Number;
		protected var _maxValue:Number;

		protected var _isDragging:Boolean;
		protected var _enabled:Boolean;
		protected var draggingOffset:Number;
		protected var _wheelDeltaScale:Number;

		protected var _extra:*;

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

		protected function setDefaultData():void {
			_width = 20;
			_position = 0;

			_hitMargin = 2;
			_minPickerSize = 10;
			_maxPickerSize = 10000;
			_pickerScale = 0.1;
			_roundPickerPosition = false;

			_minValue = 0;
			_maxValue = 100;

			_wheelDeltaScale = 0.01;

			_pickerColor = 0xffffff;
			_pickerAlpha = 1;
			_backgroundColor = 0x333333;
			_backgroundAlpha = 1;
		}

		protected function createAssets():void {
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

		override protected function redrawWidth():void {
			background.width = _width;

			redrawPosition();
		}

		override protected function redrawHeight():void {
			background.height = _height;
			picker.height = _height;
			hitter.y = -_hitMargin;
			hitter.height = _height + _hitMargin * 2;
		}

		protected function redrawPosition():void {
			var pw:Number = Math.min(MathUtils.clamp(_pickerScale * _width, _minPickerSize, _maxPickerSize), _width);
			if (_roundPickerPosition) pw = Math.round(pw);

			var px:Number = MathUtils.map(_position, 0, 1, 0, _width - pw);
			if (_roundPickerPosition) px = Math.round(px);

			picker.width = pw;
			picker.x = px;
			pickerContainer.x = picker.x;

			hitter.x = picker.x - _hitMargin;
			hitter.width = pw + _hitMargin * 2;
		}

		protected function startDragging():void {
			// Starts dragging the head
			if (!_isDragging && enabled) {
				draggingOffset = mouseX - picker.x;

				AppUtils.getStage().addEventListener(MouseEvent.MOUSE_MOVE, onDraggingMouseMove);
				AppUtils.getStage().addEventListener(MouseEvent.MOUSE_UP, onDraggingMouseUp);

				_isDragging = true;
			}
		}

		protected function continueDragging():void {
			if (_isDragging) {
				var newPos:Number = MathUtils.map(mouseX - draggingOffset, 0, _width - picker.width, 0, 1, true);
				if(newPos != _position) {
					position = newPos;
					dispatchEvent(new Event(EVENT_POSITION_CHANGED_BY_USER));
				}
			}
		}

		protected function stopDragging():void {
			if (_isDragging) {
				continueDragging();

				AppUtils.getStage().removeEventListener(MouseEvent.MOUSE_MOVE, onDraggingMouseMove);
				AppUtils.getStage().removeEventListener(MouseEvent.MOUSE_UP, onDraggingMouseUp);

				_isDragging = false;
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onMouseDown(e:MouseEvent):void {
			startDragging();
		}

		protected function onDraggingMouseMove(e:MouseEvent):void {
			continueDragging();
		}

		protected function onDraggingMouseUp(e:MouseEvent):void {
			stopDragging();
		}

		protected function onStageMouseWheel(e:MouseEvent):void {
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

		public function get position():Number {
			return _position;
		}
		public function set position(__value:Number):void {
			if (_position != __value) {
				_position = MathUtils.clamp(__value);
				redrawPosition();
				dispatchEvent(new Event(EVENT_POSITION_CHANGED));
			}
		}

		public function get enabled():Boolean {
			return _enabled;
		}
		public function set enabled(__value:Boolean):void {
			_enabled = hitter.mouseEnabled = __value;
		}

		public function get isDragging():Boolean {
			return _isDragging;
		}

		public function get wheelDeltaScale():Number {
			return _wheelDeltaScale;
		}
		public function set wheelDeltaScale(__value:Number):void {
			if (_wheelDeltaScale != __value) {
				_wheelDeltaScale = __value;
			}
		}

		public function get backgroundColor():int {
			return _backgroundColor;
		}
		public function set backgroundColor(__value:int):void {
			if (_backgroundColor != __value) {
				_backgroundColor = __value;
				background.color = _backgroundColor;
			}
		}

		public function get backgroundAlpha():Number {
			return _backgroundAlpha;
		}
		public function set backgroundAlpha(__value:Number):void {
			if (_backgroundAlpha != __value) {
				_backgroundAlpha = __value;
				background.alpha = _backgroundAlpha;
			}
		}

		public function get pickerColor():int {
			return _pickerColor;
		}
		public function set pickerColor(__value:int):void {
			if (_pickerColor != __value) {
				_pickerColor = __value;
				picker.color = _pickerColor;
			}
		}

		public function get pickerAlpha():Number {
			return _pickerAlpha;
		}
		public function set pickerAlpha(__value:Number):void {
			if (_pickerAlpha != __value) {
				_pickerAlpha = __value;
				picker.alpha = _pickerAlpha;
			}
		}

		public function get pickerScale():Number {
			return _pickerScale;
		}
		public function set pickerScale(__value:Number):void {
			if (_pickerScale != __value) {
				_pickerScale = __value;
				redrawPosition();
			}
		}

		public function get minPickerSize():Number {
			return _minPickerSize;
		}
		public function set minPickerSize(__value:Number):void {
			if (_minPickerSize != __value) {
				_minPickerSize = __value;
				redrawPosition();
			}
		}

		public function get maxPickerSize():Number {
			return _maxPickerSize;
		}
		public function set maxPickerSize(__value:Number):void {
			if (_maxPickerSize != __value) {
				_maxPickerSize = __value;
				redrawPosition();
			}
		}

		public function get minValue():Number {
			return _minValue;
		}
		public function set minValue(__value:Number):void {
			_minValue = __value;
		}

		public function get maxValue():Number {
			return _maxValue;
		}
		public function set maxValue(__value:Number):void {
			_maxValue = __value;
		}

		public function get value():Number {
			return MathUtils.map(_position, 0, 1, _minValue, _maxValue, true);
		}
		public function set value(__value:Number):void {
			position = MathUtils.map(__value, _minValue, _maxValue, 0, 1, true);
		}

		public function get extra():* {
			return _extra;
		}
		public function set extra(__value:*):void {
			_extra = __value;
		}
	}
}
