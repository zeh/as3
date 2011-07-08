package com.zehfernando.utils {

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
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
			var sp:Sprite = e.currentTarget as Sprite;
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
			while (objects[0]["parent"]) objects.unshift(objects[0]["parent"]);
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
		
		public static function getCurrentCallStack(): Vector.<Vector.<String>> {
			
			if (!Capabilities.isDebugger) {
				// It's not the debug player, so returns nothing
				var tt:Vector.<Vector.<String>> = new Vector.<Vector.<String>>();
				var ll:Vector.<String> = new Vector.<String>();
				ll.push("?");
				ll.push("?");
				ll.push("?");
				ll.push("?");
				tt.push(ll);
				tt.push(ll);
				tt.push(ll);
				tt.push(ll);
				return tt;
			}

			var stackTrace:Array = new Error().getStackTrace().split("\n");
			var cStack:String;
			
			var cPackage:String;
			var cClass:String;
			var cFunction:String;
			var cFullClass:String;
			
			var cIsStatic:Boolean;			// Static class method: "com.zehfernando.utils::Log$/echo"
			var cIsConstructor:Boolean;		// Constructor call: "com.coachella.display::Main"
			var cIsFunction:Boolean;		// Anonymous function call: "Function/<anonymous>"
			
			var call:Vector.<String>;
			
			var calls:Vector.<Vector.<String>> = new Vector.<Vector.<String>>();
			
			for (var i:int = 2; i < stackTrace.length; i++) {
				cStack = stackTrace[i];
				cStack = cStack.substr(4, cStack.indexOf("(") - 4);

				cFullClass = cStack.split("/")[0];
				cFunction = cStack.split("/")[1];
				
				// Is a global function?
				cIsFunction = cFullClass == "Function";
				
				if (cIsFunction) {
					cPackage = "";
					cClass = "(Global)";
				} else {
					cPackage = cFullClass.split("::")[0];
					cClass = cFullClass.split("::")[1];
				}

				// Static calls?
				cIsStatic = false;
				if (Boolean(cClass) && cClass.substr(-1, 1) == "$") {
					cIsStatic = true;
					cClass = cClass.substr(0, cClass.length - 1);
				}
				
				// Constructor calls?
				cIsConstructor = false;
				if (!Boolean(cFunction)) {
					cIsConstructor = true;
					//cFunction = "[constructor]";
				}
				
				call = new Vector.<String>();
				
				call.push(cPackage);
				call.push(cClass);
				
				if (cIsStatic) cFunction = "(s)" + cFunction;
				
				if (!cIsConstructor) {
					call.push(cFunction);
				} else {
					call.push(cClass);
				}
				
				//trace ("--> " + call.join("--"));
				
				calls.push(call);

			}
			
			return calls;
		}
	}
}
