package com.zehfernando.system {
	import starling.textures.TextureSmoothing;

	import com.zehfernando.utils.console.info;

	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DTextureFormat;
	/**
	 * @author zeh fernando
	 */
	public class PlatformProfile {

		// Arbitrary information about the platform, coming from external data (normally from a JSON file)

		// Properties
		public var id:String;					// E.g., "ouya" or "desktop" or "desktop-debug"
		public var densityScale:Number;			// Density scale to scale everything by (default 1)
		public var fontScale:Number;			// Font scale to scale everything by (default 1)
		public var targetWidth:int;				// Expected width
		public var targetHeight:int;			// Expected height
		public var showMouse:Boolean;			// Whether the mouse is shown or not
		public var antiAliasLevel:int;			// Anti-alias level for texture/polygon edges in starling; 0 (none) to (16) maximum. Default is 0
		public var textureSmoothing:String;		// Texture smoothing; [none|bilinear|trilinear]. Default is bilinear. None is nearest neighbor
		public var geometryFormat:String;		// Static geometry format (Context3DTextureFormat); [bgra|compressed|compressedAlpha|bgrPacked565|bgraPacked4444]. Default is bgra
		public var geometryTextureSize:int;		// Ideal size for geometry chunks, default 512
		public var maximumTextureSize:int;		// Maximum texture dimensions. Default 2048
		public var forceFullscreen:Boolean;		// If true, never use "window" mode
		public var showStatsSimple:Boolean;		// If true, shows starling statistics
		public var showStatsComplex:Boolean;	// If true, shows my statistics
		public var context3DProfile:String;		// Context3DProfile. [baseline|baselineConstrained|baselineExtended]. Default is baselineConstrained. extended increases maximum texture size to 4096.


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function PlatformProfile() {
			id = "";
			densityScale = 1;
			fontScale = 1;
			targetWidth = 0;
			targetHeight = 0;
			showMouse = true;
			antiAliasLevel = 0;
			textureSmoothing = TextureSmoothing.BILINEAR;
			geometryFormat = Context3DTextureFormat.BGRA;
			geometryTextureSize = 512;
			maximumTextureSize = 2048;
			forceFullscreen = false;
			context3DProfile = Context3DProfile.BASELINE_CONSTRAINED;
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function get(__JSONObject:Object, __platformId:String):PlatformProfile {
			var profile:PlatformProfile = new PlatformProfile();

			// Dump everything from the profile into this object
			var loadedProperties:Vector.<String> = new Vector.<String>();

			for each (var obj:Object in __JSONObject) {
				if (obj["id"] == __platformId) {
					for (var iis:String in obj) {
						if (profile.hasOwnProperty(iis)) {
							loadedProperties.push(iis);
							profile[iis] = obj[iis];
						}
					}
					break;
				}
			}

			info("Using profile [" + __platformId + "] with the following dumped properties: [" + loadedProperties.join(",") + "]");

			return profile;
		}

		public function get stackedFontScale():Number {
			return fontScale * densityScale;
		}
	}
}
