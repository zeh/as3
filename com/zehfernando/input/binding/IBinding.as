package com.zehfernando.input.binding {
	/**
	 * @author zeh fernando
	 */
	public interface IBinding {
		function matchesKeyboardKey(__keyCode:uint, __keyLocation:uint):Boolean;
		function matchesGamepadControl(__controlId:String, __gamepadIndex:uint):Boolean;
	}
}
