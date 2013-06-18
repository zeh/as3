package com.zehfernando.utils.tracking {
	import com.zehfernando.utils.AppUtils;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;

	/**
	 * @author Zeh Fernando
	 */
	public class DARTUtils {

		// Properties
		protected static var inited:Boolean;
		protected static var testMode:Boolean;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function DARTUtils() {
			throw new Error("You cannot initialize this class");
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		public static function init():void {
			if (!inited) {
				inited = true;
				if (!AppUtils.isDebugSWF()) {
					trace ("DARTUtils :: init :: LIVE mode :: ExternalInterface.available = " + ExternalInterface.available);
					testMode = false;
				} else {
					//trace ("DARTUtils :: init :: TEST mode");
					testMode = true;
				}
			}
		}

		public static function trackPageView(__tag:String):void {
			if (!inited) return;

			if (__tag == "") return;

			// Below code comes from DART themselves (with small changes)
			var ldr:Loader = new Loader();
			var rnd:Number = Math.floor(Math.random() * 1000000000);
			var url:String = __tag.replace("[rnd]", rnd.toString(10));
			//var url:String = "http://ad.doubleclick.net/activity;src=1234567;type=group123;cat=trans123;ord="+ rnd +"?";
			var urlReq:URLRequest = new URLRequest(url);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false,0, true);
			ldr.load(urlReq);

			//if (!testMode) {
			//ExternalInterface.call("dcsMultiTrack",  WT_PARAMETER_URI, __uri, WT_PARAMETER_TITLE, __title);
			//}

			if (testMode) {
				trace ("DARTUtils :: trackPageView :: " + url);
			}

		}

		protected static function onError(e:IOErrorEvent):void {
			// To catch error message due to DART's loading of invalid content
			trace ("GAUtils :: IOError :: ["+e+"]");
		}

	}
}
