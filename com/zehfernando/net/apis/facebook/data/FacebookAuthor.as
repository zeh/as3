package com.zehfernando.net.apis.facebook.data {

	import com.zehfernando.net.apis.facebook.FacebookConstants;

	/**
	 * @author zeh
	 */
	public class FacebookAuthor {

		// Properties		
		public var id:String;
		public var name:String;

		protected var _picture:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookAuthor() {
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------
		
		public static function fromJSONObject(o:Object): FacebookAuthor {
			if (!Boolean(o)) return null;
			
			var author:FacebookAuthor;
			
			if (Boolean(o["category"])) {
				// It's a page
				author = FacebookPage.fromJSONObject(o);
			} else {
				// It's a normal user
				author = FacebookUser.fromJSONObject(o);
			}

			return author;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Picture ?types:
		//  "square" = 50x50 but zoomed (default)
		//  "small" = 50x50 (50 pixels wide, variable height)
		//  "normal" = 100x100
		//  "large" = 200x200 (about 200 pixels wide, variable height):
		
		public function get pictureLarge(): String {
			return (FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_FILE_PICTURE_LARGE).replace(FacebookConstants.PARAMETER_AUTHOR_ID, id);
		}

		public function get picture():String {
			// If the direct link to the profile picture has been supplied, use it. If not, use the service that redirects to the picture
			return Boolean (_picture) ? _picture : (FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_FILE_PICTURE).replace(FacebookConstants.PARAMETER_AUTHOR_ID, id);
		}

		// Ugh, error on people without profiles -- tries to load an image from http://static.ak.fbcdn.net/rsrc.php/yL/r/HsTZSDw4avx.gif?type=large
		// TODO: auto-detect this, somehow?

		
		public function set picture(picture:String):void {
			_picture = picture;
		}
	}
}
