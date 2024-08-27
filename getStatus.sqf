SOG_tempDb = missionNamespace getVariable ["SOG_tempDb", []];

{
    private _puid = getPlayerUID _x;
    private _status = [SOG_tempDb, ["players", _puid, "status"], "available"] call BIS_fnc_dbValueReturn;
    systemChat format ["%1", _status];
} forEach allPlayers;

private _puid = getPlayerUID player;
private _status = [SOG_tempDb, ["players", _puid, "status"], "available"] call BIS_fnc_dbValueReturn;

hint _status;