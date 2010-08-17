package com.zehfernando.net.apis.youtube.data {

	/**
	 * @author zeh
	 */
	public class YouTubeCategory {

		// Properties
		public var term:String;
		public var label:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function YouTubeCategory(__term:String = "", __label:String = "") {
			term = __term;
			label = __label;
		}

	}
}
