package com.zehfernando.display.components 
{
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;

	/**
	 * 
	 * Easy way to apply filter effects to a TextSprite instance.
	 * 
	 * @param					p_font					The font name of text field.
	 * @param					p_size					The size of text field.
	 * @param					p_color					The color of text field.
	 * 
	 * @example
	 * <pre>
	 * var label : EffectTextSprite = new EffectTextSprite("_sans", 20, 0x444444);
	 * label.x = 20;
	 * label.y = 20;
	 * label.text = "FIRSTBORN MULTIMEDIA";
	 * label.shadow(2);
	 * label.smoothing(3);
	 * label.glow(4, 0x00CC00);
	 * addChild(label);
	 * </pre>
	 * 
	 * @author Rafael Rinaldi (rafaelrinaldi.com)
	 * 
	 */
	 
	public class EffectTextSprite extends TextSprite 
	{
		public function EffectTextSprite( p_font : String = "_sans", p_size : Number = 12, p_color : Number = 0x0 )
		{
			super(p_font, p_size, p_color);
		}
		
		/**
		 * 
		 * 	Apply a blur filter to the text sprite.
		 * 	
		 * 	@param					p_effect					The amount of blur or a new BlurFilter instance.
		 * 
		 */
		public function smoothing( p_effect : * ) : void
		{
			if(p_effect is Number) {
				applyEffect(new BlurFilter(p_effect, p_effect));
			} else if(p_effect is BlurFilter) {
				applyEffect(p_effect);
			} else {
				throw new Error("Effect parameter has a invalid value!");
			}
		}
		
		/**
		 * 
		 * 	Apply a shadow filter to the text sprite.
		 * 	
		 * 	@param					p_effect					The amount of shadow or a new DropShadowFilter instance.
		 * 
		 */
		public function shadow( p_effect : * ) : void
		{
			if(p_effect is Number) {
				applyEffect(new DropShadowFilter(0, 45, 0x0, .7, p_effect, p_effect));
			} else if(p_effect is DropShadowFilter) {
				applyEffect(p_effect);
			} else {
				throw new Error("Effect parameter has a invalid value!");
			}
		}

		/**
		 * 
		 * 	Apply a glow filter to the text sprite.
		 * 	
		 * 	@param					p_effect					The amount of glow or a new GlowFilter instance.
		 * 
		 */
		public function glow( p_effect : *, p_color : uint = 0xCC0000 ) : void 
		{
			if(p_effect is Number) {
				applyEffect(new GlowFilter(p_color, 1, p_effect, p_effect));
			} else if(p_effect is GlowFilter) {
				applyEffect(p_effect);
			} else {
				throw new Error("Effect parameter has a invalid value!");
			}
		}
		
		/**
		 * 
		 *  Just apply the effect.
		 *  
		 *  @param					p_effect					The filter instance.
		 * 
		 */
		public function applyEffect( p_effect : * ) : void 
		{
			var filters : Array = this.textContainer.filters;
			
			filters[filters.length] = p_effect;
			
			this.textContainer.filters = filters;
		}
	}
}
