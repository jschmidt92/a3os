/*
	File: CoalaOsFileStructure.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

coala_FileSystem = [
	["C:", 0, 0, [1, 2, 3], 1],
	["Programs", 1, 0, [15, 16, 17, 18, 19, 20], 1],
	["Windows", 2, 0, [], 1],
	["Users", 3, 0, [4], 1],
	["root", 4, 3, [5, 6, 7, 8, 9, 10], 1],
	["Desktop", 5, 4, [], 1, nil, "desktop"],
	["Documents", 6, 4, [], 1, nil, "documents"],
	["Downloads", 7, 4, [], 1, nil, "downloads"],
	["Music", 8, 4, [], 1, nil, "music"],
	["Pictures", 9, 4, [11], 1, nil, "pictures"],
	["Videos", 10, 4, [12, 13, 14], 1, nil, "videos"],
	["image1.jpg", 11, 9, [], 0, MISSION_ROOT + "CoalaOs\Images\tank.jpg", "picture"],
	["video1.mp4", 12, 10, [], 0, "\A3\Missions_F_EPA\video\A_in_intro.ogv", "video"],
	["video2.mp4", 13, 10, [], 0, "\A3\Missions_F_EPA\video\A_hub_quotation.ogv", "video"],
	["video3.mp4", 14, 10, [], 0, "\A3\Missions_F_EPA\video\A_in_quotation.ogv", "video"],
	["UAVFeed.exe", 15, 1, [], 0, "CoalaOs\Programs\CoalaOsUAV.sqf", "exe", "surveillance"],
	["Frontcam.exe", 16, 1, [], 0, "CoalaOs\Programs\CoalaOsFrontCam.sqf", "exe", "frontcam"],
	["Bodycam.exe", 17, 1, [], 0, "CoalaOs\Programs\CoalaOsBodyCam.sqf", "exe", "bodycam"],
	["BFT.exe", 18, 1, [], 0, "CoalaOs\Programs\CoalaOsBFT.sqf", "exe", "bluefortracker"],
	["Chatty.exe", 19, 1, [], 0, "CoalaOs\Programs\CoalaOsChatty.sqf", "exe", "Chatty"],
	["MDT.exe", 20, 1, [], 0, "CoalaOs\Programs\CoalaOsMDT.sqf", "exe", "MDT"]
];

coala_ActivePrograms = [];
coala_currentFolderId = 0;
coala_currentFolder = coala_FileSystem select coala_currentFolderId;
coala_currentFolderName = format ["%1\", coala_currentFolder select coala_currentFolderId];

fnCoala_addFolder = {
	// [FolderName, parentId] call fnCoala_addFolder;
	_folderName = _this select 0;
	_parentId = _this select 1;
	_success = "Successfully created the folder.";

	if (count (toArray _folderName) > 0) then {
		_newId = count coala_FileSystem;
		// name, id, parent id, children, isfolder?
		_newFolder = [_folderName, _newId, _parentId, [], 1];

		// beim parent einspeichern
		(coala_FileSystem select _parentId) set [count(coala_FileSystem select _parentId), _newId];
		coala_FileSystem set [count coala_FileSystem, _newFolder];
	} else {
		_success = "Could not create the folder: No name given";
	};
	_return = _success
};

fnCoala_getSubFolders = {
	// [FolderId] call fnCoala_getSubFolders
	_folderId = _this select 0;
	_subFolderIds = (coala_FileSystem select _folderId) select 3;
	_folders = [];

	{
		_curFolder = coala_FileSystem select _x;
		_folders set [count _folders, _curFolder];
	} forEach _subFolderIds;

	_folders
};

fnCoala_getSubFolderIdFromname = {
	// [subFolderName] call fnCoala_getSubFolderIdFromname
	_subFolderName = _this select 0;
	_id = -1;

	if (count (toArray _subFolderName) > 0) then {
		_folders = [coala_currentFolderId] call fnCoala_getSubFolders;
		{
			if (_x select 0 == _subFolderName) then {
				_didFind = true;
				_id = _x select 1;
			};
		} forEach _folders;
	};

	_id
};

fnCoala_getCompleteFolderName = {
	// [folderId] call fnCoala_getCompleteFolderName
	_folderId = _this select 0;
	_folder = coala_FileSystem select _folderId;

	while { _folder select 1 != _folder select 2 } do {
		_parentFolder = coala_FileSystem select (_folder select 2);
		_fullPath = format ["%2\%1", _fullPath, _parentFolder select 0];
		_folder = _parentFolder;
	};

	_fullPath
};

fnCoala_getFileWithName = {
	// [fileName] call fnCoala_getFileWithName;
	_fileName = _this select 0;
	_fileId = -1;
	_toFindFile = [];

	_allCurFiles = coala_currentFolder select 3;
	{
		_curFile = coala_FileSystem select _x;
		if ((_curFile) select 0 == _fileName) then {
			_fileId = _curFile select 1;
			_toFindFile = _curFile;
		};
	} forEach _allCurFiles;

	_toFindFile
};