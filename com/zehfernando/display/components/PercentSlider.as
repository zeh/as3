package com.zehfernando.display.components {

	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.display.shapes.Box;
	import com.zehfernando.display.shapes.RoundedBox;
	import com.zehfernando.utils.AppUtils;
	import com.zehfernando.utils.MathUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * @author zeh
	 */
	public class PercentSlider extends ResizableSprite {

		// Events
		public static const EVENT_POSITION_CHANGED_BY_USER:String = "onPositionChangedByUser";
		public static const EVENT_POSITION_DRAG_START:String = "onPositionDragStart";
		public static const EVENT_POSITION_DRAG_END:String = "onPositionDragEnd";
		public static const EVENT_POSITION_REDRAWN:String = "onPositionRedrawn";

		// Properties
		protected var mouseOffsetY:Number;

		protected var _backgroundColor:int;
		protected var _foregroundColor:int;
		protected var _radius:Number;

		protected var _position:Number;

		protected var _hitMargin:Number;

		protected var _isDragging:Boolean;
		protected var _enabled:Boolean;
//		protected var _wheelDeltaScale:Number;

		// Instances
		protected var background:Box;
		protected var foreground:RoundedBox;
		protected var barContent:Sprite;
		protected var barMask:RoundedBox;
		protected var hitter:Box;
//		protected var wheelTarget:DisplayObject;

		protected var selectorContainer:Sprite;

		protected var selectors:Vector.<Sprite>;
		protected var selectorAlignments:Vector.<Number>;					// -1 (left) to 1 (right)


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function PercentSlider() {
//			wheelTarget = __wheelTarget;

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
			_radius = 0;

			_hitMargin = 2;

//			_wheelDeltaScale = 0.01;

			_foregroundColor = 0xffffff;
			_backgroundColor = 0x333333;
		}

		protected function createAssets():void {
			barMask = new RoundedBox(100, 100, _backgroundColor);
			addChild(barMask);

			barContent = new Sprite();
			barContent.mask = barMask;
			addChild(barContent);

			background = new Box(100, 100, _backgroundColor);
			barContent.addChild(background);

			foreground = new RoundedBox(100, 100, _foregroundColor);
			barContent.addChild(foreground);

			hitter = new Box(100, 100, 0xff0000);
			hitter.alpha = 0;
			hitter.buttonMode = true;
			hitter.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);

			addChild(hitter);

			selectorContainer = new Sprite();
			selectorContainer.buttonMode = true;
			addChild(selectorContainer);

			selectorAlignments = new Vector.<Number>();

			selectorContainer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownSelector, false, 0, true);

			redrawRadius();

//			if (Boolean(wheelTarget)) AppUtils.getStage().addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel, false, 0, true);
		}

		override protected function redrawWidth():void {
			barMask.width = _width;
			background.width = _width;
			foreground.width = _width;
			hitter.x = -_hitMargin;
			hitter.width = _width + _hitMargin * 2;

			var i:int;
			for (i = 0; i < selectorContainer.numChildren; i++) {
				selectorContainer.getChildAt(i).x = MathUtils.map(selectorAlignments[i], -1, 1, 0, _width);
			}
		}

		override protected function redrawHeight():void {
			barMask.height = _height;
			background.height = _height;
			foreground.height = _height;

			redrawPosition();
		}

		protected function redrawPosition():void {
			foreground.y = -MathUtils.map(_position, 0, 1, _height, 0);
			//foreground.height = MathUtils.map(_position, 0, 1, 0, _height);

			hitter.y = -_hitMargin;
			hitter.height = _height + _hitMargin * 2;

			selectorContainer.y = MathUtils.map(_position, 0, 1, 0, _height);

			dispatchEvent(new Event(EVENT_POSITION_REDRAWN));
		}

		protected function redrawRadius():void {
			foreground.radius = _radius;
			barMask.radius = _radius;
		}

		protected function continueDragging():void {
			if (_isDragging) {
				var newPos:Number = MathUtils.map(mouseY + mouseOffsetY, 0, _height, 0, 1, true);
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

				dispatchEvent(new Event(EVENT_POSITION_DRAG_END));
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onMouseDown(e:MouseEvent):void {
			startDragging();
		}

		protected function onMouseDownSelector(e:MouseEvent):void {
			startDragging(true);
		}

		protected function onDraggingMouseMove(e:MouseEvent):void {
			continueDragging();
		}

		protected function onDraggingMouseUp(e:MouseEvent):void {
			stopDragging();
		}

//		protected function onStageMouseWheel(e:MouseEvent):void {
//			if (_enabled) {
//				position -= _wheelDeltaScale * e.delta;
//				dispatchEvent(new Event(EVENT_POSITION_CHANGED_BY_USER));
//			}
//		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

//		public function getPickerContainer(): Sprite {
//			return pickerContainer;
//		}

		public function startDragging(__relativePosition:Boolean = false):void {
			// Starts dragging the head
			if (!_isDragging && enabled) {

				mouseOffsetY = __relativePosition ? -selectorContainer.mouseY : 0;

				AppUtils.getStage().addEventListener(MouseEvent.MOUSE_MOVE, onDraggingMouseMove, false, 0, true);
				AppUtils.getStage().addEventListener(MouseEvent.MOUSE_UP, onDraggingMouseUp, false, 0, true);
				_isDragging = true;

				dispatchEvent(new Event(EVENT_POSITION_DRAG_START));
				continueDragging();
			}
		}

		public function addSelector(__selector:Sprite, __alignment:Number = -1):void {
			selectorContainer.addChild(__selector);
			selectorAlignments.push(__alignment);
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get position():Number {
			return _position;
		}
		public function set position(__value:Number):void {
			if (_position != __value) {
				_position = MathUtils.clamp(__value);
				redrawPosition();
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

		public function get backgroundColor():int {
			return _backgroundColor;
		}
		public function set backgroundColor(__value:int):void {
			if (_backgroundColor != __value) {
				_backgroundColor = __value;
				background.color = _backgroundColor;
			}
		}

		public function get foregroundColor():int {
			return _foregroundColor;
		}
		public function set foregroundColor(__value:int):void {
			if (_foregroundColor != __value) {
				_foregroundColor = __value;
				foreground.color = _foregroundColor;
			}
		}

//		public function get wheelDeltaScale():Number {
//			return _wheelDeltaScale;
//		}
//		public function set wheelDeltaScale(__value:Number):void {
//			if (_wheelDeltaScale != __value) {
//				_wheelDeltaScale = __value;
//			}
//		}

		public function get hitMargin():Number {
			return _hitMargin;
		}
		public function set hitMargin(__value:Number):void {
			if (_hitMargin != __value) {
				_hitMargin = __value;
				redrawWidth();
				redrawHeight();
			}
		}

		public function get radius():Number {
			return _radius;
		}
		public function set radius(__value:Number):void {
			if (_radius != __value) {
				_radius = __value;
				redrawRadius();
			}
		}

		public function getUserPosition():Number {
			return MathUtils.map(mouseY, 0, _height, 0, 1, true);
		}
	}
}
