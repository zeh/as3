package com.zehfernando.display.shapes {

	import com.zehfernando.data.types.Color;

	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * @author zeh
	 */
	public class BoxMarker extends Sprite {

		// Properties
		protected var _lineColor:int;
		protected var _width:Number;
		protected var _height:Number;

		// Instances
		protected var background:Box;
		protected var foreground:Shape;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BoxMarker(__width:Number = 100, __height:Number = 100, __lineColor:int = 0x555555, __backgroundColor:int = 0xe3e3e3) {
			_width = __width;
			_height = __height;

			background = new Box(100, 100, __backgroundColor);
			addChild(background);

			foreground = new Shape();
			foreground.graphics.lineStyle(1.6, 0x000000, 1, false, LineScaleMode.NONE, CapsStyle.ROUND, JointStyle.MITER);
			foreground.graphics.drawRect(0, 0, 100, 100);
			foreground.graphics.moveTo(0, 0);
			foreground.graphics.lineTo(100, 100);
			foreground.graphics.moveTo(100, 0);
			foreground.graphics.lineTo(0, 100);
			foreground.graphics.endFill();
			addChild(foreground);
			lineColor = __lineColor;

			redraw();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function redraw():void {
			background.width = _width;
			background.height = _height;

			foreground.scaleX = _width/100;
			foreground.scaleY = _height/100;
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get color():int {
			return background.color;
		}
		public function set color(__value:int):void {
			background.color = __value;
		}

		public function get lineColor():int {
			return _lineColor;
		}
		public function set lineColor(__value:int):void {
			if (_lineColor != __value) {
				_lineColor = __value;
				foreground.transform.colorTransform = Color.fromRRGGBB(_lineColor).toColorTransform();
			}
		}

		// TODO: use invalidate

		override public function get width():Number { return _width; }
		override public function set width(__value:Number):void {
			if (_width != __value) {
				_width = __value;
				redraw();
			}
		}

		override public function get height():Number { return _height; }
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				redraw();
			}
		}
	}
}
