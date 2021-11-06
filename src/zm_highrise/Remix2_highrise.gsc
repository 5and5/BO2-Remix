#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_ai_leaper;

main()
{
    replaceFunc( maps/mp/zombies/_zm_ai_leaper::leaper_round_tracker, ::leaper_round_tracker_override );

    level thread onplayerconnect();
}

onplayerconnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon("disconnect");
    self.initial_spawn_highrise = true;
    
    for(;;)
    {
        self waittill("spawned_player");

        if(self.initial_spawn_highrise)
		{
            self.initial_spawn_highrise = true;

            self thread give_elevator_key();
        }
    }
}

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


leaper_round_tracker_override()
{	
	level.leaper_round_count = 1;
	level.next_leaper_round = (level.round_number + 4);
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;

	while ( 1 )
	{
		level waittill( "between_round_over" );
		if ( level.round_number == level.next_leaper_round )
		{
			level.music_round_override = 1;
			old_spawn_func = level.round_spawn_func;
			old_wait_func = level.round_wait_func;
			leaper_round_start();
			level.round_spawn_func = ::leaper_round_spawning;
			level.round_wait_func = ::leaper_round_wait;
			level.next_leaper_round = (level.round_number + 4);
		}
		else if ( flag( "leaper_round" ) )
		{
			leaper_round_stop();
			level.round_spawn_func = old_spawn_func;
			level.round_wait_func = old_wait_func;
			level.music_round_override = 0;
			level.leaper_round_count += 1;
		}
	}
}