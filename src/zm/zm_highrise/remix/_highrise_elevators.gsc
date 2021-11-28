#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

give_elevator_key()
{
    level endon("end_game");
    self endon("disconnect");

    for(;;)
    {
        if (isDefined(self maps/mp/zombies/_zm_buildables::player_get_buildable_piece()) && self maps/mp/zombies/_zm_buildables::player_get_buildable_piece() == "keys_zm")
        {
            wait 1;
        }
        else
        {
            candidate_list = [];
            foreach (zone in level.zones)
            {
                if (isDefined(zone.unitrigger_stubs))
                {
                    candidate_list = arraycombine(candidate_list, zone.unitrigger_stubs, 1, 0);
                }
            }
            foreach (stub in candidate_list)
            {
                if (isDefined(stub.piece) && stub.piece.buildablename == "keys_zm")
                {
                    self thread maps/mp/zombies/_zm_buildables::player_take_piece(stub.piece);
                    break;
                }
            }
        }
        wait 1;
    }
}