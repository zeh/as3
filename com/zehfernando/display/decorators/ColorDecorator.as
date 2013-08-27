package com.zehfernando.display.decorators {
	import com.zehfernando.utils.RenderUtils;

	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;

	/**
	 * @author zeh
	 */
	public class ColorDecorator extends AbstractDecorator {

		// Sources:
		//
		// http://www.graficaobscura.com/matrix/index.html
		//
		// And specially Mario Klingemann's ColorMatrix class 2.1:
		// http://www.quasimondo.com/archives/000565.php
		// http://www.quasimondo.com/colormatrix/ColorMatrix.as
		// http://www.quasimondo.com
		// His code is licensed under MIT license:
		// http://www.opensource.org/licenses/mit-license.php


		// Static constants -------------------------------------------------------------------

		// Defines luminance using sRGB luminance
		protected static const LUMINANCE_R:Number = 0.212671;
		protected static const LUMINANCE_G:Number = 0.715160;
		protected static const LUMINANCE_B:Number = 0.072169;

		// Instance properties ----------------------------------------------------------------

		// Color properties interface
		protected var _saturation:Number;		// Saturation: 0 (grayscale) -> 1 (normal, default) -> 2+ (highly saturated)
		protected var _contrast:Number;			// Contrast: 0 (grey) -> 1 (normal) -> 2 (high contrast)
		protected var _brightness:Number;		// Brightness offset: -1 (black) -> 0 (normal) -> 1 (full white)
		protected var _exposure:Number;			// Brightness multiplier: 0 (black) -> 1 (normal) -> 2 (super bright)
		protected var _hue:Number;				// Hue offset in degrees: -180 -> 0 (normal) -> 180

		// Matrices
		protected var saturationMatrix:Array;
		protected var contrastMatrix:Array;
		protected var brightnessMatrix:Array;
		protected var exposureMatrix:Array;
		protected var hueMatrix:Array;

		// Overridden properties
		//protected var _filters:Array;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ColorDecorator(__target:DisplayObject) {
			saturation = 1;
			contrast = 1;
			brightness = 0;
			exposure = 1;
			hue = 0;

			super(__target);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function apply():void {
			RenderUtils.addFunction(doVisualUpdate);
		}

		protected function doVisualUpdate():void {
			// Create empty matrix
			var mtx:Array = [
				1,0,0,0,0,
				0,1,0,0,0,
				0,0,1,0,0,
				0,0,0,1,0
			];
			var temp:Array = [];

			// Precalculate a single matrix from all matrices by multiplication
			// The order the final matrix is calculated can change the way it looks
			var matrices:Array = [saturationMatrix, contrastMatrix, brightnessMatrix, exposureMatrix, hueMatrix];

			var i:int, j:int, mat:Array;
			var x:int, y:int;

			for (j = 0; j < matrices.length; j++) {
				i = 0;
				mat = matrices[j];
				for (y = 0; y < 4; y++ ) {

					for (x = 0; x < 5; x++ ) {
						temp[ int( i + x) ] =	Number(mat[i])        * Number(mtx[x]) +
												Number(mat[int(i+1)]) * Number(mtx[int(x +  5)]) +
												Number(mat[int(i+2)]) * Number(mtx[int(x + 10)]) +
												Number(mat[int(i+3)]) * Number(mtx[int(x + 15)]) +
												(x == 4 ? Number(mat[int(i+4)]) : 0);
					}
					i+=5;
				}
				mtx = temp;
			}

			// Update object filters
			var newFilters:Array = [new ColorMatrixFilter(mtx)];
			_target.filters = newFilters;
			//super.filters = newFilters.concat(_filters);
		}

		protected function updateSaturationMatrix():void {
			// Create the pre-calculated saturation matrix

			var nc:Number = 1-_saturation;
			var nr:Number = LUMINANCE_R * nc;
			var ng:Number = LUMINANCE_G * nc;
			var nb:Number = LUMINANCE_B * nc;

			saturationMatrix = [
				nr+_saturation,	ng,				nb,				0,	0,
				nr,				ng+_saturation,	nb,				0,	0,
				nr,				ng,				nb+_saturation,	0,	0,
				0,				0,				0,				1,	0
			];

			apply();
		}

		protected function updateContrastMatrix():void {
			// Create the pre-calculated contrast matrix

			var co:Number = 128 * (1-_contrast);

			contrastMatrix = [
				_contrast,	0,	0,	0,	co,
				0,	_contrast,	0,	0,	co,
				0,	0,	_contrast,	0,	co,
				0,	0,	0,	1,	0
			];

			apply();
		}

		protected function updateBrightnessMatrix():void {
			// Create the pre-calculated brightness matrix

			var co:Number = 255 * _brightness;

			brightnessMatrix = [
				1,	0,	0,	0,	co,
				0,	1,	0,	0,	co,
				0,	0,	1,	0,	co,
				0,	0,	0,	1,	0
			];

			apply();
		}

		protected function updateExposureMatrix():void {
			// Create the pre-calculated exposture matrix

			exposureMatrix = [
				_exposure,	0,	0,	0,	0,
				0,	_exposure,	0,	0,	0,
				0,	0,	_exposure,	0,	0,
				0,	0,	0,	1,	0
			];

			apply();
		}

		protected function updateHueMatrix():void {
			// Create the pre-calculated hue matrix

			var hAngle:Number = _hue / 180 * Math.PI;
			var hCos:Number = Math.cos(hAngle);
			var hSin:Number = Math.sin(hAngle);

			hueMatrix = [
				((LUMINANCE_R + (hCos * (1 - LUMINANCE_R))) + (hSin * -(LUMINANCE_R))), ((LUMINANCE_G + (hCos * -(LUMINANCE_G))) + (hSin * -(LUMINANCE_G))), ((LUMINANCE_B + (hCos * -(LUMINANCE_B))) + (hSin * (1 - LUMINANCE_B))), 0, 0,
				((LUMINANCE_R + (hCos * -(LUMINANCE_R))) + (hSin * 0.143)), ((LUMINANCE_G + (hCos * (1 - LUMINANCE_G))) + (hSin * 0.14)), ((LUMINANCE_B + (hCos * -(LUMINANCE_B))) + (hSin * -0.283)), 0, 0,
				((LUMINANCE_R + (hCos * -(LUMINANCE_R))) + (hSin * -((1 - LUMINANCE_R)))), ((LUMINANCE_G + (hCos * -(LUMINANCE_G))) + (hSin * LUMINANCE_G)), ((LUMINANCE_B + (hCos * (1 - LUMINANCE_B))) + (hSin * LUMINANCE_B)), 0, 0,
				0, 0, 0, 1, 0
			];

			apply();
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get saturation():Number {
			return _saturation;
		}
		public function set saturation(__value:Number):void {
			if (_saturation != __value) {
				_saturation = __value;
				updateSaturationMatrix();
			}
		}

		public function get contrast():Number {
			return _contrast;
		}
		public function set contrast(__value:Number):void {
			if (_contrast != __value) {
				_contrast = __value;
				updateContrastMatrix();
			}
		}

		public function get brightness():Number {
			return _brightness;
		}
		public function set brightness(__value:Number):void {
			if (_brightness != __value) {
				_brightness = __value;
				updateBrightnessMatrix();
			}
		}

		public function get exposure():Number {
			return _exposure;
		}
		public function set exposure(__value:Number):void {
			if (_exposure != __value) {
				_exposure = __value;
				updateExposureMatrix();
			}
		}

		public function get hue():Number {
			return _hue;
		}
		public function set hue(__value:Number):void {
			if (_hue != __value) {
				_hue = __value;
				updateHueMatrix();
			}
		}

//		override public function get filters(): Array {
//			return _filters;
//		}
//		override public function set filters(__value:Array):void {
//			_filters = __value;
//			requestVisualUpdate();
//		}
	}
}
