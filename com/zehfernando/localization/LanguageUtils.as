package com.zehfernando.localization {
	import com.zehfernando.utils.StringUtils;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class LanguageUtils {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function LanguageUtils() {
			throw new Error("Instantiation not allowed");
		}


		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		public static function filterNodes(__xmlList:XMLList, __language:String = null, __correctLanguageFirst:Boolean = false): XMLList {
			// Filters a XMLList by valid nodes only (with corresponding "language" attribute, or none language at all) 
			var _language:String = Boolean(__language) ? __language : StringList.getLanguage();
			
			var newList:XMLList = new XMLList();
			var requestLanguages:Array = _language.toLowerCase().split(";"); // Accepted languages
			
			var itemLanguages:String;
			
			var i:Number, j:Number;

			for (j = 0; j < requestLanguages.length; j++) {
				for (i = 0; i < __xmlList.length(); i++) {
					itemLanguages = __xmlList[i].@language;
					if (itemLanguages.split(";").indexOf(requestLanguages[j]) > -1 || (!Boolean(itemLanguages) && !__correctLanguageFirst)) {
						newList[newList.length()] = __xmlList[i]; 
						//newList.appendChild(__xmlList[i]);
						//trace ("ok");
						break;
					}
				}
			}
			
			if (__correctLanguageFirst) {
				for (i = 0; i < __xmlList.length(); i++) {
					itemLanguages = __xmlList[i].@language;
					if (!Boolean(itemLanguages)) {
						newList[newList.length()] = __xmlList[i]; 
						break;
					}
				}
			}

			//trace ("BEFORE: ["+__xmlList+"]")
			//trace ("AFTER: ["+newList+"]")
			return newList;
		}
		
		public static function getNodeString(__xmlList:XMLList, __language:String = null, __filterHashtags:Boolean = true): String {
			var str:String = filterNodes(__xmlList, __language, true)[0];
			if (__filterHashtags) str = StringList.filter(str, __language);
			str = StringUtils.stripDoubleCRLF(str);
			return str;
		}
	}
}
