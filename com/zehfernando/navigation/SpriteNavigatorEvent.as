package com.zehfernando.navigation {
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class SpriteNavigatorEvent extends Event {

		public static const CHANGED_LOCATION:String = "onChangedLocation";				// Location has changed, on ANY location hop
		public static const CHANGED_LOCATION_FINAL:String = "onChangedLocationFinal";	// Location has changed, and it's on the final location
		public static const LOCATION_WILL_CHANGE:String = "onLocationBeforeChange";		// Location will change


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function SpriteNavigatorEvent(__type:String, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone(): Event {
			return new SpriteNavigatorEvent(type, bubbles, cancelable);
		}
	}
}
