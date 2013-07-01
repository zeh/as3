package com.zehfernando.controllers.focus {
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	/**
	 * @author zeh fernando
	 */
	public interface IFocusable {
		function setFocused(__isFocused:Boolean):void;						// So it can tell the item whether it's focused or not
		function getBounds(__targetCoordinateSpace:DisplayObject):Rectangle;	// To calculate position for moving with the arrows
		function simulateEnterDown():void;
		function simulateEnterUp():void;
		function simulateEnterCancel():void;
	}
}
