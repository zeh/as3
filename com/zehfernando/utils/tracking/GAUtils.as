package com.zehfernando.utils.tracking {

	import com.zehfernando.utils.console.debug;

	import flash.external.ExternalInterface;

	/**
	 * @author Zeh Fernando
	 */
	public class GAUtils {

		// Google analytics tracking
		protected static var _verbose:Boolean;						// If true, trace statements
		protected static var _simulated:Boolean;					// If true, doesn't actually make any post

		/*
		HTML should contain:

		<script type="text/javascript">
		var _gaq = _gaq || [];
		_gaq.push(['_setAccount', 'UA-XXXXXXX-X']);
		_gaq.push(['_trackPageview']);

		(function() {
		var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
		})();

		</script>
		*/

		public function GAUtils() {
			throw new Error("You cannot instantiate this class.");
		}

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		{
			_verbose = true;
			_simulated = false;

			if (_verbose) debug ("Initialized :: verbose set to ["+_verbose+"] and simulated set to ["+_simulated+"]");
		}


		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		// TODO: test for presence of tracking object?

		public static function trackPageView(__url:String):void {
			if (_verbose) debug ("[" + __url + "]");
			if (!_simulated) ExternalInterface.call("function(__url){_gaq.push(['_trackPageview', __url]);}", __url);
		}

		public static function trackEvent(__category:String, __action:String, __label:String = null, __value:Number = 0):void {
			if (_verbose) debug ("Category: ["+__category+"] Action:["+__action+"] Label:["+__label+"] Value:["+__value+"]");
			if (!_simulated) ExternalInterface.call("function(__category, __action, __label, __value){_gaq.push(['_trackEvent', __category, __action, __label, __value]);}", __category, __action, __label, __value);
			//("Videos", "Video Load Time", "Gone With the Wind", downloadTime);
			//("Videos", "Play", "Gone With the Wind");
		}

		public static function trackEventNumericLabel(__category:String, __action:String, __labelTemplate:String, __value:Number, __granularity:int, __algarisms:int, __maximum:Number = NaN, __minimum:Number = NaN, __minimumTemplate:String = "<[[max]]", __maximumTemplate:String = ">[[min]]"):void {

			var templateToUse:String = __labelTemplate;

			var valueConsidered:Number = __value;
			if (!isNaN(__minimum) && valueConsidered < __minimum) {
				valueConsidered = __minimum;
				templateToUse = __minimumTemplate;
			}
			if (!isNaN(__maximum) && valueConsidered > __maximum) {
				valueConsidered = __maximum;
				templateToUse = __maximumTemplate;
			}

			var valMin:Number = Math.floor(valueConsidered / __granularity) * __granularity;
			var valMax:Number = valMin + __granularity;

			var strMin:String = ("0000000000000" + valMin.toString(10)).substr(-__algarisms, __algarisms);
			var strMax:String = ("0000000000000" + valMax.toString(10)).substr(-__algarisms, __algarisms);

			var newLabel:String = templateToUse.split("[[min]]").join(strMin).split("[[max]]").join(strMax);

			trackEvent(__category, __action, newLabel, Math.round(__value)); // Apparently floating point numbers are breaking the script?!?
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public static function get simulated():Boolean {
			return _simulated;
		}
		public static function set simulated(__value:Boolean):void {
			if (_simulated != __value) {
				_simulated = __value;
				debug("simulated is " + _simulated);
			}
		}

		public static function get verbose():Boolean {
			return _verbose;
		}
		public static function set verbose(__value:Boolean):void {
			if (_verbose != __value) {
				_verbose = __value;
				debug("verbose is " + _verbose);
			}
		}
	}
}
