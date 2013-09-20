package com.zehfernando.display.shapes {
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class RoundedBox extends Sprite {

		// Properties
		protected var _width:Number;
		protected var _height:Number;
		private var _color:uint;

		private var _radius:Number;
		private var _outlineWidth:Number;
		protected var _topLeftRadius:Number;
		protected var _topRightRadius:Number;
		protected var _bottomLeftRadius:Number;
		protected var _bottomRightRadius:Number;

		protected var _superEllipseCorners:Boolean;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RoundedBox(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000, __radius:Number = 0, __outlineWidth:Number = 0) {
			_color = __color;
			_width = __width;
			_height = __height;
			_superEllipseCorners = false;

			_radius = _topLeftRadius = _topRightRadius = _bottomLeftRadius = _bottomRightRadius = __radius;
			_outlineWidth = __outlineWidth;

			paint();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function drawRoundRectSuperEllipse(__x:Number, __y:Number, __width:Number, __height:Number, __topLeftRadius:Number, __topRightRadius:Number, __bottomLeftRadius:Number, __bottomRightRadius:Number):void {
			// Draws a normal rectangle, but with "super ellipse" corners
			// https://en.wikipedia.org/wiki/Superellipse

			// "Super ellipse" corners need a bigger radius so they look more like the original
			__topLeftRadius *= 2;
			__topRightRadius *= 2;
			__bottomLeftRadius *= 2;
			__bottomRightRadius *= 2;

			// TL
			if (__topLeftRadius <= 0) {
				graphics.moveTo(__x, __y);
			} else {
				drawSuperEllipseCurve(graphics, __x + __topLeftRadius, __y + __topLeftRadius, __topLeftRadius, __topLeftRadius, 180, 270, true);
			}

			// TR
			if (__topRightRadius <= 0) {
				graphics.lineTo(__x + __width, __y);
			} else {
				drawSuperEllipseCurve(graphics, __x + __width - __topRightRadius, __y + __topRightRadius, __topRightRadius, __topRightRadius, 270, 360);
			}

			// BR
			if (__bottomRightRadius <= 0) {
				graphics.lineTo(__x + __width, __y + __height);
			} else {
				drawSuperEllipseCurve(graphics, __x + __width - __bottomRightRadius, __y + __height - __bottomRightRadius, __bottomRightRadius, __bottomRightRadius, 0, 90);
			}

			// BL
			if (__bottomLeftRadius <= 0) {
				graphics.lineTo(__x, __y + __height);
			} else {
				drawSuperEllipseCurve(graphics, __x + __bottomLeftRadius, __y + __height - __bottomLeftRadius, __bottomLeftRadius, __bottomLeftRadius, 90, 180);
			}
		}

		private function drawSuperEllipseCurve(__target:Graphics, __cx:Number, __cy:Number, __xRadius:Number, __yRadius:Number, __startAngleDegrees:Number, __endAngleDegrees:Number, __moveFirst:Boolean = false):void {
			// Draw a "super ellipse" curve
			// https://en.wikipedia.org/wiki/Superellipse

			const SEGMENT_SIZE:Number = 2; // In degrees.. more = more precise but more points/may be slower if done repeatedly

			// Enforce always min->max
			while (__endAngleDegrees < __startAngleDegrees) __endAngleDegrees += 360;

			var p:Point;
			for (var angleDegrees:Number = __startAngleDegrees; angleDegrees < __endAngleDegrees; angleDegrees += SEGMENT_SIZE) {
				p = getSuperEllipsePointOnCurve(__cx, __cy, angleDegrees, __xRadius, __yRadius);
				if (angleDegrees == __startAngleDegrees && __moveFirst) {
					__target.moveTo(p.x, p.y);
				} else {
					__target.lineTo(p.x, p.y);
				}
			}
			// Last point
			p = getSuperEllipsePointOnCurve(__cx, __cy, __endAngleDegrees, __xRadius, __yRadius);
			__target.lineTo(p.x, p.y);

			return;
		}

		private function getSuperEllipsePointOnCurve(__cx:Number, __cy:Number, __angleDegrees:Number, __xRadius:Number, __yRadius:Number):Point {
			const N:Number = 5; // The n of the curve
			var cn:Number = 2 / N;
			var angle:Number = __angleDegrees / 180 * Math.PI;
			var ca:Number = Math.cos(angle);
			var sa:Number = Math.sin(angle);
			return new Point(
				Math.pow(Math.abs(ca), cn) * __xRadius * (ca < 0 ? -1 : 1) + __cx,
				Math.pow(Math.abs(sa), cn) * __yRadius * (sa < 0 ? -1 : 1) + __cy
			);
		}

		protected function paint():void {
			graphics.clear();
			graphics.lineStyle();
			graphics.beginFill(_color, 1);
			if (!_superEllipseCorners) {
				graphics.drawRoundRectComplex(0, 0, _width, _height, _topLeftRadius, _topRightRadius, _bottomLeftRadius, _bottomRightRadius);
			} else {
				drawRoundRectSuperEllipse(0, 0, _width, _height, _topLeftRadius, _topRightRadius, _bottomLeftRadius, _bottomRightRadius);
			}

			if (_outlineWidth != 0) {
				if (!_superEllipseCorners) {
					graphics.drawRoundRectComplex(_outlineWidth, _outlineWidth, _width - _outlineWidth * 2, _height - _outlineWidth * 2, Math.max(_topLeftRadius - _outlineWidth, 0), Math.max(_topRightRadius - _outlineWidth, 0), Math.max(_bottomLeftRadius - _outlineWidth, 0), Math.max(_bottomRightRadius - _outlineWidth, 0));
				} else {
					drawRoundRectSuperEllipse(_outlineWidth, _outlineWidth, _width - _outlineWidth * 2, _height - _outlineWidth * 2, Math.max(_topLeftRadius - _outlineWidth, 0), Math.max(_topRightRadius - _outlineWidth, 0), Math.max(_bottomLeftRadius - _outlineWidth, 0), Math.max(_bottomRightRadius - _outlineWidth, 0));
				}
			}

			graphics.endFill();
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		override public function get width():Number { return _width; }
		override public function set width(__value:Number):void {
			if (_width != __value) {
				_width = __value;
				paint();
			}
		}

		override public function get height():Number { return _height; }
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				paint();
			}
		}

		public function get outlineWidth():Number { return _outlineWidth; }
		public function set outlineWidth(__value:Number):void {
			if (isNaN(__value)) __value = 0;
			if (_outlineWidth != __value) {
				_outlineWidth = __value;
				paint();
			}
		}

		public function get color():uint { return _color; }
		public function set color(__value:uint):void {
			if (_color != __value) {
				_color = __value & 0xffffff;
				paint();
			}
		}

		public function get radius():Number { return _radius; }
		public function set radius(__value:Number):void {
			_radius = _topLeftRadius = _topRightRadius = _bottomLeftRadius = _bottomRightRadius = __value;
			paint();
		}

		public function get topLeftRadius():Number { return _topLeftRadius; }
		public function set topLeftRadius(__value:Number):void {
			if (_topLeftRadius != __value) {
				_topLeftRadius = __value;
				paint();
			}
		}

		public function get topRightRadius():Number { return _topRightRadius; }
		public function set topRightRadius(__value:Number):void {
			if (_topRightRadius != __value) {
				_topRightRadius = __value;
				paint();
			}
		}

		public function get bottomLeftRadius():Number { return _bottomLeftRadius; }
		public function set bottomLeftRadius(__value:Number):void {
			if (_bottomLeftRadius != __value) {
				_bottomLeftRadius = __value;
				paint();
			}
		}

		public function get bottomRightRadius():Number { return _bottomRightRadius; }
		public function set bottomRightRadius(__value:Number):void {
			if (_bottomRightRadius != __value) {
				_bottomRightRadius = __value;
				paint();
			}
		}

		public function get borderSize():Number { return _outlineWidth; }
		public function set borderSize(__value:Number):void {
			if (_outlineWidth != __value) {
				_outlineWidth = __value;
				paint();
			}
		}

		public function get superEllipseCorners():Boolean { return _superEllipseCorners; }
		public function set superEllipseCorners(__value:Boolean):void {
			if (_superEllipseCorners != __value) {
				_superEllipseCorners = __value;
				paint();
			}
		}
	}
}
