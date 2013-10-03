package com.zehfernando.display.gestures {
	import com.zehfernando.display.abstracts.ResizableSprite;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * @author zeh fernando
	 */
	public class GestureRecorderSprite extends ResizableSprite {

		// Event enums
		public static const EVENT_GESTURE_COMPLETED:String = "onGestureCompleted";

		// Properties
		private var _isRecording:Boolean;
		private var _drawLines:Boolean;

		// Instances
		private var _points:Vector.<Point>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GestureRecorderSprite(__drawLines:Boolean) {
			super();

			_drawLines = __drawLines;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
		}

		override protected function redrawHeight():void {
		}

		private function startRecording():void {
			if (!_isRecording) {
				_isRecording = true;
				_points = new Vector.<Point>();

				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

				recordPoint();
			}
		}

		private function recordPoint():void {
			if (_isRecording) {
				_points.push(new Point(mouseX, mouseY));

				if (_drawLines) drawLines();
			}
		}

		private function endRecording():void {
			if (_isRecording) {
				_isRecording = false;

				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

				if (_drawLines) graphics.clear();

				dispatchEvent(new Event(EVENT_GESTURE_COMPLETED));
			}
		}

		private function drawLines():void {
			graphics.clear();
			graphics.lineStyle(2, 0xff0000);
			if (_points.length > 0) {
				graphics.moveTo(_points[0].x, _points[0].y);
				for (var i:int = 1; i < _points.length; i++) {
					graphics.lineTo(_points[i].x, _points[i].y);
				}
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onAddedToStage(__e:Event):void {
			super.onAddedToStage(__e);

			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		override protected function onRemovedFromStage(__e:Event):void {
			super.onRemovedFromStage(__e);

			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			endRecording();
		}

		protected function onMouseDown(__e:Event):void {
			startRecording();
		}

		protected function onMouseMove(__e:Event):void {
			recordPoint();
		}

		protected function onMouseUp(__e:Event):void {
			endRecording();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getLastGesture():Vector.<Point> {
			return _points;
		}

	}
}
