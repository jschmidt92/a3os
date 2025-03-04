/*
	File: CoalaOsFrontCam.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

_processId = _this select 1;
_fileName = _this select 2;

fnCoala_startfrontcam = {
	_width = 23.25;
	_height = 10.75;
	_x = -2;
	_y = 1;

	_programWindow = [_x, _y, _width, _height, _fileName] call fnCoala_DrawWindow;
	_renderSurface = ["RscPicture", "", 0, 0, 0, 0] call addCtrl;
	[_programWindow select 0, _renderSurface, [0, 0, _width, _height - 1.5]] call fnCoala_addControlToWindow;

	[_programWindow select 0, _processId, "processID"] call fnCoala_addVariableToControl;

	/* create render surface */
	_renderSurface ctrlSetText "#(argb,512,512,1)r2t(frontcam,1)";

	/* create camera and stream to render surface */
	_cam = "camera" camCreate (getPos player);
	_cam cameraEffect ["Internal", "Back", "frontcam"];
	_cam camSetTarget player;
	_cam attachTo [player, [0.1, 0.75, 1.5]];
	_cam camSetFov 0.8;
	_cam camCommit 0;
	
	missionNamespace setVariable [format ["%1%2", _processId, "_cam"], _cam];
};

fncoala_stopfrontcam = {
	_procId = _this select 0;
	_cam = missionNamespace getVariable format ["%1%2", _procId, "_cam"];
	
	_cam cameraEffect ["terminate", "back", str (_procId)]; 
	camDestroy _cam;
};

call fncoala_startfrontcam;