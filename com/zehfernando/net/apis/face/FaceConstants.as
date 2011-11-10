package com.zehfernando.net.apis.face {
	import flash.system.Security;
	/**
	 * @author zeh
	 */
	public class FaceConstants {
		
		// Constants
		public static const DOMAIN:String = "http://api.face.com";

		public static const SERVICE_FACES_DETECT:String = "/faces/detect.json";
		
		public static const PARAMETER_NAME_API_KEY:String = "api_key";
		public static const PARAMETER_NAME_API_SECRET:String = "api_secret";
		public static const PARAMETER_NAME_URLS:String = "urls";

		public static const PARAMETER_NAME_DETECTORS:String = "detectors";
		public static const PARAMETER_NAME_ATTRIBUTES:String = "attributes";
		public static const PARAMETER_NAME_FORMAT:String = "format";

		public static const PARAMETER_VALUE_FORMAT_JSON:String = "json";

		public static const PARAMETER_LIST_CONCATENATOR:String = ",";

		public static const PARAMETER_NAME_STATUS:String = "status";
		public static const STATUS_FAILURE:String = "failure";
		public static const PARAMETER_NAME_ERROR_MESSAGE:String = "error_message";

		// Initializations
		{
			Security.loadPolicyFile("http://api.face.com/crossdomain.xml");
			Security.loadPolicyFile("https://api.face.com/crossdomain.xml");
		}
	}
}