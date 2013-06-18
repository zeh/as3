package com.zehfernando.controllers.focus {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	/**
	 * @author zeh fernando
	 */
	public interface IFocusable {
		function get focused():Number;
		function set focused(__value:Number):void;
		function getBounds(targetCoordinateSpace:DisplayObject):Rectangle; // To calculate next/prev
		function dispatchEvent(event:Event):Boolean; // Just so mouse events can be injected
	}
}
