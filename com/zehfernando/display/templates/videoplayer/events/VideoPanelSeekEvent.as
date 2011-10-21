package com.zehfernando.display.templates.videoplayer.events {

	import flash.events.Event;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class VideoPanelSeekEvent extends Event {

		// Constants
		public static const SEEK:String = "onSeek";

		// Properties
		public var time:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoPanelSeekEvent(__type:String, __time:Number, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);

			time = __time;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone(): Event {
			return new VideoPanelSeekEvent(type, time, bubbles, cancelable);
		}
	}
}
