package com.zehfernando.net.apis.twitter.services {
	import com.adobe.serialization.json.JSON;
	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.twitter.TwitterConstants;
	import com.zehfernando.net.apis.twitter.TwitterDataUtils;
	import com.zehfernando.net.apis.twitter.data.Tweet;
	import com.zehfernando.net.apis.twitter.enums.TwitterSearchResultType;
	import com.zehfernando.net.apis.twitter.events.TwitterSearchEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author zeh
	 */
	public class TwitterSearchRequest extends BasicServiceRequest {
		
		// http://apiwiki.twitter.com/Twitter-Search-API-Method%3A+search

		// Properties
		protected var _q:String;
		protected var _from:String;
		protected var _resultType:String;
		protected var _lang:String;						// As based on http://en.wikipedia.org/wiki/ISO_639-1
		protected var _maxId:String;
		protected var _resultsPerPage:int;
		protected var _page:int;
		protected var _since:Date;
		protected var _until:Date;
		protected var _sinceId:String;

		// Results
		protected var _tweets:Vector.<Tweet>;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TwitterSearchRequest() {
			super();

			// Basic service configuration
			requestURL = TwitterConstants.DOMAIN_SEARCH + TwitterConstants.SERVICE_SEARCH;
			requestMethod = URLRequestMethod.GET;

			_resultType = TwitterSearchResultType.RECENT;
			
			// TODO: add missing parameters: locale, geococde
			// TODO: add simulated API points?
			
			// http://apiwiki.twitter.com/Things-Every-Developer-Should-Know
			
			
			
			// http://search.twitter.com/search.format
			// GET
			// # lang: Optional: Restricts tweets to the given language, given by an ISO 639-1 code.
			//   * Example: http://search.twitter.com/search.atom?lang=en&q=devo
			
			// http://search.twitter.com/advanced
			// http://search.twitter.com/search?q=twitter  would become 
			// http://search.twitter.com/search.json?q=twitter
			
			// From a user:
			// http://search.twitter.com/search.atom?q=from%3Aal3x
			
			// With a hashtag:
			// http://search.twitter.com/search.atom?q=%23haiku
			
			
			// http://search.twitter.com/search.json?q=twitter
			
			// result_type, popular/recent
			
			// 150 requests per hour
			// 3,200 statuses (forever?)
			// page: up to a max of roughly 1500 results

			/*
			<feed xmlns:google="http://base.google.com/ns/1.0" xml:lang="en-US" xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/" xmlns="http://www.w3.org/2005/Atom" xmlns:twitter="http://api.twitter.com/">
			  <id>tag:search.twitter.com,2005:search/from:rms_titanic_inc</id>
			  <link type="text/html" href="http://search.twitter.com/search?q=from%3Arms_titanic_inc" rel="alternate"/>
			  <link type="application/atom+xml" href="http://search.twitter.com/search.atom?q=from%3Arms_titanic_inc" rel="self"/>
			  <title>from:rms_titanic_inc - Twitter Search</title>
			  <link type="application/opensearchdescription+xml" href="http://search.twitter.com/opensearch.xml" rel="search"/>
			  <link type="application/atom+xml" href="http://search.twitter.com/search.atom?q=from%3Arms_titanic_inc&amp;since_id=19692205228" rel="refresh"/>
			  <updated>2010-07-27T22:50:14Z</updated>
			  <openSearch:itemsPerPage>15</openSearch:itemsPerPage>
			  <entry>
			    <id>tag:search.twitter.com,2005:19692205228</id>
			    <published>2010-07-27T22:50:14Z</published>
			    <link type="text/html" href="http://twitter.com/RMS_Titanic_Inc/statuses/19692205228" rel="alternate"/>
			    <title>@Technotoaster  Thx!  We have a dream team on board, cutting-edge technology, terrific supporters and a noble cause.</title>
			    <content type="html">&lt;a href=&quot;http://twitter.com/Technotoaster&quot;&gt;@Technotoaster&lt;/a&gt;  Thx!  We have a dream team on board, cutting-edge technology, terrific supporters and a noble cause.</content>
			    <updated>2010-07-27T22:50:14Z</updated>
			    <link type="image/png" href="http://a3.twimg.com/profile_images/1087754811/titanic_avatar_normal.jpg" rel="image"/>
			    <twitter:geo>
			    </twitter:geo>
			    <twitter:metadata>
			      <twitter:result_type>recent</twitter:result_type>
			    </twitter:metadata>
			    <twitter:source>&lt;a href=&quot;http://www.tweetdeck.com&quot; rel=&quot;nofollow&quot;&gt;TweetDeck&lt;/a&gt;</twitter:source>
			    <twitter:lang>en</twitter:lang>
			    <author>
			      <name>RMS_Titanic_Inc (RMS Titanic, Inc.)</name>
			      <uri>http://twitter.com/RMS_Titanic_Inc</uri>
			    </author>
			  </entry>
			*/
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getURLVariables():URLVariables {
			var vars:URLVariables = super.getURLVariables();

			if (Boolean(_q))				vars["q"] = _q;
			if (Boolean(_from))				vars["from"] = _from;
			if (Boolean(_resultType))		vars["result_type"] = _resultType;
			if (Boolean(_lang))				vars["_lang"] = _lang;
			if (Boolean(_maxId))			vars["max_id"] = _maxId;
			if (_resultsPerPage > 0)		vars["rpp"] = _resultsPerPage;
			if (_page > 0)					vars["page"] = _page;
			if (Boolean(_since))			vars["since"] = TwitterDataUtils.getDateAsParamString(_since);
			if (Boolean(_until))			vars["until"] = TwitterDataUtils.getDateAsParamString(_until);
			if (Boolean(_sinceId))			vars["until_id"] = _sinceId;

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onSecurityError(e:SecurityErrorEvent): void {
			//trace ("twitter --> onSecurityError");
			super.onSecurityError(e);
			dispatchEvent(new TwitterSearchEvent(TwitterSearchEvent.ERROR));
		}
		
		override protected function onIOError(e:IOErrorEvent): void {
			//trace ("twitter --> onIOError");
			super.onIOError(e);
			dispatchEvent(new TwitterSearchEvent(TwitterSearchEvent.ERROR));
		}

		override protected function onComplete(e:Event): void {
			//trace ("twitter --> onComplete");

			var response:Object = JSON.decode(loader.data);
			
			_tweets = Tweet.fromSearchJSONObjectArray(response["results"]);
			
			// Example:
			/*
			{
			   "results":[
			      {
			         "profile_image_url":"http://a0.twimg.com/profile_images/1092781896/avatar2_normal.jpg",
			         "created_at":"Mon, 16 Aug 2010 20:15:18 +0000",
			         "from_user":"OneLag",
			         "metadata":{
			            "result_type":"recent"
			         },
			         "to_user_id":12872148,
			         "text":"@todearaujo nao rapaz, nao to falando do meu BG, to falando de como eu uso o meu twitter mesmo",
			         "id":21341803331,
			         "from_user_id":201065,
			         "to_user":"todearaujo",
			         "geo":null,
			         "iso_language_code":"pt",
			         "source":"&lt;a href=&quot;http://www.tweetdeck.com&quot; rel=&quot;nofollow&quot;&gt;TweetDeck&lt;/a&gt;"
			      },
			   ],
			   "max_id":21341803331,
			   "since_id":0,
			   "refresh_url":"?since_id=21341803331&q=twitter",
			   "next_page":"?page=2&max_id=21341803331&q=twitter",
			   "results_per_page":15,
			   "page":1,
			   "completed_in":0.042722,
			   "query":"twitter"
			}
			*/

			super.onComplete(e);
			dispatchEvent(new TwitterSearchEvent(TwitterSearchEvent.COMPLETE));
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get q():String {
			return _q;
		}
		public function set q(__value:String):void {
			_q = __value;
		}
		
		public function get from():String {
			return _from;
		}
		public function set from(__value:String):void {
			_from = __value;
		}
		
		public function get resultType():String {
			return _resultType;
		}
		public function set resultType(__value:String):void {
			_resultType = __value;
		}
		
		public function get lang():String {
			return _lang;
		}
		public function set lang(__value:String):void {
			_lang = __value;
		}
		
		public function get maxId():String {
			return _maxId;
		}
		public function set maxId(__value:String):void {
			_maxId = __value;
		}
		
		public function get resultsPerPage():int {
			return _resultsPerPage;
		}
		public function set resultsPerPage(__value:int):void {
			_resultsPerPage = __value;
		}
		
		public function get page():int {
			return _page;
		}
		public function set page(__value:int):void {
			_page = __value;
		}
		
		public function get since():Date {
			return _since;
		}
		public function set since(__value:Date):void {
			_since = __value;
		}
		
		public function get until():Date {
			return _until;
		}
		public function set until(__value:Date):void {
			_until = __value;
		}
		
		public function get sinceId():String {
			return _sinceId;
		}
		
		public function set sinceId(__value:String):void {
			_sinceId = __value;
		}

		// Results
		
		public function get tweets(): Vector.<Tweet> {
			return _tweets.concat();
		}
	}
}
