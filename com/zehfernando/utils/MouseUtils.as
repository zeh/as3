package com.zehfernando.utils {
	import org.ffnnkk.display.common.SkinnedBackground;

	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class MouseUtils {

		public static const CURSOR_HAND:String = "mouse_cursor_hand";	// flash.ui.MouseCursor.HAND
		public static const CURSOR_MOVE:String = "mouse_cursor_move";
		public static const CURSOR_RESIZE_NWSE:String = "mouse_cursor_resize_nwse";
		public static const CURSOR_RESIZE_NS:String = "mouse_cursor_resize_ns";
		public static const CURSOR_RESIZE_WE:String = "mouse_cursor_resize_we";

		protected static var isInited:Boolean;

		protected static var stage:Stage;

		protected static var hasSpecialCursor:Boolean;

		protected static var currentCursor:String;
		protected static var cursorContainer:SkinnedBackground;

		// ================================================================================================================
		// INITIALIZATION functions ---------------------------------------------------------------------------------------

		public static function init(__stage:Stage): void {
			if (!isInited) {
				stage = __stage;
				removeSpecialCursor();
				isInited = true;
			}
		}


		// ================================================================================================================
		// PUBLIC functions -----------------------------------------------------------------------------------------------

		public static function setSpecialCursor(__type:String = null): void {
			if (__type == currentCursor) return;

			removeSpecialCursor();
			if (Boolean(__type)) {

				if (__type == CURSOR_HAND) {
					Mouse.cursor = MouseCursor.HAND;
				} else {
					// Normal bitmaps
					cursorContainer = new SkinnedBackground();
					stage.addChild(cursorContainer);
					cursorContainer.mouseChildren = cursorContainer.mouseEnabled = false;
					cursorContainer.setSprite(__type);
					cursorContainer.width = cursorContainer.originalWidth;
					cursorContainer.height = cursorContainer.originalHeight;
					updatePosition();

					Mouse.hide();
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveStage);

					hasSpecialCursor = true;
				}

				currentCursor = __type;
			}
		}

		public static function removeSpecialCursor(): void {
			if (hasSpecialCursor) {
				stage.removeChild(cursorContainer);
				cursorContainer = null;

				Mouse.show();
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveStage);

				hasSpecialCursor = false;
			}

			Mouse.cursor = MouseCursor.AUTO;

			currentCursor = null;

		}


		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected static function updatePosition(): void {
			cursorContainer.x = stage.mouseX - cursorContainer.handleX;
			cursorContainer.y = stage.mouseY - cursorContainer.handleY;
		}

		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		protected static function onMouseMoveStage(e:MouseEvent): void {
			updatePosition();
			e.updateAfterEvent();
		}

	}
}
