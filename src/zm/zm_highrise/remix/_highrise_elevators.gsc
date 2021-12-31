#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_ai_faller;

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

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

do_zombie_emerge_override( spot ) //checked changed to match cerberus output
{
	self endon( "death" );
	self thread setup_deathfunc( ::faller_death_ragdoll );
	self.no_powerups = 1;
	self.in_the_ceiling = 1;
	anim_org = spot.origin;
	anim_ang = spot.angles;
	self thread zombie_emerge_fx( spot );
	self thread zombie_faller_death_wait( "risen" );
	self thread watch_for_elevator_during_faller_spawn_custom();
	self zombie_faller_emerge( spot );
	self.create_eyes = 1;
	wait 0.1;
	self notify( "risen", spot.script_string );
	self zombie_faller_enable_location();
}

watch_for_elevator_during_faller_spawn_custom()
{
	self endon( "death" );
	self endon( "risen" );
	self endon( "spawn_anim" );
	while ( 1 )
	{
		should_gib = 0;
		_a1531 = level.elevators;
		_k1531 = getFirstArrayKey( _a1531 );
		while ( isDefined( _k1531 ) )
		{
			elevator = _a1531[ _k1531 ];
			if ( self istouching( elevator.body ) )
			{
				should_gib = 1;
			}
			_k1531 = getNextArrayKey( _a1531, _k1531 );
		}
		if ( should_gib )
		{
			playfx( level._effect[ "zomb_gib" ], self.origin );
			if ( isDefined( self.has_been_damaged_by_player ) && !self.has_been_damaged_by_player && isDefined( self.is_leaper ) && !self.is_leaper )
			{
				level.zombie_total++;
			}
			if ( isDefined( self.is_leaper ) && self.is_leaper )
			{
				self maps/mp/zombies/_zm_ai_leaper::leaper_cleanup();
				self dodamage( self.health + 100, self.origin );
			}
			else
			{
                self dodamage( self.health + 100, self.origin );
				// self delete();
			}
			return;
		}
		else
		{
			wait 0.1;
		}
	}
}