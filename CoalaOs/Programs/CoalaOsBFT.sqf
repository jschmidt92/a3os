/*
	File: CoalaOsBFT.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

params ["_parameters", "_processId", "_fileName"];

fnCoala_startbluefortracker = {
	_width = 30;
	_height = 20.25;
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

	_map = ["RscMapControl", "", 0, 0, 0, 0] call addCtrl;
	[_programWindow select 0, _map, [0, 0, _width, _height - 1.5]] call fnCoala_addControlToWindow;

	_map ctrlAddEventHandler ["Draw", {
		{
			_items = items _x;
			_device = ["SOG_Tablet"];
			if (((playerSide == side _x) || (side player == side _x)) && ((_device findIf { _x in _items } > -1) || ((commander vehicle _x == _x) && (vehicle _x != _x)))) then {
				_name = name _x;
				if ((commander vehicle _x == _x) && (vehicle _x != _x)) then {
					_name = format ["%1 - %2", _name, getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "displayname")];
				};
				_this select 0 drawIcon [getText (configFile >> "CfgVehicles" >> typeOf (vehicle _x) >> "icon"), [0, 0, 0.7, 0.7], getPos _x, 40, 40, getDir _x, _name, 1, 0.05, "TahomaB", "right"];
			};
		} forEach allUnits;
	}];
	_map ctrlAddEventHandler ["MouseButtonDblClick", {
		_WorldCoord = (_this select 0) posScreenToWorld [_this select 2, _this select 3];
		
		if (isNil "BFT_MarkerCount") then { BFT_MarkerCount = 0; };
		BFT_MarkerCount = BFT_MarkerCount + 1;
		
		// hint format ["%1 %2", str (_WorldCoord select 0), str (_WorldCoord select 1)];

		_markerName = format ["_USER_DEFINED #%1/%2/%3", clientOwner, BFT_MarkerCount, 1];
		_marker = createMarker [_markerName, _WorldCoord];
		_marker setMarkerShape "ICON";
		_marker setMarkerType "hd_dot";
		_marker setMarkerSize [1, 1];
		_marker setMarkerPos (_WorldCoord);
		_marker setMarkerColor "ColorBlack";
		// _marker setMarkerTextLocal (format ["%1", _markerName]);
	}];
};

fnCoala_stopbluefortracker = {};

call fnCoala_startbluefortracker;