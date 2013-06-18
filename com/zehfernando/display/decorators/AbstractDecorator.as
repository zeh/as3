package com.zehfernando.display.decorators {
	import flash.display.DisplayObject;

	/**
	 * @author zeh
	 */
	public class AbstractDecorator {

		// Properties
		protected var _target:DisplayObject;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AbstractDecorator(__target:DisplayObject) {
			_target = __target;
			apply();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function apply():void {
			throw new Error("This must be overridden.");
		}

	}
}