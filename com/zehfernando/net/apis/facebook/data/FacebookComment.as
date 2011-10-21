package com.zehfernando.net.apis.facebook.data {
	import com.zehfernando.net.apis.facebook.FacebookDataUtils;

	/**
	 * @author zeh
	 */
	public class FacebookComment {

		// https://graph.facebook.com/136208713078882_146368762058100/comments

		// Properties
		public var id:String;
		public var from:FacebookAuthor;
		public var message:String;
		public var created:Date;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookComment() {
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromJSONObject(o:Object): FacebookComment {
			if (!Boolean(o)) return null;

			var comment:FacebookComment = new FacebookComment();

			comment.id =									o["id"];
			comment.from =									FacebookAuthor.fromJSONObject(o["from"]);
			comment.message =								o["message"];
			comment.created =								FacebookDataUtils.getResultStringAsDate(o["created_time"]);

			return comment;
		}

		public static function fromJSONObjectArray(o:Array): Vector.<FacebookComment> {
			var comments:Vector.<FacebookComment> = new Vector.<FacebookComment>();

			if (!Boolean(o)) return comments;

			for (var i:int = 0; i < o.length; i++) {
				comments.push(FacebookComment.fromJSONObject(o[i]));
			}

			return comments;
		}
	}
}
