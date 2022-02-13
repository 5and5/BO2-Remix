#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps\mp\_utility;

#include scripts/zm/remix/_utility;

all_hud_watcher()
{	
	self endon("disconnect");
	level endon( "end_game" );

	create_dvar( "hud_all", 0 );

	while(1)
	{	
		while( getDvarInt( "hud_all" ) == 0 )
		{
			wait 0.1;
		}
		self setClientDvar( "hud_round_timer", 1 );
		self setClientDvar( "hud_remaining", 1 );
		self setClientDvar( "hud_zone", 1 );
		self setClientDvar( "hud_health_bar", 1 );

		while( getDvarInt( "hud_all" ) >= 1 )
		{
			wait 0.1;
		}
		self setClientDvar( "hud_round_timer", 0 );
		self setClientDvar( "hud_remaining", 0 );
		self setClientDvar( "hud_zones", 0 );
		self setClientDvar( "hud_health_bar", 0 );
	}
}

timer_hud()
{	
	self endon("disconnect");

	create_dvar( "hud_timer", 1 );

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

	// self thread tab_hud();
	// self thread waittill_player_pressed_scoreboard();

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
		self.timer_hud_offset = 10;
	}
	else
	{
		self.timer_hud_offset = 0;	
	}
	self.zone_hud_offset = 15;
}

timer_hud_watcher()
{	
	self endon("disconnect");
	level endon( "end_game" );

	while(1)
	{	
		while( getDvarInt( "hud_timer" ) == 0 )
		{
			wait 0.1;
		}
		self.timer_hud.y = (2 + self.timer_hud_offset);
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

	create_dvar( "hud_round_timer", 0 );

	self.round_timer_hud = newClientHudElem(self);
	self.round_timer_hud.alignx = "left";
	self.round_timer_hud.aligny = "top";
	self.round_timer_hud.horzalign = "user_left";
	self.round_timer_hud.vertalign = "user_top";
	self.round_timer_hud.x += 4;
	self.round_timer_hud.y += (2 + (15 * getDvarInt("hud_timer") ) + self.timer_hud_offset );
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
		leaper_round = flag( "leaper_round" );

		self.round_timer_hud setTimerUp(0);
		start_time = int(getTime() / 1000);

		level waittill( "end_of_round" );

		end_time = int(getTime() / 1000);
		time = end_time - start_time;

		self display_round_time(time, hordes, dog_round, leaper_round);

		level waittill( "start_of_round" );

		if( getDvarInt( "hud_round_timer" ) >= 1 )
		{
			self.round_timer_hud FadeOverTime(level.FADE_TIME);
			self.round_timer_hud.alpha = 1;
		}
	}
}

display_round_time(time, hordes, dog_round, leaper_round)
{
	timer_for_hud = time - 0.05;

	sph_off = 1;
	if(level.round_number > 50 && !dog_round && !leaper_round)
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

	while(1)
	{
		while( getDvarInt( "hud_round_timer" ) == 0 )
		{
			wait 0.1;
		}
		self.round_timer_hud.y = (2 + (15 * getDvarInt("hud_timer") ) + self.timer_hud_offset );
		self.round_timer_hud.alpha = 1;

		while( getDvarInt( "hud_round_timer" ) >= 1 )
		{
			wait 0.1;
		}
		self.round_timer_hud.alpha = 0;

	}
}

zombie_remaining_hud()
{
	self endon( "disconnect" );
	level endon( "end_game" );

	level waittill( "start_of_round" );

    self.zombie_counter_hud = maps/mp/gametypes_zm/_hud_util::createFontString( "hudsmall" , 1.4 );
    self.zombie_counter_hud maps/mp/gametypes_zm/_hud_util::setPoint( "CENTER", "CENTER", "CENTER", 190 );
    self.zombie_counter_hud.alpha = 0;
    self.zombie_counter_hud.label = &"Zombies: ^1";
	self thread zombie_remaining_hud_watcher();

    while( 1 )
    {
        self.zombie_counter_hud setValue( ( maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total ) );
        
        wait 0.05; 
    }
}

zombie_remaining_hud_watcher()
{	
	self endon("disconnect");
	level endon( "end_game" );

	create_dvar( "hud_remaining", 0 );

	while(1)
	{
		while( getDvarInt( "hud_remaining" ) == 0 )
		{
			wait 0.1;
		}
		self.zombie_counter_hud.alpha = 1;

		while( getDvarInt( "hud_remaining" ) >= 1 )
		{
			wait 0.1;
		}
		self.zombie_counter_hud.alpha = 0;
	}
}

health_bar_hud()
{
	self endon("disconnect");

	create_dvar( "hud_health_bar", 0 );

	flag_wait( "initial_blackscreen_passed" );

	x = 62;
	y = 135;
	if (level.script == "zm_buried")
	{
		y += 27;
	}
	else if (level.script == "zm_tomb")
	{
		y -= 60;
	}

	self.health_bar = self createbar((1, 1, 1), level.primaryprogressbarwidth - 9, level.primaryprogressbarheight - 1);
	self.health_bar setpoint_custom(undefined, "LEFT", x, y);
	self.health_bar.hidewheninmenu = 1;
	self.health_bar.bar.hidewheninmenu = 1;
	self.health_bar.barframe.hidewheninmenu = 1;

	self.health_bar_text = createfontstring("objective", 1.1);
	self.health_bar_text setpoint_custom(undefined, "LEFT", x + 67, y - 0.5);
	self.health_bar_text.hidewheninmenu = 1;

	while( 1 )
	{
		if( getDvarInt( "hud_health_bar" ) == 0)
		{	
			self.health_bar hideelem();
			self.health_bar_text hideelem();
		}
		else
		{
			if( isDefined(self.e_afterlife_corpse) || isDefined( self.waiting_to_revive ) && self.waiting_to_revive == 1 || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
			{
				self.health_bar hideelem();
				self.health_bar_text hideelem();
			}
			else
			{
				self.health_bar showelem();
				self.health_bar_text showelem();
			}

			self.health_bar updatebar(self.health / self.maxhealth);
			self.health_bar_text setvalue(self.health);
		}

		wait 0.05;
	}
}

trap_timer_hud()
{
	if( level.script != "zm_prison" || !level.hud_trap_timer )
		return;

	self endon( "disconnect" );

	self.traptimer_hud = newclienthudelem( self );
	self.traptimer_hud.alignx = "left";
	self.traptimer_hud.aligny = "top";
	self.traptimer_hud.horzalign = "user_left";
	self.traptimer_hud.vertalign = "user_top";
	self.traptimer_hud.x += 4;
	self.traptimer_hud.y += (2 + (15 * (getDvarInt("hud_timer") + getDvarInt("hud_round_timer")) ) + self.timer_hud_offset );
	self.traptimer_hud.fontscale = 1.4;
	self.traptimer_hud.alpha = 0;
	self.traptimer_hud.color = ( 1, 1, 1 );
	self.traptimer_hud.hidewheninmenu = 1;
	self.traptimer_hud.hidden = 0;
	self.traptimer_hud.label = &"";

	while( 1 )
	{
		level waittill( "trap_activated" );
		if( !level.trap_activated )
		{
			wait 0.5;
			self.traptimer_hud.alpha = 1;
			self.traptimer_hud settimer( 50 );
			wait 50;
			self.traptimer_hud.alpha = 0;
		}
	}
}

zone_hud()
{
	self endon("disconnect");

	create_dvar( "hud_zone", 0 );

	x = 8;
	y = -111;
	if (level.script == "zm_buried")
	{
		y -= 25;
	}
	else if (level.script == "zm_tomb")
	{
		y -= 60;
	}

	self.zone_hud = newClientHudElem(self);
	self.zone_hud.alignx = "left";
	self.zone_hud.aligny = "bottom";
	self.zone_hud.horzalign = "user_left";
	self.zone_hud.vertalign = "user_bottom";
	self.zone_hud.x += x;
	self.zone_hud.y += y;
	self.zone_hud.fontscale = 1.3;
	self.zone_hud.alpha = 0;
	self.zone_hud.color = ( 1, 1, 1 );
	self.zone_hud.hidewheninmenu = 1;

	flag_wait( "initial_blackscreen_passed" );

	self thread zone_hud_watcher(x, y);
}

zone_hud_watcher( x, y )
{	
	self endon("disconnect");
	level endon( "end_game" );

	prev_zone = "";
	while(1)
	{
		while( getDvarInt( "hud_zone" ) == 0 )
		{
			wait 0.1;
		}

		while( getDvarInt( "hud_zone" ) >= 1 )
		{
			self.zone_hud.y = (y + (self.zone_hud_offset * !getDvarInt("hud_health_bar") ) );

			zone = self get_zone_name();
			if(prev_zone != zone)
			{
				prev_zone = zone;

				self.zone_hud fadeovertime(0.2);
				self.zone_hud.alpha = 0;
				wait 0.2;

				self.zone_hud settext(zone);

				self.zone_hud fadeovertime(0.2);
				self.zone_hud.alpha = 1;
				wait 0.2;

				continue;
			}

			wait 0.05;
		}
		self.zone_hud.alpha = 0;
	}
}

get_zone_name()
{
	zone = self get_current_zone();
	if (!isDefined(zone))
	{
		return "";
	}

	name = zone;

	if (level.script == "zm_transit")
	{
		if (zone == "zone_pri")
		{
			name = "Bus Depot";
		}
		else if (zone == "zone_pri2")
		{
			name = "Bus Depot Hallway";
		}
		else if (zone == "zone_station_ext")
		{
			name = "Outside Bus Depot";
		}
		else if (zone == "zone_trans_2b")
		{
			name = "Fog After Bus Depot";
		}
		else if (zone == "zone_trans_2")
		{
			name = "Tunnel Entrance";
		}
		else if (zone == "zone_amb_tunnel")
		{
			name = "Tunnel";
		}
		else if (zone == "zone_trans_3")
		{
			name = "Tunnel Exit";
		}
		else if (zone == "zone_roadside_west")
		{
			name = "Outside Diner";
		}
		else if (zone == "zone_gas")
		{
			name = "Gas Station";
		}
		else if (zone == "zone_roadside_east")
		{
			name = "Outside Garage";
		}
		else if (zone == "zone_trans_diner")
		{
			name = "Fog Outside Diner";
		}
		else if (zone == "zone_trans_diner2")
		{
			name = "Fog Outside Garage";
		}
		else if (zone == "zone_gar")
		{
			name = "Garage";
		}
		else if (zone == "zone_din")
		{
			name = "Diner";
		}
		else if (zone == "zone_diner_roof")
		{
			name = "Diner Roof";
		}
		else if (zone == "zone_trans_4")
		{
			name = "Fog After Diner";
		}
		else if (zone == "zone_amb_forest")
		{
			name = "Forest";
		}
		else if (zone == "zone_trans_10")
		{
			name = "Outside Church";
		}
		else if (zone == "zone_town_church")
		{
			name = "Church";
		}
		else if (zone == "zone_trans_5")
		{
			name = "Fog Before Farm";
		}
		else if (zone == "zone_far")
		{
			name = "Outside Farm";
		}
		else if (zone == "zone_far_ext")
		{
			name = "Farm";
		}
		else if (zone == "zone_brn")
		{
			name = "Barn";
		}
		else if (zone == "zone_farm_house")
		{
			name = "Farmhouse";
		}
		else if (zone == "zone_trans_6")
		{
			name = "Fog After Farm";
		}
		else if (zone == "zone_amb_cornfield")
		{
			name = "Cornfield";
		}
		else if (zone == "zone_cornfield_prototype")
		{
			name = "Nacht";
		}
		else if (zone == "zone_trans_7")
		{
			name = "Upper Fog Before Power";
		}
		else if (zone == "zone_trans_pow_ext1")
		{
			name = "Fog Before Power";
		}
		else if (zone == "zone_pow")
		{
			name = "Outside Power Station";
		}
		else if (zone == "zone_prr")
		{
			name = "Power Station";
		}
		else if (zone == "zone_pcr")
		{
			name = "Power Control Room";
		}
		else if (zone == "zone_pow_warehouse")
		{
			name = "Warehouse";
		}
		else if (zone == "zone_trans_8")
		{
			name = "Fog After Power";
		}
		else if (zone == "zone_amb_power2town")
		{
			name = "Cabin";
		}
		else if (zone == "zone_trans_9")
		{
			name = "Fog Before Town";
		}
		else if (zone == "zone_town_north")
		{
			name = "North Town";
		}
		else if (zone == "zone_tow")
		{
			name = "Center Town";
		}
		else if (zone == "zone_town_east")
		{
			name = "East Town";
		}
		else if (zone == "zone_town_west")
		{
			name = "West Town";
		}
		else if (zone == "zone_town_south")
		{
			name = "South Town";
		}
		else if (zone == "zone_bar")
		{
			name = "Bar";
		}
		else if (zone == "zone_town_barber")
		{
			name = "Bookstore";
		}
		else if (zone == "zone_ban")
		{
			name = "Bank";
		}
		else if (zone == "zone_ban_vault")
		{
			name = "Bank Vault";
		}
		else if (zone == "zone_tbu")
		{
			name = "Below Bank";
		}
		else if (zone == "zone_trans_11")
		{
			name = "Fog After Town";
		}
		else if (zone == "zone_amb_bridge")
		{
			name = "Bridge";
		}
		else if (zone == "zone_trans_1")
		{
			name = "Fog Before Bus Depot";
		}
	}
	else if (level.script == "zm_nuked")
	{
		if (zone == "culdesac_yellow_zone")
		{
			name = "Yellow House Middle";
		}
		else if (zone == "culdesac_green_zone")
		{
			name = "Green House Middle";
		}
		else if (zone == "truck_zone")
		{
			name = "Truck";
		}
		else if (zone == "openhouse1_f1_zone")
		{
			name = "Green House Downstairs";
		}
		else if (zone == "openhouse1_f2_zone")
		{
			name = "Green House Upstairs";
		}
		else if (zone == "openhouse1_backyard_zone")
		{
			name = "Green House Backyard";
		}
		else if (zone == "openhouse2_f1_zone")
		{
			name = "Yellow House Downstairs";
		}
		else if (zone == "openhouse2_f2_zone")
		{
			name = "Yellow House Upstairs";
		}
		else if (zone == "openhouse2_backyard_zone")
		{
			name = "Yellow House Backyard";
		}
		else if (zone == "ammo_door_zone")
		{
			name = "Yellow House Backyard Door";
		}
	}
	else if (level.script == "zm_highrise")
	{
		if (zone == "zone_green_start")
		{
			name = "Green Highrise Level 3b";
		}
		else if (zone == "zone_green_escape_pod")
		{
			name = "Escape Pod";
		}
		else if (zone == "zone_green_escape_pod_ground")
		{
			name = "Escape Pod Shaft";
		}
		else if (zone == "zone_green_level1")
		{
			name = "Green Highrise Level 3a";
		}
		else if (zone == "zone_green_level2a")
		{
			name = "Green Highrise Level 2a";
		}
		else if (zone == "zone_green_level2b")
		{
			name = "Green Highrise Level 2b";
		}
		else if (zone == "zone_green_level3a")
		{
			name = "Green Highrise Restaurant";
		}
		else if (zone == "zone_green_level3b")
		{
			name = "Green Highrise Level 1a";
		}
		else if (zone == "zone_green_level3c")
		{
			name = "Green Highrise Level 1b";
		}
		else if (zone == "zone_green_level3d")
		{
			name = "Green Highrise Behind Restaurant";
		}
		else if (zone == "zone_orange_level1")
		{
			name = "Upper Orange Highrise Level 2";
		}
		else if (zone == "zone_orange_level2")
		{
			name = "Upper Orange Highrise Level 1";
		}
		else if (zone == "zone_orange_elevator_shaft_top")
		{
			name = "Elevator Shaft Level 3";
		}
		else if (zone == "zone_orange_elevator_shaft_middle_1")
		{
			name = "Elevator Shaft Level 2";
		}
		else if (zone == "zone_orange_elevator_shaft_middle_2")
		{
			name = "Elevator Shaft Level 1";
		}
		else if (zone == "zone_orange_elevator_shaft_bottom")
		{
			name = "Elevator Shaft Bottom";
		}
		else if (zone == "zone_orange_level3a")
		{
			name = "Lower Orange Highrise Level 1a";
		}
		else if (zone == "zone_orange_level3b")
		{
			name = "Lower Orange Highrise Level 1b";
		}
		else if (zone == "zone_blue_level5")
		{
			name = "Lower Blue Highrise Level 1";
		}
		else if (zone == "zone_blue_level4a")
		{
			name = "Lower Blue Highrise Level 2a";
		}
		else if (zone == "zone_blue_level4b")
		{
			name = "Lower Blue Highrise Level 2b";
		}
		else if (zone == "zone_blue_level4c")
		{
			name = "Lower Blue Highrise Level 2c";
		}
		else if (zone == "zone_blue_level2a")
		{
			name = "Upper Blue Highrise Level 1a";
		}
		else if (zone == "zone_blue_level2b")
		{
			name = "Upper Blue Highrise Level 1b";
		}
		else if (zone == "zone_blue_level2c")
		{
			name = "Upper Blue Highrise Level 1c";
		}
		else if (zone == "zone_blue_level2d")
		{
			name = "Upper Blue Highrise Level 1d";
		}
		else if (zone == "zone_blue_level1a")
		{
			name = "Upper Blue Highrise Level 2a";
		}
		else if (zone == "zone_blue_level1b")
		{
			name = "Upper Blue Highrise Level 2b";
		}
		else if (zone == "zone_blue_level1c")
		{
			name = "Upper Blue Highrise Level 2c";
		}
	}
	else if (level.script == "zm_prison")
	{
		if (zone == "zone_start")
		{
			name = "D-Block";
		}
		else if (zone == "zone_library")
		{
			name = "Library";
		}
		else if (zone == "zone_cellblock_west")
		{
			name = "Cellblock 2nd Floor";
		}
		else if (zone == "zone_cellblock_west_gondola")
		{
			name = "Cellblock 3rd Floor";
		}
		else if (zone == "zone_cellblock_west_gondola_dock")
		{
			name = "Cellblock Gondola";
		}
		else if (zone == "zone_cellblock_west_barber")
		{
			name = "Michigan Avenue";
		}
		else if (zone == "zone_cellblock_east")
		{
			name = "Times Square";
		}
		else if (zone == "zone_cafeteria")
		{
			name = "Cafeteria";
		}
		else if (zone == "zone_cafeteria_end")
		{
			name = "Cafeteria End";
		}
		else if (zone == "zone_infirmary")
		{
			name = "Infirmary 1";
		}
		else if (zone == "zone_infirmary_roof")
		{
			name = "Infirmary 2";
		}
		else if (zone == "zone_roof_infirmary")
		{
			name = "Roof 1";
		}
		else if (zone == "zone_roof")
		{
			name = "Roof 2";
		}
		else if (zone == "zone_cellblock_west_warden")
		{
			name = "Sally Port";
		}
		else if (zone == "zone_warden_office")
		{
			name = "Warden's Office";
		}
		else if (zone == "cellblock_shower")
		{
			name = "Showers";
		}
		else if (zone == "zone_citadel_shower")
		{
			name = "Citadel To Showers";
		}
		else if (zone == "zone_citadel")
		{
			name = "Citadel";
		}
		else if (zone == "zone_citadel_warden")
		{
			name = "Citadel To Warden's Office";
		}
		else if (zone == "zone_citadel_stairs")
		{
			name = "Citadel Tunnels";
		}
		else if (zone == "zone_citadel_basement")
		{
			name = "Citadel Basement";
		}
		else if (zone == "zone_citadel_basement_building")
		{
			name = "China Alley";
		}
		else if (zone == "zone_studio")
		{
			name = "Building 64";
		}
		else if (zone == "zone_dock")
		{
			name = "Docks";
		}
		else if (zone == "zone_dock_puzzle")
		{
			name = "Docks Gates";
		}
		else if (zone == "zone_dock_gondola")
		{
			name = "Upper Docks";
		}
		else if (zone == "zone_golden_gate_bridge")
		{
			name = "Golden Gate Bridge";
		}
		else if (zone == "zone_gondola_ride")
		{
			name = "Gondola";
		}
	}
	else if (level.script == "zm_buried")
	{
		if (zone == "zone_start")
		{
			name = "Processing";
		}
		else if (zone == "zone_start_lower")
		{
			name = "Lower Processing";
		}
		else if (zone == "zone_tunnels_center")
		{
			name = "Center Tunnels";
		}
		else if (zone == "zone_tunnels_north")
		{
			name = "Courthouse Tunnels 2";
		}
		else if (zone == "zone_tunnels_north2")
		{
			name = "Courthouse Tunnels 1";
		}
		else if (zone == "zone_tunnels_south")
		{
			name = "Saloon Tunnels 3";
		}
		else if (zone == "zone_tunnels_south2")
		{
			name = "Saloon Tunnels 2";
		}
		else if (zone == "zone_tunnels_south3")
		{
			name = "Saloon Tunnels 1";
		}
		else if (zone == "zone_street_lightwest")
		{
			name = "Outside General Store & Bank";
		}
		else if (zone == "zone_street_lightwest_alley")
		{
			name = "Outside General Store & Bank Alley";
		}
		else if (zone == "zone_morgue_upstairs")
		{
			name = "Morgue";
		}
		else if (zone == "zone_underground_jail")
		{
			name = "Jail Downstairs";
		}
		else if (zone == "zone_underground_jail2")
		{
			name = "Jail Upstairs";
		}
		else if (zone == "zone_general_store")
		{
			name = "General Store";
		}
		else if (zone == "zone_stables")
		{
			name = "Stables";
		}
		else if (zone == "zone_street_darkwest")
		{
			name = "Outside Gunsmith";
		}
		else if (zone == "zone_street_darkwest_nook")
		{
			name = "Outside Gunsmith Nook";
		}
		else if (zone == "zone_gun_store")
		{
			name = "Gunsmith";
		}
		else if (zone == "zone_bank")
		{
			name = "Bank";
		}
		else if (zone == "zone_tunnel_gun2stables")
		{
			name = "Stables To Gunsmith Tunnel 2";
		}
		else if (zone == "zone_tunnel_gun2stables2")
		{
			name = "Stables To Gunsmith Tunnel";
		}
		else if (zone == "zone_street_darkeast")
		{
			name = "Outside Saloon & Toy Store";
		}
		else if (zone == "zone_street_darkeast_nook")
		{
			name = "Outside Saloon & Toy Store Nook";
		}
		else if (zone == "zone_underground_bar")
		{
			name = "Saloon";
		}
		else if (zone == "zone_tunnel_gun2saloon")
		{
			name = "Saloon To Gunsmith Tunnel";
		}
		else if (zone == "zone_toy_store")
		{
			name = "Toy Store Downstairs";
		}
		else if (zone == "zone_toy_store_floor2")
		{
			name = "Toy Store Upstairs";
		}
		else if (zone == "zone_toy_store_tunnel")
		{
			name = "Toy Store Tunnel";
		}
		else if (zone == "zone_candy_store")
		{
			name = "Candy Store Downstairs";
		}
		else if (zone == "zone_candy_store_floor2")
		{
			name = "Candy Store Upstairs";
		}
		else if (zone == "zone_street_lighteast")
		{
			name = "Outside Courthouse & Candy Store";
		}
		else if (zone == "zone_underground_courthouse")
		{
			name = "Courthouse Downstairs";
		}
		else if (zone == "zone_underground_courthouse2")
		{
			name = "Courthouse Upstairs";
		}
		else if (zone == "zone_street_fountain")
		{
			name = "Fountain";
		}
		else if (zone == "zone_church_graveyard")
		{
			name = "Graveyard";
		}
		else if (zone == "zone_church_main")
		{
			name = "Church Downstairs";
		}
		else if (zone == "zone_church_upstairs")
		{
			name = "Church Upstairs";
		}
		else if (zone == "zone_mansion_lawn")
		{
			name = "Mansion Lawn";
		}
		else if (zone == "zone_mansion")
		{
			name = "Mansion";
		}
		else if (zone == "zone_mansion_backyard")
		{
			name = "Mansion Backyard";
		}
		else if (zone == "zone_maze")
		{
			name = "Maze";
		}
		else if (zone == "zone_maze_staircase")
		{
			name = "Maze Staircase";
		}
	}
	else if (level.script == "zm_tomb")
	{
		if (isDefined(self.teleporting) && self.teleporting)
		{
			return "";
		}

		if (zone == "zone_start")
		{
			name = "Lower Laboratory";
		}
		else if (zone == "zone_start_a")
		{
			name = "Upper Laboratory";
		}
		else if (zone == "zone_start_b")
		{
			name = "Generator 1";
		}
		else if (zone == "zone_bunker_1a")
		{
			name = "Generator 3 Bunker 1";
		}
		else if (zone == "zone_fire_stairs")
		{
			name = "Fire Tunnel";
		}
		else if (zone == "zone_bunker_1")
		{
			name = "Generator 3 Bunker 2";
		}
		else if (zone == "zone_bunker_3a")
		{
			name = "Generator 3";
		}
		else if (zone == "zone_bunker_3b")
		{
			name = "Generator 3 Bunker 3";
		}
		else if (zone == "zone_bunker_2a")
		{
			name = "Generator 2 Bunker 1";
		}
		else if (zone == "zone_bunker_2")
		{
			name = "Generator 2 Bunker 2";
		}
		else if (zone == "zone_bunker_4a")
		{
			name = "Generator 2";
		}
		else if (zone == "zone_bunker_4b")
		{
			name = "Generator 2 Bunker 3";
		}
		else if (zone == "zone_bunker_4c")
		{
			name = "Tank Station";
		}
		else if (zone == "zone_bunker_4d")
		{
			name = "Above Tank Station";
		}
		else if (zone == "zone_bunker_tank_c")
		{
			name = "Generator 2 Tank Route 1";
		}
		else if (zone == "zone_bunker_tank_c1")
		{
			name = "Generator 2 Tank Route 2";
		}
		else if (zone == "zone_bunker_4e")
		{
			name = "Generator 2 Tank Route 3";
		}
		else if (zone == "zone_bunker_tank_d")
		{
			name = "Generator 2 Tank Route 4";
		}
		else if (zone == "zone_bunker_tank_d1")
		{
			name = "Generator 2 Tank Route 5";
		}
		else if (zone == "zone_bunker_4f")
		{
			name = "zone_bunker_4f";
		}
		else if (zone == "zone_bunker_5a")
		{
			name = "Workshop Downstairs";
		}
		else if (zone == "zone_bunker_5b")
		{
			name = "Workshop Upstairs";
		}
		else if (zone == "zone_nml_2a")
		{
			name = "No Man's Land Walkway";
		}
		else if (zone == "zone_nml_2")
		{
			name = "No Man's Land Entrance";
		}
		else if (zone == "zone_bunker_tank_e")
		{
			name = "Generator 5 Tank Route 1";
		}
		else if (zone == "zone_bunker_tank_e1")
		{
			name = "Generator 5 Tank Route 2";
		}
		else if (zone == "zone_bunker_tank_e2")
		{
			name = "zone_bunker_tank_e2";
		}
		else if (zone == "zone_bunker_tank_f")
		{
			name = "Generator 5 Tank Route 3";
		}
		else if (zone == "zone_nml_1")
		{
			name = "Generator 5 Tank Route 4";
		}
		else if (zone == "zone_nml_4")
		{
			name = "Generator 5 Tank Route 5";
		}
		else if (zone == "zone_nml_0")
		{
			name = "Generator 5 Left Footstep";
		}
		else if (zone == "zone_nml_5")
		{
			name = "Generator 5 Right Footstep Walkway";
		}
		else if (zone == "zone_nml_farm")
		{
			name = "Generator 5";
		}
		else if (zone == "zone_nml_celllar")
		{
			name = "Generator 5 Cellar";
		}
		else if (zone == "zone_bolt_stairs")
		{
			name = "Lightning Tunnel";
		}
		else if (zone == "zone_nml_3")
		{
			name = "No Man's Land 1st Right Footstep";
		}
		else if (zone == "zone_nml_2b")
		{
			name = "No Man's Land Stairs";
		}
		else if (zone == "zone_nml_6")
		{
			name = "No Man's Land Left Footstep";
		}
		else if (zone == "zone_nml_8")
		{
			name = "No Man's Land 2nd Right Footstep";
		}
		else if (zone == "zone_nml_10a")
		{
			name = "Generator 4 Tank Route 1";
		}
		else if (zone == "zone_nml_10")
		{
			name = "Generator 4 Tank Route 2";
		}
		else if (zone == "zone_nml_7")
		{
			name = "Generator 4 Tank Route 3";
		}
		else if (zone == "zone_bunker_tank_a")
		{
			name = "Generator 4 Tank Route 4";
		}
		else if (zone == "zone_bunker_tank_a1")
		{
			name = "Generator 4 Tank Route 5";
		}
		else if (zone == "zone_bunker_tank_a2")
		{
			name = "zone_bunker_tank_a2";
		}
		else if (zone == "zone_bunker_tank_b")
		{
			name = "Generator 4 Tank Route 6";
		}
		else if (zone == "zone_nml_9")
		{
			name = "Generator 4 Left Footstep";
		}
		else if (zone == "zone_air_stairs")
		{
			name = "Wind Tunnel";
		}
		else if (zone == "zone_nml_11")
		{
			name = "Generator 4";
		}
		else if (zone == "zone_nml_12")
		{
			name = "Generator 4 Right Footstep";
		}
		else if (zone == "zone_nml_16")
		{
			name = "Excavation Site Front Path";
		}
		else if (zone == "zone_nml_17")
		{
			name = "Excavation Site Back Path";
		}
		else if (zone == "zone_nml_18")
		{
			name = "Excavation Site Level 3";
		}
		else if (zone == "zone_nml_19")
		{
			name = "Excavation Site Level 2";
		}
		else if (zone == "ug_bottom_zone")
		{
			name = "Excavation Site Level 1";
		}
		else if (zone == "zone_nml_13")
		{
			name = "Generator 5 To Generator 6 Path";
		}
		else if (zone == "zone_nml_14")
		{
			name = "Generator 4 To Generator 6 Path";
		}
		else if (zone == "zone_nml_15")
		{
			name = "Generator 6 Entrance";
		}
		else if (zone == "zone_village_0")
		{
			name = "Generator 6 Left Footstep";
		}
		else if (zone == "zone_village_5")
		{
			name = "Generator 6 Tank Route 1";
		}
		else if (zone == "zone_village_5a")
		{
			name = "Generator 6 Tank Route 2";
		}
		else if (zone == "zone_village_5b")
		{
			name = "Generator 6 Tank Route 3";
		}
		else if (zone == "zone_village_1")
		{
			name = "Generator 6 Tank Route 4";
		}
		else if (zone == "zone_village_4b")
		{
			name = "Generator 6 Tank Route 5";
		}
		else if (zone == "zone_village_4a")
		{
			name = "Generator 6 Tank Route 6";
		}
		else if (zone == "zone_village_4")
		{
			name = "Generator 6 Tank Route 7";
		}
		else if (zone == "zone_village_2")
		{
			name = "Church";
		}
		else if (zone == "zone_village_3")
		{
			name = "Generator 6 Right Footstep";
		}
		else if (zone == "zone_village_3a")
		{
			name = "Generator 6";
		}
		else if (zone == "zone_ice_stairs")
		{
			name = "Ice Tunnel";
		}
		else if (zone == "zone_bunker_6")
		{
			name = "Above Generator 3 Bunker";
		}
		else if (zone == "zone_nml_20")
		{
			name = "Above No Man's Land";
		}
		else if (zone == "zone_village_6")
		{
			name = "Behind Church";
		}
		else if (zone == "zone_chamber_0")
		{
			name = "The Crazy Place Lightning Chamber";
		}
		else if (zone == "zone_chamber_1")
		{
			name = "The Crazy Place Lightning & Ice";
		}
		else if (zone == "zone_chamber_2")
		{
			name = "The Crazy Place Ice Chamber";
		}
		else if (zone == "zone_chamber_3")
		{
			name = "The Crazy Place Fire & Lightning";
		}
		else if (zone == "zone_chamber_4")
		{
			name = "The Crazy Place Center";
		}
		else if (zone == "zone_chamber_5")
		{
			name = "The Crazy Place Ice & Wind";
		}
		else if (zone == "zone_chamber_6")
		{
			name = "The Crazy Place Fire Chamber";
		}
		else if (zone == "zone_chamber_7")
		{
			name = "The Crazy Place Wind & Fire";
		}
		else if (zone == "zone_chamber_8")
		{
			name = "The Crazy Place Wind Chamber";
		}
		else if (zone == "zone_robot_head")
		{
			name = "Robot's Head";
		}
	}

	return name;
}

color_hud_watcher()
{
	self endon("disconnect");

	create_dvar( "hud_color", "1 1 1" );
	prev_color = "1 1 1";

	while( 1 )
	{
		while( color == prev_color )
		{
			color = getDvar( "hud_color" );
			wait 0.1;
		}

		colors = strTok( color, " ");
		if( colors.size != 3 )
			continue;

		prev_color = color;

		self.timer_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		self.round_timer_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		self.health_bar.bar.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		self.health_bar_text.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		self.zombie_counter_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
		self.zone_hud.color = ( string_to_float(colors[0]), string_to_float(colors[1]), string_to_float(colors[2]) );
	}
}

tab_hud()
{
	while(1)
	{
		if(self buttonPressed( "TAB" ))
		{
			// self notify("player_pressed_scoreboard_button");
			self notifyonplayercommand("player_pressed_scoreboard_button", "+scores");
			// iPrintLn("working");
		}
		wait 0.05;
	}
}

waittill_player_pressed_scoreboard()
{
	while(1)
	{
		self waittill("player_pressed_scoreboard_button");
		self.timer_hud.alpha = 0;
		iPrintLn("?");
	}
}

/*
* *****************************************************
*	
* ********************* Utility ***********************
*
* *****************************************************
*/

setpoint_custom( point, relativepoint, xoffset, yoffset ) //checked matches cerberus output
{

	element = self getparent();

	if ( !isDefined( xoffset ) )
	{
		xoffset = 0;
	}
	self.xoffset = xoffset;
	if ( !isDefined( yoffset ) )
	{
		yoffset = 0;
	}
	self.yoffset = yoffset;
	self.point = point;
	self.alignx = "center";
	self.aligny = "middle";
	switch( point )
	{
		case "CENTER":
			break;
		case "TOP":
			self.aligny = "top";
			break;
		case "BOTTOM":
			self.aligny = "bottom";
			break;
		case "LEFT":
			self.alignx = "left";
			break;
		case "RIGHT":
			self.alignx = "right";
			break;
		case "TOPRIGHT":
		case "TOP_RIGHT":
			self.aligny = "top";
			self.alignx = "right";
			break;
		case "TOPLEFT":
		case "TOP_LEFT":
			self.aligny = "top";
			self.alignx = "left";
			break;
		case "TOPCENTER":
			self.aligny = "top";
			self.alignx = "center";
			break;
		case "BOTTOM RIGHT":
		case "BOTTOM_RIGHT":
			self.aligny = "bottom";
			self.alignx = "right";
			break;
		case "BOTTOM LEFT":
		case "BOTTOM_LEFT":
			self.aligny = "bottom";
			self.alignx = "left";
			break;
		default:
			break;
	}
	if ( !isDefined( relativepoint ) )
	{
		relativepoint = point;
	}
	self.relativepoint = relativepoint;
	relativex = "center";
	relativey = "middle";
	switch( relativepoint )
	{
		case "CENTER":
			break;
		case "TOP":
			relativey = "top";
			break;
		case "BOTTOM":
			relativey = "bottom";
			break;
		case "LEFT":
			relativex = "user_left";
			break;
		case "RIGHT":
			relativex = "user_right";
			break;
		case "TOPRIGHT":
		case "TOP_RIGHT":
			relativey = "top";
			relativex = "user_right";
			break;
		case "TOPLEFT":
		case "TOP_LEFT":
			relativey = "top";
			relativex = "user_left";
			break;
		case "TOPCENTER":
			relativey = "top";
			relativex = "center";
			break;
		case "BOTTOM RIGHT":
		case "BOTTOM_RIGHT":
			relativey = "bottom";
			relativex = "user_right";
			break;
		case "BOTTOM LEFT":
		case "BOTTOM_LEFT":
			relativey = "bottom";
			relativex = "user_left";
			break;
		default:
			break;
	}
	if ( element == level.uiparent )
	{
		self.horzalign = relativex;
		self.vertalign = relativey;
	}
	else
	{
		self.horzalign = element.horzalign;
		self.vertalign = element.vertalign;
	}
	if ( relativex == element.alignx )
	{
		offsetx = 0;
		xfactor = 0;
	}
	else if ( relativex == "center" || element.alignx == "center" )
	{
		offsetx = int( element.width / 2 );
		if ( relativex == "left" || element.alignx == "right" )
		{
			xfactor = -1;
		}
		else
		{
			xfactor = 1;
		}
	}
	else
	{
		offsetx = element.width;
		if ( relativex == "left" )
		{
			xfactor = -1;
		}
		else
		{
			xfactor = 1;
		}
	}
	self.x = element.x + ( offsetx * xfactor );
	if ( relativey == element.aligny )
	{
		offsety = 0;
		yfactor = 0;
	}
	else if ( relativey == "middle" || element.aligny == "middle" )
	{
		offsety = int( element.height / 2 );
		if ( relativey == "top" || element.aligny == "bottom" )
		{
			yfactor = -1;
		}
		else
		{
			yfactor = 1;
		}
	}
	else
	{
		offsety = element.height;
		if ( relativey == "top" )
		{
			yfactor = -1;
		}
		else
		{
			yfactor = 1;
		}
	}
	self.y = element.y + ( offsety * yfactor );
	self.x += self.xoffset;
	self.y += self.yoffset;
	switch( self.elemtype )
	{
		case "bar":
			setpointbar( point, relativepoint, xoffset, yoffset );
			self.barframe setparent( self getparent() );
			self.barframe setpoint_custom( point, relativepoint, xoffset, yoffset );
			break;
	}
	self updatechildren();
}

hud_setter( hud, x, y )
{
	create_dvar( "x", x );
	create_dvar( "y", y );

	while( 1 )
	{
		x = getDvarInt( "x" );
		y = getDvarInt( "y" );
		hud setpoint_custom(undefined, "LEFT", x, y);
		wait 0.1;
	}
}

hud_setter2( hud, x, y )
{
	create_dvar( "x2", x );
	create_dvar( "y2", y );

	while( 1 )
	{
		x = getDvarInt( "x2" );
		y = getDvarInt( "y2" );
		hud setpoint_custom(undefined, "LEFT", x, y);
		wait 0.1;
	}
}