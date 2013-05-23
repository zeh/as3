package com.zehfernando.controllers.gamecontroller {
	/**
	 * @author zeh fernando
	 */
	public interface IGameObject {
		function update(__timePassedMS:int, __totalTimePassedMS:int):void;
		function dispose():void;
		function pause():void;
		function resume():void;
	}
}
