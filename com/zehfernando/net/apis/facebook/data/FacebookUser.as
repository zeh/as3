package com.zehfernando.net.apis.facebook.data {
	import com.zehfernando.net.apis.facebook.FacebookDataUtils;

	/**
	 * @author zeh
	 */
	public class FacebookUser extends FacebookAuthor {

		// http://developers.facebook.com/docs/reference/api/user
		
		// http://graph.facebook.com/me

		// Properties
		public var firstName:String;
		public var lastName:String;
		public var link:String;
		public var about:String;
		public var bio:String;
		public var birthday:String;					// TODO: change to date?
		public var hometown:FacebookLocation;
		public var location:FacebookLocation;
		//public var work:String;
		//public var education:String;
		//meeting_for
		//interested_in
		public var gender:String; // FacebookGender
		public var relationshipStatus:String; // FacebookRelationshipStatus
		public var significantOther:FacebookAuthor;
		public var religion:String;
		public var political:String;
		public var website:String;
		public var timezone:Number;
		public var locale:String;
		public var verified:Boolean;
		public var updated:Date;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookUser() {
			super();
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromJSONObject(o:Object): FacebookUser {
			if (!Boolean(o)) return null;

			var user:FacebookUser = new FacebookUser();

			user.id =										o["id"];
			user.name =										o["name"];
			
			user.bio =										o["bio"];
			user.link =										o["link"];
			user.about =									o["about"];
			user.birthday =									o["birthday"];
			user.hometown =									FacebookLocation.fromJSONObject(o["hometown"]);
			user.location =									FacebookLocation.fromJSONObject(o["location"]);
			user.gender =									o["gender"];
			user.relationshipStatus =						o["relationship_status"];
			user.significantOther =							FacebookAuthor.fromJSONObject(o["significant_other"]);
			user.religion =									o["religion"];
			user.political =								o["political"];
			user.website =									o["website"];
			user.timezone =									o["timezone"];
			user.locale =									o["locale"];
			user.verified =									o["verified"];
			user.updated =									FacebookDataUtils.getResultStringAsDate(o["updated"]);

			return user;
		}
	}
}
