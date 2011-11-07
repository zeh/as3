package com.zehfernando.utils.air {

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class NativeMenuUtils {

		protected static var isInited:Boolean;
		protected static var menuInstance:NativeMenuAgent;

		public function NativeMenuUtils() {
		}

		// ================================================================================================================
		// INITIALIZATION functions ---------------------------------------------------------------------------------------

		public static function init(): void {
			if (!isInited) {
				menuInstance = new NativeMenuAgent();
				isInited = true;
			}
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public static function setMenu(__menuInstance:NativeMenuAgent): void {
			menuInstance = __menuInstance;
		}

		public static function getMenu(): NativeMenuAgent {
			return menuInstance;
		}
	}
}

import com.zehfernando.utils.AppUtils;

import org.ffnnkk.editor.data.MenuItemInfo;
import org.ffnnkk.events.InterfaceEvent;

import flash.desktop.NativeApplication;
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.events.EventDispatcher;

class NativeMenuAgent extends EventDispatcher {

	protected static var nativeMenu:NativeMenu;

	protected var _enabled:Boolean;

	protected var menuData:MenuItemInfo;

	protected var _shortcutsEnabled:Boolean;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function NativeMenuAgent() {
		if (NativeApplication.supportsMenu) {
			// Mac
			nativeMenu = NativeApplication.nativeApplication.menu;
		} else {
			// PC & etc
			nativeMenu = new NativeMenu();
			AppUtils.getStage()["nativeWindow"].menu = nativeMenu;
		}

		_shortcutsEnabled = false;
		menuData = new MenuItemInfo();
		enabled = true;

		// http://livedocs.adobe.com/flex/3/html/help.html?content=Menus_2.html
		// http://www.adobe.com/devnet/air/flex/articles/flickr_floater_08.html
	}

	// ================================================================================================================
	// INSTANCE functions ---------------------------------------------------------------------------------------------

	public function addItem(__itemInfo:MenuItemInfo): void {
		menuData.addItem(__itemInfo);

		if (__itemInfo.visible) {
			var item:NativeMenuItem = createItem(__itemInfo);
			nativeMenu.addItem(item);
		}
	}

	protected function createItem(__itemInfo:MenuItemInfo): NativeMenuItem {

		var __item:NativeMenuItem;

		if (__itemInfo.caption == "") {
			// Separator
			__item = new NativeMenuItem("", true);
		} else {
			// Normal item
			__item = new NativeMenuItem(__itemInfo.caption, false);
//			__item.enabled = __itemInfo.enabled; // featured on onMenuDisplay below
//			__item.checked = __itemInfo.checked; // featured on onMenuDisplay below
//			__item.selected = __itemInfo.selected; // featured on onMenuDisplay below
//			__item.visible = __itemInfo.visible; // check for __itemInfo.visible happens above - ONLY WORKS WHEN THE MENU IS CREATED
			//__item.hasTriangle = __itemInfo.items.length > 0;
			__item.keyEquivalent = __itemInfo.keyEquivalent;
			__item.keyEquivalentModifiers = __itemInfo.keyEquivalentModifiers;
			if (!isNaN(__itemInfo.mnemonicIndex)) __item.mnemonicIndex = __itemInfo.mnemonicIndex;
			//__item.mnemonicIndex = 0;
		}

		if (__itemInfo.items.length > 0) {
			__item.submenu = new NativeMenu();

			for (var i:Number = 0; i < __itemInfo.items.length; i++) {
				if (__itemInfo.items[i].visible) __item.submenu.addItem(createItem(__itemInfo.items[i]));
			}
		}

		__item.data = __itemInfo;
		__item.addEventListener(Event.SELECT, onMenuSelect);
		__item.addEventListener(Event["DISPLAYING"], onMenuDisplay);

		return __item;
	}

	/*
	public function createFileMenu():NativeMenu {
		var fileMenu:NativeMenu = new NativeMenu();
		fileMenu.addEventListener(Event.SELECT, onMenuSelectNative);

		var newCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("New"));
		newCommand.addEventListener(Event.SELECT, onMenuSelectNative);
		var saveCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Save"));
		saveCommand.addEventListener(Event.SELECT, onMenuSelectNative);
		var openRecentMenu:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Open Recent"));
		openRecentMenu.submenu = new NativeMenu();
		//openRecentMenu.submenu.addEventListener(Event.DISPLAYING, updateRecentDocumentMenu);
		openRecentMenu.submenu.addEventListener(Event.SELECT, onMenuSelectNative);

		return fileMenu;
	}
	*/

	public function getMenuItemInfo(__id:String): MenuItemInfo {
		return menuData.getById(__id);
	}

	protected function enableShortcuts():void {
		if (!_shortcutsEnabled) {
//			AppUtils.getStage().addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
			_shortcutsEnabled = true;
		}
	}

	protected function disableShortcuts():void {
		if (_shortcutsEnabled) {
//			AppUtils.getStage().removeEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
			_shortcutsEnabled = false;
		}
	}

	// ================================================================================================================
	// EVENT functions ------------------------------------------------------------------------------------------------

	protected function onMenuSelect(e:Event): void {
		//Logger.getInstance().addMessage("AirEditor :: pick menu & execute :: "+e);
		if (_enabled && _shortcutsEnabled) {
			var ie:InterfaceEvent = new InterfaceEvent(InterfaceEvent.SELECT, this);
			ie.data = NativeMenuItem(e.target).data;
			dispatchEvent(ie);
		}
	}

	protected function onMenuDisplay(e:Event): void {
		var mi:NativeMenuItem = NativeMenuItem(e.target);
		var ii:MenuItemInfo = MenuItemInfo(mi.data);
		mi.enabled = ii.enabled;
		mi.checked = ii.checked || ii.selected; // TODO: support selected?
		//mi.selected =
		//mi.visible
	}

	// ================================================================================================================
	// ACCESSOR functions ---------------------------------------------------------------------------------------------

	public function get shortcutsEnabled():Boolean {
		return _shortcutsEnabled;
	}
	public function set shortcutsEnabled(__value:Boolean):void {
		if (__value != _shortcutsEnabled) {
			if (__value) {
				enableShortcuts();
			} else {
				disableShortcuts();
			}
		}
	}

	public function get enabled():Boolean {
		return _enabled;
	}
	public function set enabled(__value:Boolean):void {
		for (var i:Number = 0; i < nativeMenu.numItems; i++) {
			nativeMenu.items[i].checked = __value; // TODO: this must take into consideration each item's .checked property
		}
		_enabled = __value;
	}
}