package com.zehfernando.net.assets {

	/**
	 * @author Zeh
	 */
	public class AssetType {

		// Constants
		public static const CSS:String = "css";
		public static const XML:String = "xml";
		public static const JSON:String = "json";
		public static const IMAGE:String = "image";
		public static const BINARY:String = "binary";
		public static const SWF:String = "swf";
		public static const VIDEO:String = "video";

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		public static function getTypes(): Vector.<String> {
			var types:Vector.<String> = new Vector.<String>();
			types.push(AssetType.CSS);
			types.push(AssetType.XML);
			types.push(AssetType.JSON);
			types.push(AssetType.IMAGE);
			types.push(AssetType.BINARY);
			types.push(AssetType.SWF);
			types.push(AssetType.VIDEO);

			return types;
		}

		public static function getExtensions(__type:String): Vector.<String> {
			// TODO: use dictionaries/vectors of info classes/something that makes more sense

			var vv:Vector.<String> = new Vector.<String>();

			switch (__type) {
				case AssetType.CSS:
					vv.push("css");
					break;
				case AssetType.XML:
					vv.push("xml");
					vv.push("svg");
					break;
				case AssetType.JSON:
					vv.push("json");
					break;
				case AssetType.IMAGE:
					vv.push("jpg");
					vv.push("jpeg");
					vv.push("gif");
					vv.push("png");
					break;
				case AssetType.BINARY:
					vv.push("atf");
					break;
				case AssetType.SWF:
					vv.push("swf");
					break;
				case AssetType.VIDEO:
					vv.push("flv");
					vv.push("f4v");
					vv.push("mov");
					vv.push("mp4");
					break;
			}

			return vv;
		}

		public static function getFromURL(__url:String):String {
			// Based on the extension of an URL file, return the type
			// TODO: must test for querystrings!
			// TODO: must test for other URLs with dots on them!

			var lastDot:Number = 0;
			while (__url.indexOf(".", lastDot+1) > -1) {
				lastDot = __url.indexOf(".", lastDot+1);
			}
			__url = __url.substr(lastDot);

			var extSearch:RegExp = /\.([A-Za-z0-9]+)(\?*|)/i;
			var result:Object = extSearch.exec(__url);
			//trace ("search [" + __url + "] = " + result + " @ " + (Boolean(result) ? result.index : null));
			var extension:String;
			extension = Boolean(result) ? result[1] : "";

			var types:Vector.<String> = getTypes();
			var i:int;
			for (i = 0; i < types.length; i++) {
				if (getExtensions(types[i]).indexOf(extension) > -1) {
					return types[i];
				}
			}

			return "";
		}
	}
}
