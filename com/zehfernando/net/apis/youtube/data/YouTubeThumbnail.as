package com.zehfernando.net.apis.youtube.data {

	/**
	 * @author zeh
	 */
	public class YouTubeThumbnail {

		// Properties
		public var url:String;
		public var height:int;
		public var width:int;
		public var time:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function YouTubeThumbnail(__url:String = "", __height:int = 0, __width:int = 0, __time:Number = 0) {
			url = __url;
			height = __height;
			width = __width;
			time = __time;
		}

	}
}
