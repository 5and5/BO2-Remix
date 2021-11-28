#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;

fake_reset()
{
    level endon("disconnect");
	level endon("end_game");

    level.win_game = false;
	level.total_time = 0;
	level.paused_time = 0;

	flag_wait( "initial_blackscreen_passed" );

	start_time = int(getTime() / 1000);

    while(1)
    {
        current_time = int(getTime() / 1000);
		level.total_time = (current_time - level.paused_time) - start_time;
		
        if (level.total_time >= 43200) // 12h reset
        {
			players = Get_Players();	
			for(i=0;i<players.size;i++)
			{
				players[i] FreezeControls( true );
			}
            level.win_game = true;
            level notify( "end_game" );
			break;
        }

        wait 0.05;
    }
}

coop_pause()
{	
	level endon("disconnect");
	level endon("end_game");

	setDvar( "coop_pause", 0 );

	paused_time = 0;
	paused_start_time = 0;
	paused = false;

	start_time = int(getTime() / 1000);

	players = get_players();

	while(players.size > 1)
	{
		if( getDvarInt( "coop_pause" ) == 1 )
		{	
			if(get_round_enemy_array().size + level.zombie_total != 0 || flag( "dog_round" ) )
			{
				iprintln("All players will be paused at the start of the next round");
				level waittill( "end_of_round" );
			}

			players[0] SetClientDvar( "ai_disableSpawn", "1" );

			level waittill( "start_of_round" );

			black_hud = newhudelem();
			black_hud.horzAlign = "fullscreen";
			black_hud.vertAlign = "fullscreen";
			black_hud SetShader( "black", 640, 480 );
			black_hud.alpha = 0;

			black_hud FadeOverTime( 1.0 );
			black_hud.alpha = 0.7;

			paused_hud = newhudelem();
			paused_hud.horzAlign = "center";
			paused_hud.vertAlign = "middle";
			paused_hud setText("GAME PAUSED");
			paused_hud.foreground = true;
			paused_hud.fontScale = 2.3;
			paused_hud.x -= 63;
			paused_hud.y -= 20;
			paused_hud.alpha = 0;
			paused_hud.color = ( 1.0, 1.0, 1.0 );

			paused_hud FadeOverTime( 1.0 );
			paused_hud.alpha = 0.85;
			
			players = get_players();
			for(i = 0; players.size > i; i++)
			{
				players[i] freezecontrols(true);
			}

			paused = true;
			paused_start_time = int(getTime() / 1000);
			total_time = 0 - (paused_start_time - level.paused_time) - (start_time - 0.05);
			previous_paused_time = level.paused_time;

			while(paused)
			{	
				players = get_players();
				for(i = 0; players.size > i; i++)
				{
					players[i].timer_hud SetTimerUp(total_time);
				}
				
				wait 0.2;

				current_time = int(getTime() / 1000);
				current_paused_time = current_time - paused_start_time;
				level.paused_time = previous_paused_time + current_paused_time;

				if( getDvarInt( "coop_pause" ) == 0 )
				{
					paused = false;

					for(i = 0; players.size > i; i++)
					{
						players[i] freezecontrols(false);
					}

					players[0] SetClientDvar( "ai_disableSpawn", "0");

					paused_hud FadeOverTime( 0.5 );
					paused_hud.alpha = 0;
					black_hud FadeOverTime( 0.5 );
					black_hud.alpha = 0;
					wait 0.5;
					black_hud destroy();
					paused_hud destroy();
				}
			}
		}
		wait 0.05;
	}
}