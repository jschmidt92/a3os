/*
	File: CoalaOsWindowManager.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

GUI_GRID_W = 0.025;
GUI_GRID_H = 0.04;
GUI_GRID_X = 0;
GUI_GRID_Y = 0;
coalaMouseX = 0;
coalaMouseY = 0;
isMouseDown = 0;
coalaWindowId = 1801;

GUI_TOP = 1;
GUI_LEFT = -2;
GUI_WIDTH = 46.5;
GUI_HEIGHT = 21.75;
GUI_RIGHT = (GUI_WIDTH + GUI_LEFT) * GUI_GRID_W;
GUI_BOTTOM = (GUI_HEIGHT + GUI_TOP) * GUI_GRID_H;

coalaDisplay displayAddEventHandler ["MouseMoving", {
	[_this]call checkAndMoveWindow;
	coalaMouseX = _this select 1;
	coalaMouseY = _this select 2;
}];

coalaDisplay displayAddEventHandler ["MouseButtonUp", {
	isMouseDown = 0;
}];

checkAndMoveWindow = {
	if (isMouseDown == 1) then {
		_coalaActiveControl = missionNamespace getVariable "coalaActiveControl";
		_toMove = _coalaActiveControl select 0;
		_pos = ctrlPosition _toMove;

		_width = missionNamespace getVariable format ["%1%2", _toMove, "width"];
		_height = missionNamespace getVariable format ["%1%2", _toMove, "height"];

		_movementSpeed = 0.36 / diag_fps;

		_newX = (_pos select 0) + (coalaMouseX * _movementSpeed);
		_newY = (_pos select 1) + (coalaMouseY * (_movementSpeed * 1.28));

		if (_newX + _width > GUI_RIGHT) then {
			_newX = GUI_RIGHT - _width;
		};
		if (_newX < GUI_LEFT * GUI_GRID_W) then {
			_newX = GUI_LEFT * GUI_GRID_W;
		};
		if (_newY + _height > GUI_BOTTOM) then {
			_newY = GUI_BOTTOM - _height;
		};
		if (_newY < GUI_TOP * GUI_GRID_H) then {
			_newY = GUI_TOP * GUI_GRID_H;
		};
		_toMove ctrlSetPosition [_newX, _newY, _pos select 2, _pos select 3];
		_toMove ctrlCommit 0;

		{
			if (_x != _toMove) then {
				_xVersatz = missionNamespace getVariable format ["%1xPlus", str (_x)];
				_yVersatz = missionNamespace getVariable format ["%1yPlus", str (_x)];
				_subPos = ctrlPosition _x;
				_controlType = [_x, "type"] call fnCoala_getVariableToControl;
				if (_controlType == "basic") then {
					_x ctrlSetPosition [_newX + _xVersatz, _newY + _yVersatz, _subPos select 2, _subPos select 3];
				} else {
					_x ctrlSetPosition [_newX + _xVersatz, _newY + _yVersatz + (1.45 * GUI_GRID_H), _subPos select 2, _subPos select 3];
				};
				_x ctrlCommit 0;
			};

			if (ctrlText _x == "cmd") then {
				[_x] call fnCoala_FocusWindow;
			};
		} forEach _coalaActiveControl;

		_processId = [_toMove, "processID"] call fnCoala_getVariableToControl;
		_prog = ([_processId] call fnCoala_getProgramEntryById);
		_prog set [7, [_newX / GUI_GRID_W + GUI_GRID_X, _newY / GUI_GRID_H + GUI_GRID_Y]];
	};
};

addCtrl = {
	_type = _this select 0;
	_text = _this select 1;
	_x = (_this select 2) * GUI_GRID_W + GUI_GRID_X;
	_y = (_this select 3) * GUI_GRID_H + GUI_GRID_Y;
	_w = (_this select 4) * GUI_GRID_W;
	_h = (_this select 5) * GUI_GRID_H;

	_toCreate = coalaDisplay ctrlCreate [_type, coalaWindowId];
	missionNamespace setVariable ["COALA_latestCIDC", coalaWindowId, true];
	// diag_log format ["%1", coalaWindowId];
	// hint format ["%1", coalaWindowId];
	coalaWindowId = coalaWindowId + 1;

	if (_text != "") then {
		_toCreate ctrlSetText _text;
	};

	_toCreate ctrlSetPosition [_x, _y, _w, _h];

	if (count _this > 6) then {
		_toCreate ctrlAddEventHandler ["MouseEnter", {
			(_this select 0) ctrlSetBackgroundColor [1, 1, 1, 0.3];
			(_this select 0) ctrlCommit 0;
		}];
		_toCreate ctrlAddEventHandler ["MouseExit", {
			(_this select 0) ctrlSetBackgroundColor [0, 0, 0, 0];
			(_this select 0) ctrlCommit 0;
		}];
	};

	_toCreate ctrlCommit 0;

	missionNamespace setVariable [format ["%1%2", _toCreate, "width"], _w];
	missionNamespace setVariable [format ["%1%2", _toCreate, "height"], _h];

	_toCreate
};

addStaticCtrl = {
	_type = _this select 0;
	_text = _this select 1;
	_x = (_this select 2) * GUI_GRID_W + GUI_GRID_X;
	_y = (_this select 3) * GUI_GRID_H + GUI_GRID_Y;
	_w = (_this select 4) * GUI_GRID_W;
	_h = (_this select 5) * GUI_GRID_H;
	_cidc = _this select 6;

	_toCreate = coalaDisplay ctrlCreate [_type, _cidc];

	if (_text != "") then {
		_toCreate ctrlSetText _text;
	};

	_toCreate ctrlSetPosition [_x, _y, _w, _h];
	_toCreate ctrlCommit 0;

	missionNamespace setVariable [format ["%1%2", _toCreate, "width"], _w];
	missionNamespace setVariable [format ["%1%2", _toCreate, "height"], _h];

	_toCreate
};

// Draws the Background image. Should be called before any Windows or the Desktop are added
fnCoala_drawBackgroundImage = {
	_backgroundControl = ["RscPicture", MISSION_ROOT + "CoalaOs\Images\win11.paa", GUI_LEFT, GUI_TOP, GUI_WIDTH, GUI_HEIGHT] call addCtrl;
};

// Changes the path of the Explorer
// _this select 0 -> the Command that should be excecuted (for example "cd Arma")
// _this select 1 -> the old Explorer Window
fnCoala_changeExplorerPath = {
	params ["_command", "_newWindow"];

	_width = 20;
	_height = 12;
	_x = 10;
	_y = 6;

	[_newWindow select 0] call fnCoala_CloseWindow;
	_newWindow = [_x, _y, _width, _height, "Explorer - C:\"] call fnCoala_DrawWindow;

	[_command] call fnCoala_excecuteCommandFromNonConsole;
	_folders = ["ls"] call fnCoala_excecuteCommandFromNonConsole;

	_yIndex = 0;
	_breaker = 3;
	_counter = 0;

	_folders = [[".."]] + _folders;
	{
		_cur = (_folders select _forEachIndex);

		_imageName = "folder";
		if (count _cur > 6) then {
			if (_cur select 6 == "exe") then {
				_imageName = "exe";
			};
			if (_cur select 6 == "picture") then {
				_imageName = "picture";
			};
			if (_cur select 6 == "desktop") then {
				_imageName = "desktop";
			};
			if (_cur select 6 == "documents") then {
				_imageName = "documents";
			};
			if (_cur select 6 == "downloads") then {
				_imageName = "downloads";
			};
			if (_cur select 6 == "music") then {
				_imageName = "music";
			};
			if (_cur select 6 == "pictures") then {
				_imageName = "pictures";
			};
			if (_cur select 6 == "videos") then {
				_imageName = "videos";
			};
			if (_cur select 6 == "video") then {
				_imageName = "video";
			};
		};

		_folderCtrl = ["RscPicture", MISSION_ROOT + "CoalaOs\Images\" + _imageName + ".paa", 0, 0, 0, 0] call addCtrl;
		_folderCtrl ctrlEnable true;
		[_folderCtrl, _cur, "folderStructure"] call fnCoala_addVariableToControl;
		_folderCtrl ctrlAddEventHandler ["MouseButtonDblClick", {
			_folderInfo = [_this select 0, "folderStructure"] call fnCoala_getVariableToControl;
			if (count _folderInfo > 4) then {
				if (_folderInfo select 4 == 1) then {
					_folders = [_this select 0] call fnCoala_getWindowFromControl;
					[format ["cd %1", (_folderInfo select 0)], _folders] call fnCoala_changeExplorerPath;
				} else {
					if ((_folderInfo select 6) == "exe") then {
						// Close the current explorer window
						[_this select 0] call fnCoala_CloseWindow;
						ctrlShow [020, false];
						ctrlShow [021, false];
					};
					[format ["open %1", (_folderInfo select 0)]] call fnCoala_excecuteCommandFromNonConsole;
				};
			} else {
				_folders = [_this select 0] call fnCoala_getWindowFromControl;
				[format ["cd %1", (_folderInfo select 0)], _folders] call fnCoala_changeExplorerPath;
			};
		}];

		_name = (_cur select 0);
		_folderCtrlText = ["RscText", _name, 0, 0, 0, 0] call addCtrl;
		_folderCtrlText ctrlSetFontHeight 0.03;
		_folderCtrlText ctrlSetTextColor [0, 0, 0, 1];
		_folderCtrlText ctrlSetTooltip _name;

		[_newWindow select 0, _folderCtrl, [0.5 + _counter * 4 + 1 * _counter, _yIndex * 5 + 0.2, 4, 4]] call fnCoala_addControlToWindow;
		[_newWindow select 0, _folderCtrlText, [0.5 + _counter * 4 + 1 * _counter, _yIndex * 5 + 3.8, 4, 1]] call fnCoala_addControlToWindow;

		if (_breaker == _counter) then {
			_yIndex = _yIndex + 1;
			_counter = 0;
		} else {
			_counter = _counter + 1;
		};
	} forEach _folders;
};

// Adds a single Desktop Icon
// _this select 0 -> x
// _this select 1 -> y
// _this select 2 -> picture path
// _this select 3 -> name
// _this select 4 -> text X Correction
// Returns: the Control of the Icon and the control of the text : Array
fnCoala_AddDesktopIcon = {
	_picture = _this select 2;
	_name = _this select 3;
	_xAnpasser = _this select 4;
	_id = _this select 5;

	_icon = ["RscPicture", MISSION_ROOT + _picture, _this select 0, _this select 1, 4, 3, _id] call addStaticCtrl;
	_icon ctrlEnable true;

	_windowName = ["RscText", _name, (_this select 0) + _xAnpasser, (_this select 1) + 2.4, 4, 1.5] call addCtrl;
	_windowName ctrlEnable true;

	_returned = [_icon, _windowName];
	_returned
};

// Draws the Taskbar
fnCoala_DrawTaskBar = {
	_taskBar = ["RscBackground", "", GUI_LEFT - 0, GUI_HEIGHT - 0.5, GUI_WIDTH + 0, 1.5] call addCtrl;
	_r = 24;
	_g = 31;
	_b = 28;
	_taskBar ctrlSetBackgroundColor [_r/255, _g/255, _b/255, 1];
	_taskBar ctrlSetForegroundColor [_r/255, _g/255, _b/255, 1];

	_taskBarTime = ["RscText", "", (GUI_LEFT + GUI_WIDTH) - 3.5, GUI_HEIGHT - 0.5, 5, 1.5] call addCtrl;

	[_taskBarTime] spawn fnCoala_drawTime;
};

// Draws the Ingame time on the bottom right Corner
fnCoala_drawTime = {
	_timeControl = _this select 0;
	while { (dialog) and (alive player) } do {
		_hour = floor dayTime;
		_strHour = str (_hour);
		if (_hour < 10) then {
			_strHour = format ["0%1", _hour];
		};

		_minute = floor ((dayTime - _hour) * 60);
		_strMinute = str (_minute);
		if (_minute < 10) then {
			_strMinute = format ["0%1", _minute];
		};

		_second = floor (((((dayTime) - (_hour))*60) - _minute)*60);
		_strSecond = str (_second);
		if (_second < 10) then {
			_strSecond = format ["0%1", _second];
		};

		_time24 = format ["%1:%2:%3", _strHour, _strMinute, _strSecond];
		_timeControl ctrlSetText _time24;
		sleep 1;
	};
};

// Draws the Desktop
fnCoala_DrawDesktop = {
	_explorer = [GUI_LEFT + 2, GUI_TOP + 2, "CoalaOs\Images\driveC.paa", "", 1.1, 020] call fnCoala_AddDesktopIcon;
	(_explorer select 0) ctrlAddEventHandler ["MouseButtonDblClick", {
		_newWindow = [5, 5, 20, 12, "Explorer - C:\"] call fnCoala_DrawWindow;
		["", _newWindow] call fnCoala_changeExplorerPath;
	}];

	// _cmd = [GUI_LEFT + 8, GUI_TOP + 2, "CoalaOs\Images\pws.paa", "cmd", 0.9] call fnCoala_AddDesktopIcon;
	// (_cmd select 0) ctrlAddEventHandler ["MouseButtonDblClick", {
		// _newWindow = [5, 5, 20, 12, "cmd"] call fnCoala_DrawWindow;
		// [_newWindow select 0, coalaConsole, [0, 0, 20, 10.5]] call fnCoala_addControlToWindow;
		//
	// }];
	

	_browser = [GUI_LEFT + 8, GUI_TOP + 2, "CoalaOs\Images\browserA.paa", "", 0, 021] call fnCoala_AddDesktopIcon;
	(_browser select 0) ctrlAddEventHandler ["MouseButtonDblClick", {
		_width = 46.5;
		_height = 21.5;
		_x = -2;
		_y = 1;

		ctrlShow [020, false];
		ctrlShow [021, false];

		_standartURL = "https://spearnet.mil/portal";
		_newWindow = [_x, _y, _width, _height, "Portal - Home"] call fnCoala_DrawWindow;

		_backgroundCtrl = ["RscText", "", 0, 0, 0, 0] call addCtrl;
		_backgroundCtrl ctrlSetBackgroundColor [1, 1, 1, 1];
		[_newWindow select 0, _backgroundCtrl, [0, 0, _width - 0, _height - 1.25]] call fnCoala_addControlToWindow;

		_fdic = ["RscPicture", "CoalaOs\Images\fdic.paa", 0, 0, 0, 0] call addCtrl;
		[_newWindow select 0, _fdic, [16, 5, _width - 32, _height - 18]] call fnCoala_addControlToWindow;
		_fdic ctrlEnable true;
		_fdic ctrlAddEventHandler ["MouseButtonDown", {
			[_this select 0] call fnCoala_CloseWindow;
			[] execVM "CoalaOs\Drawing\CoalaOsWindowFDIC.sqf";
		}];

		_gms = ["RscPicture", "CoalaOs\Images\gms.paa", 0, 0, 0, 0] call addCtrl;
		[_newWindow select 0, _gms, [16, 9, _width - 32, _height - 18]] call fnCoala_addControlToWindow;
		_gms ctrlEnable true;
		_gms ctrlAddEventHandler ["MouseButtonDown", {
			[_this select 0] call fnCoala_CloseWindow;
			[] execVM "CoalaOs\Drawing\CoalaOsWindowGMS.sqf";
		}];

		_fms = ["RscPicture", "CoalaOs\Images\fms.paa", 0, 0, 0, 0] call addCtrl;
		[_newWindow select 0, _fms, [16, 13, _width - 32, _height - 18]] call fnCoala_addControlToWindow;
		_fms ctrlEnable true;
		_fms ctrlAddEventHandler ["MouseButtonDown", {
			[_this select 0] call fnCoala_CloseWindow;
			[] execVM "CoalaOs\Drawing\CoalaOsWindowFMS.sqf";
		}];

		_url = ["RscEdit", _standartURL, 0, 0, 0, 0] call addCtrl;
		_url ctrlSetBackgroundColor [0.25, 0.25, 0.25, 1];
		_url ctrlSetTextColor [1, 1, 1, 1];
		[_newWindow select 0, _url, [0.1, 0.2, _width - 5.5, 1.5]] call fnCoala_addControlToWindow;

		_changeSiteButton = ["RscButton", "Go", 0, 0, 0, 0] call addCtrl;
		_changeSiteButton ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
		[_newWindow select 0, _changeSiteButton, [_width - 5.4, 0.2, 5.4, 1.5]] call fnCoala_addControlToWindow;

		missionNamespace setVariable [ format ["%1url", str (_changeSiteButton)], _url];

		_allControls = [];

		{
			_x setVariable ["otherElements", _allControls];
			_x ctrlCommit 0;
			[_x, _allControls] call fnCoala_addVariableToControl;
			[_x, "Basic", "type"] call fnCoala_addVariableToControl;
		} forEach _allControls;
		_allControls
	}];

	call fnCoala_DrawTaskBar;
};

setXYVersatz = {
	missionNamespace setVariable [ format ["%1xPlus", str (_this select 0)], (_this select 1) * GUI_GRID_W];
	missionNamespace setVariable [ format ["%1yPlus", str (_this select 0)], (_this select 2) * GUI_GRID_H];
};

// Closes the given Window
// _this select 0 -> Any control from the window
fnCoala_CloseWindow = {
	_control = _this select 0;
	_window = [_control] call fnCoala_getWindowFromControl;

	_processId = [_window select 0, "processID"] call fnCoala_getVariableToControl;
	if (str (_processId) != "<null>") then {
		[format ["close %1", _processId]] call fnCoala_excecuteCommandFromNonConsole;
		[] call fnCoala_stopplayer;
	};

	{
		ctrlDelete _x;
	} forEach _window;
};

// Draws a Window on the Screen. The returned Window will already have a close button and will be dragable
// _this select 0 -> x
// _this select 1 -> y
// _this select 2 -> width
// _this select 3 -> height
// _this select 4 -> name
// Returns: All controls in the Window : Array
fnCoala_DrawWindow = {
	_width = 20;
	_height = 12;

	if (count _this > 2) then {
		_width = _this select 2;
		if (count _this > 3) then {
			_height = _this select 3;
		};
	};

	_windowBackground = ["RscPicture", MISSION_ROOT + "CoalaOs\Images\winBg.paa", (_this select 0), (_this select 1), _width, _height] call addCtrl;
	[_windowBackground, 0, 0] call setXYVersatz;

	_topBar = ["RscBackground", "", (_this select 0), (_this select 1), _width, 1.5] call addCtrl;
	[_topBar, 0, 0] call setXYVersatz;
	_topBar ctrlEnable true;
	_r = 24;
	_g = 31;
	_b = 28;
	_topBar ctrlSetBackgroundColor [_r/255, _g/255, _b/255, 1];
	_topBar ctrlSetForegroundColor [_r/255, _g/255, _b/255, 1];
	_topBar ctrlAddEventHandler ["MouseButtonDown", {
		isMouseDown = 1;
		[_this select 0] call fnCoala_FocusWindow;
		_coalaActiveControl = [_this select 0] call fnCoala_getWindowFromControl;
		missionNamespace setVariable ["coalaActiveControl", _coalaActiveControl];
	}];

	_windowName = ["RscText", (_this select 4), (_this select 0), (_this select 1), _width - 1.5, 1.5] call addCtrl;
	[_windowName, 0, 0] call setXYVersatz;
	_windowName ctrlEnable true;
	_windowName ctrlSetBackgroundColor [0, 0.5, 0.75, 1];
	_windowName ctrlAddEventHandler ["MouseButtonDown", {
		isMouseDown = 1;
		[_this select 0] call fnCoala_FocusWindow;
		_coalaActiveControl = [_this select 0] call fnCoala_getWindowFromControl;
		missionNamespace setVariable ["coalaActiveControl", _coalaActiveControl];
	}];

	_close = ["RscText", " X", ((_this select 0) + (_width - 1.5)), (_this select 1), 1.5, 1.5] call addCtrl;
	[_close, _width - 1.5, 0] call setXYVersatz;
	_close ctrlSetBackgroundColor [0.9, 0, 0, 1];
	_close ctrlSetActiveColor [1, 0, 0, 1];
	_close ctrlEnable true;
	_close ctrlAddEventHandler ["MouseButtonDown", {
		[_this select 0] call fnCoala_CloseWindow;
		ctrlShow [020, true];
		ctrlShow [021, true];
	}];

	_allControls = [_windowBackground, _topBar, _close, _windowName];

	{
		_x setVariable ["otherElements", _allControls];
		_x ctrlCommit 0;
		[_x, _allControls] call fnCoala_addVariableToControl;
		[_x, "Basic", "type"] call fnCoala_addVariableToControl;
	} forEach _allControls;
	_allControls
};

// Currently crashes arma after a few trys
// Deletes all Controls that were customly added to the control.
// _this select 0 -> the Background of the window.
fnCoala_clearWindow = {
	_windowControl = _this select 0;
	_controls = [_windowControl] call fnCoala_getWindowFromControl;
	{
		_controlType = [_x, "type"] call fnCoala_getVariableToControl;
		if (_controLType == "added") then {
			ctrlDelete _x;
		};
	} forEach _controls;
};

// Add a variable to a given Control
// _this select 0 -> the Control that will get the variable
// _this select 1 -> the Value of the Variable
// (Optional) _this select 2 -> The name of the Variable
fnCoala_addVariableToControl = {
	_control = _this select 0;
	_variable = _this select 1;
	_varName = "";

	if (count _this > 2) then {
		_varName = _this select 2;
	};
	missionNamespace setVariable [format ["%1%2", str (_control), _varName], _variable];
};

// get a variable from the given Control
// _this select 0 -> The Control
// (Optional) _this select 1 -> the name of the variable. - if no parameter is given, it will return the value set from fnCoala_addVariableToControl with no given paramter
// Returns: The variable : Any
fnCoala_getVariableToControl = {
	_control = _this select 0;
	_varName = "";

	if (count _this > 1) then {
		_varName = _this select 1;
	};
	_variable = missionNamespace getVariable format ["%1%2", str (_control), _varName];
	_variable
};

// Returns a array with all Controls of the window to the given control
// _this select 0 -> the Control who's window you want
// Returns: All Controls in the Window : Array
fnCoala_getWindowFromControl = {
	_window = missionNamespace getVariable str (_this select 0);
	_window
};

// set the given Window as Focused.
// _this select 0 -> the background control of the window.
fnCoala_FocusWindow = {
	_control = _this select 0;
	_window = [_control] call fnCoala_getWindowFromControl;
	{
		ctrlSetFocus _x;
	} forEach _window;
	ctrlSetFocus _control;
};

// _this select 0 -> wo es hinzugef�gt werden soll
// _this select 1 -> das control das hinzugef�gt werden soll
// (Optional) _this select 2 -> [x, y, h, w] wobei 0, 0 oben links im window des Controls aus _this select 0 ist
fnCoala_addControlToWindow = {
	_control = _this select 0;
	_toAddControl = _this select 1;
	_allControls = missionNamespace getVariable str (_control);
	_allControls = _allControls + [_toAddControl];
	_window = [_control] call fnCoala_getWindowFromControl;

	[_toAddControl, "added", "type"] call fnCoala_addVariableToControl;
	{
		_x setVariable ["otherElements", _allControls];
		[_x, _allControls] call fnCoala_addVariableToControl;
	} forEach _window;

	if (count _this > 2) then {
		_pos = _this select 2;
		_zeroPos = ctrlPosition (_allControls select 0);
		_newX = (_zeroPos select 0) + ((_pos select 0) * GUI_GRID_W);
		_newY = (_zeroPos select 1) + (1.5 * GUI_GRID_H) + ((_pos select 1) * GUI_GRID_H);
		_newW = (_pos select 2) * GUI_GRID_W;
		_newH = (_pos select 3) * GUI_GRID_H;

		_toAddControl ctrlSetPosition[_newX, _newY, _newW, _newH];
		[_toAddControl, (_zeroPos select 0) + (_pos select 0), (_zeroPos select 1) + (_pos select 1)] call setXYVersatz;

		_toAddControl ctrlCommit 0;
	};
};

// Shows a basic dialog (UNFINISHED)
// _this select 0 -> The text
// _this select 1 -> The header text
fnCoala_showDialog = {
	_text = _this select 0;
	_headerText = _this select 1;
	_newWindow = [5, 5, 20, 12, _headerText] call fnCoala_DrawWindow;
	_textRsc = ["RscText", _text, 0, 0, 10, 5] call addCtrl;

	[_newWindow select 0, _textRsc, [0, 0, 20, 10.5]] call fnCoala_addControlToWindow;
};