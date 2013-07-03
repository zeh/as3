package com.zehfernando.navigation {
	import com.zehfernando.utils.console.log;
	import com.zehfernando.utils.console.logOff;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * @author zeh
	 */
	public class SpriteNavigator {

		// Constants
		public static const COMMAND_UP:String = "..";

		public static const COMMAND_TYPE_BACK:String = "commandTypeBack";
		public static const COMMAND_TYPE_UP:String = "commandTypeUp";
		public static const COMMAND_TYPE_FORWARD:String = "commandTypeForward";
		public static const COMMAND_TYPE_DIRECT:String = "commandTypeDirect";

		// Properties
		protected static var rootSprite:NavigableSprite;

		//public static var siteTitle:String = "siteTitle";
		public static var titleSeparator:String = " - ";
		public static var useLastTitleOnly:Boolean = false;						// TODO: make this a getter/setter

		protected static var currentLocationInternal:Vector.<String>;			// List of stubs

		protected static var navigationCommands:Vector.<String>;
		protected static var executingNavigationCommand:Boolean;

		protected static var targetLocations:Vector.<String>;

		protected static var locationWaitingToOpen:Vector.<String>;

		protected static var eventDispatcher:EventDispatcher;

		public static var lastCommandExecuted:String;
		public static var lastCommandExecutedType:String;


		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		{
			targetLocations = new Vector.<String>;
			eventDispatcher = new EventDispatcher();

			logOff();
		}

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function SpriteNavigator() {
			super();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected static function executeNextNavigationCommand():void {
			// Sets title
			log();
			updateTitle(); // TODO: move this somewhere else?

			// TODO: this is being called unnecessarily before it actually starts navigating somewhere
			eventDispatcher.dispatchEvent(new SpriteNavigatorEvent(SpriteNavigatorEvent.CHANGED_LOCATION));

			// Executes next command from the list
			if (navigationCommands.length > 0) {

				if (targetLocations.length > 0) {
					// Cut the navigation in the middle and jump to the new location -- test!
					log("Halting execution for new destination");
					executingNavigationCommand = false;
					changeAddressIfNeeded();
					return;
				}
				executingNavigationCommand = true;

				var __nextCommand:String = navigationCommands.shift();
				log("Executing command [" + __nextCommand + "]");

				eventDispatcher.dispatchEvent(new SpriteNavigatorEvent(SpriteNavigatorEvent.LOCATION_WILL_CHANGE));

				if (__nextCommand == COMMAND_UP) {
					lastCommandExecuted = COMMAND_UP;
					closeSprite();
				} else {
					lastCommandExecuted = __nextCommand;
					openSprite(__nextCommand);
				}
			} else {
				// Finished executing all commands

				executingNavigationCommand = false;
				log ("Finished execution");

				var ns:NavigableSprite = rootSprite.getChildByStubs(currentLocationInternal);
				ns.finishedExecutionAsCurrentArea(false);

				eventDispatcher.dispatchEvent(new SpriteNavigatorEvent(SpriteNavigatorEvent.CHANGED_LOCATION_FINAL));

				changeAddressIfNeeded();
			}
		}

		protected static function updateTitle():void {
			//var newTitle:String = siteTitle + titleSeparator + getLocationTitles().join(titleSeparator);
			/*FDT_IGNORE*/
			SWFAddress.setTitle(getTitle());
			/*FDT_IGNORE*/
//			trace ("SpriteNavigator :: updateTitle :: new title is [" + newTitle + "]");
		}

		protected static function openSprite(__stub:String):void {
			// Open a sprite, going down on the hierarchy

			// Sets the new location
			var newLocation:Vector.<String>;
			if (!Boolean(currentLocationInternal) || currentLocationInternal.length == 0) {
				newLocation = new Vector.<String>();
				//if (__stub != "") newLocation.push(__stub);
			} else {
				newLocation = currentLocationInternal.concat();
				//newLocation = currentLocationInternal.concat(__stub);
			}
			if (__stub != "") newLocation.push(__stub);

			//trace ("SpriteNavigator :: openSprite() :: "+__stub+" :: new location becomes /" + newLocation.join("/"));

			if (newLocation.length > 0) {
				// Wait for the parent to actually allow it
				locationWaitingToOpen = newLocation;
				var parentSprite:NavigableSprite = rootSprite.getChildByStubs(locationWaitingToOpen.slice(0, locationWaitingToOpen.length - 1));
				parentSprite.addEventListener(NavigableSpriteEvent.ALLOWED_TO_PRE_OPEN_CHILD, onSpriteAllowedToPreOpenChild);
				parentSprite.requestPermissionToPreOpenChild(__stub, navigationCommands.length);
			} else {
				// Just open it directly
				openSpriteByLocation(newLocation);
			}

		}

		protected static function openSpriteByLocation(__location:Vector.<String>, __allowedByParent:Boolean = false, __allowedBySelf:Boolean = false):void {
			//trace ("SpriteNavigator :: openSpriteByLocation() :: /"+__location.join("/"));

			// Opens the sprite
			var ns:NavigableSprite = rootSprite.getChildByStubs(__location);
			//trace ("SpriteNavigator :: openSprite() :: new area is " + ns);

			if (Boolean(ns)) {
				if (__location.length > 0 && !__allowedByParent) {
					// Request permission to really open first
					locationWaitingToOpen = __location;
					var parentSprite:NavigableSprite = rootSprite.getChildByStubs(__location.slice(0, __location.length - 1));
					parentSprite.addEventListener(NavigableSpriteEvent.ALLOWED_TO_OPEN_CHILD, onSpriteAllowedToOpenChild);
					parentSprite.requestPermissionToOpenChild(ns, navigationCommands.length);
				} else if (!__allowedBySelf) {
					locationWaitingToOpen = __location;
					ns.addEventListener(NavigableSpriteEvent.ALLOWED_TO_OPEN, onSpriteAllowedToOpen);
					ns.requestPermissionToOpen(navigationCommands.length-1);
				} else {
					// Finally, really opens it
					ns.addEventListener(NavigableSpriteEvent.OPENED, onOpenedNavigableSprite);

					var __isImmediate:Boolean = false; // TODO: when to use this?
					var __isLast:Boolean = navigationCommands.length == 0;
					ns.open(__isImmediate, __isLast);
				}
			} else {
				// Children doesn't exist, halt!
				trace ("SpriteNavigator :: ERROR! Impossible to create new children; halting execution");
				navigationCommands.length = 0;
				executeNextNavigationCommand();
			}
			//trace ("SpriteNavigator :: openSprite() :: done");
		}

		protected static function onSpriteAllowedToPreOpenChild(e:Event):void {
			rootSprite.getChildByStubs(locationWaitingToOpen.slice(0, locationWaitingToOpen.length - 1)).removeEventListener(NavigableSpriteEvent.ALLOWED_TO_PRE_OPEN_CHILD, onSpriteAllowedToPreOpenChild);
			var locationWaitingToOpenSafe:Vector.<String> = locationWaitingToOpen;
			locationWaitingToOpen = null;
			openSpriteByLocation(locationWaitingToOpenSafe);
		}

		protected static function onSpriteAllowedToOpenChild(e:Event):void {
			(e.target as NavigableSprite).removeEventListener(NavigableSpriteEvent.ALLOWED_TO_OPEN_CHILD, onSpriteAllowedToOpenChild);

			rootSprite.getChildByStubs(locationWaitingToOpen.slice(0, locationWaitingToOpen.length - 1)).removeEventListener(NavigableSpriteEvent.ALLOWED_TO_PRE_OPEN_CHILD, onSpriteAllowedToOpenChild);
			var locationWaitingToOpenSafe:Vector.<String> = locationWaitingToOpen;
			locationWaitingToOpen = null;
			openSpriteByLocation(locationWaitingToOpenSafe, true);
		}

		protected static function onSpriteAllowedToOpen(e:Event):void {
			(e.target as NavigableSprite).removeEventListener(NavigableSpriteEvent.ALLOWED_TO_OPEN, onSpriteAllowedToOpen);

			var locationWaitingToOpenSafe:Vector.<String> = locationWaitingToOpen;
			locationWaitingToOpen = null;
			openSpriteByLocation(locationWaitingToOpenSafe, true, true);
		}

		protected static function onSpriteAllowedToClose(e:Event):void {
			(e.target as NavigableSprite).removeEventListener(NavigableSpriteEvent.ALLOWED_TO_CLOSE, onSpriteAllowedToClose);
			closeSprite(true, true);
		}

		protected static function closeSprite(__allowedByParent:Boolean = false, __allowedBySelf:Boolean = false):void {
			// Close the current sprite, going up on the hierarchy

			//trace ("SpriteNavigator :: closeSprite()");

			var ns:NavigableSprite = rootSprite.getChildByStubs(currentLocationInternal);

			if (!__allowedByParent) {
				// Request permission to really close first
				var parentSprite:NavigableSprite = rootSprite.getChildByStubs(currentLocationInternal.slice(0, currentLocationInternal.length - 1));
				parentSprite.addEventListener(NavigableSpriteEvent.ALLOWED_TO_CLOSE_CHILD, onSpriteAllowedToCloseChild);
				parentSprite.requestPermissionToCloseChild(ns, navigationCommands.length);
			} else if (!__allowedBySelf) {
				ns.addEventListener(NavigableSpriteEvent.ALLOWED_TO_CLOSE, onSpriteAllowedToClose);
				ns.requestPermissionToClose(navigationCommands.length-1);
			} else {
				// Finally, really closes it
				ns.addEventListener(NavigableSpriteEvent.CLOSED, onClosedNavigableSprite);
				var __isImmediate:Boolean = false; // TODO: when to use this?
				var __isLast:Boolean = navigationCommands.length == 0;
				ns.close(__isImmediate,  __isLast);
				//var __isImmediate:Boolean = false; // TODO: when to use this?
				//ns.close(__isImmediate);
			}
		}

		protected static function onSpriteAllowedToCloseChild(e:Event):void {
			var parentSprite:NavigableSprite = rootSprite.getChildByStubs(currentLocationInternal.slice(0, currentLocationInternal.length - 1));
			parentSprite.removeEventListener(NavigableSpriteEvent.ALLOWED_TO_CLOSE_CHILD, onSpriteAllowedToCloseChild);
			closeSprite(true);
		}

		protected static function getLocationTitles(): Vector.<String> {
			// Returns a list of the titles of the of all NavigableSprites currently open
			var __currentLocation:Vector.<String> = Boolean(currentLocationInternal) ? currentLocationInternal : new Vector.<String>(); //getLocationAsVector(getLocation());
			var __titles:Vector.<String> = new Vector.<String>();

			var i:int;
			for (i = 0; i <= __currentLocation.length; i++) {
				__titles.push(rootSprite.getChildByStubs(__currentLocation.slice(0, i) as Vector.<String>).title);
			}
			return __titles;
		}

		protected static function getLocationAsVector(__location:String): Vector.<String> {
			// Based on an URL (for example, "/file/2000"), retorns a String Vector (for example, ["file", "2000"])
			var locs:Array = !Boolean(__location) || __location == "/" ? [] : __location.substr(1).split("/");

			var nlocs:Vector.<String> = new Vector.<String>();
			for (var i:int = 0; i < locs.length; i++) {
				nlocs.push(locs[i]); // ugh
			}

			return nlocs;
		}


		protected static function changeAddressIfNeeded():void {
			// Navigates from current location to the new one

			if (!executingNavigationCommand && targetLocations.length > 0) {
				var i:int;

				var __oldLocation:Vector.<String> = Boolean(currentLocationInternal) ? currentLocationInternal : new Vector.<String>();
				var __newLocation:Vector.<String> = getLocationAsVector(targetLocations.pop()); // go straight to it
				targetLocations.length = 0;

				// Checks how much of the path is common between the two
				var __similarLocation:Vector.<String> = new Vector.<String>();
				for (i = 0; i < __oldLocation.length; i++) {
					if (__newLocation.length <= i || __oldLocation[i] != __newLocation[i]) {
						break;
					} else {
						__similarLocation.push(__oldLocation[i]);
					}
				}

				// Creates a list of needed commands
				navigationCommands = new Vector.<String>();

				// TODO: implement NavigableSprite.canSwitchChildren!
				// TODO: implement some kind of NavigableSprite.openChild command instead of calling directly? maybe .prepareChild then .open?

				if (!Boolean(currentLocationInternal)) {
					navigationCommands.push("");
					currentLocationInternal = new Vector.<String>();
				}

				// Go back up...
				for (i = __oldLocation.length; i > __similarLocation.length; i--) {
					navigationCommands.push(COMMAND_UP);
				}

				// Then, go down on sprites as needed
				for (i = __similarLocation.length; i < __newLocation.length; i++) {
					navigationCommands.push(__newLocation[i]);
				}

				log("       oldLocation: [" + __oldLocation + "] (" + __oldLocation.length + ")");
				log("       newLocation: [" + __newLocation + "] (" + __newLocation.length + ")");
				log("   similarLocation: [" + __similarLocation + "] (" + __similarLocation.length + ")");
				log("navigationCommands: [" + navigationCommands.join(" -> ") + "]");

				// And starts by executing the next command
				if (!executingNavigationCommand) executeNextNavigationCommand();

		//		this._parent.mainTitle.setText(getAreaName(p_idx));

		//		SWFAddress.setValue(p_location);

				//currentLocationInternal = getLocation();
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected static function onAddressChange(e:Event):void {
		//protected static function onAddressChange(e:SWFAddressEvent):void {
			log("Location should change from [" + currentLocationInternal + "] ("+ (Boolean(currentLocationInternal) ? currentLocationInternal.length : "-") +") to [" + getLocation() + "]");
			targetLocations.push(getLocation());
			changeAddressIfNeeded();
		}

		protected static function onOpenedNavigableSprite(e:NavigableSpriteEvent):void {
			//trace ("SpriteNavigator :: onOpenedNavigableSprite :: " + e.target);
			var ns:NavigableSprite = e.target as NavigableSprite;
			if (ns != rootSprite) currentLocationInternal.push(ns.stub);
			ns.removeEventListener(NavigableSpriteEvent.OPENED, onOpenedNavigableSprite);
			executeNextNavigationCommand();
		}

		protected static function onClosedNavigableSprite(e:NavigableSpriteEvent):void {
			//trace ("SpriteNavigator :: onClosedNavigableSprite :: " + e.target);
			var ns:NavigableSprite = e.target as NavigableSprite;
			if (ns != rootSprite) currentLocationInternal.pop();
			ns.removeEventListener(NavigableSpriteEvent.CLOSED, onClosedNavigableSprite);
			executeNextNavigationCommand();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function start(__sprite:NavigableSprite):void {
			rootSprite = __sprite;
			/*FDT_IGNORE*/
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onAddressChange);
			/*FDT_IGNORE*/

			//rootSprite.open();
			//currentLocation = null;
			//navigationCommands = new Vector.<String>;
			//_commandList = new Array();
			//_currentLocation = "/";
			//_executingCommand = false;
		}

		public static function setLocation(__path:String):void {
			// Open a new location, like "/file/2000"
			log ("======================================================> SETTING as " + __path);
			lastCommandExecutedType = COMMAND_TYPE_DIRECT;
			/*FDT_IGNORE*/
			SWFAddress.setValue(__path);
			/*FDT_IGNORE*/
		}

		/*
		public static function setChildLocation(__childLocation:String):void {
			// Open a new sub-location, like "/2000" on "/file" to become "/file/2000"
			SWFAddress.setValue(getLocation() + "/" + __childLocation);
		}
		*/

		public static function getLocation(__forceCurrent:Boolean = false):String {
			if (__forceCurrent) {
				// Get the current navigation phase instead
				return Boolean(currentLocationInternal) ? "/" + currentLocationInternal.join("/") : "/";
			}
			var loc:String;
			/*FDT_IGNORE*/
			loc = SWFAddress.getValue();
			/*FDT_IGNORE*/
			//log("current location from SWFAddress is [" + loc + "]");
			// Quick and dirty method to remove trailing slash
			if (loc.substr(-1,1) == "/") loc = loc.substr(0, loc.length-1);
			return loc;
		}

		public static function getTitle():String {
			var titles:Vector.<String> = getLocationTitles();
			var lastTitle:String = "";

			// Get last title that is not empty
			var i:int = titles.length - 1;
			while (i >= 0) {
				if (Boolean(titles[i])) {
					lastTitle = titles[i];
					break;
				}
				i--;
			}

			return useLastTitleOnly ? lastTitle : titles.join(titleSeparator);
		}

		/*
		// Only works on opera?
		public static function setStatus(__message:String):void {
			SWFAddress.setStatus(__message);
		}

		public static function resetStatus():void {
			SWFAddress.resetStatus();
		}
		*/

		// EventDispatcher extensions
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function dispatchEvent(event:Event):Boolean {
			return eventDispatcher.dispatchEvent(event);
		}

		public static  function hasEventListener(type:String):Boolean {
			return eventDispatcher.hasEventListener(type);
		}

		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}

		public static function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}

		// SWFAddress extensions
		public static function goBack():void {
			lastCommandExecutedType = COMMAND_TYPE_BACK;
			/*FDT_IGNORE*/
			SWFAddress.back();
			/*FDT_IGNORE*/
		}

		public static function goForward():void {
			lastCommandExecutedType = COMMAND_TYPE_FORWARD;
			/*FDT_IGNORE*/
			SWFAddress.forward();
			/*FDT_IGNORE*/
		}

		public static function goUp():void {
			lastCommandExecutedType = COMMAND_TYPE_UP;
			/*FDT_IGNORE*/
			SWFAddress.up();
			/*FDT_IGNORE*/
		}
	}
}

/*
class MovieNavigator extends MovieClip {

	// Constantes
	private static var _rootPos:MovieClip;					// Onde os movieclips tão localizados
	private static var _commandList:Array;					// Listagem de comandos que têm de ser executados

	// Propriedades
	private static var _currentLocation:String;				// Localização atual
	private static var _executingCommand:Boolean;				// Se já está executando um comando de hop ou não

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function MovieNavigator() {
		trace("This is an static class and there it can't be instantiated.");
	}

	public static function setRootMovie(p_movie:MovieClip):void {
		_rootPos = p_movie;
		_commandList = new Array();
		_currentLocation = "/";
		_executingCommand = false;
	}


	// ================================================================================================================
	// EVENT functions ------------------------------------------------------------------------------------------------


	// ================================================================================================================
	// INSTANCE functions ---------------------------------------------------------------------------------------------

	public static function getLocation():String {
		// Retorna a localização atual
		return _currentLocation;
	}

	public static function setLocationDirectly(p_location:String):void {
		// Seta a nova localização (exemplo: "/arquivo/1992"), indo direto pra lá, baseado na posição atual, sem ativar o SWFAddress

		if (_rootPos == undefined) return; // Ainda não foi inicializado

		var i:Number;

		if (p_location == "") {
			// Abrir default
			var $areas = _global.areas.areas[0].area;
			for (i = 0; i < $areas.length; i++){
				if ($areas[i]["default"][0].toString() == "true") {
					p_location = "/" + $areas[i].id[0].toString();
					break;
				}
			}
		}

//		if (p_location == "") p_location = "/videos";
//		if (p_location == "") p_location = "/colecoes"; // *******
//		if (p_location == "") p_location = "/videos"; // *******
//		if (p_location == "") p_location = "/parcerias"; // *******

		//trace ("MovieNavigator :: setLocationDirectly ["+p_location+"] (atual é "+_currentLocation+")");

		var $oldLocation:Array = getLocationArray(_currentLocation);
		var $newLocation:Array = getLocationArray(p_location);

		// Fix hardcoded
		if (_currentLocation == "/") $oldLocation = new Array();

		// Checa quanto da URL é comum entre os dois
		var $similarLocation:Array = new Array();
		for (i = 0; i < $oldLocation.length; i++) {
			if ($oldLocation[i] != $newLocation[i]) {
				break;
			} else {
				$similarLocation.push($oldLocation[i]);
			}
		}

		// Faz a lista de comandos necessários
		_commandList = new Array();

		// Vai voltando...
		for (i = $oldLocation.length; i > $similarLocation.length; i--) {
			_commandList.push("..");
		}

		// Agora entra nos movieclips correspondentes
		for (i = $similarLocation.length; i < $newLocation.length; i++) {
			_commandList.push($newLocation[i]);
		}

//		trace ("MovieNavigator ::     oldLocation: " + $oldLocation);
//		trace ("MovieNavigator ::     newLocation: " + $newLocation);
//		trace ("MovieNavigator :: similarLocation: " + $similarLocation);
//		trace ("MovieNavigator ::     commandList: " + _commandList.join(" -> "));

		// E manda executar o próximo comando
		if (!_executingCommand) executeNextCommand();

//		this._parent.mainTitle.setText(getAreaName(p_idx));

//		SWFAddress.setValue(p_location);
	}

	public static function executeNextCommand():Void {
		// Executa o próximo comando da _commandList, em ordem
		if (_commandList.length > 0) {
			_executingCommand = true;
			var $nextCommand = _commandList.shift(1);
		//	trace ("MovieNavigator :: executeNextCommand :: "+$nextCommand);
			if ($nextCommand == "..") {
				goUp();
			} else {
				openMovie($nextCommand);
			}
			// Seta a posição do menu principal
			var $locations:Array = getLocationArray(_currentLocation);
			if (_commandList.length == 0) _root.areaMenu.head.setPosFromId($locations[0]);

			// Seta título
			updateTitles();

//			if (_commandList.length == 0) {
//				_executingCommand = false;
//			}
		} else {
			// Terminou de executar os comandos
			_executingCommand = false;
//			trace ("----------------------- end exec");
		}
	}

	public static function updateTitles():void {
		// Atualiza os títulos necessários
		if (getCurrentTopLocation().simpleMenu[0].toString() == "true") {
			// Sem texto
			_root.mainTitle.setText("");
		} else {
			// Com texto
			_root.mainTitle.setText(getLocationNames()); // ugh
		}
		_root.logotype.setVisibility(getCurrentTopLocation().hideLogo[0].toString() != "true");
		//_root.mainTitle.setColor(getLocationColor());
		//_root.logotype.setColor(getLocationColor());
		//SWFAddress.setTitle("Alexandre Herchcovitch - " + getLocationNames(true));
		SWFAddress.setTitle("HERCHCOVITCH;ALEXANDRE " + getLocationNames(true).toUpperCase());
	}

	private static function goUp():Void {
		// Volta pra um Movie anterior

		var $oldMovie:NavigableMovie = _rootPos.getChild(getLocationArray(_currentLocation));

		// Seta a nova localização
		var $location:Array = getLocationArray(_currentLocation);
		$location.pop();
		_currentLocation = "/" + $location.join("/");

		// Aí fecha o movie
		$oldMovie.hide();
	}

	private static function openMovie(movie:String):Void {
		// Abre um movie

		// Seta a nova localização
		if (_currentLocation == "/") {
			_currentLocation += movie;
		} else {
			_currentLocation += "/" + movie;
		}

		// E aí abre o movie
		_rootPos.getChild(getLocationArray(_currentLocation)).show();
	}

//	private static function getLocationColor():Number {
//		// Retorna a cor da seção atual
//		return parseInt(getCurrentTopLocation().mainColor[0].toString().substr(1), 16);
//	}

	private static function getCurrentTopLocation(): Object {
		// Acha a localização top (área) atual
		var $lst:Array = getLocationArray(_currentLocation);
		var $id = $lst[0];
		for (var i:Number = 0; i < _global.areas.areas[0].area.length; i++){
			if (_global.areas.areas[0].area[i].id[0].toString() == $id) {
				return _global.areas.areas[0].area[i];
			}
		}
		return undefined;
	}

	private static function getLocationColor():Number {
		// Retorna a cor da seção atual
		var $lst:Array = getLocationArray(_currentLocation);
		var $id = $lst[0];
		for (var i:Number = 0; i < _global.areas.areas[0].area.length; i++){
			if (_global.areas.areas[0].area[i].id[0].toString() == $id) {
				return parseInt(_global.areas.areas[0].area[i].mainColor[0].toString().substr(1), 16);
			}
		}
		return undefined;
	}

	private static function getLocationArray(p_location:String): Array {
		// Baseado numa URL (por exemplo, "/arquivo/2000"), retorna um array de strings (por exemplo, "arquivo","2000")
		var $sArray:Array = p_location.substr(1).split("/");
		if (p_location == "/") $sArray = new Array();
		return $sArray;
	}

	private static function getLocationNames(longOnly:Boolean):String {
		// Pega o nome de todas as seções abertas
		var $newName:String = "";
		var $currentLocation:Array = getLocationArray(_currentLocation);

		var i:Number, j:Number;
		for (i = 0; i < $currentLocation.length; i++) {
			var $child:Array = new Array();
			for (j = 0; j <= i; j++) {
				$child.push ($currentLocation[j]);
			}
			$newName += _rootPos.getChild($child).getTitle(longOnly);
			if (i < $currentLocation.length-1) $newName += " / ";
		}
		return $newName;
	}

	// ================================================================================================================
	// Funções pra uso público real -----------------------------------------------------------------------------------

	public static function openSubLocationAddress(p_location:String):void {
		// Abre um endereço inferior (tipo "i1996f" a partir do "/arquivo" pra virar "/arquivo/i1996f")
		SWFAddress.setValue(_currentLocation + "/" + p_location);
	}

	public static function setLocation(p_location:String):void {
		// Abre um endereço absoluto, tipo "/colecoes/1997i"
	//	trace ("MovieNavigator :: setLocation "+p_location+" (atual é "+_currentLocation+")");
		SWFAddress.setValue(p_location);
	}

}
*/