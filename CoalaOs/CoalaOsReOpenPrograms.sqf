/*
	File: CoalaOsReOpenPrograms.sqf
	Creator: J. Schmidt
	Date: 02.25.2024
*/

_programs = _this select 0;

{
	[format ["%1 %2 %3", (_x select 6) select 0, (_x select 7) select 0, (_x select 7) select 1]] call fnCoala_excecuteCommandFromNonConsole;
} forEach _programs;