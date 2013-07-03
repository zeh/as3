package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.facebook.auth.FacebookAuth;
	import com.zehfernando.net.apis.facebook.events.FacebookServiceEvent;
	import com.zehfernando.utils.console.log;

	import flash.events.Event;
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

		override protected function getData():Object {
			var vars:URLVariables = new URLVariables();

			if (FacebookAuth.loggedIn || FacebookAuth.hasAppAccessToken) vars["access_token"] = FacebookAuth.accessToken;

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onSecurityError(e:SecurityErrorEvent):void {
			log("Security error while loading " + requestURL);
			super.onSecurityError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}

		override protected function onIOError(e:IOErrorEvent):void {
			log("IO Error while loading " + requestURL + " - are you sure an access token is available?");
			log(loader.data);
			super.onIOError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}

		override protected function onComplete(e:Event):void {
			super.onComplete(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.COMPLETE));
		}
	}
}
