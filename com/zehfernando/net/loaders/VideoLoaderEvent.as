package com.zehfernando.net.loaders {
	import flash.events.Event;
	/**
	 * @author zeh
	 */
	public class VideoLoaderEvent extends Event {

		// Constants
		public static const SEEK_NOTIFY:String = "onSeekNotify";
		public static const STREAM_NOT_FOUND:String = "onStreamNotFound";
		public static const BUFFER_EMPTY:String = "onBufferEmpty";
		public static const BUFFER_FULL:String = "onBufferFull";
		public static const BUFFER_FLUSH:String = "onBufferFlush";
		public static const PLAY_START:String = "onPlayStart";			// First play
		public static const RESUME:String = "onResume";					// Any play
		public static const PAUSE:String = "onPause";					// Any pause
		public static const PLAY_STOP:String = "onPlayStop";
		public static const PLAY_FINISH:String = "onPlayFinish";
		public static const RECEIVED_XMP_DATA: String = "onReceivedXMPData";
		public static const RECEIVED_METADATA: String = "onReceivedMetaData";
		public static const TIME_CHANGE: String = "onTimeChange";

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoLoaderEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false):void {
			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone():Event {
			return new VideoLoaderEvent(type, bubbles, cancelable);
		}
	}
}
