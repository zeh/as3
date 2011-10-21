package com.zehfernando.utils {

	/**
	 * @author zeh
	 */
	public class SocialSharer {

//		// Constants
//		public static const TYPE_TWITTER:String = "twitter";
//		public static const TYPE_FACEBOOK:String = "facebook";

		// Public vars
//		public static var twitterShareURL:String;		// Normally http://twitter.com/share?text=text_here&url=[[url]] --- REMEMBER TO URLENCODE PARAMETERS
//		public static var facebookShareURL:String;		// Normally http://www.facebook.com/share.php?u=[[url]]&t=some_title --- REMEMBER TO URLENCODE PARAMETERS
//		public static var shareWindowTarget:String;		// Normally _blank

//		public static var parameterURL:String;			// Example:  "http://coachella.5gum"


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function share(__serviceURL:String, __windowTarget:String = "_blank"):void {
			// Shares the current page on some service

			HTMLUtils.openPopup(__serviceURL, 600, 400, __windowTarget);
		}

		public static function shareWithVars(__serviceURL:String, __shareText:String, __siteURL:String, __windowTarget:String = "_blank"):void {
			// Shares the current page on some service

			var url:String = __serviceURL;

			url = url.split("{url}").join(StringUtils.URLEncode(__siteURL));
			url = url.split("{text}").join(StringUtils.URLEncode(__shareText));

			HTMLUtils.openPopup(url, 600, 400, __windowTarget);
		}

//		public static function share(__type:String):void {
//			// Shares the current page on some service
//
//			var _url:String;
//			//var _trackId:String;
//
//			switch(__type) {
//				case TYPE_TWITTER:
//					_url = twitterShareURL;
//					break;
//				case TYPE_FACEBOOK:
//					_url = facebookShareURL;
//					break;
//				default:
//					trace("SocialSharer :: ERROR! Tried sharing via unknown type [" + __type + "]!");
//					return;
//			}
//
//			_url = _url.split("[[url]]").join(StringUtils.URLEncode(parameterURL));
//
//			HTMLUtils.openPopup(_url, 600, 400, shareWindowTarget);
//		}
	}
}
