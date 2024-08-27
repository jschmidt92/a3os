/*
	File: CoalaOsWindowFMS.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

_width = 46.5;
_height = 21.5;
_x = -2;
_y = 1;

_standartURL = "https://spearnet.mil/portal/fleet-military-surplus";
_newWindow = [_x, _y, _width, _height, "Portal - Fleet Military Surplus Store"] call fnCoala_DrawWindow;

_backgroundCtrl = ["RscText", "", 0, 0, 0, 0] call addCtrl;
_backgroundCtrl ctrlSetBackgroundColor [1, 1, 1, 1];
[_newWindow select 0, _backgroundCtrl, [0, 0, _width - 0, _height - 1.25]] call fnCoala_addControlToWindow;

_url = ["RscEdit", _standartURL, 0, 0, 0, 0] call addCtrl;
_url ctrlSetBackgroundColor [0.25, 0.25, 0.25, 1];
_url ctrlSetTextColor [1, 1, 1, 1];
[_newWindow select 0, _url, [0.1, 0.2, _width - 5.5, 1.5]] call fnCoala_addControlToWindow;

_changeSiteButton = ["RscButton", "Go", 0, 0, 0, 0] call addCtrl;
_changeSiteButton ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
[_newWindow select 0, _changeSiteButton, [_width - 5.4, 0.2, 5.4, 1.5]] call fnCoala_addControlToWindow;

missionNamespace setVariable [ format ["%1url", str (_changeSiteButton)], _url];