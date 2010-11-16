package com.zehfernando.display.debug {
	import flash.text.TextFormatAlign;
	import com.zehfernando.display.components.TextSpriteAlign;
	import com.zehfernando.display.components.TextSprite;

	/**
	 * @author zeh
	 */
	public class QuickText extends TextSprite {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function QuickText(__text:String, __size:Number = 10, __color:Number = 0x000000, __x:Number = 0, __y:Number = 0, __width:Number = 70) {
			super("_sans", __size, __color);
			textField.embedFonts = false;
			//textField.border = true;
			//textField.borderColor = 0xffffff;
			
			x = __x;
			y = __y;
			width = __width;
			
			align = TextFormatAlign.LEFT;
			blockAlignHorizontal = TextSpriteAlign.LEFT;

			text = __text;
			
			textField.x = 0;// This shouldn't be needed...
		}
	}
}
