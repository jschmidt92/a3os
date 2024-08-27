/*
	File: CoalaOsMDT.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

params ["_parameters", "_processId", "_fileName"];

SOG_tempDb = missionNamespace getVariable ["SOG_tempDb", []];

fnCoala_startmdt = {
	_width = 46.5;
	_height = 21.5;
	_x = -2;
	_y = 1;

	if (count _parameters > 2) then {
		_x = parseNumber (_parameters select 2);
		_y = parseNumber (_parameters select 3);
	};

	_programWindow = [_x, _y, _width, _height, _fileName] call fnCoala_DrawWindow;
	[_programWindow select 0, _processId, "processID"] call fnCoala_addVariableToControl;

	_pos = ctrlPosition (_programWindow select 0);
	_prog = ([_processId] call fnCoala_getProgramEntryById);
	_prog set [7, [(_pos select 0) / GUI_GRID_W + GUI_GRID_X, (_pos select 1) / GUI_GRID_H + GUI_GRID_Y]];

	_backgroundCtrl = ["RscText", "", 0, 0, 0, 0] call addCtrl;
	_backgroundCtrl ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
	[_programWindow select 0, _backgroundCtrl, [0, 0, _width - 0, _height - 1.25]] call fnCoala_addControlToWindow;

	_map = ["RscMapControl", "", 0, 0, 0, 0, 001] call addStaticCtrl;
	ctrlShow [001, false];
	[_programWindow select 0, _map, [0, 0, _width - 0, _height - 2.75]] call fnCoala_addControlToWindow;
	_map ctrlAddEventHandler ["Draw", {
		{
			_items = items _x;
			_device = ["SOG_Tablet"];
			if (((playerSide == side _x) || (side player == side _x)) && ((_device findIf { _x in _items } > -1) || ((commander vehicle _x == _x) && (vehicle _x != _x)))) then {
				_name = name _x;
				if ((commander vehicle _x == _x) && (vehicle _x != _x)) then {
					_name = format ["%1 - %2", _name, getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "displayname")];
				};

				private _puid = getPlayerUID _x;
				private _status = [SOG_tempDb, ["players", _puid, "status"], "available"] call BIS_fnc_dbValueReturn;

				switch (_status) do {
					case "busy": {
						_this select 0 drawIcon [getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "icon"), [1, 0.5, 0, 0.7], getPos _x, 40, 40, getDir _x, _name, 1, 0.05, "TahomaB", "right"];
					};
					case "unavailable": {
						_this select 0 drawIcon [getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "icon"), [1, 0, 0, 0.7], getPos _x, 40, 40, getDir _x, _name, 1, 0.05, "TahomaB", "right"];
					};
					case "available": {
						_this select 0 drawIcon [getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "icon"), [0, 0.5, 0.5, 0.7], getPos _x, 40, 40, getDir _x, _name, 1, 0.05, "TahomaB", "right"];
					};
					case "enroute": {
						_this select 0 drawIcon [getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "icon"), [0, 0, 1, 0.7], getPos _x, 40, 40, getDir _x, _name, 1, 0.05, "TahomaB", "right"];
					};
					case "onscene": {
						_this select 0 drawIcon [getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "icon"), [0, 1, 0, 0.7], getPos _x, 40, 40, getDir _x, _name, 1, 0.05, "TahomaB", "right"];
					};
					case "panic": {
						_this select 0 drawIcon [getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "icon"), [1, 0.27, 0, 0.7], getPos _x, 40, 40, getDir _x, _name, 1, 0.05, "TahomaB", "right"];
					};
					default {
						_this select 0 drawIcon [getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "icon"), [0, 0, 0.7, 0.7], getPos _x, 40, 40, getDir _x, _name, 1, 0.05, "TahomaB", "right"];
					};
				};
			};
		} forEach playableUnits;
	}];

	_playerList = ["RscListBox", "", 0, 0, 0, 0, 002] call addStaticCtrl;
	_playerList ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.75];
	ctrlShow [002, false];

	_contractList = ["RscListBox", "", 0, 0, 0, 0, 003] call addStaticCtrl;
	_contractList ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.75];
	ctrlShow [003, false];

	_allPlayers = [];
	{
		private _puid = getPlayerUID _x;
		private _status = [SOG_tempDb, ["players", _puid, "status"], "available"] call BIS_fnc_dbValueReturn;

		if ('SOG_Tablet' in (items _x)) then {
			_index1 = lbAdd [002, (format ["%1", (name _x)])];
		};
	} forEach playableUnits;
	[_programWindow select 0, _playerList, [8, 1.5, 30, _height - 4.25]] call fnCoala_addControlToWindow;

	missionNamespace setVariable [format ["%1%2", _playerList, "players"], _allPlayers];
	missionNamespace setVariable [format ["%1%2", _playerList, "processId"], _processId];
	missionNamespace setVariable [format ["%1%2", _processId, "programActive"], "1"];
	lbSetCurSel [002, 0];

	[_processId, _playerList] spawn fnCoala_heartbeat;

	_allContracts = [];
	{
		private _puid = getPlayerUID _x;
		private _status = [SOG_tempDb, ["players", _puid, "status"], "available"] call BIS_fnc_dbValueReturn;

		if ('SOG_Tablet' in (items _x)) then {
			_index1 = lbAdd [003, (format ["%1", (name _x)])];
		};
	} forEach playableUnits;
	[_programWindow select 0, _contractList, [8, 1.5, 30, _height - 4.25]] call fnCoala_addControlToWindow;

	missionNamespace setVariable [format ["%1%2", _contractList, "players"], _allContracts];
	missionNamespace setVariable [format ["%1%2", _contractList, "processId"], _processId];
	missionNamespace setVariable [format ["%1%2", _processId, "programActive"], "1"];
	lbSetCurSel [003, 0];

	[_processId, _contractList] spawn fnCoala_heartbeat;

	_btn1 = ["RscButton", "Busy", 0, 0, 0, 0, 010] call addStaticCtrl;
	_btn1 ctrlSetBackgroundColor [1, 0.5, 0, 1];
	_btn1 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn1, [8, 0.25, 5, 1]] call fnCoala_addControlToWindow;
	_btn1 ctrlAddEventHandler ["MouseButtonDown", {
		private _uid = getPlayerUID player;
		"ArmaSOGClient" callExtension ["save_status", [_uid, "busy"]];
	}];
	
	_btn2 = ["RscButton", "Unavailable", 0, 0, 0, 0, 011] call addStaticCtrl;
	_btn2 ctrlSetBackgroundColor [1, 0, 0, 1];
	_btn2 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn2, [13, 0.25, 5, 1]] call fnCoala_addControlToWindow;
	_btn2 ctrlAddEventHandler ["MouseButtonDown", {
		private _uid = getPlayerUID player;
		"ArmaSOGClient" callExtension ["save_status", [_uid, "unavailable"]];
	}];

	_btn3 = ["RscButton", "Available", 0, 0, 0, 0, 012] call addStaticCtrl;
	_btn3 ctrlSetBackgroundColor [0, 0.5, 0.5, 1];
	_btn3 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn3, [18, 0.25, 5, 1]] call fnCoala_addControlToWindow;
	_btn3 ctrlAddEventHandler ["MouseButtonDown", {
		private _uid = getPlayerUID player;
		"ArmaSOGClient" callExtension ["save_status", [_uid, "available"]];
	}];

	_btn4 = ["RscButton", "Enroute", 0, 0, 0, 0, 013] call addStaticCtrl;
	_btn4 ctrlSetBackgroundColor [0, 0, 1, 1];
	_btn4 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn4, [23, 0.25, 5, 1]] call fnCoala_addControlToWindow;
	_btn4 ctrlAddEventHandler ["MouseButtonDown", {
		private _uid = getPlayerUID player;
		"ArmaSOGClient" callExtension ["save_status", [_uid, "enroute"]];
	}];

	_btn5 = ["RscButton", "On Scene", 0, 0, 0, 0, 014] call addStaticCtrl;
	_btn5 ctrlSetBackgroundColor [0, 1, 0, 1];
	_btn5 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn5, [28, 0.25, 5, 1]] call fnCoala_addControlToWindow;
	_btn5 ctrlAddEventHandler ["MouseButtonDown", {
		private _uid = getPlayerUID player;
		"ArmaSOGClient" callExtension ["save_status", [_uid, "onscene"]];
	}];

	_btn6 = ["RscButton", "Panic", 0, 0, 0, 0, 015] call addStaticCtrl;
	_btn6 ctrlSetBackgroundColor [1, 0.27, 0, 1];
	_btn6 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn6, [33, 0.25, 5, 1]] call fnCoala_addControlToWindow;
	_btn6 ctrlAddEventHandler ["MouseButtonDown", {
		private _uid = getPlayerUID player;
		"ArmaSOGClient" callExtension ["save_status", [_uid, "panic"]];
	}];

	btnGroupStatic = [010, 011, 012, 013, 014, 015];

	_btn7 = ["RscButton", "Dashboard", 0, 0, 0, 0] call addCtrl;
	_btn7 ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
	_btn7 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn7, [0.25, 19, 5, 1]] call fnCoala_addControlToWindow;
	_btn7 ctrlAddEventHandler ["MouseButtonDown", {
		ctrlShow [001, false];
		ctrlShow [002, false];
		ctrlShow [003, false];
		{
			ctrlShow [_x, true];
		} forEach btnGroupStatic;
	}];

	_btn8 = ["RscButton", "Live Map", 0, 0, 0, 0] call addCtrl;
	_btn8 ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
	_btn8 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn8, [5.25, 19, 5, 1]] call fnCoala_addControlToWindow;
	_btn8 ctrlAddEventHandler ["MouseButtonDown", {
		ctrlShow [001, true];
		ctrlShow [002, false];
		ctrlShow [003, false];
		{
			ctrlShow [_x, false];
		} forEach btnGroupStatic;
	}];

	_btn9 = ["RscButton", "Active Units", 0, 0, 0, 0] call addCtrl;
	_btn9 ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
	_btn9 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn9, [10.25, 19, 5, 1]] call fnCoala_addControlToWindow;
	_btn9 ctrlAddEventHandler ["MouseButtonDown", {
		ctrlShow [001, false];
		ctrlShow [002, true];
		ctrlShow [003, false];
		{
			ctrlShow [_x, false];
		} forEach btnGroupStatic;
	}];

	_btn10 = ["RscButton", "Active Contracts", 0, 0, 0, 0] call addCtrl;
	_btn10 ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
	_btn10 ctrlSetTextColor [1, 1, 1, 1];
	[_programWindow select 0, _btn10, [15.25, 19, 6, 1]] call fnCoala_addControlToWindow;
	_btn10 ctrlAddEventHandler ["MouseButtonDown", {
		ctrlShow [001, false];
		ctrlShow [002, false];
		ctrlShow [003, true];
		{
			ctrlShow [_x, false];
		} forEach btnGroupStatic;
	}];
};

fnCoala_heartbeat = {
	params ["_processId", "_control"];
	_active = missionNamespace getVariable format ["%1%2", _processId, "programActive"];

	while { _active == "1" } do {
		sleep 5;

		lbClear _control;
		_allPlayers = [];
		{
			private _puid = getPlayerUID _x;
			private _status = [SOG_tempDb, ["players", _puid, "status"], "available"] call BIS_fnc_dbValueReturn;

			if ('SOG_Tablet' in (items _x)) then {
				_allPlayers pushBack [_x, name _x];
				private _color = [1, 1, 1, 1];
				switch (_status) do {
					case "busy": { _color = [1, 0.5, 0, 1]; };
					case "unavailable": { _color = [1, 0, 0, 1]; };
					case "available": { _color = [0, 0.5, 0.5, 1]; };
					case "enroute": { _color = [0, 0, 1, 1]; };
					case "onscene": { _color = [0, 1, 0, 1]; };
					case "panic": { _color = [1, 0.27, 0, 1]; };
				};
				private _index = _control lbAdd (format ["%1", (name _x)]);
				_control lbSetColor [_index, _color];
			};
		} forEach playableUnits;
		missionNamespace setVariable [format ["%1%2", _control, "players"], _allPlayers];
		
		_active = missionNamespace getVariable format ["%1%2", _processId, "programActive"];
	};
};

// fnCoala_heartbeat = {
// 	params ["_processId", "_control"];
// 	_active = missionNamespace getVariable format ["%1%2", _processId, "programActive"];

// 	while { _active == "1" } do {
// 		sleep 5;

// 		lbClear _control;
// 		_allPlayers = [];
// 		{
// 			private _puid = getPlayerUID _x;
// 			private _status = [SOG_tempDb, ["players", _puid, "status"], "available"] call BIS_fnc_dbValueReturn;

// 			if ('SOG_Tablet' in (items _x)) then {
// 				_allPlayers pushBack [_x, name _x];
// 				_control lbAdd (format ["%1	%2", (name _x), _status]);
// 			};
// 		} forEach playableUnits;
// 		missionNamespace setVariable [format ["%1%2", _control, "players"], _allPlayers];
		
// 		_active = missionNamespace getVariable format ["%1%2", _processId, "programActive"];
// 	};
// };

fnCoala_stopmdt = {};

call fnCoala_startmdt;