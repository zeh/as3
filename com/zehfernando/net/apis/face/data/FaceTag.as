package com.zehfernando.net.apis.face.data {
	import flash.geom.Point;
	/**
	 * @author zeh
	 */
	public class FaceTag {
		
		// http://developers.face.com/docs/api/faces-detect/
		
		// Properties		
		public var tid:String;
		public var threshold:uint;
		public var uids:Vector.<String>;
		public var label:String;
		public var confirmed:Boolean;
		public var manual:Boolean;
		public var width:Number;
		public var height:Number;
		public var center:Point;
		public var eyeLeft:Point;
		public var eyeRight:Point;
		public var mouthLeft:Point;
		public var mouthCenter:Point;
		public var mouthRight:Point;
		public var nose:Point;
		public var earLeft:Point;
		public var earRight:Point;
		public var chin:Point;
		public var yaw:Number;
		public var roll:Number;
		public var pitch:Number;
		public var attributes:FaceTagAttributes;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FaceTag() {
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------
		
		public static function fromJSONObject(o:Object): FaceTag {
			if (!Boolean(o)) return null;

			var tag:FaceTag = new FaceTag();
			
			tag.tid =			o["tid"];
			tag.threshold =		o["threshold"];
			//tag.uid =		o["threshold"];
			tag.label =			o["label"];
			tag.confirmed = 	o["confirmed"]; // TODO: confirm that booleans are being properly parsed
			tag.manual =	 	o["manual"]; // TODO: confirm that booleans are being properly parsed
			tag.width =			o["width"];
			tag.height =		o["height"];
			if (Boolean(o["center"]))		tag.center =		new Point(o["center"]["x"],			o["center"]["y"]);
			if (Boolean(o["eye_left"]))		tag.eyeLeft =		new Point(o["eye_left"]["x"],		o["eye_left"]["y"]);
			if (Boolean(o["eye_right"]))	tag.eyeRight =		new Point(o["eye_right"]["x"],		o["eye_right"]["y"]);
			if (Boolean(o["mouth_left"]))	tag.mouthLeft =		new Point(o["mouth_left"]["x"],		o["mouth_left"]["y"]);
			if (Boolean(o["mouth_center"]))	tag.mouthCenter =	new Point(o["mouth_center"]["x"],	o["mouth_center"]["y"]);
			if (Boolean(o["mouth_right"]))	tag.mouthRight =	new Point(o["mouth_right"]["x"],	o["mouth_right"]["y"]);
			if (Boolean(o["ear_left"]))		tag.earLeft =		new Point(o["ear_left"]["x"],		o["ear_left"]["y"]);
			if (Boolean(o["ear_right"]))	tag.earRight =		new Point(o["ear_right"]["x"],		o["ear_right"]["y"]);
			if (Boolean(o["chin"]))			tag.chin =			new Point(o["chin"]["x"],			o["chin"]["y"]);
			
			tag.yaw =			o["yaw"];
			tag.roll =			o["roll"];
			tag.pitch =			o["pitch"];
			
			tag.attributes =	FaceTagAttributes.fromJSONObject(o["attributes"]);

			return tag;
		}

		public static function fromJSONObjectArray(o:Array): Vector.<FaceTag> {
			var tags:Vector.<FaceTag> = new Vector.<FaceTag>();

			if (!Boolean(o)) return tags;

			for (var i:int = 0; i < o.length; i++) {
				tags.push(FaceTag.fromJSONObject(o[i]));
			}

			return tags;
		}
	}
}
