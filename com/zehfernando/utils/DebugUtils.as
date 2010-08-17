package com.zehfernando.utils {
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * @author zeh
	 */
	public class DebugUtils {
		
		// Properties
		//protected static var draggableObjects:Array;
		protected static var dragMoveFunctions:Dictionary;
		protected static var dragUpFunctions:Dictionary;
		
		protected static var draggingObject:Sprite;
		protected static var draggingObjectOffset:Point;

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
		
		{
			dragMoveFunctions = new Dictionary(true);
			dragUpFunctions = new Dictionary(true);
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected static function onMouseDownDraggableObject(e:MouseEvent): void {
			// Start dragging an object
			var sp:Sprite = e.target as Sprite;
			draggingObject = sp;
			draggingObjectOffset = new Point(sp.parent.mouseX - sp.x, sp.parent.mouseY - sp.y);
			
			sp.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveDraggableObject, false, 0, true);
			sp.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpDraggableObject, false, 0, true);

		}

		protected static function onMouseMoveDraggableObject(e:MouseEvent): void {
			draggingObject.x = draggingObject.parent.mouseX - draggingObjectOffset.x;
			draggingObject.y = draggingObject.parent.mouseY - draggingObjectOffset.y;
			if (dragMoveFunctions[draggingObject]) dragMoveFunctions[draggingObject]();
		}

		protected static function onMouseUpDraggableObject(e:MouseEvent): void {
			draggingObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveDraggableObject);
			draggingObject.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpDraggableObject);
			
			if (dragUpFunctions[draggingObject]) dragUpFunctions[draggingObject]();
			
			draggingObject = null;
			draggingObjectOffset = null;
		}

		protected static function onClickStageTrace(e:MouseEvent): void {
			var st:Stage = e.currentTarget as Stage;
			var objects:Array = st.getObjectsUnderPoint(new Point(st.mouseX, st.mouseY));
			
			objects = [objects[0]];
			while (objects[0].parent) objects.unshift(objects[0].parent);
			trace(objects.join(" / "));
			
			var mouseStates:Array = [];
			for (var i:int = 0; i <  objects.length; i++) {
				mouseStates.push((objects[i] as Object).hasOwnProperty("mouseEnabled") ? objects[i]["mouseEnabled"] : "-",
								(objects[i] as Object).hasOwnProperty("mouseChildren") ? objects[i]["mouseChildren"] : "-");
			}
			trace (mouseStates.join("/"));
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------
		

		public static function makeDraggable(__sprite:Sprite, __onMouseMove:Function = null, __onMouseUp:Function = null): void {
			// Makes an object draggable
			__sprite.buttonMode = true;
			__sprite.mouseEnabled = true;
			__sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownDraggableObject, false, 0, true);
			
			if (Boolean(__onMouseMove)) dragMoveFunctions[__sprite] = __onMouseMove;
			if (Boolean(__onMouseUp)) dragUpFunctions[__sprite] = __onMouseUp;
			
		}

		public static function traceEveryMouseClick(__stage:Stage):void {
			__stage.addEventListener(MouseEvent.CLICK, onClickStageTrace);
		}
	}
}
