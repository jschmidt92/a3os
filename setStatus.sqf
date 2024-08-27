private _newStatus = "available";
private _puid = getPlayerUID player;

[SOG_tempDb, ["players", _puid, "status"], _newStatus] call BIS_fnc_dbValueSet;