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
		public var tags:Vector.<FacebookTag>;
		public var name:String; // Title
		public var picture:String; // Thumbnail
		public var source:String; // Original
		public var height:int; // For 'source'
		public var width:int; // For 'source'
		// images
		/*
		 "images": [
			{
			   "height": 453,
			   "width": 604,
			   "source": "http://sphotos.ak.fbcdn.net/hphotos-ak-ash1/hs744.ash1/163609_837287192727_13610420_46245965_1639588_n.jpg"
			},
			{
			   "height": 135,
			   "width": 180,
			   "source": "http://photos-e.ak.fbcdn.net/hphotos-ak-ash1/hs744.ash1/163609_837287192727_13610420_46245965_1639588_a.jpg"
			},
			{
			   "height": 97,
			   "width": 130,
			   "source": "http://photos-e.ak.fbcdn.net/hphotos-ak-ash1/hs744.ash1/163609_837287192727_13610420_46245965_1639588_s.jpg"
			},
			{
			   "height": 56,
			   "width": 75,
			   "source": "http://photos-e.ak.fbcdn.net/hphotos-ak-ash1/hs744.ash1/163609_837287192727_13610420_46245965_1639588_t.jpg"
			}
		 ],
		*/
		public var link:String;
		public var icon:String;
		public var created:Date;
		//  "position": 1,
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
			photo.tags =									Boolean(o["tags"]) ? FacebookTag.fromJSONObjectArray(o["tags"]["data"]) : new Vector.<FacebookTag>();
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

			//photo.picture = FacebookDataUtils.getImageURLSafeReplacement(photo.picture);
			photo.source = FacebookDataUtils.getImageURLSafeReplacement(photo.source);

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
