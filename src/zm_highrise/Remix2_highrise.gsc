#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#include maps/mp/zombies/_zm_ai_leaper;

main()
{
    replaceFunc( maps/mp/zombies/_zm_ai_leaper::leaper_round_tracker, ::leaper_round_tracker_override );

    level.initial_spawn_highrise = true;
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
            self thread patch_shaft();
        }

        if(level.initial_spawn_highrise)
        {
            level.initial_spawn_highrise = false;

            thread fix_slide_death_gltich();
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

patch_shaft()
{
    level endon( "end_game" );

    zone = "zone_orange_elevator_shaft_middle_2";
    timeout = 300; // 5 mins

    self.return_to_playable_area_time = timeout;

    self thread return_to_playable_area_hud();
	while ( 1 )
	{
        if ( isDefined(self get_current_zone()) && self get_current_zone() == zone && self get_current_zone() != "")
        {
            self.return_to_playable_area_hud.alpha = 1;

            if( self.return_to_playable_area_time == 0 )
            {	
                if ( get_players().size == 1 && flag( "solo_game" ) && isDefined( self.waiting_to_revive ) && self.waiting_to_revive )
                {
                    level notify( "end_game" );
                    break;
                }
                else
                {
                    self disableinvulnerability();
                    self.lives = 0;
                    self dodamage( self.health + 1000, self.origin );
                    self.bleedout_time = 0;
                }
                self.return_to_playable_area_time = 0;
                wait 2;
                self.return_to_playable_area_time = timeout;
            }
        }
        else
        {
            self.return_to_playable_area_time = timeout;
            self.return_to_playable_area_hud.alpha = 0;
        }
        wait 0.05;
    }

}

fix_slide_death_gltich()
{
    flag_wait( "start_zombie_round_logic" );
   	wait 0.05;

    // collision = spawn( "script_model", ( 2815, 2537, 2869 ), 1 );
	// collision.angles = ( 0, 90, 0 );
	// collision setModel( "collision_clip_wall_128x128x10" );

    // barrier_model = spawn( "script_model", ( 2815, 2537, 2869 ), 1 );
	// barrier_model.angles = ( 0, 0, 0 );
	// barrier_model setmodel( "p6_zm_hr_elevator_indicator" );
}

return_to_playable_area_hud()
{   
	self.return_to_playable_area_hud = newClientHudElem( self );
	self.return_to_playable_area_hud.alignx = "center";
    self.return_to_playable_area_hud.aligny = "top";
    self.return_to_playable_area_hud.horzalign = "user_center";
    self.return_to_playable_area_hud.vertalign = "user_top";
    self.return_to_playable_area_hud.x += 0;
    self.return_to_playable_area_hud.y += 0;
    self.return_to_playable_area_hud.fontscale = 2;
    self.return_to_playable_area_hud.color = ( 0.423, 0.004, 0 );
	self.return_to_playable_area_hud.alpha = 1;
    self.return_to_playable_area_hud.hidewheninmenu = 1;
    self.return_to_playable_area_hud.label = &"Return to playable area: "; 

	while(1)
	{	
		self.return_to_playable_area_hud SetValue( self.return_to_playable_area_time );
        
		wait 1;
        self.return_to_playable_area_time--;
	
		if( self.return_to_playable_area_time == 0)
		{	
			self.return_to_playable_area_hud SetValue( self.return_to_playable_area_time );
			wait 1;
			self.return_to_playable_area_hud.alpha = 0;
		}
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