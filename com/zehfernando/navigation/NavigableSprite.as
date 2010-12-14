package com.zehfernando.navigation {

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	/**
	 * @author zeh
	 */
	public class NavigableSprite extends Sprite {
		
		// A movie that can be navigated to -- to be used with the Navigator class
		
		// Properties
		protected var _title:String;
		protected var _stub:String;
		protected var _childrenContainer:DisplayObjectContainer;
		protected var _myLocation:String;
		protected var _createChildrenDynamically:Boolean;
		protected var _destroyChildrenAfterClosing:Boolean;

		protected var createdChildren:Vector.<NavigableSprite>;

		
		//protected var _canSwitchChildren:Boolean;								// Whether this can do a hot child switch (one child stub to the other) or not (must close old child, and then show new child)

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------
		
		public function NavigableSprite() {
			//_myLocation = null;
			_title = "Default Area";
			_stub = "default-area";
			_myLocation = "/";
			_childrenContainer = this;
			_createChildrenDynamically = true;
			_destroyChildrenAfterClosing = true;
			createdChildren = new Vector.<NavigableSprite>();
			
			//_canSwitchChildren = false;
			
			addEventListener(NavigableSpriteEvent.OPENING, onOpeningInternal, false, 0, true);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
		
		private function onOpeningInternal(e:NavigableSpriteEvent): void {
			// TODO: this is a bit of a crappy method to open sub-sections... rethink this approach
			//_myLocation = SpriteNavigator.getLocation();
			//_myLocation = (Boolean(navigableParent) ? navigableParent.location :  "") + "/" + _stub;//SpriteNavigator.getLocation(true);
			//trace ("==== "+this+" my location = " + _myLocation);
			//_myLocation = SpriteNavigator.getLocation(true);
			//_myLocation += (_myLocation.length > 1 ? "/" : "") + _stub;
			if (_myLocation == "/" || _stub == "default-area") _myLocation = "";
			//trace ("NavigableSprite :: onOpeningInternal :: setting [" +_stub + "]'s location as [" + _myLocation + "]");
			//trace ("---->" + SpriteNavigator.getLocation(true)+"/" + _stub);
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function createChild(__stub:String): NavigableSprite {
			// Creates new sub-work area, and returns it
			//trace ("NavigableSprite :: createChild :: ["+__stub+"]");
			var ns:NavigableSprite = createChildInstance(__stub);
			if (Boolean(ns)) {
				if (_destroyChildrenAfterClosing) ns.addEventListener(NavigableSpriteEvent.CLOSED, onClosedChildDestroy, false, 0, true);
				ns.location = _myLocation + "/" + __stub;
				createdChildren.push(ns);
				_childrenContainer.addChildAt(ns, 0);
				return ns;
			} else {
				trace ("NavigableSprite :: createChildInternal :: Child ["+__stub+"] creation failed!");
			}
			return null;
		}

		protected function dispatchOpeningEvent(): void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.OPENING));
		}

		protected function dispatchOpenedEvent(): void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.OPENED));
		}

		protected function dispatchClosingEvent(): void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.CLOSING));
		}

		protected function dispatchClosedEvent(): void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.CLOSED));
		}

		protected function createChildInstance(__stub:String): NavigableSprite {
			// Should be extended!
//			var ns:NavigableSprite = new WorkView(__stub);
			//trace ("NavigableSprite :: createChildInstance :: Attempted to create child "+__stub);
			return null;
		}

		protected function destroyChild(__navigableSprite:NavigableSprite): void {
			// Removes a navigable sub-area as it's not needed anymore
			__navigableSprite.removeEventListener(NavigableSpriteEvent.CLOSED, onClosedChildDestroy);
			_childrenContainer.removeChild(__navigableSprite);
			var i:int = createdChildren.indexOf(__navigableSprite);
			if (i > -1) createdChildren.splice(i, 1);
		}

		protected function getAllNavigableChildren():Vector.<NavigableSprite> {
			var allChildren:Vector.<NavigableSprite> = new Vector.<NavigableSprite>();

			var ns:DisplayObject;
			for (var i:int = 0; i < _childrenContainer.numChildren; i++) {
				ns = _childrenContainer.getChildAt(i);
				if (ns is NavigableSprite) allChildren.push(ns as NavigableSprite);
			}
			
			return allChildren;

		}
		
		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onClosedChildDestroy(e:NavigableSpriteEvent): void {
			destroyChild(e.target as NavigableSprite);
		}
		
		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------
		
		public function open(__immediate:Boolean = false, __isLast:Boolean = false): void {
			if (__immediate) {
				dispatchOpeningEvent();
				dispatchOpenedEvent();
			} else {
				// Animate this
				dispatchOpeningEvent();
				dispatchOpenedEvent();
			}
		}

		public function finishedExecutionAsCurrentArea(__immediate:Boolean = false, __fake:Boolean = false): void {
			// Navigation execution has finished, and this is the current area!
		}

		public function close(__immediate:Boolean = false): void {
			if (__immediate) {
				dispatchClosingEvent();
				dispatchClosedEvent();
			} else {
				// Animate this
				dispatchClosingEvent();
				dispatchClosedEvent();
			}
		}

		public function requestPermissionToPreOpenChild(__stub:String, __furtherChildren:int, __immediate:Boolean = false): void {
			// Requests permission to PRE-open a child sprite (meaning instantiate it if it doesn't exist)
			// This usually should be immediate, but if a parent needs to close or hide something prior to showing a
			// child, it must do so and only then dispatch the permission
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.ALLOWED_TO_PRE_OPEN_CHILD));
		}

		public function requestPermissionToOpenChild(__child:NavigableSprite, __furtherChildren:int, __immediate:Boolean = false): void {
			// Requests permission to OPEN a child sprite (meaning call open() on it)
			// This usually should be immediate, but if a parent needs to close or hide something prior to showing a
			// child, it must do so and only then dispatch the permission
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.ALLOWED_TO_OPEN_CHILD));
		}
		
		public function requestPermissionToCloseChild(__child:NavigableSprite, __immediate:Boolean = false): void {
			// Requests permission to CLOSE a child sprite (meaning call close() on it)
			// This usually should be immediate, but if a parent needs to close or hide something prior to closing a
			// child, it must do so and only then dispatch the permission
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.ALLOWED_TO_CLOSE_CHILD));
		}
		
		public function requestPermissionToOpen(__furtherChildren:int, __immediate:Boolean = false): void {
			// Requests permission to open THIS sprite (meaning call open() on it)
			// This usually should be immediate, but if a sprite needs to close or hide something prior to showing itself,
			// it must do so and only then dispatch the permission
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.ALLOWED_TO_OPEN));
		}
				
		public function getChildByStubs(__stubList:Vector.<String>): NavigableSprite {
			// Based on an array of locations (example: ["file", "2000"], returns the specific NavigableContainer ("2000" in this case)
			
			//trace ("NavigableSprite [" + _stub + "] :: getChildByStubs ENTER :: [" + __stubList + "] (" + __stubList.length + ")");
			
			var cn:NavigableSprite;

			if (__stubList.length == 0) {
				// This movie!
				cn = this;
			} else {
				// Needs to go deeper
				
				var __name:String = __stubList[0];
				cn = getChildByStub(__name);
				
				if (Boolean(cn)) {
					cn = cn.getChildByStubs(__stubList.slice(1));
				} else {
					cn = null;
					trace ("NavigableSprite :: ERROR! There is no children with the name \""+__name+"\"!");
					//throw new Error("Error: there is no children with the name \""+__name+"\"!");
				}
			}
			
			//trace ("NavigableSprite [" + _stub + "] :: getChildByStubs EXIT :: [" + __stubList + "] (" + __stubList.length + ")");
			
			return cn;
		}
		
		public function getChildByStub(__stub:String, __allowDynamicCreation:Boolean = true): NavigableSprite {
			
			//trace ("NavigableSprite :: getChildByStub :: [" + __stub + "]");
			//trace ("NavigableSprite :: getChildByStub :: _childrenContainer has " + _childrenContainer.numChildren + " children");
			
			var ds:DisplayObject;
			for (var i:int = 0; i < _childrenContainer.numChildren; i++) {
				ds = _childrenContainer.getChildAt(i);
				if (ds is NavigableSprite && (ds as NavigableSprite).stub == __stub) return ds as NavigableSprite;
			}
			
			//trace ("NavigableSprite :: getChildByStub :: Stub [" + __stub + "] not found at ["+_stub+"], creating it"); 
			if (_createChildrenDynamically && __allowDynamicCreation) return createChild(__stub);
			
			return null;
		}
		
		public function requestOpenChildArea(__stub:String): void {
			SpriteNavigator.setLocation(_myLocation + "/" + __stub); 
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get title(): String {
			// Returns the title of this sprite
			return _title;
		}
		
		public function get stub(): String {
			return _stub;
		}
		
		public function get location():String {
			return _myLocation;
		}
		
		public function set location(__value:String): void {
			_myLocation = __value;
		}
		
//		public function canSwitchChildren(): Boolean {
//			return _canSwitchChildren;
//		}
	}
}


/*
class NavigableMovie extends MovieClip {

	// Constantes globais (ou quase)
	public static var CANVAS_WIDTH:Number = 780;			// Largura do documento
	public static var CANVAS_HEIGHT:Number = 450;			// Altura do documento

	public static var CANVAS_MARGIN_TOP:Number = 60;				// Margem do topo típico

//	private var _currentChild:String;			// Filho aberto atualmente
	private var _myLocation:String;			// Localização deste movie

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function NavigableMovie() {
		// Inicializa

//		_currentChild = null;
		_myLocation = null;
		_visible = false;
		_alpha = 0;
		
		//onResize();
	}


	// ================================================================================================================
	// EVENT functions ------------------------------------------------------------------------------------------------

	public function onResize(): Void {
	}


	// ================================================================================================================
	// INSTANCE functions ---------------------------------------------------------------------------------------------

	public function getTitle(): String {
		// Retorna um texto que corresponde a este movieclip specífico
		return "Default NavigableMovie";
	}

	public function getChild(p_childList:Array): MovieClip {
		// Baseado num array de filhos (por exemplo: ["arquivo", "2000"]), retorna o Movie correspondente a este nome ("2000")
		var $nome:String = p_childList[0];
		if (p_childList.length == 0) {
			// Ele mesmo
			return this;
		} else {
			// Precisa entrar mais fundo
			var $subChildList:Array = new Array();
			for (var i:Number = 1; i < p_childList.length; i++) $subChildList.push(p_childList[i]);
			return this[$nome].getChild($subChildList);
		}
	}

//	private function getStandardChildrenLocation(): MovieClip {
//		// Retorna a localização "padrão" dos children
//		return this;
//	}

	public function hide(): Void {
		// Esconde este movie
//		trace ("["+this+"] hide");
		Tweener.addTween(this, {_alpha:0, time:0.3, transition:"linear", onStart:onPreHide, onComplete:onPostHide});
//		_visible = false;
//		MovieNavigator.executeNextCommand();
	}

	public function show(): Void {
		// Mostra este movie
//		trace ("["+this+"] show");
		Tweener.addTween(this, {_alpha:100, time:0.3, transition:"linear", onStart:onPreShow, onComplete:onPostShow});
//		_visible = true;
//		MovieNavigator.executeNextCommand();
	}

	// ================================================================================================================
	// EVENT functions ------------------------------------------------------------------------------------------------

	private function onPreShow(): Void {
		// Função rodada antes de mostrar
		_visible = true;
		_myLocation = MovieNavigator.getLocation();
		Stage.addListener(this);
	}

	private function onPostShow(): Void {
		// Função rodada depois de mostrar
//		trace ("NavigableMovie :: SHOW MovieNavigator.executeNextCommand");
		MovieNavigator.executeNextCommand();
	}

	private function onPreHide(): Void {
		// Função rodada antes de esconder
	}

	private function onPostHide(): Void {
		// Função rodada depois de esconder
//		trace ("NavigableMovie :: HIDE MovieNavigator.executeNextCommand");
		Stage.removeListener(this);
		MovieNavigator.executeNextCommand();
		_visible = false;
	}


}

*/