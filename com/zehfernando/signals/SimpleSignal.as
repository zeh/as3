package com.zehfernando.signals {
	/**
	 * @author zeh fernando
	 */
	public class SimpleSignal {

		// Super-simple signals class inspired by Robert Penner's AS3Signals:
		// http://github.com/robertpenner/as3-signals

		// Properties
		private var functions:Vector.<Function>;
		private var functionsDuplicate:Vector.<Function>;			// For dispatching

		private var ifd:int;										// i for dispatching (to limit garbage collection)
		private var ifr:int;										// i for removal (to limit garbage collection)

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
			ifr = functions.indexOf(__function);
			if (ifr > -1) {
				functions.splice(ifr, 1);
				return true;
			}
			return false;
		}

		public function removeAll():Boolean {
			if (functions.length > 0) {
				functions.length = 0;
				return true;
			}
			return false;
		}

		public function dispatch(...__args:Array):void {
			functionsDuplicate = functions.concat();
			functionsDuplicate.fixed = true;
			for (ifd = 0; ifd < functionsDuplicate.length; ifd++) {
				functionsDuplicate[ifd].apply(undefined, __args);
			}
			functionsDuplicate = null;
		}
	}
}
