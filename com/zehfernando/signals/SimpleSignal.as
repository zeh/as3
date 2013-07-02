package com.zehfernando.signals {
	/**
	 * @author zeh fernando
	 */
	public class SimpleSignal {

		// Super-simple signals class inspired by Robert Penner's AS3Signals:
		// http://github.com/robertpenner/as3-signals

		// Properties
		private var functions:Vector.<Function>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function SimpleSignal() {
			functions = new Vector.<Function>();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function add(__function:Function):Boolean {
			if (functions.indexOf(__function) == -1) {
				functions.push(__function);
				return true;
			}
			return false;
		}

		public function remove(__function:Function):Boolean {
			var i:int = functions.indexOf(__function);
			if (i > -1) {
				functions.splice(i, 1);
				return true;
			}
			return false;
		}

		public function removeAll():Boolean {
			var cleared:Boolean = functions.length > 0;
			functions.length = 0;
			return cleared;
		}

		public function dispatch(...__args:Array):void {
			for (var i:int = 0; i < functions.length; i++) {
				functions[i].apply(undefined, __args);
			}
		}
	}
}
