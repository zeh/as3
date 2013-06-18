package com.zehfernando.net.apis.facebook.auth {

	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.events.FacebookAuthEvent;
	import com.zehfernando.utils.HTMLUtils;
	import com.zehfernando.utils.console.log;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.LocalConnection;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	/**
	 * @author zeh
	 */
	public class FacebookAuth {

		// http://developers.facebook.com/docs/authentication/javascript

		// Move this all to a more generic OAuth class?

		// Properties
		public static var appId:String;			// Needed for app access, login access
		public static var appSecret:String;		// Needed for app access
		public static var redirectURL:String;
		public static var redirectLogoutURL:String;

		protected static var localConnection:LocalConnection;
		protected static var _accessToken:String;

		protected static var _loggedIn:Boolean;
		protected static var _hasAppAccessToken:Boolean;

		protected static var eventDispatcher:EventDispatcher = new EventDispatcher();

		protected static var appAccessTokenLoader:URLLoader;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookAuth() {
		}

		// ================================================================================================================
		// EVENT DISPATCHER INTERFACE -------------------------------------------------------------------------------------

		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function dispatchEvent(event:Event):Boolean {
			return eventDispatcher.dispatchEvent(event);
		}

		public static function hasEventListener(type:String):Boolean {
			return eventDispatcher.hasEventListener(type);
		}

		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}

		public static function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		public static function onLoginSuccessLC(__accessToken:String):void {
			log("Login success with access token " + __accessToken);
			_accessToken = __accessToken;
			_loggedIn = true;
			closeLocalConnection();
			dispatchEvent(new FacebookAuthEvent(FacebookAuthEvent.LOG_IN_SUCCESS));
		}

		public static function onLoginErrorLC(__errorReason:String, __errorType:String, __errorDescription:String):void {
			log("Login error with reason ["+__errorReason+"], type ["+__errorType+"], description ["+__errorDescription+"]");
			_loggedIn = false;
			closeLocalConnection();
			dispatchEvent(new FacebookAuthEvent(FacebookAuthEvent.LOG_IN_ERROR));
		}

		protected static function onLoginWindowClosedLC():void {
			if (Boolean(localConnection)) {
				// Window closed, while a local connection still exists
				log("Login error (window closed)");
				_loggedIn = false;
				closeLocalConnection();
				dispatchEvent(new FacebookAuthEvent(FacebookAuthEvent.LOG_IN_ERROR));
			} else {
				// Window closed, but after an error or success was already registered
			}
		}

		protected static function onLogoutWindowClosedLC():void {
			log("Logout window closed");
		}

		protected static function onGetAppAccessTokenSuccess(e:Event):void {
			_accessToken = appAccessTokenLoader.data["access_token"];
			_hasAppAccessToken = true;
			destroyAppAccessTokenLoader();
			dispatchEvent(new FacebookAuthEvent(FacebookAuthEvent.GOT_APP_ACCESS_TOKEN_SUCCESS));
		}

		protected static function onGetAppAccessTokenIOError(e:Event):void {
			log("I/O error when getting app access token!");
			destroyAppAccessTokenLoader();
			dispatchEvent(new FacebookAuthEvent(FacebookAuthEvent.GOT_APP_ACCESS_TOKEN_ERROR));
		}

		protected static function onGetAppAccessTokenSecurityError(e:Event):void {
			log("Security error when getting app access token!");
			destroyAppAccessTokenLoader();
			dispatchEvent(new FacebookAuthEvent(FacebookAuthEvent.GOT_APP_ACCESS_TOKEN_ERROR));
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected static function closeLocalConnection():void {
			if (Boolean(localConnection)) {
				localConnection.close();
				localConnection = null;
			}
		}

		protected static function destroyAppAccessTokenLoader():void {
			if (Boolean(appAccessTokenLoader)) {
				//appAccessTokenLoader.close();
				appAccessTokenLoader.removeEventListener(Event.COMPLETE, onGetAppAccessTokenSuccess);
				appAccessTokenLoader.removeEventListener(IOErrorEvent.IO_ERROR, onGetAppAccessTokenIOError);
				appAccessTokenLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetAppAccessTokenSecurityError);
				appAccessTokenLoader = null;
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function login(__permissions:Array = null, __useNormalLink:Boolean = false):void {
			// Open the popup window asking for login permission

			closeLocalConnection();

			localConnection = new LocalConnection();
			localConnection.allowDomain("*");
			localConnection.client = {onLoginSuccessLC:onLoginSuccessLC, onLoginErrorLC:onLoginErrorLC};
			try {
				localConnection.connect("_zFacebookAuthConn");
			} catch (e:Error) {
				log("Login failed because the LocalConnection is already connected somewhere else!");
			}

			if (!Boolean(__permissions)) __permissions = [];
			var permissions:String = __permissions.join(",");

			var url:String = FacebookConstants.AUTHORIZE_URL.split(FacebookConstants.PARAMETER_AUTH_APP_ID).join(appId).split(FacebookConstants.PARAMETER_AUTH_REDIRECT_URL).join(redirectURL).split(FacebookConstants.PARAMETER_AUTH_PERMISSIONS).join(permissions);

			if (__useNormalLink) {
				navigateToURL(new URLRequest(url), "_blank");
			} else {
				HTMLUtils.openPopup(url, 600, 400, "_blank", onLoginWindowClosedLC);
			}

			// https://graph.facebook.com/oauth/authorize?client_id=147149585329358&redirect_uri=http://www.facebook.com/connect/login_success.html&type=user_agent&display=popup
			// Goes to
			// http://www.facebook.com/connect/login_success.html#access_token=147149585329358|2.0FiQGOUJJO4c_Cn9ldS2sw__.3600.1287158400-711322444|DWZFLTJtB48ilCs73xp8uu1jn4E&expires_in=4997

			// https://graph.facebook.com/oauth/authorize?client_id=147149585329358&redirect_uri=http://fakehost.com/SANDBOX/deploy/fb_login_success.html&type=user_agent&display=popup
			// Goes to
			// http://fakehost.com/SANDBOX/deploy/fb_login_success.html#access_token=147149585329358|2.0FiQGOUJJO4c_Cn9ldS2sw__.3600.1287158400-711322444|DWZFLTJtB48ilCs73xp8uu1jn4E&expires_in=3677
			// Or
			// http://fakehost.com/SANDBOX/deploy/fb_login_success.html?error_reason=user_denied&error=access_denied&error_description=The+user+denied+your+request.

			// https://graph.facebook.com/me?access_token=2227470867%7C2.ymbE61jcLXs8V0LybrlzPA__.3600.1287158400-711322444%7Cz8rYDB_GlfbSaEiJ0-3j6MZxBCg
			// https://graph.facebook.com/me/friends?access_token=2227470867|2.ymbE61jcLXs8V0LybrlzPA__.3600.1287158400-711322444|z8rYDB_GlfbSaEiJ0-3j6MZxBCg
		}

		public static function logout(__forceSiteLogout:Boolean = false):void {
			if (_loggedIn) {
				dispatchEvent(new FacebookAuthEvent(FacebookAuthEvent.LOG_OUT_SUCCESS));
				_loggedIn = false;
				closeLocalConnection();

				if (__forceSiteLogout) {
					// Method 1
					// http://m.facebook.com/logout.php?confirm=1&next=http://yoursitename.com

					log("redirecting to "+redirectLogoutURL);

					var url:String = FacebookConstants.LOGOUT_URL.split(FacebookConstants.PARAMETER_AUTH_REDIRECT_URL).join(redirectLogoutURL);
					HTMLUtils.openPopup(url, 600, 400, "_blank", onLogoutWindowClosedLC);

					// Method 2
					// http://www.facebook.com/logout.php?api_key={0}&;session_key={1}
					// http://stackoverflow.com/questions/2764436/facebook-oauth-logout
				}
			}
		}

		public static function getAppAccessToken():void {
			// Tries to get an access token for app access
			destroyAppAccessTokenLoader();

			var url:String = FacebookConstants.AUTHORIZE_APP_URL.split(FacebookConstants.PARAMETER_AUTH_APP_ID).join(appId).split(FacebookConstants.PARAMETER_AUTH_APP_SECRET).join(appSecret);

			appAccessTokenLoader = new URLLoader();
			appAccessTokenLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			appAccessTokenLoader.addEventListener(Event.COMPLETE, onGetAppAccessTokenSuccess);
			appAccessTokenLoader.addEventListener(IOErrorEvent.IO_ERROR, onGetAppAccessTokenIOError);
			appAccessTokenLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetAppAccessTokenSecurityError);
			appAccessTokenLoader.load(new URLRequest(url));
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public static function get accessToken():String {
			return _accessToken;
		}

		public static function get loggedIn():Boolean {
			return _loggedIn;
		}

		public static function get hasAppAccessToken():Boolean {
			return _hasAppAccessToken;
		}

	}
}
