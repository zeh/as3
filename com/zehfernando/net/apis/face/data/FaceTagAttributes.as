package com.zehfernando.net.apis.face.data {
	import com.zehfernando.net.apis.face.enums.FaceAttributeType;
	/**
	 * @author zeh
	 */
	public class FaceTagAttributes {

		// Properties
		public var face:Boolean;
		public var faceConfidence:Number;		// 0-100
		public var gender:String;
		public var genderConfidence:Number;		// 0-100
		public var glasses:Boolean;
		public var glassesConfidence:Number;
		public var smiling:Boolean;
		public var smilingConfidence:Number;
		public var mood:String;
		public var moodConfidence:Number;
		public var lips:String;
		public var lipsConfidence:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FaceTagAttributes() {
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromJSONObject(o:Object): FaceTagAttributes {
			if (!Boolean(o)) return null;

			//log ("CONVERTING ===> " + JSON.encode(o));

			var attributes:FaceTagAttributes = new FaceTagAttributes();

			if (Boolean(o["gender"])) {
				attributes.gender = o["gender"]["value"];
				attributes.genderConfidence = o["gender"]["confidence"];
			}

			if (Boolean(o["face"])) {
				attributes.face = o["face"]["value"] == FaceAttributeType.TRUE;
				attributes.faceConfidence = o["face"]["confidence"];
			}

			if (Boolean(o["glasses"])) {
				attributes.glasses = o["glasses"]["value"] == FaceAttributeType.TRUE;
				attributes.glassesConfidence = o["glasses"]["confidence"];
			}

			if (Boolean(o["smiling"])) {
				attributes.smiling = o["smiling"]["value"] == FaceAttributeType.TRUE;
				attributes.smilingConfidence = o["smiling"]["confidence"];
			}

			if (Boolean(o["mood"])) {
				attributes.mood = o["mood"]["value"];
				attributes.moodConfidence = o["mood"]["confidence"];
			}

			if (Boolean(o["lips"])) {
				attributes.lips = o["lips"]["value"];
				attributes.lipsConfidence = o["lips"]["confidence"];
			}

			return attributes;
		}
	}
}
