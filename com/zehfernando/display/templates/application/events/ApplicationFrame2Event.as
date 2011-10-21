package com.zehfernando.display.templates.application.events {

	import flash.events.Event;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class ApplicationFrame2Event extends Event {

		// Constants
		public static const INIT_PROGRESS:String = "onInitProgress";
		public static const INIT_COMPLETE:String = "onInitComplete";

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ApplicationFrame2Event(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone(): Event {
			return new ApplicationFrame2Event(type, bubbles, cancelable);
		}
	}
}