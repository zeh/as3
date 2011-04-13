package com.zehfernando.utils {

	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * @author zeh
	 */
	public class DelayedCalls {

		// Creates calls

		// Static properties
		protected static var calls:Vector.<DelayedCalls>;
		
		// Instances
		protected var timer:Timer;
		protected var callback:Function;
		protected var params:Array;
		protected var scope:Object;
		protected var reference:Object;
		
		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		{
			calls = new Vector.<DelayedCalls>();
		}

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function DelayedCalls(__time:Number, __callback:Function, __params:Array = null, __scope:Object = null, __reference:Object = null) {
			
			callback = __callback;
			params = Boolean(__params) ? __params : [];
			scope = __scope;
			reference = __reference;
			
			if (__time == 0) {
				execute();
				disposeData();
				return;
			}

			timer = new Timer(__time, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			timer.start();
			
			addToList(this);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function execute(): void {
			callback.apply(scope, params);
		}
		
		protected function disposeTimer(): void {
			if (Boolean(timer)) {
				timer.stop();
				timer = null;
			}
		}

		protected function disposeData(): void {
			callback = null;
			params = null;
			scope = null;
			reference = null;
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------
		
		protected static function addToList(__call:DelayedCalls): void {
			if (calls.indexOf(__call) == -1) {
				calls.push(__call);
			}
		}

		protected static function removeFromList(__call:DelayedCalls): void {
			var pos:int = calls.indexOf(__call);
			if (pos != -1) {
				calls.splice(pos, 1);
			}
		}

		
		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onTimerComplete(e:TimerEvent): void {
			execute();
			dispose();
		}
		
		public function dispose(): void {
			removeFromList(this);
			disposeTimer();
			disposeData();
		}

		// ================================================================================================================
		// PUBLIC STATIC INTERFACE ----------------------------------------------------------------------------------------
		
		public static function add(__time:Number, __callback:Function, __params:Array = null, __scope:Object = null, __reference:Object = null): DelayedCalls {
			// __time is in miliseconds
			return new DelayedCalls(__time, __callback, __params, __scope, __reference);
		}

		public static function removeByReference(__reference:Object): void {
			// Remove all delayed calls that use a specific object as a reference
			for (var i:int = 0; i < calls.length; i++) {
				if (calls[i].reference == __reference) {
					calls[i].dispose();
					i--;
				}
			}
		}

		public static function remove(__callback:Function): void {
			// Remove all delayed calls that try calling a specific function
			for (var i:int = 0; i < calls.length; i++) {
				if (calls[i].callback == __callback) {
					calls[i].dispose();
					i--;
				}
			}
		}
	}
}
