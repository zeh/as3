package com.zehfernando.utils.tracking {
	import com.zehfernando.utils.AppUtils;

	import flash.external.ExternalInterface;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class WTUtils {

		// Webtrends tracking

		// Constants
		protected static const WT_PARAMETER_URI:String = "DCS.dcsuri";
		protected static const WT_PARAMETER_TITLE:String = "WT.ti";

		protected static const WT_PARAMETER_RIA_APPNAME:String = "WT.ria_a";		// Application name
		//protected static const WT_PARAMETER_RIA_URI:String = "DCS.dcsuri";
		protected static const WT_PARAMETER_RIA_CONTENT:String = "WT.ria_c";		// Content name
		protected static const WT_PARAMETER_RIA_FEATURE:String = "WT.ria_f";		// Feature name
		protected static const WT_PARAMETER_RIA_EVENT:String = "WT.ria_ev";		// Event name
		protected static const WT_PARAMETER_RIA_GROUP:String = "WT.cg_n";		// Group name
		protected static const WT_PARAMETER_RIA_SUBGROUP:String = "WT.cg_s";		// Subgroup name

		public static const WT_PARAMETER_OPTIONAL_SCENARIO_NAME:String = "WT.si_n";	// Scenario name
		public static const WT_PARAMETER_OPTIONAL_SCENARIO_STEP:String = "WT.si_x";	// Scenario step

		protected static const WT_ADDITIONAL_PARAMETERS:Array = ["WT.dl", "6"]; // From WebTrends_Technical_Solution_Design.doc: "WT.dl=6 – ALWAYS passed to indicate that this was a RIA server call (event). This is critical to insure differentiation between RIA type events and other events."

		public static const FOLDER_SEPARATOR:String = "/";
		public static const TITLE_SEPARATOR:String = " - ";
		public static const SUBGROUP_SEPARATOR:String = ";";
		public static const SCENARIO_SEPARATOR:String = ";";

		// Properties
		protected static var inited:Boolean;
		protected static var testMode:Boolean;
		protected static var keysToReset:Array;					// Additional params that need to be sent again on the next call so they're reset
		protected static var appName: String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function WTUtils() {
			throw new Error("You cannot initialize this class");
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		public static function init(__appName:String, __testMode:Boolean = false):void {

			appName = __appName;

			if (!inited) {
				inited = true;
				if (!AppUtils.isDebugSWF() && !__testMode) {
					trace ("WebTracking :: init :: LIVE mode :: ExternalInterface.available = " + ExternalInterface.available);
					testMode = false;
				} else {
					trace ("WebTracking :: init :: TEST mode");
					testMode = true;
				}
				keysToReset = [];
			}
		}

		public static function trackPageView(__uri:String, __title:String, __feature:String, __event:String, __group:String, __subGroup:String, __extraParameters:Array = null):void {
			if (!inited) return;

			if (__title == null) __title = __uri;
			if (!Boolean(__extraParameters)) __extraParameters = [];

			var params:Array = ["dcsMultiTrack"];
			params = params.concat(WT_PARAMETER_URI, __uri, WT_PARAMETER_TITLE, __title);
			params = params.concat(WT_PARAMETER_RIA_APPNAME, appName);
			params = params.concat(WT_PARAMETER_RIA_CONTENT, __title);
			params = params.concat(WT_PARAMETER_RIA_FEATURE, __feature);
			params = params.concat(WT_PARAMETER_RIA_EVENT, __event);
			//if (__group.length > 0)		params = params.concat(WT_PARAMETER_RIA_GROUP, __group);
			//if (__subGroup.length > 0)	params = params.concat(WT_PARAMETER_RIA_SUBGROUP, __subGroup);
			params = params.concat(WT_ADDITIONAL_PARAMETERS);

			if (__group.length > 0)		__extraParameters = __extraParameters.concat(WT_PARAMETER_RIA_GROUP, __group);
			if (__subGroup.length > 0)	__extraParameters = __extraParameters.concat(WT_PARAMETER_RIA_SUBGROUP, __subGroup);

			// Add keys that need to be reset to __extraParameters if they're not there already
			// This is not very elegant
			var i:Number;
			var pos:Number;
			for (i = 0; i < __extraParameters.length; i += 2) {
				pos = keysToReset.indexOf(__extraParameters[i]);
				if (pos > -1) {
					// Key already on the list, remove from reset list
					keysToReset.splice(pos, 1);
				}
			}

			// Add extra parameters to the list
			var paramReset:Array = [];
			for (i = 0; i < keysToReset.length; i++) {
				paramReset.push(keysToReset[i], "");
			}

			// Add params to be reset to the list the next time
			keysToReset = [];
			for (i = 0; i < __extraParameters.length; i += 2) {
				keysToReset.push(__extraParameters[i]);
			}

			params = params.concat(__extraParameters);
			params = params.concat(paramReset);

			ExternalInterface.call.apply(undefined, params);
			//ExternalInterface.call("dcsMultiTrack",  WT_PARAMETER_URI, __uri, WT_PARAMETER_TITLE, __title);

			// Safe length for contents inside parenthesis = 1813
			// example: "dcsMultiTrack('DCS.dcsuri','test')" = 19chars

			trace ("WebTracking :: trackPageView :: " + params[0]);
			for (i = 1; i < params.length; i += 2) {
				trace("  + " + params[i] + " = [" + params[i+1] + "]");
			}
		}
	}
}
