package com.zehfernando.net.apis.facebook.data {
	import com.zehfernando.net.apis.facebook.FacebookDataUtils;

	/**
	 * @author zeh
	 */
	public class FacebookPhoto {
		
		// https://graph.facebook.com/138296789536741/photos
		
		// http://developers.facebook.com/docs/reference/api/photo

		// Properties		
		public var id:String;
		public var from:FacebookAuthor;
		public var name:String;
		public var picture:String; // Thumbnail
		public var source:String; // Original
		public var height:int;
		public var width:int;
		public var link:String;
		public var icon:String;
		public var created:Date;
		public var updated:Date;
		public var numComments:int;
		public var comments:Vector.<FacebookComment>;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookPhoto() {
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------
		
		public static function fromJSONObject(o:Object): FacebookPhoto {
			if (!Boolean(o)) return null;

			var photo:FacebookPhoto = new FacebookPhoto();

			photo.id =										o["id"];
			photo.from =									FacebookAuthor.fromJSONObject(o["from"]);
			photo.name =									o["name"];
			photo.picture =									o["picture"];
			photo.source =									o["source"];
			photo.height =									o["height"];
			photo.width =									o["width"];
			photo.link =									o["link"];
			photo.icon =									o["icon"];
			photo.created =									FacebookDataUtils.getResultStringAsDate(o["created_time"]);
			photo.updated =									FacebookDataUtils.getResultStringAsDate(o["updated_time"]);
			photo.numComments =								Boolean(o["comments"]) ? o["comments"]["count"] : 0;
			photo.comments =								Boolean(o["comments"]) ? FacebookComment.fromJSONObjectArray(o["comments"]["data"]) : new Vector.<FacebookComment>();

			return photo;
		}

		public static function fromJSONObjectArray(o:Array): Vector.<FacebookPhoto> {
			var photos:Vector.<FacebookPhoto> = new Vector.<FacebookPhoto>();

			if (!Boolean(o)) return photos;

			for (var i:int = 0; i < o.length; i++) {
				photos.push(FacebookPhoto.fromJSONObject(o[i]));
			}

			return photos;
		}
	}
}
