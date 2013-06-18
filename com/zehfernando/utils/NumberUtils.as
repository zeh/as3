package com.zehfernando.utils {

	/**
	 * @author zeh
	 */
	public class NumberUtils {

		public static function formatNumber(__value:Number, __thousandsSeparator:String = ",", __decimalSeparator:String = ".", __decimalPlaces:Number = NaN):String {

			var nInt:Number = Math.floor(__value);
			var nDec:Number = __value - nInt;

			var sInt:String = nInt.toString(10);
			var sDec:String;

			if (!isNaN(__decimalPlaces)) {
				sDec = (Math.round(nDec * Math.pow(10, __decimalPlaces)) / Math.pow(10, __decimalPlaces)).toString(10).substr(2);
			} else {
				sDec = nDec == 0 ? "" : nDec.toString(10).substr(2);
			}

			var fInt:String = "";
			var i:Number;
			for (i = 0; i < sInt.length; i++) {
				fInt += sInt.substr(i, 1);
				if ((sInt.length - i - 1) % 3 == 0 && i != sInt.length - 1) fInt += __thousandsSeparator;
			}

			return fInt + (sDec.length > 0 ? __decimalSeparator + sDec : "");

		}
	}
}
