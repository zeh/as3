package com.zehfernando.display.templates.videoplayer.events {

	import flash.events.Event;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class VideoPanelVolumeEvent extends Event {

		// Constants
		public static const VOLUME_CHANGE:String = "onVolumeChange";

		// Properties
		public var volume:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoPanelVolumeEvent(__type:String, __volume:Number, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);

			volume = __volume;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone(): Event {
			return new VideoPanelVolumeEvent(type, volume, bubbles, cancelable);
		}
	}
}
