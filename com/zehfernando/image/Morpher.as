package com.zehfernando.image {

	import com.zehfernando.utils.MathUtils;

	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class Morpher {

		// Properties
		protected var needsRedraw:Boolean;					// Something changed, need to re-render
		protected var needsBitmap:Boolean;					// Something changed on the target bitmap, need to re-create

		protected var _width:int;
		protected var _height:int;

		protected var _phase:Number;

		// Instances
		protected var imageA:MorphImageData;
		protected var imageB:MorphImageData;
		protected var triangles:Vector.<TrianglePoints>;

		protected var bitmap:BitmapData;					// Final image
		protected var bitmapCompositeA:BitmapData;			// Composite: image A with dimensions of final bitmap, with vertices moved
		protected var bitmapCompositeB:BitmapData;			// Composite: image B with dimensions of final bitmap, with vertices moved

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Morpher(__width:Number = 100, __height:Number = 100) {
			_width = __width;
			_height = __height;

			_phase = 0.5;

			imageA = new MorphImageData();
			imageB = new MorphImageData();

			needsRedraw = true;
			needsBitmap = true;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function requestRedraw(__needsNewBitmap:Boolean = false):void {
			needsRedraw = true;
			if (__needsNewBitmap) needsBitmap = true;
		}

		protected function removeBitmap():void {
			if (Boolean(bitmap)) {
				bitmap.dispose();
				bitmap = null;

				bitmapCompositeA.dispose();
				bitmapCompositeA = null;

				bitmapCompositeB.dispose();
				bitmapCompositeB = null;

				needsBitmap = true;
			}
		}

		protected function createDistordtedImage(__target:BitmapData, __image:MorphImageData, __alternateImage:MorphImageData, __f:Number):void {
			var i:int;

			// Create transformed image A
			__target.fillRect(__target.rect, 0x000000);

			var vertices:Vector.<Number> = new Vector.<Number>();
			var pw:Number = MathUtils.map(__f, 0, 1, __image.bitmap.width, __alternateImage.bitmap.width);
			var ph:Number = MathUtils.map(__f, 0, 1, __image.bitmap.height, __alternateImage.bitmap.height);
			for (i = 0; i < __image.vertices.length; i++) {
				vertices.push((MathUtils.map(__f, 0, 1, __image.vertices[i].x, __alternateImage.vertices[i].x) / pw) * bitmap.width);
				vertices.push((MathUtils.map(__f, 0, 1, __image.vertices[i].y, __alternateImage.vertices[i].y) / ph) * bitmap.height);
			}

			var indices:Vector.<int> = new Vector.<int>();
			for (i = 0; i < triangles.length; i++) {
				indices.push(triangles[i].p1);
				indices.push(triangles[i].p2);
				indices.push(triangles[i].p3);
			}

			var uvtData:Vector.<Number> = new Vector.<Number>();
			for (i = 0; i < __image.vertices.length; i++) {
				uvtData.push(__image.vertices[i].x / __image.bitmap.width);
				uvtData.push(__image.vertices[i].y / __image.bitmap.height);
			}

			var spr:Sprite = new Sprite();
			spr.graphics.beginBitmapFill(__image.bitmap, null, false, true);
			spr.graphics.drawTriangles(vertices, indices, uvtData);
			spr.graphics.endFill();

//			for (i = 0; i < indices.length; i+= 3) {
//				spr.graphics.beginFill(Math.random() * 0xffffff, 0.5);
//				spr.graphics.moveTo(vertices[indices[i+0] * 2], vertices[indices[i+0] * 2 + 1]);
//				spr.graphics.lineTo(vertices[indices[i+1] * 2], vertices[indices[i+1] * 2 + 1]);
//				spr.graphics.lineTo(vertices[indices[i+2] * 2], vertices[indices[i+2] * 2 + 1]);
//				spr.graphics.endFill();
//			}
//			spr.graphics.lineStyle(0x000000, 1);
//			for (i = 0; i < indices.length; i+= 3) {
//				spr.graphics.moveTo(vertices[indices[i+0] * 2], vertices[indices[i+0] * 2 + 1]);
//				spr.graphics.lineTo(vertices[indices[i+1] * 2], vertices[indices[i+1] * 2 + 1]);
//				spr.graphics.lineTo(vertices[indices[i+2] * 2], vertices[indices[i+2] * 2 + 1]);
//			}

			__target.draw(spr);
		}

		protected function redrawMorphedImage():void {
			// Redraws the morphed image

			// Creates updated distorted images for compositing
			createDistordtedImage(bitmapCompositeA, imageA, imageB, _phase);
			createDistordtedImage(bitmapCompositeB, imageB, imageA, 1-_phase);

			// Creates composite
			var mtx:Matrix;

			// All black
			bitmap.fillRect(bitmap.rect, 0x000000);

			// First image
			mtx = new Matrix();
			mtx.scale(bitmap.width / bitmapCompositeA.width, bitmap.height / bitmapCompositeA.height);
			bitmap.draw(bitmapCompositeA, mtx, new ColorTransform(1, 1, 1, 1-(_phase * _phase)), BlendMode.LIGHTEN, null, true);
			//bitmap.draw(bitmapCompositeA, mtx, null, null, null, true);

			// Right
			mtx = new Matrix();
			mtx.scale(bitmap.width / bitmapCompositeB.width, bitmap.height / bitmapCompositeB.height);
			bitmap.draw(bitmapCompositeB, mtx, new ColorTransform(1, 1, 1, _phase), BlendMode.LIGHTEN, null, true);
			//bitmap.draw(bitmapCompositeB, mtx, new ColorTransform(1, 1, 1, _phase), null, null, true);

			needsRedraw = false;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setImageA(__image:BitmapData):void {
			imageA.setBitmapData(__image);

			requestRedraw(true);
		}

		public function setImageB(__image:BitmapData):void {
			imageB.setBitmapData(__image);

			requestRedraw(true);
		}

		public function setPointsA(__points:Array):void {
			// Parameters should be an array of points, using the image's coordinate system
			imageA.setPointsFromArray(__points);

			requestRedraw();
		}

		public function setPointsB(__points:Array):void {
			// Parameters should be an array of points
			imageB.setPointsFromArray(__points);

			requestRedraw();
		}

		public function setTriangles(__triangles:Array):void {
			// Parameters should be by vertices, like: [[0, 1, 2], [0, 1, 3]]

			triangles = new Vector.<TrianglePoints>();
			for (var i:int = 0; i < __triangles.length; i++) {
				triangles.push(new TrianglePoints(__triangles[i][0], __triangles[i][1], __triangles[i][2]));
			}

			requestRedraw();
		}

		public function getBitmap(): BitmapData {
			if (needsBitmap) {
				// TODO: allow transparency
				bitmap = new BitmapData(_width, _height, false, 0x000000);
				bitmapCompositeA = new BitmapData(_width, _height, false, 0x000000);
				bitmapCompositeB = new BitmapData(_width, _height, false, 0x000000);

				needsBitmap = false;
			}

			if (needsRedraw) {
				redrawMorphedImage();
			}

			return bitmap;
		}

		public function dispose():void {
			removeBitmap();

			imageA.dispose();
			imageA = null;

			imageB.dispose();
			imageB = null;

			triangles = null;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get width():int {
			return _width;
		}
		public function set width(__value:int):void {
			if (_width != __value) {
				_width = __value;
				requestRedraw(true);
			}
		}

		public function get height():int {
			return _height;
		}
		public function set height(__value:int):void {
			if (_height != __value) {
				_height = __value;
				requestRedraw(true);
			}
		}

		public function get phase():Number {
			return _phase;
		}
		public function set phase(__value:Number):void {
			if (_phase != __value) {
				_phase = __value;
				requestRedraw();
			}
		}
	}
}

import flash.display.BitmapData;
import flash.geom.Point;
class TrianglePoints {

	// Instances
	public var p1:int;
	public var p2:int;
	public var p3:int;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function TrianglePoints(__p1:int, __p2:int, __p3:int) {
		p1 = __p1;
		p2 = __p2;
		p3 = __p3;
	}

}

class MorphImageData {

	// Instances
	public var vertices:Vector.<Point>;
	public var bitmap:BitmapData;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function MorphImageData() {
	}

	// ================================================================================================================
	// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

	protected function removeBitmapData():void {
		if (Boolean(bitmap)) {
			bitmap.dispose();
			bitmap = null;
		}
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function setBitmapData(__bitmap:BitmapData):void {
		removeBitmapData();
		bitmap = __bitmap;
	}

	public function setPointsFromArray(__points:Array):void {
		var ps:Vector.<Point> = new Vector.<Point>();
		for (var i:int = 0; i < __points.length; i++) {
			ps.push(__points[i]);
		}
		vertices = ps;
		// TODO: create triangle cache
	}

	public function dispose():void {
		removeBitmapData();
		vertices = null;
	}
}