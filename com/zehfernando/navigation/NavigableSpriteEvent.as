package com.zehfernando.navigation {
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class NavigableSpriteEvent extends Event {

		// Enums
		public static const OPENING:String = "onOpening";				// A NavigableSprite is about to start opening
		public static const OPENED:String = "onOpened";					// A NavigableSprite has finished opening
		public static const CLOSING:String = "onClosing";				// A NavigableSprite is about to start closing
		public static const CLOSED:String = "onClosed";					// A NavigableSprite has finished closing

		public static const OPENING_CHILD:String = "onOpeningChild";	// Implemented; test
		public static const OPENED_CHILD:String = "onOpenedChild";		// Implemented; test
		public static const CLOSING_CHILD:String = "onClosingChild";	// Implemented; test
		public static const CLOSED_CHILD:String = "onClosedChild";		// Implemented; test

		public static const ALLOWED_TO_OPEN:String = "allowedToOpen";						// Permission is given to call open() on this sprite
		public static const ALLOWED_TO_CLOSE:String = "allowedToClose";						// Permission is given to call close() on this sprite

		public static const ALLOWED_TO_PRE_OPEN_CHILD:String = "allowedToPreOpenChild";		// Permission is given to PRE-OPEN (create) a child
		public static const ALLOWED_TO_OPEN_CHILD:String = "allowedToOpenChild";			// Permission is given to call open() on a child
		public static const ALLOWED_TO_CLOSE_CHILD:String = "allowedToCloseChild";			// Permission is given to call close() on a child

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
