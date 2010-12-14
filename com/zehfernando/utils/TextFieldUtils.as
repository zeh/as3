package com.zehfernando.utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.utils.Dictionary;
	
	import com.zehfernando.localization.StringList;		

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class TextFieldUtils {

		// Static properties
		protected static var fixedTextFields:Dictionary;

		public static function getContentHeight(__tf:TextField): Number {
			// Correctly returns the height of a textfield's whole content (TextField.textHeight sucks)
			// Needs to be more throughly tested

			var tm:TextLineMetrics;
			
			var leading:Number = __tf.getTextFormat().leading == null ? 0 : Number(__tf.getTextFormat().leading);
			
			var totalHeight:Number = 0;
			for (var i:Number = 0; i < __tf.numLines; i++) {
				tm = __tf.getLineMetrics(i);
				// Don't use height. It's not the actual total line length.
				totalHeight += tm.ascent + tm.descent;
				if (i < __tf.numLines - 1) totalHeight += leading; //tm.leading sucks
			}

			totalHeight += 4;

			return totalHeight;
		}
		
		public static function fixEmbed(__tf:TextField, __captureQuality:Number = 8, __finalQuality:Number = 2): void {

			if (StringList.getValue("use_embed") == "true") {

				// Creates a copy of a textfield as a bitmap that holds a copy of the non-embed textfield and is then rotated to match, since embeded textfields can't be rotated and scaled

				if (!Boolean(__tf)) return;

				if (fixedTextFields == null) {
					fixedTextFields = new Dictionary(true);
				}
				
				var fieldData:Object = fixedTextFields[__tf];
				
				var tfAlreadyFixed:Boolean = Boolean(fieldData);
				var tfContainsForeignChars:Boolean = false;
				for (var i:Number = 0; i < __tf.text.length; i++) {
					if (__tf.text.charCodeAt(i) > 1000) {
						tfContainsForeignChars = true;
						break;
					}
				} 

				if (tfContainsForeignChars) {
					if (!tfAlreadyFixed) {
						// This textfield has never been "fixed", so attempt
						
						//trace ("fixEmbed :: create holder");
					
						var mtx:Matrix;
						var fixRatio:Number;
		
						// Turn off embedFonts
						__tf.embedFonts = false;
						
						// Setup text format
						var realFormat:TextFormat = __tf.getTextFormat();
						var fmt:TextFormat = __tf.getTextFormat();
						fmt.font = "_sans";
						var ns:Number = Number(fmt.size) * 0.8;
						if (ns < 10) ns = 10;
						//if (ns > 26) ns = 26;
						fmt.size = ns;
						__tf.setTextFormat(fmt);
	
						var realParent:DisplayObjectContainer = __tf.parent;
						var realIndex:Number = realParent.getChildIndex(__tf);
	
						// Creates container
						var ghostContainer:Sprite = new Sprite();
						ghostContainer.addChild(__tf);
	
						fieldData = {realParent:realParent, realIndex:realIndex, ghostContainer:ghostContainer, realTextFormat:realFormat};
						
						fixedTextFields[__tf] = fieldData;
	
					} else {
				
						//trace ("fixEmbed :: update");
						
						// Remove old bitmaps
						fieldData.realParent.removeChild(fieldData.containerBmp);
						fieldData.containerBmp = null;
	
						fieldData.finalBmp.dispose();
						fieldData.finalBmp = null;
					}
				
					// Finally, update images
	
					// Save field data
					var oldX:Number = __tf.x;
					var oldY:Number = __tf.y;
					var oldRotation:Number = __tf.rotation;
					var oldAlpha:Number = __tf.alpha;
		
					__tf.x = 0;
					__tf.y = 0;
					__tf.rotation = 0;
					__tf.alpha = 1;
		
					// Creates duplicate for capture
					var captureW:Number = __tf.width * __captureQuality;
					var captureH:Number = __tf.height * __captureQuality;
					
					if (captureW > 2880) {
						fixRatio = 2880 / captureW;
						captureW = captureW * fixRatio; 
						captureH = captureH * fixRatio;
					}
					if (captureH > 2880) {
						fixRatio = 2880 / captureH;
						captureW = captureW * fixRatio; 
						captureH = captureH * fixRatio;
					}
					captureW = Math.round(captureW);
					captureH = Math.round(captureH);
					
					var captureBmp:BitmapData = new BitmapData(captureW, captureH, true, 0x00000000);
					
					mtx = new Matrix();
					mtx.scale(__captureQuality, __captureQuality);
					
					captureBmp.draw(fieldData.ghostContainer, mtx, null, null, null, true);
	
					// Return textfield properties
					__tf.x = oldX;
					__tf.y = oldY;
					__tf.rotation = oldRotation;
					__tf.alpha = oldAlpha;
					
					// Creates final bitmap
					var finalW:Number = __tf.width * __finalQuality;
					var finalH:Number = __tf.height * __finalQuality;
						
					if (finalW > 2880) {
						fixRatio = 2880 / captureW;
						finalW = finalW * fixRatio; 
						finalH = finalH * fixRatio;
					}
					if (captureH > 2880) {
						fixRatio = 2880 / captureH;
						finalW = finalW * fixRatio; 
						finalH = finalH * fixRatio;
					}
					captureW = Math.round(captureW);
					captureH = Math.round(captureH);
	
					var finalBmp:BitmapData = new BitmapData(finalW, finalH, true, 0x00000000);
					
					mtx = new Matrix();
					mtx.scale(__finalQuality/__captureQuality, __finalQuality/__captureQuality);
					
					finalBmp.draw(captureBmp, mtx, null, null, null, true);
	
					// Attaches final bitmap
					var containerBmp:Bitmap = new Bitmap(finalBmp, "auto", true);
					fieldData.realParent.addChildAt(containerBmp, fieldData.realIndex);
					//fieldData.realParent.addChild(containerBmp);
					
					containerBmp.x = oldX;
					containerBmp.y = oldY;
					containerBmp.scaleX = containerBmp.scaleY = 1/__finalQuality;
					containerBmp.rotation = oldRotation;
	
					// Dispose of uneeded stuff
					captureBmp.dispose();
					captureBmp = null;
						
					fieldData.finalBmp = finalBmp;
					fieldData.containerBmp =  containerBmp;
				
				} else {
					if (tfAlreadyFixed) {
						// Does not contain foreign chars but it's already fixed, so remove it instead
						removeEmbed(__tf);
					}
				}
			}
		}

		public static function wrapEmbed(__tf:TextField): DisplayObject {
			// "Wrap around" an object, returning the embed if it exists, the original textfield otherwise
			return fixedTextFields != null && Boolean(fixedTextFields[__tf]) ? Bitmap(fixedTextFields[__tf].containerBmp) : __tf;
		}

		public static function removeEmbed(__tf:TextField): void {
			if (!Boolean(__tf) || fixedTextFields == null) return;
			var fieldData:Object = fixedTextFields[__tf];
			if (Boolean(fieldData)) {
				//trace ("fixEmbed :: remove holder");
				fieldData.realParent.removeChild(fieldData.containerBmp);
				fieldData.containerBmp = null;
				
				fieldData.finalBmp.dispose();
				fieldData.finalBmp = null;
				
				__tf.setTextFormat(fieldData.realTextFormat);

				fieldData.realParent.addChildAt(__tf, fieldData.realIndex);
				fieldData.ghostContainer = null;

				__tf.embedFonts = false;
				
				fixedTextFields[__tf] = null;
				
				delete (fixedTextFields[__tf]);
			}
		} 
	}
}
