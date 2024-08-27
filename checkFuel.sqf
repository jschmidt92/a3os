params ["_veh"];

while { true } do {
    if ((fuel _veh) < 0.8) then {
        _veh setFuel 1;
    };
    sleep 120;
};