package com.zehfernando.net.apis.twitter.events {
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class TwitterSearchEvent extends Event {
		
		// Constants
		public static const COMPLETE:String = "onSearchComplete";
		public static const ERROR:String = "onSearchError";

		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TwitterSearchEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------
		
		override public function clone(): Event {
			return new TwitterSearchEvent(type, bubbles, cancelable);
		}

	}
}
