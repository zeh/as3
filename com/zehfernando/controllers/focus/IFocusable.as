package com.zehfernando.controllers.focus {
	import flash.geom.Rectangle;
	/**
	 * @author zeh fernando
	 */
	public interface IFocusable {
		function setFocused(__isFocused:Boolean, __immediate:Boolean = false):void;			// So it can tell the item whether it's focused or not
		function getVisualBounds():Rectangle;												// To calculate position for moving with the arrows
		function wasClickSimulated():Boolean;												// Whether the click came from simulate() or not
		function simulateEnterDown():void;
		function simulateEnterUp():void;
		function simulateEnterCancel():void;
		function canReceiveFocus():Boolean;
	}
}
