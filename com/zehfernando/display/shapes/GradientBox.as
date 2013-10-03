package com.zehfernando.display.shapes {
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	/**
	 * @author zeh
	 */
	public class GradientBox extends Sprite {

		// Properties
		protected var _width:Number;
		protected var _height:Number;

		protected var _type:String;
		protected var _angle:Number;
		protected var _colors:Array;
		protected var _alphas:Array;
		protected var _ratios:Array;

		protected var _gradientScaleX:Number;
		protected var _gradientScaleY:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GradientBox(__width:Number = 100, __height:Number = 100, __angle:Number = 0, __colors:Array = null, __alphas:Array = null, __ratios:Array = null, __type:String = null) {

			_width = __width;
			_height = __height;

			_angle = __angle;
			_colors = __colors;
			_alphas = __alphas;
			_ratios = __ratios;

			_gradientScaleX = 1;
			_gradientScaleY = 1;

			if (!Boolean(__type)) __type = GradientType.LINEAR;
			_type = __type;

			paint();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function paint():void {
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(_width, _height, (_angle / 180) * Math.PI, 0, 0);
			mtx.translate(-_width * 0.5, -_height * 0.5);
			mtx.scale(_gradientScaleX, _gradientScaleY);
			mtx.translate(_width * 0.5, _height * 0.5);

			var i:int;

			var colorsTemp:Array = _colors;
			var alphasTemp:Array = _alphas;
			var ratiosTemp:Array = _ratios;

			if (colorsTemp == null) colorsTemp = [0xff0000, 0x00ff00];
			if (alphasTemp == null) {
				alphasTemp = [];
				for (i = 0; i < colorsTemp.length; i++) alphasTemp.push(1 + (1 * (i/(colorsTemp.length-1))));
			}
			if (ratiosTemp == null) {
				ratiosTemp = [];
				for (i = 0; i < colorsTemp.length; i++) ratiosTemp.push(0 + (255 * (i/(colorsTemp.length-1))));
			}

			graphics.clear();
			graphics.lineStyle();
			graphics.beginGradientFill(_type, colorsTemp, alphasTemp, ratiosTemp, mtx, SpreadMethod.PAD, InterpolationMethod.RGB);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get angle():Number {
			return _angle;
		}
		public function set angle(__value:Number):void {
			if (_angle != __value) {
				_angle = __value;
				paint();
			}
		}

		public function get colors():Array {
			return _colors;
		}
		public function set colors(__value:Array):void {
			_colors = __value;
			paint();
		}

		public function get alphas():Array {
			return _alphas;
		}
		public function set alphas(__value:Array):void {
			_alphas = __value;
			paint();
		}

		public function get ratios():Array {
			return _ratios;
		}
		public function set ratios(__value:Array):void {
			_ratios = __value;
			paint();
		}

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

		public function get gradientScaleX():Number { return _gradientScaleX; }
		public function set gradientScaleX(__value:Number):void {
			if (_gradientScaleX != __value) {
				_gradientScaleX = __value;
				paint();
			}
		}

		public function get gradientScaleY():Number { return _gradientScaleY; }
		public function set gradientScaleY(__value:Number):void {
			if (_gradientScaleY != __value) {
				_gradientScaleY = __value;
				paint();
			}
		}
	}
}
