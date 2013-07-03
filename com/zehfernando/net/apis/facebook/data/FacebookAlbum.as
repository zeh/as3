package com.zehfernando.net.apis.facebook.data {

	import com.zehfernando.net.apis.facebook.FacebookDataUtils;

	/**
	 * @author zeh
	 */
	public class FacebookAlbum {

		// http://developers.facebook.com/docs/reference/api/album
		// https://graph.facebook.com/143423629024057

		// Properties
		public var id:String;
		public var from:FacebookAuthor;
		public var name:String;
		public var description:String;
		public var location:String;
		public var link:String;
		public var numPhotos:String;
		public var created:Date;
		public var updated:Date;
		public var numComments:int;
		public var comments:Vector.<FacebookComment>;
		public var type:String;
		public var canUpload:Boolean;
		public var coverPhoto:String; // id

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookAlbum() {
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromJSONObject(o:Object): FacebookAlbum {
			if (!Boolean(o)) return null;

			var album:FacebookAlbum = new FacebookAlbum();

			album.id =								o["id"];
			album.from =							FacebookAuthor.fromJSONObject(o["from"]); /// *************
			album.name =							o["name"];
			album.description =						o["description"];
			album.location =						o["location"];
			album.link =							o["link"];
			album.created =							FacebookDataUtils.getResultStringAsDate(o["created_time"]);
			album.updated =							FacebookDataUtils.getResultStringAsDate(o["updated_time"]);
			album.numComments =						Boolean(o["comments"]) ? o["comments"]["count"] : 0;
			album.comments =						Boolean(o["comments"]) ? FacebookComment.fromJSONObjectArray(o["comments"]["data"]) : new Vector.<FacebookComment>();
			album.numPhotos =						o["count"];
			album.type =							o["type"];
			album.canUpload =						Boolean(o["can_upload"]);
			album.coverPhoto =						o["cover_photo"];

			return album;
		}

		public static function fromJSONObjectArray(o:Array): Vector.<FacebookAlbum> {
			var albums:Vector.<FacebookAlbum> = new Vector.<FacebookAlbum>();

			if (!Boolean(o)) return albums;

			for (var i:int = 0; i < o.length; i++) {
				albums.push(FacebookAlbum.fromJSONObject(o[i]));
			}

			return albums;
		}
	}
}
