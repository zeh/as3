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

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GradientBox(__width:Number = 100, __height:Number = 100, __angle:Number = 0, __colors:Array = null, __alphas:Array = null, __ratios:Array = null, __type:String = null) {

			_width = __width;
			_height = __height;

			var i:int;

			_angle = __angle;

			if (__colors == null) __colors = [0xff0000, 0x00ff00];
			_colors = __colors;

			if (__alphas == null) {
				__alphas = [];
				for (i = 0; i < _colors.length; i++) __alphas.push(1 + (1 * (i/(_colors.length-1))));
			}
			_alphas = __alphas;

			if (__ratios == null) {
				__ratios = [];
				for (i = 0; i < _colors.length; i++) __ratios.push(0 + (255 * (i/(_colors.length-1))));
			}
			_ratios = __ratios;

			if (!Boolean(__type)) __type = GradientType.LINEAR;
			_type = __type;

			paint();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function paint():void {
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(_width, _height, (_angle / 180) * Math.PI, 0, 0);

			graphics.clear();
			graphics.lineStyle();
			graphics.beginGradientFill(_type, _colors, _alphas, _ratios, mtx, SpreadMethod.PAD, InterpolationMethod.RGB);
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

		public function get colors(): Array {
			return _colors;
		}
		public function set colors(__value:Array):void {
			_colors = __value;
			paint();
		}

		public function get alphas(): Array {
			return _alphas;
		}
		public function set alphas(__value:Array):void {
			_alphas = __value;
			paint();
		}

		public function get ratios(): Array {
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
	}
}
