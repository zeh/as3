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
		protected var _angle:Number;
		protected var _colors:Array;
		protected var _alphas:Array;
		protected var _ratios:Array;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GradientBox(__width:Number = 100, __height:Number = 100, __angle:Number = 0, __colors:Array = null, __alphas:Array = null, __ratios:Array = null) {
			
			_angle = __angle;

			if (__colors == null) __colors = [0xff0000, 0x00ff00];
			_colors = __colors;

			if (__alphas == null) __alphas = [1, 1]; // TODO: properly distribute based on number of colors?
			_alphas = __alphas;

			if (__ratios == null) __colors = [0, 255]; // TODO: properly distribute based on number of colors?
			_ratios = __ratios;
			
			scaleX = __width/100;
			scaleY = __height/100;

			paint();
		}

		
		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------

		protected function paint(): void {
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(100, 100, (_angle / 180) * Math.PI, 0, 0);

			graphics.clear();
			graphics.lineStyle();
			graphics.beginGradientFill(GradientType.LINEAR, _colors, _alphas, _ratios, mtx, SpreadMethod.PAD, InterpolationMethod.RGB);
			graphics.drawRect(0, 0, 100, 100);
			graphics.endFill();
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get angle(): Number {
			return _angle;
		}
		public function set angle(__value:Number): void {
			if (_angle != __value) {
				_angle = __value;
				paint();
			}
		}

		public function get colors(): Array {
			return _colors;
		}
		public function set colors(__value:Array): void {
			_colors = __value;
			paint();
		}

		public function get alphas(): Array {
			return _alphas;
		}
		public function set alphas(__value:Array): void {
			_alphas = __value;
			paint();
		}

		public function get ratios(): Array {
			return _ratios;
		}
		public function set ratios(__value:Array): void {
			_ratios = __value;
			paint();
		}

	}
}
