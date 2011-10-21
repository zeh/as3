package com.zehfernando.display.containers {
	import flash.events.IEventDispatcher;

	/**
	 * @author zeh
	 */
	public interface IVideoContainer extends IEventDispatcher {

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		function playVideo():void;
		function pauseVideo():void;
		function stopVideo():void;
		function playPauseVideo():void;

		function load(__urlOrId:String): void;
		function unload(): void;

		function dispose(): void;

		function getMaximumPositionPlayed():Number;

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		function get time(): Number;
		function set time(__value:Number): void;

		function get duration(): Number;

		function get position(): Number;
		function set position(__value:Number): void;

		function get framerate(): Number;

		function get isPlaying(): Boolean;

		function get autoPlay(): Boolean;
		function set autoPlay(__value:Boolean):void;

		function get volume():Number;
		function set volume(__value:Number):void;

		function get loop(): Boolean;
		function set loop(__value:Boolean):void;

		function get loadedPercent(): Number;

		//

		function get smoothing(): Boolean;
		function set smoothing(__value:Boolean):void;

		function get scaleMode(): String;
		function set scaleMode(__value:String):void;

		function get width(): Number;
		function set width(__value:Number):void;

		function get height(): Number;
		function set height(__value:Number):void;

		function get contentWidth(): Number;

		function get contentHeight(): Number;

	}
}
