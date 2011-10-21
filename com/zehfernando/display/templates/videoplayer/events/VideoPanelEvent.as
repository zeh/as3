package com.zehfernando.display.templates.videoplayer.events {
	import flash.events.Event;
	/**
	 * @author zeh
	 */
	public class VideoPanelEvent extends Event {

		// Constants
		public static const PAUSE:String = "onPause";
		public static const PLAY:String = "onPlay";
		public static const SCRUB_START:String = "onScrubStart";
		public static const SCRUB_END:String = "onScrubEnd";
		public static const SCREEN_FULL:String = "onScreenFull";
		public static const SCREEN_NORMAL:String = "onScreenNormal";

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoPanelEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone(): Event {
			return new VideoPanelEvent(type, bubbles, cancelable);
		}
	}
}
