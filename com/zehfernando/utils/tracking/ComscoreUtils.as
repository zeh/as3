package com.zehfernando.utils.tracking {

	import com.zehfernando.utils.console.log;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * @author zeh
	 */
	public class ComscoreUtils {

		// ComScore tracking
		protected static var _verbose:Boolean;						// If true, trace statements
		protected static var _simulated:Boolean;					// If true, doesn't actually make any post

		// Properties
		protected static var loaders:Vector.<LoaderInfo>;

		public function ComscoreUtils() {
			throw new Error("You cannot instantiate this class.");
		}

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		{
			_verbose = true;
			_simulated = false;

			if (_verbose) log ("Initialized :: verbose set to ["+_verbose+"] and simulated set to ["+_simulated+"]");

			loaders = new Vector.<LoaderInfo>();
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected static function onLoaderComplete(e:Event):void {
			// Loaded this loader, so remove from list
			var loaderIndex:int = loaders.indexOf(e.target);
			loaders[loaderIndex].removeEventListener(Event.COMPLETE, onLoaderComplete);
			loaders.splice(loaderIndex, 1);
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		public static function trackURL(__url:String):void {
			if (_verbose) log ("[" + __url + "]");
			if (!_simulated && Boolean(__url)) {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
				loaders.push(loader.contentLoaderInfo);
				loader.load(new URLRequest(__url), new LoaderContext(true));
			}
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public static function get simulated():Boolean {
			return _simulated;
		}
		public static function set simulated(__value:Boolean):void {
			if (_simulated != __value) {
				_simulated = __value;
				log("simulated is " + _simulated);
			}
		}

		public static function get verbose():Boolean {
			return _verbose;
		}
		public static function set verbose(__value:Boolean):void {
			if (_verbose != __value) {
				_verbose = __value;
				log("verbose is " + _verbose);
			}
		}
	}
}
