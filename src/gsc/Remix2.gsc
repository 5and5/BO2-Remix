#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#include maps/mp/zombies/_zm_powerups;

init()
{ 
	replaceFunc( maps/mp/zombies/_zm_utility::set_run_speed, ::set_run_speed_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::powerup_drop, ::powerup_drop_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::func_should_drop_fire_sale, ::func_should_drop_fire_sale_override );

    level.inital_spawn = true;
    level thread onConnect();
}
onConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread connected();
    }
}
connected()
{
    level endon( "game_ended" );
    self endon("disconnect");

    self.initial_spawn = true;

    for(;;)
    {
        self waittill("spawned_player");

        self iprintln("Welcome to Remix!");
        self setClientDvar( "cg_fov", 90 );
        self setClientDvar( "cg_fovScale", 1.1 );
        self setClientDvar( "com_maxfps", 101 );

    	if(self.initial_spawn)
		{
            self.initial_spawn = false;

            self on_initial_spawn();
        }

        if(level.inital_spawn)
		{
			level.inital_spawn = false;

			level thread post_all_players_spawned();
		}
	}
}

on_initial_spawn()
{
    self thread timer_hud();
}

post_all_players_spawned()
{
	flag_wait( "start_zombie_round_logic" );
    wait 0.05;


}

/*
* *****************************************************
*	
* ********************* Override **********************
*
* *****************************************************
*/

set_run_speed_override()
{
	self.zombie_move_speed = "sprint";
}

powerup_drop_override( drop_point ) //checked partially changed to match cerberus output
{
	if ( level.powerup_drop_count >= level.zombie_vars[ "zombie_powerup_drop_max_per_round" ] )
	{
		return;
	}
	if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size == 0 )
	{
		return;
	}
	rand_drop = randomint( 100 );
	if ( rand_drop > 99 ) // 2 -> 3
	{
		if ( !level.zombie_vars[ "zombie_drop_item" ] )
		{
			return;
		}
		debug = "score";
	}
	else
	{
		debug = "random";
	}
	playable_area = getentarray( "player_volume", "script_noteworthy" );
	level.powerup_drop_count++;
	powerup = maps/mp/zombies/_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + vectorScale( ( 0, 0, 1 ), 40 ) );
	valid_drop = 0;
	for ( i = 0; i < playable_area.size; i++ )
	{
		if ( powerup istouching( playable_area[ i ] ) )
		{
			valid_drop = 1;
			break;
		}
	}
	if ( valid_drop && level.rare_powerups_active )
	{
		pos = ( drop_point[ 0 ], drop_point[ 1 ], drop_point[ 2 ] + 42 );
		if ( check_for_rare_drop_override( pos ) )
		{
			level.zombie_vars[ "zombie_drop_item" ] = 0;
			valid_drop = 0;
		}
	}
	if ( !valid_drop )
	{
		level.powerup_drop_count--;

		powerup delete();
		return;
	}
	powerup powerup_setup();
	print_powerup_drop( powerup.powerup_name, debug );
	powerup thread powerup_timeout();
	powerup thread powerup_wobble();
	powerup thread powerup_grab();
	powerup thread powerup_move();
	powerup thread powerup_emp();
	level.zombie_vars[ "zombie_drop_item" ] = 0;
	level notify( "powerup_dropped" );
}

func_should_drop_fire_sale_override() //checked partially changed to match cerberus output
{
	if ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 1 || level.chest_moves < 1 || is_true( level.disable_firesale_drop ) && level.round_number > 5)
	{
		return 1; // firesale now drop untill you move the first box
	}
	return 0;
}
/*
* *************************************************
*	
* ********************* HUD ***********************
*
* *************************************************
*/

timer_hud()
{
	self endon("disconnect");

	self thread round_timer_hud();

	timer_hud = newClientHudElem(self);
	timer_hud.alignx = "left";
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_left";
	timer_hud.vertalign = "user_top";
	timer_hud.x += 4;
	timer_hud.y += 2;
	timer_hud.fontscale = 1.4;
	timer_hud.alpha = 0;
	timer_hud.color = ( 1, 1, 1 );
	timer_hud.hidewheninmenu = 1;

	flag_wait( "initial_blackscreen_passed" );
	
	timer_hud setTimerUp(0);

	if( getDvar( "hud_timer") == "" )
		setDvar( "hud_timer", 1 );

	while(1)
	{	
		if( getDvarInt( "hud_timer" ) == 0 )
		{
			wait 0.1;
		}
		timer_hud.alpha = 1;

		if( getDvarInt( "hud_timer" ) >= 1 )
		{
			wait 0.1;
		}
		timer_hud.alpha = 0;
	}
}

round_timer_hud()
{
	self endon("disconnect");

	round_timer_hud = newClientHudElem(self);
	round_timer_hud.alignx = "left";
	round_timer_hud.aligny = "top";
	round_timer_hud.horzalign = "user_left";
	round_timer_hud.vertalign = "user_top";
	round_timer_hud.x += 4;
	round_timer_hud.y += 17;
	round_timer_hud.fontscale = 1.4;
	round_timer_hud.alpha = 0;
	round_timer_hud.color = ( 1, 1, 1 );
	round_timer_hud.hidewheninmenu = 1;

	flag_wait( "initial_blackscreen_passed" );

	self thread round_timer_watcher(round_timer_hud);

	while (1)
	{
		round_timer_hud setTimerUp(0);
		start_time = int(getTime() / 1000);

		level waittill( "end_of_round" );

		end_time = int(getTime() / 1000);
		time = end_time - start_time;

		round_timer_set_time_frozen(round_timer_hud, time);
	}
}

round_timer_watcher(round_timer_hud)
{
	if( getDvar( "hud_round_timer") == "" )
		setDvar( "hud_round_timer", 0 );

	while(1)
	{	
		if( getDvarInt( "hud_round_timer" ) == 0 )
		{
			wait 0.1;
		}
		round_timer_hud.y = (2 + (15 * getDvarInt("hud_timer")));
		round_timer_hud.alpha = 1;

		if( getDvarInt( "hud_round_timer" ) >= 1 )
		{
			wait 0.1;
		}
		round_timer_hud.alpha = 0;
	}
}

round_timer_set_time_frozen(hud, time)
{
	level endon( "start_of_round" );

	time -= .1; // need to set it below the number or it shows the next number

	while (1)
	{
		hud setTimer(time);

		wait 0.5;
	}
}
