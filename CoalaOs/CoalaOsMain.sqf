/*
	File: CoalaOsMain.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

/*    ___..._           _...___
	   /'--.._ `'-="""=-'` _..--'\
	   |   ~. )  _     _  ( .~   |
	    \  '~/   a  _  a   \~'  /
	     \  `|     / \     |`  /
	      `'--\    \_/    /--'`
	          .'._  J__.-'.
	         / /  '-/_ `-  \
	        / -"-'-.  '-.__/
	        \__,-.\/     | `\
	        /  ;---.  .--'   |
	       |     /\'-'      /
	       '.___.\   _.--;'`)
              '-'     `"*/
coalaFunctionsInit = execVM "CoalaOs\CoalaOsFunctions.sqf";
coalaHandlerInit = execVM "CoalaOs\CoalaOsHandler.sqf";
coalaFileInit = execVM "CoalaOs\CoalaOsFileStructure.sqf";
coalaDefaultWebPage = "CoalaOs\Web\index.html";
coalaDebug = true;
_coalaOpenPrograms = missionNamespace getVariable ["CoalaLastOpenPrograms", []];

fnCoala_debug = {
	// "debug_console" callExtension ((_this select 0) + "#1111");
};

waitUntil {
	scriptDone coalaFunctionsInit && scriptDone coalaHandlerInit && scriptDone coalaFileInit
};

_laptop = "Land_SOG_Tablet" createVehicle position player;
_laptop attachTo [player, [-0.03125, 0.3, 0.125], "head"];
_laptop setDir (180);
hideObject _laptop;

_ok = createDialog "LaptopBase";

sleep 0.10;
closeDialog 2;

_ok = createDialog "LaptopBase";
// _CRLF = toString [0x0D, 0x0A];
// _welcomeText = format ["Coala OS [Version 1.34.483]%1Copyright (c) 2015 Legion Corporation. All rights reserved. jk.%1%1%2 ", _CRLF, coala_currentFolderName];
// ctrlSetText [1400, _welcomeText];

[_coalaOpenPrograms] execVM "CoalaOs\CoalaOsReOpenPrograms.sqf";

waitUntil {
	(!dialog) or (!alive player)
}; // hit ESC to close it

if (!alive player) then {
	closeDialog 2;
};

// kill remaining processes
{
	call compile format ["[%2] call fnCoala_stop%1", _x select 4, _x select 1];
} forEach coala_ActivePrograms;
missionNamespace setVariable ["CoalaLastOpenPrograms", coala_ActivePrograms];

deleteVehicle _laptop;
// coalaDisplay displayRemoveAllEventHandlers "MouseMoving";
// coalaDisplay displayRemoveAllEventHandlers "MouseButtonUp";