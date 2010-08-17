package com.zehfernando.transitions {

	/**
	 * @author Zeh Fernando
	 */
	public class ZTweenProperty {

		public var valueStart				:Number;	// Starting value of the tweening (NaN if not started yet)
		public var valueComplete			:Number;	// Final desired value
		public var name:String;

		public var valueChange:Number;					// Change needed in value (cache)
		
		public function ZTweenProperty(__name:String, __valueComplete:Number) {
			name			= __name;
			valueComplete	= __valueComplete;
			//originalValueComplete	=	p_originalValueComplete;
			//extra					=	p_extra;
			//isSpecialProperty		=	p_isSpecialProperty;
			//hasModifier			=	Boolean(p_modifierFunction);
			//modifierFunction 	=	p_modifierFunction;
			//modifierParameters	=	p_modifierParameters;
		}
		
	}
}
