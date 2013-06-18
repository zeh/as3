package com.zehfernando.navigation {

	import com.zehfernando.utils.console.warn;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	/**
	 * @author zeh
	 */
	public class NavigableSprite extends Sprite {

		// A movie that can be navigated to -- to be used with the SpriteNavigator class

		// Properties
		protected var _title:String;									// Title for the HTML
		protected var _stub:String;										// stub for the address
		protected var _childrenContainer:DisplayObjectContainer;		// Container that contains children created
		protected var _myLocation:String;								// Full location for this instance
		protected var _createChildrenDynamically:Boolean;				// Whether it can create children dynamically as needed
		protected var _destroyChildrenAfterClosing:Boolean;				// Whether children must be destroyed after being closed

		protected var createdChildren:Vector.<NavigableSprite>;			// List of children that were dynamically created

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function NavigableSprite() {
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

		private function onOpeningInternal(e:NavigableSpriteEvent):void {
			// This NavigableSprite os opening, therefore, set its currenrt location
			if (_myLocation == "/" || _stub == "default-area") _myLocation = "";
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function createChild(__stub:String): NavigableSprite {
			// Creates new sub-work area, and returns it
			//trace ("NavigableSprite :: createChild :: ["+__stub+"]");
			var ns:NavigableSprite = createChildInstance(__stub);
			if (Boolean(ns)) {
				ns.addEventListener(NavigableSpriteEvent.OPENING, onOpeningChild, false, 0, true);
				ns.addEventListener(NavigableSpriteEvent.OPENED, onOpenedChild, false, 0, true);
				ns.addEventListener(NavigableSpriteEvent.CLOSING, onClosingChild, false, 0, true);
				ns.addEventListener(NavigableSpriteEvent.CLOSED, onClosedChild, false, 0, true);
				ns.location = _myLocation + "/" + __stub;
				createdChildren.push(ns);
				_childrenContainer.addChild(ns);
				//_childrenContainer.addChildAt(ns, 0);
				return ns;
			} else {
				trace ("NavigableSprite :: createChildInternal :: Child ["+__stub+"] creation failed!");
			}
			return null;
		}

		protected function dispatchOpeningEvent():void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.OPENING));
		}

		protected function dispatchOpenedEvent():void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.OPENED));
		}

		protected function dispatchClosingEvent():void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.CLOSING));
		}

		protected function dispatchClosedEvent():void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.CLOSED));
		}

		protected function createChildInstance(__stub:String): NavigableSprite {
			// Should be extended!
//			var ns:NavigableSprite = new WorkView(__stub);
			//trace ("NavigableSprite :: createChildInstance :: Attempted to create child "+__stub);
			return null;
		}

		protected function destroyChild(__navigableSprite:NavigableSprite):void {
			// Removes a navigable sub-area as it's not needed anymore
			__navigableSprite.removeEventListener(NavigableSpriteEvent.OPENING, onOpeningChild);
			__navigableSprite.removeEventListener(NavigableSpriteEvent.OPENED, onOpenedChild);
			__navigableSprite.removeEventListener(NavigableSpriteEvent.CLOSING, onClosingChild);
			__navigableSprite.removeEventListener(NavigableSpriteEvent.CLOSED, onClosedChild);
			__navigableSprite.dispose();
			if (_childrenContainer.contains(__navigableSprite) && __navigableSprite.parent == _childrenContainer) {
				_childrenContainer.removeChild(__navigableSprite);
			} else {
				warn("_childrenContainer didn't contain the navigable sprite being removed; it won't be removed. Do it manually?");
			}
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

		protected function onOpeningChild(e:NavigableSpriteEvent):void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.OPENING_CHILD));
		}

		protected function onOpenedChild(e:NavigableSpriteEvent):void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.OPENED_CHILD));
		}

		protected function onClosingChild(e:NavigableSpriteEvent):void {
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.CLOSING_CHILD));
		}

		protected function onClosedChild(e:NavigableSpriteEvent):void {
			if (_destroyChildrenAfterClosing) destroyChild(e.target as NavigableSprite);
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.CLOSED_CHILD));
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function open(__immediate:Boolean = false, __isLast:Boolean = false):void {
			if (__immediate) {
				dispatchOpeningEvent();
				dispatchOpenedEvent();
			} else {
				// Animate this
				dispatchOpeningEvent();
				dispatchOpenedEvent();
			}
		}

		public function finishedExecutionAsCurrentArea(__immediate:Boolean = false, __fake:Boolean = false):void {
			// Navigation execution has finished, and this is the current area!
		}

		public function dispose():void {
			// Disposes of this (called when the parent's _destroyChildrenAfterClosing is set to true)
		}

		public function close(__immediate:Boolean = false, __isLast:Boolean = false):void {
			if (__immediate) {
				dispatchClosingEvent();
				dispatchClosedEvent();
			} else {
				// Animate this
				dispatchClosingEvent();
				dispatchClosedEvent();
			}
		}

		public function requestPermissionToPreOpenChild(__stub:String, __furtherChildren:int, __immediate:Boolean = false):void {
			// Requests permission to PRE-open a child sprite (meaning instantiate it if it doesn't exist)
			// This usually should be immediate, but if a parent needs to close or hide something prior to showing a
			// child, it must do so and only then dispatch the permission
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.ALLOWED_TO_PRE_OPEN_CHILD));
		}

		public function requestPermissionToOpenChild(__child:NavigableSprite, __furtherChildren:int, __immediate:Boolean = false):void {
			// Requests permission to OPEN a child sprite (meaning call open() on it)
			// This usually should be immediate, but if a parent needs to close or hide something prior to showing a
			// child, it must do so and only then dispatch the permission
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.ALLOWED_TO_OPEN_CHILD));
		}

		public function requestPermissionToCloseChild(__child:NavigableSprite, __furtherChildren:int, __immediate:Boolean = false):void {
			// Requests permission to CLOSE a child sprite (meaning call close() on it)
			// This usually should be immediate, but if a parent needs to close or hide something prior to closing a
			// child, it must do so and only then dispatch the permission
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.ALLOWED_TO_CLOSE_CHILD));
		}

		public function requestPermissionToOpen(__furtherChildren:int, __immediate:Boolean = false):void {
			// Requests permission to open THIS sprite (meaning call open() on it)
			// This usually should be immediate, but if a sprite needs to close or hide something prior to showing itself,
			// it must do so and only then dispatch the permission
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.ALLOWED_TO_OPEN));
		}

		public function requestPermissionToClose(__furtherChildren:int, __immediate:Boolean = false):void {
			// Requests permission to close THIS sprite (meaning call close() on it)
			// This usually should be immediate, but if a sprite needs to close or hide something prior to showing itself,
			// it must do so and only then dispatch the permission
			dispatchEvent(new NavigableSpriteEvent(NavigableSpriteEvent.ALLOWED_TO_CLOSE));
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

			//log("Getting child [" + __stub + "] at [" + _stub + "], _childrenContainer has " + _childrenContainer.numChildren + " children");

			var ds:DisplayObject;
			var i:int;

			// Looks for static ones
			// TODO: remove? this is not needed anymore because it won't shouldn't be there
			for (i = 0; i < _childrenContainer.numChildren; i++) {
				ds = _childrenContainer.getChildAt(i);
				//log("    Testing ["+ds+"]... " + (ds is NavigableSprite ? "[" + (ds as NavigableSprite).stub + "]" : ""));
				if (ds is NavigableSprite && (ds as NavigableSprite).stub == __stub) return ds as NavigableSprite;
			}

			// Looks for dynamically created ones that are NOT on the children container (otherwise the above code would find it)
			for (i = 0; i < createdChildren.length; i++) {
				if (createdChildren[i].stub == __stub) return createdChildren[i];
			}

			//log("Children not found!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

			//trace ("NavigableSprite :: getChildByStub :: Stub [" + __stub + "] not found at ["+_stub+"], creating it");
			if (_createChildrenDynamically && __allowDynamicCreation) return createChild(__stub);

			return null;
		}

		public function requestOpenChildArea(__stub:String):void {
			SpriteNavigator.setLocation(_myLocation + "/" + __stub);
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get title():String {
			// Returns the title of this sprite
			return _title;
		}

		public function get stub():String {
			return _stub;
		}

		public function get location():String {
			return _myLocation;
		}

		public function set location(__value:String):void {
			_myLocation = __value;
		}

//		public function canSwitchChildren():Boolean {
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

	public function onResize():void {
	}


	// ================================================================================================================
	// INSTANCE functions ---------------------------------------------------------------------------------------------

	public function getTitle():String {
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

	public function hide():void {
		// Esconde este movie
//		trace ("["+this+"] hide");
		Tweener.addTween(this, {_alpha:0, time:0.3, transition:"linear", onStart:onPreHide, onComplete:onPostHide});
//		_visible = false;
//		MovieNavigator.executeNextCommand();
	}

	public function show():void {
		// Mostra este movie
//		trace ("["+this+"] show");
		Tweener.addTween(this, {_alpha:100, time:0.3, transition:"linear", onStart:onPreShow, onComplete:onPostShow});
//		_visible = true;
//		MovieNavigator.executeNextCommand();
	}

	// ================================================================================================================
	// EVENT functions ------------------------------------------------------------------------------------------------

	private function onPreShow():void {
		// Função rodada antes de mostrar
		_visible = true;
		_myLocation = MovieNavigator.getLocation();
		Stage.addListener(this);
	}

	private function onPostShow():void {
		// Função rodada depois de mostrar
//		trace ("NavigableMovie :: SHOW MovieNavigator.executeNextCommand");
		MovieNavigator.executeNextCommand();
	}

	private function onPreHide():void {
		// Função rodada antes de esconder
	}

	private function onPostHide():void {
		// Função rodada depois de esconder
//		trace ("NavigableMovie :: HIDE MovieNavigator.executeNextCommand");
		Stage.removeListener(this);
		MovieNavigator.executeNextCommand();
		_visible = false;
	}


}

*/