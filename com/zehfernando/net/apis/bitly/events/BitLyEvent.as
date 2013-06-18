package com.zehfernando.net.apis.bitly.events {
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class BitLyEvent extends Event {

		// Constants
		public static const SUCCESS:String = "onSuccess";
		public static const ERROR:String = "onError";

		// Properties
		protected var _data:Object;
		protected var _status_code:int;
		protected var _status_txt:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BitLyEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false, __data:Object = null, __status_code:int = 0, __status_txt:String = ""):void {
			super(__type, __bubbles, __cancelable);

			_data = __data;
			_status_code = __status_code;
			_status_txt = __status_txt;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone():Event {
			return new BitLyEvent(type, bubbles, cancelable, _data, _status_code, _status_txt);
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get data():Object {
			return _data;
		}

		public function get status_code():int {
			return _status_code;
		}

		public function get status_txt():String {
			return _status_txt;
		}

	}
}
