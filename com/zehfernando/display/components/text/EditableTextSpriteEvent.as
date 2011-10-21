package com.zehfernando.display.components.text {

	import flash.events.Event;
	/**
	 * @author zeh
	 */
	public class EditableTextSpriteEvent extends Event {

		// Constants
		public static const GOT_FOCUS:String = "onGotFocus";
		public static const LOST_FOCUS:String = "onLostFocus";
		public static const CHANGED:String = "onChanged";

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function EditableTextSpriteEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone():Event {
			return new EditableTextSpriteEvent(type, bubbles, cancelable);
		}
	}
}
