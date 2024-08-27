/*
	File: CoalaOsYoutube.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

fnCoala_startyoutube = {
	_isOpened = openYoutubeVideo "watch?v=UBIAbm7Rt78";
	hint format ["%1", _isOpened];
};

fnCoala_stopyoutube = {};

call fnCoala_startyoutube;