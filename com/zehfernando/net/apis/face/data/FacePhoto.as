package com.zehfernando.net.apis.face.data {
	/**
	 * @author zeh
	 */
	public class FacePhoto {
		
		// http://developers.face.com/docs/api/faces-detect/
		
		// Properties		
		public var url:String;
		public var pid:String;
		public var width:uint;
		public var height:uint;
		public var tags:Vector.<FaceTag>;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacePhoto() {
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------
		
		public static function fromJSONObject(o:Object): FacePhoto {
			if (!Boolean(o)) return null;

			var photo:FacePhoto = new FacePhoto();

			photo.url =										o["url"];
			photo.pid =										o["pid"];
			photo.width =									o["width"];
			photo.height =									o["height"];
			photo.tags =									Boolean(o["tags"]) ? FaceTag.fromJSONObjectArray(o["tags"]) : new Vector.<FaceTag>();
			
			return photo;
		}

		public static function fromJSONObjectArray(o:Array): Vector.<FacePhoto> {
			var photos:Vector.<FacePhoto> = new Vector.<FacePhoto>();

			if (!Boolean(o)) return photos;

			for (var i:int = 0; i < o.length; i++) {
				photos.push(FacePhoto.fromJSONObject(o[i]));
			}

			return photos;
		}
	}
}
