package com.zehfernando.net.apis.facebook.services {

	import com.zehfernando.data.serialization.json.JSON;
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookFeedPost;
	import com.zehfernando.net.apis.facebook.data.FacebookFeedPostAction;
	import com.zehfernando.net.apis.facebook.events.FacebookServiceEvent;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * @author zeh
	 */
	public class FacebookFeedPostRequest extends BasicFacebookRequest {
		
		// http://developers.facebook.com/docs/reference/api/post/
		// Requires publish_stream 
		
		// Properties
		protected var _targetId:String;
		protected var _message:String;				// The message
		protected var _picture:String;				// If available, a link to the picture included with this post
		protected var _link:String;					// The link attached to this post
		protected var _name:String;					// The name of the link
		protected var _caption:String;				// The caption of the link (appears beneath the link name)
		protected var _description:String;			// A description of the link (appears beneath the link caption)
		protected var _source:String;				// A URL to a Flash movie or video file to be embedded within the post
		protected var _actions:Vector.<FacebookFeedPostAction>;		// A list of available actions on the post (including commenting, liking, and an optional app-specified action). read_stream. A list of JSON objects containing the 'name' and 'link' --- {"name": "View on Zombo", "link": "http://www.zombo.com"}'
		protected var _privacy:String;				// ** The privacy settings of the Post. Publicly accessible. A JSON object containing the value field and optional friends, networks, allow and deny fields. Only works for user's own wall --- See http://developers.facebook.com/docs/reference/api/post/
		protected var _targeting:String;			// ** Location and language restrictions for Page posts only. manage_pages. A JSON object containing comma separated lists of valid country , city , region and locale

		// Results
		protected var _posts:Vector.<FacebookFeedPost>;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookFeedPostRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_FEED_POST;
			requestMethod = URLRequestMethod.POST;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/post/

			_targetId = "";
			
			_message = "";
			_picture = "";
			_link = "";
			_name = "";
			_caption = "";
			_description = "";
			_source = "";
			_actions = new Vector.<FacebookFeedPostAction>;
			_privacy = "";
			_targeting = "";
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getURLVariables():URLVariables {
			var vars:URLVariables = super.getURLVariables();
			var i:int;

			if (Boolean(_message) > 0)     vars["message"] = _message;
			if (Boolean(_picture) > 0)     vars["picture"] = _picture;
			if (Boolean(_link) > 0)        vars["link"] = _link;
			if (Boolean(_name) > 0)        vars["name"] = _name;
			if (Boolean(_caption) > 0)     vars["caption"] = _caption;
			if (Boolean(_description) > 0) vars["description"] = _description;
			if (Boolean(_source) > 0)      vars["source"] = _source;
			if (_actions.length > 0) {
				var actionsList:Array = [];
				for (i = 0; i < _actions.length; i++) {
					actionsList.push({name:_actions[i].name, link:_actions[i].link});
				}
				vars["actions"] = JSON.encode(actionsList);
			}
			//if (Boolean(_privacy) > 0)     vars["privacy"] = _privacy;
			//if (Boolean(_targeting) > 0)   vars["targeting"] = _targeting;

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event): void {
			//var response:Object = JSON.decode(loader.data);
			
			super.onComplete(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.COMPLETE));
		}

		
		override public function execute():void {
			requestURL = requestURL.replace(FacebookConstants.PARAMETER_TARGET_ID, _targetId);
			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get targetId():String {
			return _targetId;
		}
		public function set targetId(__value:String):void {
			_targetId = __value;
		}

		public function get message(): String {
			return _message;
		}
		public function set message(__value:String): void {
			if (_message != __value) {
				_message = __value;
			}
		}
		
		public function get picture(): String {
			return _picture;
		}
		public function set picture(__value:String): void {
			if (_picture != __value) {
				_picture = __value;
			}
		}
		
		public function get link(): String {
			return _link;
		}
		public function set link(__value:String): void {
			if (_link != __value) {
				_link = __value;
			}
		}
		
		public function get name(): String {
			return _name;
		}
		public function set name(__value:String): void {
			if (_name != __value) {
				_name = __value;
			}
		}
		
		public function get caption(): String {
			return _caption;
		}
		public function set caption(__value:String): void {
			if (_caption != __value) {
				_caption = __value;
			}
		}
		
		public function get description(): String {
			return _description;
		}
		public function set description(__value:String): void {
			if (_description != __value) {
				_description = __value;
			}
		}
		
		public function get source(): String {
			return _source;
		}
		public function set source(__value:String): void {
			if (_source != __value) {
				_source = __value;
			}
		}

		public function get actions():Vector.<FacebookFeedPostAction> {
			return _actions;
		}

		public function set actions(actions:Vector.<FacebookFeedPostAction>):void {
			_actions = actions;
		}
	}
}
