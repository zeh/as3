package com.zehfernando.display.decorators {
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;

	/**
	 * @author zeh
	 */
	public class BlurDecorator extends AbstractDecorator {

		// Properties
		protected var _blurX:Number;
		protected var _blurY:Number;
		protected var _quality:Number;

		protected var _clearIfEmpty:Boolean;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BlurDecorator(__target:DisplayObject) {
			_blurX = 0;
			_blurY = 0;
			_quality = 1;

			_clearIfEmpty = true;

			super(__target);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function apply():void {
			_target.filters = (_blurX == 0 && _blurY == 0 && _clearIfEmpty) ? [] : [new BlurFilter(_blurX, _blurY, _quality)];
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get blurX():Number {
			return _blurX;
		}
		public function set blurX(__value:Number):void {
			if (_blurX != __value) {
				_blurX = __value;
				apply();
			}
		}

		public function get blurY():Number {
			return _blurY;
		}
		public function set blurY(__value:Number):void {
			if (_blurY != __value) {
				_blurY = __value;
				apply();
			}
		}

		public function get quality():Number {
			return _quality;
		}
		public function set quality(__value:Number):void {
			if (_quality != __value) {
				_quality = __value;
				apply();
			}
		}
	}
}
