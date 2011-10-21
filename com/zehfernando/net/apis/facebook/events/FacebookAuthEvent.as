package com.zehfernando.net.apis.facebook.events {
	import flash.events.Event;
	/**
	 * @author zeh
	 */
	public class FacebookAuthEvent extends Event {

		// Constants
		public static const LOG_IN_SUCCESS:String = "onLogInSuccess";
		public static const LOG_IN_ERROR:String = "onLogInError";

		public static const LOG_OUT_SUCCESS:String = "onLogOutSuccess";

		public static const GOT_APP_ACCESS_TOKEN_SUCCESS:String = "onGotAppAccessTokenSuccess";
		public static const GOT_APP_ACCESS_TOKEN_ERROR:String = "onGotAppAccessTokenError";

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookAuthEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone(): Event {
			return new FacebookAuthEvent(type, bubbles, cancelable);
		}
	}
}
