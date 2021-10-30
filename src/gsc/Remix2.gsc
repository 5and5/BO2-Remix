#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{ 
	replaceFunc( maps/mp/zombies/_zm_utility::set_run_speed, ::set_run_speed_override );
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
