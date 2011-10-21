package com.zehfernando.display.components.text {
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class RichTextSpriteEvent extends Event {

		// Constants
		public static const LINK:String = "onClickLink";

		// Properties
		protected var _href:String;
		protected var _hrefTarget:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RichTextSpriteEvent(__type:String, __href:String, __hrefTarget:String, __bubbles:Boolean = false, __cancelable:Boolean = false) {
			_href = __href;
			_hrefTarget = __hrefTarget;

			super(__type, __bubbles, __cancelable);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function clone():Event {
			return new RichTextSpriteEvent(type, _href, _hrefTarget, bubbles, cancelable);
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get href():String {
			return _href;
		}

		public function get hrefTarget():String {
			return _hrefTarget;
		}
	}
}
