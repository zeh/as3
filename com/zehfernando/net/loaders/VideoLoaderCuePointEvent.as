package com.zehfernando.net.loaders {

	import flash.events.Event;
	/**
	 * @author zeh
	 */
	public class VideoLoaderCuePointEvent extends Event {

		// Constants
		public static const CUE_POINT:String = "onCuePoint";

		// Properties
		protected var _cuePointTime:Number;
		protected var _cuePointName:String;
		protected var _cuePointType:String;
		protected var _cuePointParameters:Object;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoLoaderCuePointEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false, __cuePointTime:Number = NaN, __cuePointName:String = "", __cuePointType:String = "", __cuePointParameters:Object = ""):void {
			super(__type, __bubbles, __cancelable);

			_cuePointTime = __cuePointTime;
			_cuePointName = __cuePointName;
			_cuePointType = __cuePointType;
			_cuePointParameters = __cuePointParameters;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone():Event {
			return new VideoLoaderCuePointEvent(type, bubbles, cancelable, _cuePointTime, _cuePointName, _cuePointType);
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get cuePointTime():Number {
			return _cuePointTime;
		}

		public function get cuePointName():String {
			return _cuePointName;
		}

		public function get cuePointType():String {
			return _cuePointType;
		}

		public function get cuePointParameters():Object {
			return _cuePointParameters;
		}

	}
}
