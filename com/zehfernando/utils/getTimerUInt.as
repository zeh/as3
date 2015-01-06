package com.zehfernando.utils {
	import flash.utils.getTimer;
	/**
	 * @author zeh at zehfernando.com
	 */

	// A safe getTimer() - runs for ~1192 hours instead of ~596
	public function getTimerUInt():uint {
		var v:int = getTimer();
		return v < 0 ? int.MAX_VALUE + 1 + v - int.MIN_VALUE : v;
	}
}
