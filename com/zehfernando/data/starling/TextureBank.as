package com.zehfernando.data.starling {
	import starling.textures.Texture;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class TextureBank {

		// Properties
		private static var textures:Object = {};
		private static var length:int = 0;

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function get(__key:String):Texture {
			return has(__key) ? textures[__key] : null;
		}

		public static function put(__key:String, __texture:Texture):void {
			textures[__key] = __texture;
			length++;
		}

		public static function remove(__key:String):void {
			delete textures[__key];
			length--;
		}

		public static function has(__key:String):Boolean{
			return textures.hasOwnProperty(__key);
		}

		public static function clear():void {
			length = 0;
			textures = {};
		}
	}
}
