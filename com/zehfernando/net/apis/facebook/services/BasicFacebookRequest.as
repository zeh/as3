package com.zehfernando.net.apis.facebook.services {

	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.facebook.auth.FacebookAuth;
	import com.zehfernando.net.apis.facebook.events.FacebookServiceEvent;

	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLVariables;

	/**
	 * @author zeh
	 */
	public class BasicFacebookRequest extends BasicServiceRequest {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BasicFacebookRequest() {
			super();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getURLVariables():URLVariables {
			var vars:URLVariables = super.getURLVariables();

			if (FacebookAuth.loggedIn) vars["access_token"] = FacebookAuth.accessToken;

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onSecurityError(e:SecurityErrorEvent): void {
			super.onSecurityError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}
		
		override protected function onIOError(e:IOErrorEvent): void {
			super.onIOError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}
	}
}
