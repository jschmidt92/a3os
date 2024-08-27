/*
	File: CoalaOsWindowFDIC.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

_width = 46.5;
_height = 21.5;
_x = -2;
_y = 1;

_standartURL = format ["https://spearnet.mil/portal/federal-deposit-insurance-corporation/%1", (player getVariable ["bankAccount", 0])];
_newWindow = [_x, _y, _width, _height, "Portal - Federal Deposit Insurance Corporation"] call fnCoala_DrawWindow;

_backgroundCtrl = ["RscText", "", 0, 0, 0, 0] call addCtrl;
_backgroundCtrl ctrlSetBackgroundColor [1, 1, 1, 1];
[_newWindow select 0, _backgroundCtrl, [0, 0, _width - 0, _height - 1.25]] call fnCoala_addControlToWindow;

_bankCtrl = ["RscText", "Bank:", 0, 0, 0, 0] call addCtrl; // idc 1817
_bankCtrl ctrlSetTextColor [0, 0, 0, 1];
[_newWindow select 0, _bankCtrl, [12, 2.5, _width - 11, _height - 20.5]] call fnCoala_addControlToWindow;
_bankValue = ["RscText", "", 0, 0, 0, 0, 2023001] call addCtrl; // idc 1818
_bankValue ctrlSetText format ["$%1", (player getVariable ["bank", 0])];
_bankValue ctrlSetTextColor [0, 0, 0, 1];
[_newWindow select 0, _bankValue, [20, 2.5, _width - 32, _height - 20.5]] call fnCoala_addControlToWindow;

_cashCtrl = ["RscText", "Cash:", 0, 0, 0, 0] call addCtrl; // idc 1819
_cashCtrl ctrlSetTextColor [0, 0, 0, 1];
[_newWindow select 0, _cashCtrl, [12, 2.5, _width - 11, _height - 16.5]] call fnCoala_addControlToWindow;
_cashValue = ["RscText", "", 0, 0, 0, 0] call addCtrl; // idc 1820
_cashValue ctrlSetText format ["$%1", (player getVariable ["cash", 0])];
_cashValue ctrlSetTextColor [0, 0, 0, 1];
[_newWindow select 0, _cashValue, [20, 2.5, _width - 32, _height - 16.5]] call fnCoala_addControlToWindow;

_amountCtrl = ["RscText", "Amount:", 0, 0, 0, 0] call addCtrl; // idc 1821
_amountCtrl ctrlSetTextColor [0, 0, 0, 1];
[_newWindow select 0, _amountCtrl, [12, 2.5, _width - 11, _height - 12.5]] call fnCoala_addControlToWindow;
_amountValue = ["RscEdit", "", 0, 0, 0, 0] call addCtrl; // idc 1822
_amountValue ctrlSetBackgroundColor [0.25, 0.25, 0.25, 1];
_amountValue ctrlSetTextColor [1, 1, 1, 1];
[_newWindow select 0, _amountValue, [20, 6.5, _width - 32, _height - 20.5]] call fnCoala_addControlToWindow;

_withdrawBtn = ["RscButton", "Withdraw", 0, 0, 0, 0] call addCtrl; // idc 1823
_withdrawBtn ctrlSetBackgroundColor [0, 0, 0, 1];
_withdrawBtn ctrlSetTextColor [1, 1, 1, 1];
[_newWindow select 0, _withdrawBtn, [14, 8.5, _width - 38, _height - 20.5]] call fnCoala_addControlToWindow;
_withdrawBtn ctrlEnable true;
_withdrawBtn ctrlAddEventHandler ["MouseButtonDown", {
	_ctrlCIDC = ctrlIDC _amountValue;
	// diag_log format ["%1", _ctrlCIDC];
	// hint format ["%1", _ctrlCIDC];
	[_ctrlCIDC] call SOG_ClientModules_fnc_bankWithdraw;
}];

_depositBtn = ["RscButton", "Deposit", 0, 0, 0, 0] call addCtrl; // idc 1824
_depositBtn ctrlSetBackgroundColor [0, 0, 0, 1];
_depositBtn ctrlSetTextColor [1, 1, 1, 1];
[_newWindow select 0, _depositBtn, [24, 8.5, _width - 38, _height - 20.5]] call fnCoala_addControlToWindow;
_depositBtn ctrlEnable true;
_depositBtn ctrlAddEventHandler ["MouseButtonDown", {
	[] call SOG_ClientModules_fnc_bankDeposit;
}];

_pageSubtitle = ["RscText", "Transfer Funds", 0, 0, 0, 0] call addCtrl; // idc 1825
_pageSubtitle ctrlSetTextColor [0, 0, 0, 1];
[_newWindow select 0, _pageSubtitle, [12, 10.5, _width - 11, _height - 20.5]] call fnCoala_addControlToWindow;

_accountCtrl = ["RscText", "Account:", 0, 0, 0, 0] call addCtrl; // idc 1826
_accountCtrl ctrlSetTextColor [0, 0, 0, 1];
[_newWindow select 0, _accountCtrl, [12, 8.5, _width - 11, _height - 12.5]] call fnCoala_addControlToWindow;
_accountValue = ["RscEdit", "", 0, 0, 0, 0] call addCtrl; // idc 1827
_accountValue ctrlSetBackgroundColor [0.25, 0.25, 0.25, 1];
_accountValue ctrlSetTextColor [1, 1, 1, 1];
[_newWindow select 0, _accountValue, [20, 12.5, _width - 32, _height - 20.5]] call fnCoala_addControlToWindow;

_transferCtrl = ["RscText", "Amount:", 0, 0, 0, 0] call addCtrl; // idc 1828
_transferCtrl ctrlSetTextColor [0, 0, 0, 1];
[_newWindow select 0, _transferCtrl, [12, 10.5, _width - 11, _height - 12.5]] call fnCoala_addControlToWindow;
_transferValue = ["RscEdit", "", 0, 0, 0, 0] call addCtrl; // idc 1829
_transferValue ctrlSetBackgroundColor [0.25, 0.25, 0.25, 1];
_transferValue ctrlSetTextColor [1, 1, 1, 1];
[_newWindow select 0, _transferValue, [20, 14.5, _width - 32, _height - 20.5]] call fnCoala_addControlToWindow;

_transferBtn = ["RscButton", "Transfer", 0, 0, 0, 0] call addCtrl; // idc 1830
_transferBtn ctrlSetBackgroundColor [0, 0, 0, 1];
_transferBtn ctrlSetTextColor [1, 1, 1, 1];
[_newWindow select 0, _transferBtn, [24, 16.5, _width - 38, _height - 20.5]] call fnCoala_addControlToWindow;
_transferBtn ctrlEnable true;
_transferBtn ctrlAddEventHandler ["MouseButtonDown", {
	[] call SOG_ClientModules_fnc_bankTransfer;
}];

_url = ["RscEdit", _standartURL, 0, 0, 0, 0] call addCtrl; // idc 1831
_url ctrlSetBackgroundColor [0.25, 0.25, 0.25, 1];
_url ctrlSetTextColor [1, 1, 1, 1];
[_newWindow select 0, _url, [0.4, 0.2, _width - 5.5, 1.5]] call fnCoala_addControlToWindow;

_changeSiteButton = ["RscButton", "Go", 0, 0, 0, 0] call addCtrl; // idc 1832
_changeSiteButton ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
[_newWindow select 0, _changeSiteButton, [_width - 5, 0.2, 5, 1.5]] call fnCoala_addControlToWindow;

missionNamespace setVariable [ format ["%1url", str (_changeSiteButton)], _url];