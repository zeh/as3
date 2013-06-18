package com.zehfernando.net.apis.twitter.services {
	import com.zehfernando.data.serialization.json.JSON;
	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.twitter.TwitterConstants;
	import com.zehfernando.net.apis.twitter.data.Tweet;
	import com.zehfernando.net.apis.twitter.events.TwitterServiceEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author zeh
	 */
	public class TwitterUserTimelineRequest extends BasicServiceRequest {

		// Example:
		// http://api.twitter.com/1/statuses/user_timeline/zeh.json
		// http://twitter.com/statuses/user_timeline.xml?screen_name=zeh
		// Docs:
		// http://dev.twitter.com/doc/get/statuses/user_timeline
		// http://dev.twitter.com/doc#Timeline

		// Properties
		protected var _count:int;			// Max 200; default 20
		protected var _userId:String;		// REQUIRES APP
		protected var _screenName:String;	// No need for app key

		protected var _page:int;
		protected var _maxId:String;
		protected var _sinceId:String;
		protected var _trimUser:Boolean;
		protected var _includeRTS:Boolean;	// Include native retweets
		protected var _includeEntities:Boolean;	// Metadata about the tweet - user_mentions, urls, and hashtags. False currently, will be true in the future

		// Results
		protected var _tweets:Vector.<Tweet>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TwitterUserTimelineRequest() {
			super();

			// Basic service configuration
			requestURL = TwitterConstants.API_REST_DOMAIN + TwitterConstants.AI_REST_SERVICE_USER_TIMELINE;
			requestMethod = URLRequestMethod.GET;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getURLVariables():URLVariables {
			var vars:URLVariables = super.getURLVariables();

			if (_count > 0)					vars["count"] = _count;
			if (Boolean(_userId))			vars["user_id"] = _userId;
			if (Boolean(_screenName))		vars["screen_name"] = _screenName;
			if (_page > 0)					vars["page"] = _page;
			if (Boolean(_maxId))			vars["max_id"] = _maxId;
			if (Boolean(_sinceId))			vars["since_id"] = _sinceId;

			if (_trimUser)					vars["trim_user"] = TwitterConstants.BOOLEAN_STRING_TRUE;
			if (_includeRTS)				vars["include_rts"] = TwitterConstants.BOOLEAN_STRING_TRUE;
			if (_includeEntities)			vars["include_entities"] = TwitterConstants.BOOLEAN_STRING_TRUE;

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onSecurityError(e:SecurityErrorEvent):void {
			//trace ("twitter --> onSecurityError");
			super.onSecurityError(e);
			dispatchEvent(new TwitterServiceEvent(TwitterServiceEvent.ERROR));
		}

		override protected function onIOError(e:IOErrorEvent):void {
			//trace ("twitter --> onIOError");
			super.onIOError(e);
			dispatchEvent(new TwitterServiceEvent(TwitterServiceEvent.ERROR));
		}

		override protected function onComplete(e:Event):void {
			//trace ("twitter --> onComplete");

			var response:Object = JSON.decode(loader.data);

			_tweets = Tweet.fromSearchJSONObjectArray(response["results"]);

			super.onComplete(e);
			dispatchEvent(new TwitterServiceEvent(TwitterServiceEvent.COMPLETE));
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// TODO: getters and setters are never locked; just use public parameters?

		// Parameters
		public function get count() :int {
			return _count;
		}
		public function set count(__value : int) :void {
			_count = __value;
		}

		public function get userId() :String {
			return _userId;
		}
		public function set userId(__value : String) :void {
			_userId = __value;
		}

		public function get screenName() :String {
			return _screenName;
		}
		public function set screenName(__value : String) :void {
			_screenName = __value;
		}

		public function get page() :int {
			return _page;
		}
		public function set page(__value : int) :void {
			_page = __value;
		}

		public function get maxId() :String {
			return _maxId;
		}
		public function set maxId(__value : String) :void {
			_maxId = __value;
		}

		public function get sinceId() :String {
			return _sinceId;
		}
		public function set sinceId(__value : String) :void {
			_sinceId = __value;
		}

		public function get trimUser() :Boolean {
			return _trimUser;
		}
		public function set trimUser(__value : Boolean) :void {
			_trimUser = __value;
		}

		public function get includeRTS() :Boolean {
			return _includeRTS;
		}
		public function set includeRTS(__value : Boolean) :void {
			_includeRTS = __value;
		}

		public function get includeEntities() :Boolean {
			return _includeEntities;
		}
		public function set includeEntities(__value : Boolean) :void {
			_includeEntities = __value;
		}



		// Results

		public function get tweets(): Vector.<Tweet> {
			return _tweets.concat();
		}

	}
}
