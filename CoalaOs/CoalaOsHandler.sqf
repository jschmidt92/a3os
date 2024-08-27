/*
	File: CoalaOsHandler.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

coalaVideoPlayer = nil;
coalaImageViewer = nil;
coalaLifeFeed = nil;
coalaDisplay = nil;
coalaConsole = nil;

myDrinkLoad = {
	private ["_display", "_idc", "_ctrl"];
	_display = _this select 0;
	coalaDisplay = _display;
	_idc = -1;
	_ctrl = _display displayCtrl _idc;
	_this select 0 displayCtrl -1 ctrlEnable false;

	[] execVM "CoalaOs\Drawing\CoalaOsWindowManager.sqf";
	[] call fnCoala_drawBackgroundImage;
	[] call fnCoala_DrawDesktop;

	_keyDown = _display displayAddEventHandler ["KeyDown", {}];
	_keyUp = _display displayAddEventHandler ["KeyUp", {}];
};