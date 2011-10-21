package com.zehfernando.net.apis.twitter.events {
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class TwitterServiceEvent extends Event {

		// Constants
		public static const COMPLETE:String = "onRequestComplete";
		public static const ERROR:String = "onRequestError";


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TwitterServiceEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone(): Event {
			return new TwitterServiceEvent(type, bubbles, cancelable);
		}

	}
}
