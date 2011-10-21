package com.zehfernando.localization {

	import flash.events.Event;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class StringListEvent extends Event {

		// Constants
		public static const CHANGED_LANGUAGE:String = "onChangedLanguage";

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StringListEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone(): Event {
			return new StringListEvent(type, bubbles, cancelable);
		}

	}
}
