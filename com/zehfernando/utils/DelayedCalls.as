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

		// Properties
		private var isPaused:Boolean;

		// Instances
		private var timer:Timer;
		private var callback:Function;
		private var params:Array;
		private var scope:Object;
		private var reference:Object;
		private var timeStarted:uint;

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		{
			calls = new Vector.<DelayedCalls>();
		}

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function DelayedCalls(__timeMS:uint, __callback:Function, __params:Array = null, __scope:Object = null, __reference:Object = null) {

			callback = __callback;
			params = Boolean(__params) ? __params : [];
			scope = __scope;
			reference = __reference;
			isPaused = false;
			timeStarted = getTimerUInt();

			if (__timeMS == 0) {
				execute();
				disposeData();
				return;
			}

			timer = new Timer(__timeMS, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			timer.start();

			addToList(this);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function execute():void {
			callback.apply(scope, params);
		}

		protected function disposeTimer():void {
			if (Boolean(timer)) {
				timer.stop();
				timer = null;
			}
		}

		protected function disposeData():void {
			callback = null;
			params = null;
			scope = null;
			reference = null;
			isPaused = false;
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		protected static function addToList(__call:DelayedCalls):void {
			if (calls.indexOf(__call) == -1) {
				calls.push(__call);
			}
		}

		protected static function removeFromList(__call:DelayedCalls):void {
			var pos:int = calls.indexOf(__call);
			if (pos != -1) {
				calls.splice(pos, 1);
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onTimerComplete(e:TimerEvent):void {
			execute();
			dispose();
		}

		public function pause():void {
			if (!isPaused && timer != null) {
				isPaused = true;
				timer.stop();
				timer.delay = getTimerUInt() - timeStarted;
				timer.reset();
			}
		}

		public function resume():void {
			if (isPaused && timer != null) {
				isPaused = false;
				timeStarted = getTimerUInt();
				timer.start();
			}
		}

		public function dispose():void {
			removeFromList(this);
			disposeTimer();
			disposeData();
		}

		// ================================================================================================================
		// PUBLIC STATIC INTERFACE ----------------------------------------------------------------------------------------

		public static function add(__timeMS:uint, __callback:Function, __params:Array = null, __scope:Object = null, __reference:Object = null):DelayedCalls {
			return new DelayedCalls(__timeMS, __callback, __params, __scope, __reference);
		}

		public static function removeByReference(__reference:Object):void {
			// Remove all delayed calls that use a specific object as a reference
			for (var i:int = 0; i < calls.length; i++) {
				if (calls[i].reference == __reference) {
					calls[i].dispose();
					i--;
				}
			}
		}

		public static function remove(__callback:Function):void {
			// Remove all delayed calls that try calling a specific function
			for (var i:int = 0; i < calls.length; i++) {
				if (calls[i].callback == __callback) {
					calls[i].dispose();
					i--;
				}
			}
		}

		public static function getNumCalls():uint {
			return calls.length;
		}
	}
}
