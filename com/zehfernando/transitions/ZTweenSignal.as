package com.zehfernando.transitions {

	/**
	 * @author zeh
	 */
	public class ZTweenSignal {
		
		// Super-simple signals class inspired by Robert Penner's AS3Signals:
		// http://github.com/robertpenner/as3-signals
		
		// Properties
		protected var functions:Vector.<Function>;
		protected var params:Vector.<Array>;
		
		// Properties for speed
		protected var i:int;
		protected var l:int;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ZTweenSignal() {
			functions = new Vector.<Function>();
			params = new Vector.<Array>();
			l = 0;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function add(__function:Function, __params:Array = null): Boolean {
			if (functions.indexOf(__function) == -1) {
				functions.push(__function);
				params.push(__params);
				l = functions.length;
				return true;
			}
			return false;
		}

		public function remove(__function:Function, __params:Array = null): Boolean {
			if (functions.indexOf(__function) == -1) {
				functions.splice(functions.indexOf(__function), 1);
				params.push(__params);
				l = functions.length;
				return true;
			}
			return false;
		}
		
		public function dispatch(): void {
			for (i = 0; i < l; i++) {
				functions[i].apply(undefined, params[i]);
				//functions[i]();
			}
		}
	}
}
