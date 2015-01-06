package com.zehfernando.display.containers {
	import com.zehfernando.utils.getTimerUInt;

	import flash.display.Bitmap;

	/**
	 * @author zeh
	 */
	public class DynamicDisplayAssetContainer extends DisplayAssetContainer {

		// Properties
		protected var _isLoaded:Boolean;
		protected var _isLoading:Boolean;

		protected var _contentURL:String;

		protected var _smoothing:Boolean;

		protected var _timeStartedLoading:uint;
		protected var _timeCompletedLoading:uint;
		protected var _bytesLoaded:Number;
		protected var _bytesTotal:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function DynamicDisplayAssetContainer(__width:Number = 100, __height:Number = 100, __backgroundColor:Number = 0x000000) {
			super(__width, __height, __backgroundColor);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function setDefaultData():void {
			super.setDefaultData();

			_smoothing = false;

			_isLoaded = false;
			_isLoading = false;
			_timeStartedLoading = NaN;
			_timeCompletedLoading = NaN;
			_bytesLoaded = 0;
			_bytesTotal = NaN;
		}

		protected function updateStartedLoadingStats():void {
			_timeStartedLoading = getTimerUInt();
		}

		protected function updateCompletedLoadingStats():void {
			_timeCompletedLoading = getTimerUInt();
		}

		protected function applySmoothing():void {
			// TODO! youtube doesn't allow it!
			if (contentAsset != null) {
				if (contentAsset is Bitmap) (contentAsset as Bitmap).smoothing = _smoothing;
			}
		}

		override protected function redraw():void {
			super.redraw();
			applySmoothing();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function load(__url:String):void {
			if (_isLoading || _isLoaded) unload();
			_contentURL = __url;
		}

		public function unload():void {
			_contentURL = null;
			_isLoaded = false;
			_isLoading = false;
			_timeStartedLoading = NaN;
			_timeCompletedLoading = NaN;
			_bytesLoaded = 0;
			_bytesTotal = NaN;
		}

		public function getLoadingSpeed():Number {
			// Returns the loading speed, in bytes per second
			if (isLoading) {
				return _bytesLoaded / ((getTimerUInt() - _timeStartedLoading) / 1000);
			} else if (isLoaded) {
				return _bytesLoaded / ((_timeCompletedLoading - _timeStartedLoading) / 1000);
			}
			return 0;
		}

		override public function dispose():void {
			unload();
			super.dispose();
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get loadedPercent():Number {
			//trace(_isLoaded, _bytesLoaded, _bytesTotal);
			return _isLoaded ? 1 : ( (isNaN(_bytesLoaded) || isNaN(_bytesTotal) || _bytesTotal == 0) ? 0 : _bytesLoaded / _bytesTotal );
		}

		public function get bytesLoaded():Number {
			return _bytesLoaded;
		}

		public function get bytesTotal():Number {
			return _bytesTotal;
		}

		public function get contentURL():String {
			return _contentURL;
		}


		// State information ----------------------------------

		public function get isLoaded():Boolean {
			return _isLoaded;
		}
		public function get isLoading():Boolean {
			return _isLoading;
		}

		public function get smoothing():Boolean {
			return _smoothing;
		}
		public function set smoothing(__value:Boolean):void {
			_smoothing = __value;
			applySmoothing();
		}
	}
}
