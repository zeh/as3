package com.zehfernando.net.apis.parse.events {
	import flash.events.Event;
	/**
	 * @author zeh fernando
	 */
	public class ParseServiceEvent extends Event {

		// Constants
		public static const COMPLETE:String = "onComplete";
		public static const ERROR:String = "onError";


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ParseServiceEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone(): Event {
			return new ParseServiceEvent(type, bubbles, cancelable);
		}
	}
}
