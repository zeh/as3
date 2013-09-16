package com.zehfernando.utils {
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class RenderUtils {

		// Properties
		protected static var functionsToCall:Vector.<Function> = new Vector.<Function>();

		// Create functions that are called prior to rendering
		protected static var isQueued:Boolean;

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected static function invalidate():void {
			AppUtils.getStage().invalidate();
		}

		protected static function queue():void {
			if (!isQueued) {
				AppUtils.getStage().addEventListener(Event.RENDER, onRenderStage);
				isQueued = true;
			}
		}

		protected static function executeQueue():void {
			unQueue();

//			for (var i:int = 0; i < functionsToCall.length; i++) {
//				functionsToCall.unshift[i]();
//			}
			while (functionsToCall.length > 0) {
				functionsToCall.shift()();
			}

			functionsToCall = new Vector.<Function>();
		}

		protected static function unQueue():void {
			if (isQueued) {
				AppUtils.getStage().removeEventListener(Event.RENDER, onRenderStage);
				isQueued = false;
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected static function onRenderStage(e:Event):void {
			executeQueue();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function addFunction(__function:Function):void {
//			__function();
//			return;
			if (functionsToCall.indexOf(__function) == -1) {
				// Doesn't exist, so adds to the stack
				functionsToCall.push(__function);
			} else {
				// Exists, so moves to the end of the list
				functionsToCall.splice(functionsToCall.indexOf(__function), 1);
				functionsToCall.push(__function);
			}

			queue();
			invalidate();
		}
	}
}
