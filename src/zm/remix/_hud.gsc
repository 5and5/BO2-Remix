#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;

timer_hud()
{	
	self endon("disconnect");

	self.timer_hud = newClientHudElem(self);
	self.timer_hud.alignx = "left";
	self.timer_hud.aligny = "top";
	self.timer_hud.horzalign = "user_left";
	self.timer_hud.vertalign = "user_top";
	self.timer_hud.x += 4;
	self.timer_hud.y += 2;
	self.timer_hud.fontscale = 1.4;
	self.timer_hud.alpha = 0;
	self.timer_hud.color = ( 1, 1, 1 );
	self.timer_hud.hidewheninmenu = 1;

	self set_hud_offset();
	self thread timer_hud_watcher();
	self thread round_timer_hud();

	flag_wait( "initial_blackscreen_passed" );
	self.timer_hud setTimerUp(0);

	level waittill( "end_game" );

	level.total_time -= .1; // need to set it below the number or it shows the next number
	while(1)
	{	
		self.timer_hud setTimer(level.total_time);
		self.timer_hud.alpha = 1;
		self.round_timer_hud.alpha = 0;
		wait 0.1;
	}
}

set_hud_offset()
{
	if (level.script == "zm_tomb" )//|| level.script == "zm_prison")
	{
		self.hud_offset = 10;
	}
	else
	{
		self.hud_offset = 0;	
	}
}

timer_hud_watcher()
{	
	self endon("disconnect");
	level endon( "end_game" );

	if( getDvar( "hud_timer") == "" )
		setDvar( "hud_timer", 1 );

	while(1)
	{	
		while( getDvarInt( "hud_timer" ) == 0 )
		{
			wait 0.1;
		}
		self.timer_hud.y = (2 + self.hud_offset);
		self.timer_hud.alpha = 1;

		while( getDvarInt( "hud_timer" ) >= 1 )
		{
			wait 0.1;
		}
		self.timer_hud.alpha = 0;
	}
}

round_timer_hud()
{
	self endon("disconnect");

	self.round_timer_hud = newClientHudElem(self);
	self.round_timer_hud.alignx = "left";
	self.round_timer_hud.aligny = "top";
	self.round_timer_hud.horzalign = "user_left";
	self.round_timer_hud.vertalign = "user_top";
	self.round_timer_hud.x += 4;
	self.round_timer_hud.y += (2 + (15 * getDvarInt("hud_timer") ) + self.hud_offset );
	self.round_timer_hud.fontscale = 1.4;
	self.round_timer_hud.alpha = 0;
	self.round_timer_hud.color = ( 1, 1, 1 );
	self.round_timer_hud.hidewheninmenu = 1;

	flag_wait( "initial_blackscreen_passed" );

	self thread round_timer_hud_watcher();

	level.FADE_TIME = 0.2;

	while (1)
	{
		zombies_this_round = level.zombie_total + get_round_enemy_array().size;
		hordes = zombies_this_round / 24;
		dog_round = flag( "dog_round" );

		self.round_timer_hud setTimerUp(0);
		start_time = int(getTime() / 1000);

		level waittill( "end_of_round" );

		end_time = int(getTime() / 1000);
		time = end_time - start_time;

		self display_round_time(time, hordes, dog_round);

		level waittill( "start_of_round" );

		if( getDvarInt( "hud_round_timer" ) >= 1 )
		{
			self.round_timer_hud FadeOverTime(level.FADE_TIME);
			self.round_timer_hud.alpha = 1;
		}
	}
}

display_round_time(time, hordes, dog_round)
{
	timer_for_hud = time - 0.05;

	sph_off = 1;
	if(level.round_number > 50 && !dog_round)
	{
		sph_off = 0;
	}

	self.round_timer_hud FadeOverTime(level.FADE_TIME);
	self.round_timer_hud.alpha = 0;
	wait level.FADE_TIME * 2;

	self.round_timer_hud.label = &"Round Time: ";
	self.round_timer_hud FadeOverTime(level.FADE_TIME);
	self.round_timer_hud.alpha = 1;

	for ( i = 0; i < 20 + (20 * sph_off); i++ ) // wait 10s or 5s
	{
		self.round_timer_hud setTimer(timer_for_hud);
		wait 0.25;
	}

	self.round_timer_hud FadeOverTime(level.FADE_TIME);
	self.round_timer_hud.alpha = 0;
	wait level.FADE_TIME * 2;

	if(sph_off == 0)
	{
		self display_sph(time, hordes);
	}

	self.round_timer_hud.label = &"";
}

display_sph( time, hordes )
{
	sph = time / hordes;

	self.round_timer_hud FadeOverTime(level.FADE_TIME);
	self.round_timer_hud.alpha = 1;
	self.round_timer_hud.label = &"SPH: ";
	self.round_timer_hud setValue(sph);

	for ( i = 0; i < 5; i++ )
	{
		wait 1;
	}

	self.round_timer_hud FadeOverTime(level.FADE_TIME);
	self.round_timer_hud.alpha = 0;

	wait level.FADE_TIME;
}

round_timer_hud_watcher()
{	
	self endon("disconnect");
	level endon( "end_game" );

	if( getDvar( "hud_round_timer") == "" )
		setDvar( "hud_round_timer", 0 );

	while(1)
	{
		while( getDvarInt( "hud_round_timer" ) == 0 )
		{
			wait 0.1;
		}
		self.round_timer_hud.y = (2 + (15 * getDvarInt("hud_timer") ) + self.hud_offset );
		self.round_timer_hud.alpha = 1;

		while( getDvarInt( "hud_round_timer" ) >= 1 )
		{
			wait 0.1;
		}
		self.round_timer_hud.alpha = 0;

	}
}

health_bar_hud()
{
	level endon("end_game");
	self endon("disconnect");

	flag_wait("initial_blackscreen_passed");

	if( getDvar( "hud_health_bar") == "" )
		setDvar( "hud_health_bar", 0 );

	health_bar = self createprimaryprogressbar();
	if (level.script == "zm_buried")
	{
		health_bar setpoint("CENTER", "BOTTOM", -335, -95);
	}
	else if (level.script == "zm_tomb")
	{
		health_bar setpoint("CENTER", "BOTTOM", -335, -100);
	}
	else
	{
		health_bar setpoint("CENTER", "BOTTOM", -335, -70);
	}
	health_bar.hidewheninmenu = 1;
	health_bar.bar.hidewheninmenu = 1;
	health_bar.barframe.hidewheninmenu = 1;

	health_bar_text = self createprimaryprogressbartext();
	if (level.script == "zm_buried")
	{
		health_bar_text setpoint("CENTER", "BOTTOM", -410, -95);
	}
	else if (level.script == "zm_tomb")
	{
		health_bar_text setpoint("CENTER", "BOTTOM", -410, -100);
	}
	else
	{
		health_bar_text setpoint("CENTER", "BOTTOM", -410, -70);
	}
	health_bar_text.hidewheninmenu = 1;

	while (1)
	{
		if( getDvarInt( "hud_health_bar" ) == 0)
		{	
			if (health_bar.alpha != 0)
			{
				health_bar.alpha = 0;
				health_bar.bar.alpha = 0;
				health_bar.barframe.alpha = 0;
				health_bar_text.alpha = 0;
			}
		}
		else
		{
			if (isDefined(self.e_afterlife_corpse))
			{
				if (health_bar.alpha != 0)
				{
					health_bar.alpha = 0;
					health_bar.bar.alpha = 0;
					health_bar.barframe.alpha = 0;
					health_bar_text.alpha = 0;
				}
				wait 0.05;
				continue;
			}

			if ( ( isDefined( self.waiting_to_revive ) && self.waiting_to_revive == 1) || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
			{
				if (health_bar.alpha != 0)
				{
					health_bar.alpha = 0;
					health_bar.bar.alpha = 0;
					health_bar.barframe.alpha = 0;
					health_bar_text.alpha = 0;
				}
				wait 0.05;
				continue;
			}

			if (health_bar.alpha != 1)
			{
				health_bar.alpha = 1;
				health_bar.bar.alpha = 1;
				health_bar.barframe.alpha = 1;
				health_bar_text.alpha = 1;
			}

			health_bar updatebar(self.health / self.maxhealth);
			health_bar_text setvalue(self.health);
		}

		wait 0.05;
	}
}

zombie_remaining_hud()
{
	self endon( "disconnect" );
	level endon( "end_game" );

	level waittill( "start_of_round" );

    self.zombiesCounter = maps/mp/gametypes_zm/_hud_util::createFontString( "hudsmall" , 1.6 );
    self.zombiesCounter maps/mp/gametypes_zm/_hud_util::setPoint( "CENTER", "CENTER", "CENTER", 190 );
    self.zombiesCounter.alpha = 0;
    self.zombiesCounter.label = &"Zombies: ^1";
	self thread zombie_remaining_hud_watcher();

    while( 1 )
    {
        self.zombiesCounter setValue( ( maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total ) );
        
        wait 0.05; 
    }
}

zombie_remaining_hud_watcher()
{	
	self endon("disconnect");
	level endon( "end_game" );

	if( getDvar( "hud_remaining") == "" )
		setDvar( "hud_remaining", 0 );

	while(1)
	{
		while( getDvarInt( "hud_remaining" ) == 0 )
		{
			wait 0.1;
		}
		self.zombiesCounter.alpha = 1;

		while( getDvarInt( "hud_remaining" ) >= 1 )
		{
			wait 0.1;
		}
		self.zombiesCounter.alpha = 0;
	}
}

sort_array_by_priority( arr )
{
    for (i = 0; i < arr.size; i++)
    {
        min_idx = i;
        for (j = i+1; j < n; j++)
		{
        	if (arr[j].priority < arr[min_idx].priority && arr[j].is_on == 1)
           		min_idx = j;
		}
 
		temp = arr[min_idx];
		arr[min_idx] = arr[i];
        arr[i] = temp;
    }
}

get_array_index( name )
{
	for( i = 0; i < self.total_hud.size; i++)
	{
		if ( self.total_hud[i].name == name)
			return i;
	}
}

set_hud_alpha_location( hud, dvar, name )
{
	if( dvar )
	{
		hud.y = 2 + ( 15 * get_array_index( name ));
		hud.alpha = 1;
		hud.is_on = 1;
	}
	else
	{
		hud.alpha = 0;
		hud.is_on = 0;
	}
}

hud_watcher()
{
	self.total_hud = [];
	// total_hud_on = [];

	self.timer_hud.priority = 1;
	self.round_timer_hud.priority = 2;

	for( i = 0; i < total_hud.size; i++)
	{
		if( self.total_hud[i].is_on == 1)
		{
			self.total_hud_on[i] = 1;
		}
		for( i = 0; i < self.total_hud.size; i++)
		{
			if( total_hud_on[i] == 1)
			{

			}
		}
	}

	if( getDvar( "hud_timer") == "" )
		setDvar( "hud_timer", 0 );
	if( getDvar( "hud_round_timer") == "" )
		setDvar( "hud_round_timer", 0 );
	while(1)
	{
		timer = getDvarInt("hud_timer"); 
		round_timer = getDvarInt("hud_round_timer");

		set_hud_alpha_location( self.timer_hud, timer, "timer");

		if( timer )
		{
			self.timer_hud.y = 2 + ( 15 * get_array_index("timer"));
			self.timer_hud.alpha = 1;
			self.timer_hud.is_on = 1;
		}
		else
		{
			self.timer_hud.alpha = 0;
			self.timer_hud.is_on = 0;
		}
		if( round_timer )
		{
			self.round_timer_hud.y = (2 + (15 * getDvarInt("hud_timer") ) );
			self.round_timer_hud.alpha = 1;
		}
		else
		{
			self.round_timer_hud.alpha = 0;
		}
	}


	while(1)
	{
		while( getDvarInt( "hud_round_timer" ) == 0 )
		{
			wait 0.1;
		}
		self.round_timer_hud.y = (2 + (15 * getDvarInt("hud_timer") ) );
		self.round_timer_hud.alpha = 1;

		while( getDvarInt( "hud_round_timer" ) >= 1 )
		{
			wait 0.1;
		}
		self.round_timer_hud.alpha = 0;

	}
}