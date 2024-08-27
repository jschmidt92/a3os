/*
	File: initCoalaAfter.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

[] spawn {
	waitUntil {
		!isNull player && player == player
	};
	waitUntil{
		!isNil "BIS_fnc_init"
	};
	waitUntil {
		!(isNull (findDisplay 46))
	};

	player addAction ["Open GeTac F110", "CoalaOs\CoalaOsMain.sqf", player, 1, true, true, "", "('ItemRadio' in (items player))"];
	player addEventHandler ["killed", {
		[] spawn {
			waitUntil {
				alive player
			};
			player addAction ["Open GeTac F110", "CoalaOs\CoalaOsMain.sqf", player, 1, true, true, "", "('ItemRadio' in (items player))"];
		};
	}];
	// player addAction ["Open GeTac F110", "CoalaOs\CoalaOsMain.sqf", player, 1, true, true, "", "('SOF_Tablet' in (items player))"];
	// player addEventHandler ["killed", {
	// 	[] spawn {
	// 		waitUntil {
	// 			alive player
	// 		};
	// 		player addAction ["Open GeTac F110", "CoalaOs\CoalaOsMain.sqf", player, 1, true, true, "", "('SOF_Tablet' in (items player))"];
	// 	};
	// }];
};