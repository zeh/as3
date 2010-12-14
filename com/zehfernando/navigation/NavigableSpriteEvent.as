package com.zehfernando.navigation {
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class NavigableSpriteEvent extends Event {
		
		public static const OPENING:String = "onOpening";
		public static const OPENED:String = "onOpened";
		public static const CLOSING:String = "onClosing";
		public static const CLOSED:String = "onClosed";
		public static const ALLOWED_TO_PRE_OPEN_CHILD:String = "allowedToPreOpenChild";
		public static const ALLOWED_TO_OPEN_CHILD:String = "allowedToOpenChild";
		public static const ALLOWED_TO_CLOSE_CHILD:String = "allowedToCloseChild";

		public static const ALLOWED_TO_OPEN:String = "allowedToOpen";

		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------
		
		public function NavigableSpriteEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------
		
		override public function clone(): Event {
			return new NavigableSpriteEvent(type, bubbles, cancelable);
		}
	}
}
