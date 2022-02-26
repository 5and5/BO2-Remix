#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_blockers;


settings()
{
	// Settings
	level.start_round = 70; 			// what round the game starts at
	level.start_delay = 15;				// time till zombies start spawning
	level.power_on = 1; 				// turns power on
	level.perks_on_revive = 1; 			// give perks back on revive
	level.perks_on_spawn = 1; 			// give perks on spawn
	level.weapons_on_spawn = 1;			// give weapons on spawn
	level.remove_boards = 1;			// remove all boards from windows
	level.open_doors = 0;				// opens all power doors
	level.strat_tester = 1;				// enable strat tester

	// HUD
	level.hud_timer = 0; 				// total game timer
	level.hud_round_timer = 1; 			// round timer
	level.hud_zombie_counter = 1;		// zombie remaining counter
	level.hud_zone_names = 1;			// spawn zone hud
	level.hud_trap_timer = 1;			// auto trap timer on mob
	level.hud_health_bar = 0;			// not added yet
}

main()
{
	// Pluto only
    // replaceFunc( maps/mp/zombies/_zm_powerups::powerup_drop, ::powerup_drop_override );
}

init()
{
	level.STRAT_TESTER_VERSION = "0.9";
    level.init = 0;
	settings();
    level thread onConnect();
}

onConnect()
{
    for (;;)
    {
        level waittill( "connected" , player);
        player thread connected();
    }
}

connected()
{
    self endon( "disconnect" );
    self.init = 0;

	enable_strat_tester( 0 );
	if( !level.strat_tester )
		return;

    for(;;)
    {
        self waittill( "spawned_player" );

		self tomb_give_shovel();

        if( !self.init )
        {
            self.init = 1;

            self.score = 500000;
			self welcome_message();

            self thread timer_hud();
			self thread round_timer_hud();
			self thread zone_hud();
			self thread trap_timer_hud();
			self thread zombie_remaining_hud();

            self thread give_weapons_on_spawn();
            self thread give_perks_on_spawn();
            self thread give_perks_on_revive();

			self thread set_persistent_stats();
			self thread infinite_afterlifes();
        }

        if( !level.init )
        {
            level.init = 1;

            enable_cheats();

			level thread start_round_delay( level.start_delay );
            level thread turn_on_power();
            level thread set_starting_round();
			level thread remove_boards_from_windows();
			level thread turn_power_on_and_open_doors_custom();

			level thread mob_map_changes();
			
			flag_wait( "start_zombie_round_logic" );
   			wait 0.05;

			level thread buildbuildables();
			level thread buildcraftables();
        }
    }
}

welcome_message()
{
	self iprintln( "Welcome to Strat Tester v" + level.STRAT_TESTER_VERSION );
	self iprintln( "Made by 5and5" );
}

enable_strat_tester( onoff )
{
	create_dvar( "strat_tester", onoff );
	if( isDvarAllowed( "strat_tester" ) )
		level.strat_tester = getDvarInt( "strat_tester" );
}

enable_cheats()
{
    setDvar( "sv_cheats", 1 );
	setDvar( "cg_ufo_scaler", 0.7 );

    if( level.player_out_of_playable_area_monitor && IsDefined( level.player_out_of_playable_area_monitor ) )
	{
		self notify( "stop_player_out_of_playable_area_monitor" );
	}
	level.player_out_of_playable_area_monitor = 0;
}

set_starting_round()
{
	create_dvar( "start_round", 70 );
	if( isDvarAllowed( "start_round" ) )
		level.start_round = getDvarInt( "start_round" );

	level.first_round = false;
    level.zombie_move_speed = 130;
	level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
	level.round_number = level.start_round;
}

start_round_delay( delay )
{
	create_dvar("start_delay", delay);
	if( isDvarAllowed( "start_delay" ) )
		level.start_delay = getDvarInt( "start_delay" );
		
	flag_clear("spawn_zombies");

	flag_wait("initial_blackscreen_passed");

	level thread round_pause( level.start_delay );
}

zombie_spawn_wait(time)
{
	level endon("end_game");
	level endon( "restart_round" );

	flag_clear("spawn_zombies");

	wait time;

	flag_set("spawn_zombies");
	level notify("start_delay_over");
}

round_pause( delay )
{
	if ( !IsDefined( delay ) )
	{
		delay = 30;
	}

	level.countdown_hud = create_simple_hud();
	level.countdown_hud.alignx = "center";
	level.countdown_hud.aligny = "top";
	level.countdown_hud.horzalign = "user_center";
	level.countdown_hud.vertalign = "user_top";
	level.countdown_hud.fontscale = 32;
	level.countdown_hud setshader( "hud_chalk_1", 64, 64 );
	level.countdown_hud SetValue( delay );
	level.countdown_hud.color = ( 1, 1, 1 );
	level.countdown_hud.alpha = 0;
	level.countdown_hud FadeOverTime( 2.0 );
	level.countdown_hud.color = ( 0.21, 0, 0 );
	level.countdown_hud.alpha = 1;
	wait 2;
	level thread zombie_spawn_wait( delay );

	while (delay >= 1)
	{
		wait 1;
		delay--;
		level.countdown_hud SetValue( delay );
	}

	// Zero!  Play end sound
	players = GetPlayers();
	for (i=0; i<players.size; i++ )
	{
		players[i] playlocalsound( "zmb_perks_packa_ready" );
	}

	level.countdown_hud FadeOverTime( 1.0 );
	level.countdown_hud.color = (1,1,1);
	level.countdown_hud.alpha = 0;
	wait( 1.0 );

	level.countdown_hud destroy_hud();
}

remove_boards_from_windows()
{	
	if( !level.remove_boards )
		return;

	flag_wait( "initial_blackscreen_passed" );

	maps/mp/zombies/_zm_blockers::open_all_zbarriers();
}

turn_on_power() //by xepixtvx
{	
	if( !level.power_on )
		return;

	flag_wait( "initial_blackscreen_passed" );
	wait 5;
	trig = getEnt( "use_elec_switch", "targetname" );
	powerSwitch = getEnt( "elec_switch", "targetname" );
	powerSwitch notSolid();
	trig setHintString( &"ZOMBIE_ELECTRIC_SWITCH" );
	trig setVisibleToAll();
	trig notify( "trigger", self );
	trig setInvisibleToAll();
	powerSwitch rotateRoll( -90, 0, 3 );
	level thread maps/mp/zombies/_zm_perks::perk_unpause_all_perks();
	powerSwitch waittill( "rotatedone" );
	flag_set( "power_on" );
	level setClientField( "zombie_power_on", 1 ); 
}

turn_power_on_and_open_doors_custom() //checked changed at own discretion
{
	if( !level.open_doors )
		return;

	flag_wait( "initial_blackscreen_passed" );
	level.local_doors_stay_open = 1;
	level.power_local_doors_globally = 1;
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
	zombie_doors = getentarray( "zombie_door", "targetname" );
	foreach ( door in zombie_doors )
	{
		if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "electric_door" )
		{
			door notify( "power_on" );
		}
		else if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "local_electric_door" )
		{
			door notify( "local_power_on" );
		}
	}
}

create_dvar( dvar, set )
{
    if( getDvar( dvar ) == "" )
		setDvar( dvar, set );
}

isDvarAllowed( dvar )
{
	if( getDvar( dvar ) == "" )
		return false;
	else
		return true;
}


/*
* *****************************************************
*	
* ****************** Weapons/Perks ********************
*
* *****************************************************
*/

give_perks_on_revive()
{
	if( !level.perks_on_revive )
		return;

	level endon("end_game");
	self endon( "disconnect" );

	while( 1 )
	{
		self waittill( "player_revived", reviver );

        self give_perks_by_map();
	}
}

give_perks_on_spawn()
{
	if( !level.perks_on_spawn )
		return;

    level waittill("initial_blackscreen_passed");
    wait 0.5;
    self give_perks_by_map();
}

give_perks_by_map()
{
    switch( level.script )
    {
        case "zm_transit":
        	location = level.scr_zm_map_start_location;
            if ( location == "farm" )
            {
				perks = array( "specialty_armorvest", "specialty_fastreload", "specialty_rof", "specialty_quickrevive" );
				self give_perks( perks );
            }
            else if ( location == "town" )
            {
				if( isDefined( level.VERSION ) )
					perks = array( "specialty_armorvest", "specialty_fastreload", "specialty_rof", "specialty_quickrevive" );
				else	
					perks = array( "specialty_armorvest", "specialty_longersprint", "specialty_rof", "specialty_quickrevive" );
				self give_perks( perks );
            }
            else if ( location == "transit" && !is_classic() ) //depot
            {
  
            }
            else if ( location == "transit" )
            {
				perks = array( "specialty_armorvest", "specialty_longersprint", "specialty_fastreload", "specialty_quickrevive" );
				self give_perks( perks );
            }
            break;
        case "zm_nuked":
			perks = array( "specialty_armorvest", "specialty_fastreload", "specialty_rof", "specialty_quickrevive" );
			self give_perks( perks );
            break;
        case "zm_highrise":
			perks = array( "specialty_armorvest", "specialty_fastreload", "specialty_rof", "specialty_quickrevive" );
			self give_perks( perks );
            break;
        case "zm_prison":
            flag_wait( "afterlife_start_over" );
			perks = array( "specialty_armorvest", "specialty_fastreload", "specialty_rof", "specialty_grenadepulldeath" );
			self give_perks( perks );
            break;
        case "zm_buried":
			perks = array( "specialty_armorvest", "specialty_fastreload", "specialty_additionalprimaryweapon", "specialty_rof", "specialty_longersprint", "specialty_quickrevive" );
			self give_perks( perks );
            break;
        case "zm_tomb":
			perks = array( "specialty_armorvest", "specialty_fastreload", "specialty_additionalprimaryweapon", "specialty_flakjacket", "specialty_rof", "specialty_longersprint", "specialty_quickrevive" );
			self give_perks( perks );
            break;
    }
}

give_perks( perk_array )
{
	foreach( perk in perk_array )
	{
		self give_perk( perk, 0 );
		wait 0.15;
	}
}

give_weapons_on_spawn()
{
	if( !level.weapons_on_spawn )
		return;
	
    level waittill("initial_blackscreen_passed");

    switch( level.script )
    {
        case "zm_transit":
        	location = level.scr_zm_map_start_location;
            if ( location == "farm" )
            {
                self giveweapon_nzv( "raygun_mark2_upgraded_zm" );
                self giveweapon_nzv( "cymbal_monkey_zm" );
                self giveweapon_nzv( "qcw05_zm" );
                self switchToWeapon( "raygun_mark2_upgraded_zm" );
            }
            else if ( location == "town" )
            {
                self giveweapon_nzv( "raygun_mark2_upgraded_zm" );
				self giveWeapon_nzv( "ray_gun_upgraded_zm");
                self giveweapon_nzv( "m1911_upgraded_zm" );
                self giveweapon_nzv( "cymbal_monkey_zm" );
                self switchToWeapon( "raygun_mark2_upgraded_zm" );
            }
            else if ( location == "transit" && !is_classic() ) //depot
            {
                self giveweapon_nzv( "raygun_mark2_upgraded_zm" );
                self giveweapon_nzv( "qcw05_zm" );
                self giveweapon_nzv( "cymbal_monkey_zm" );
                self giveweapon_nzv( "tazer_knuckles_zm" );
                self switchToWeapon( "raygun_mark2_upgraded_zm" );
            }
            else if ( location == "transit" )
            {
                self giveweapon_nzv( "raygun_mark2_upgraded_zm" );
                self giveweapon_nzv( "m1911_upgraded_zm" );
                self giveweapon_nzv( "jetgun_zm" );
                self giveweapon_nzv( "cymbal_monkey_zm" );
                self giveweapon_nzv( "tazer_knuckles_zm" );
                self switchToWeapon( "raygun_mark2_upgraded_zm" );
            }
            break;
        case "zm_nuked":
            self giveweapon_nzv( "raygun_mark2_upgraded_zm" );
            self giveweapon_nzv( "m1911_upgraded_zm" );
            self giveweapon_nzv( "cymbal_monkey_zm" );
            self switchToWeapon( "raygun_mark2_upgraded_zm" );
            break;
        case "zm_highrise":
            self giveweapon_nzv( "slipgun_zm" );
            self giveweapon_nzv( "qcw05_zm" );
            self giveweapon_nzv( "cymbal_monkey_zm" );
            self switchToWeapon( "slipgun_zm" );
            break;
        case "zm_prison":
            flag_wait( "afterlife_start_over" );
			if( isDefined( level.VERSION ) )
				self giveweapon_nzv( "blundergat_upgraded_zm" );
            self giveweapon_nzv( "blundersplat_upgraded_zm" );
            self giveweapon_nzv( "raygun_mark2_upgraded_zm" );
			self giveweapon_nzv( "claymore_zm" );
            self giveweapon_nzv( "upgraded_tomahawk_zm" );
            self setclientfieldtoplayer( "upgraded_tomahawk_in_use", 1 );
            break;
        case "zm_buried":
            self giveweapon_nzv( "raygun_mark2_upgraded_zm" );
            self giveweapon_nzv( "m1911_upgraded_zm" );
            self giveweapon_nzv( "slowgun_upgraded_zm" );
            self giveweapon_nzv( "cymbal_monkey_zm" );
			self giveweapon_nzv( "claymore_zm" );
            self switchToWeapon( "slowgun_upgraded_zm" );
            break;
        case "zm_tomb":
			if( cointoss() )
            	self giveweapon_nzv( "staff_air_upgraded_zm" );
			else
				self giveweapon_nzv( "staff_water_upgraded_zm" );
            self giveweapon_nzv( "raygun_mark2_upgraded_zm" );
            self giveweapon_nzv( "cymbal_monkey_zm" );
            self giveweapon_nzv( "mp40_upgraded_zm" );
			self giveweapon_nzv( "claymore_zm" );
            self switchToWeapon( "staff_air_upgraded_zm" );
			self switchToWeapon( "staff_water_upgraded_zm" );
            break;
    }
}

give_weapons( weapon_array )
{
	foreach( weapon in weapon_array )
	{
		self giveweapon_nzv( weapon );
	}
}

giveweapon_nzv( weapon )
{
	if( issubstr( weapon, "tomahawk_zm" ) && level.script == "zm_prison" )
	{
		self play_sound_on_ent( "purchase" );
		self notify( "tomahawk_picked_up" );
		level notify( "bouncing_tomahawk_zm_aquired" );
		self notify( "player_obtained_tomahawk" );
		if( weapon == "bouncing_tomahawk_zm" )
		{
			self.tomahawk_upgrade_kills = 0;
			self.killed_with_only_tomahawk = 1;
			self.killed_something_thq = 0;
		}
		else
		{
			self.tomahawk_upgrade_kills = 99;
			self.killed_with_only_tomahawk = 1;
			self.killed_something_thq = 1;
			self notify( "tomahawk_upgraded_swap" );
		}
		old_tactical = self get_player_tactical_grenade();
		if( old_tactical != "none" && IsDefined( old_tactical ) )
		{
			self takeweapon( old_tactical );
		}
		self set_player_tactical_grenade( weapon );
		self.current_tomahawk_weapon = weapon;
		gun = self getcurrentweapon();
		self disable_player_move_states( 1 );
		self giveweapon( "zombie_tomahawk_flourish" );
		self switchtoweapon( "zombie_tomahawk_flourish" );
		self waittill_any( "player_downed", "weapon_change_complete" );
		self switchtoweapon( gun );
		self enable_player_move_states();
		self takeweapon( "zombie_tomahawk_flourish" );
		self giveweapon( weapon );
		self givemaxammo( weapon );
		if( !(is_equipment( gun ))is_equipment( gun ) && !(is_placeable_mine( gun )) )
		{
			self switchtoweapon( gun );
			self waittill( "weapon_change_complete" );
		}
		else
		{
			primaryweapons = self getweaponslistprimaries();
			if( primaryweapons.size > 0 && IsDefined( primaryweapons ) )
			{
				self switchtoweapon( primaryweapons[ 0] );
				self waittill( "weapon_change_complete" );
			}
		}
		self play_weapon_vo( weapon );
	}
	else
	{
		if( weapon == "willy_pete_zm" && level.script == "zm_prison" )
		{
			self play_sound_on_ent( "purchase" );
			gun = self getcurrentweapon();
			old_tactical = self get_player_tactical_grenade();
			if( old_tactical != "none" && IsDefined( old_tactical ) )
			{
				self takeweapon( old_tactical );
			}
			self set_player_tactical_grenade( weapon );
			self giveweapon( weapon );
			self givemaxammo( weapon );
			if( !(is_equipment( gun ))is_equipment( gun ) && !(is_placeable_mine( gun )) )
			{
				self switchtoweapon( gun );
				self waittill( "weapon_change_complete" );
			}
			else
			{
				primaryweapons = self getweaponslistprimaries();
				if( primaryweapons.size > 0 && IsDefined( primaryweapons ) )
				{
					self switchtoweapon( primaryweapons[ 0] );
					self waittill( "weapon_change_complete" );
				}
			}
			self play_weapon_vo( weapon );
		}
		else
		{
			if( weapon == "time_bomb_zm" && level.script == "zm_buried" )
			{
				self weapon_give( weapon, undefined, undefined, 0 );
			}
			else
			{
				if( issubstr( weapon, "one_inch_punch" ) && level.script == "zm_tomb" )
				{
					self play_sound_on_ent( "purchase" );
					gun = self getcurrentweapon();
					self disable_player_move_states( 1 );
					if( weapon == "one_inch_punch_zm" )
					{
						self.b_punch_upgraded = 0;
						self giveweapon( "zombie_one_inch_punch_flourish" );
						self switchtoweapon( "zombie_one_inch_punch_flourish" );
					}
					else
					{
						self.b_punch_upgraded = 1;
						if( weapon == "one_inch_punch_air_zm" )
						{
							self.str_punch_element = "air";
						}
						else
						{
							if( weapon == "one_inch_punch_fire_zm" )
							{
								self.str_punch_element = "fire";
							}
							else
							{
								if( weapon == "one_inch_punch_ice_zm" )
								{
									self.str_punch_element = "ice";
								}
								else
								{
									if( weapon == "one_inch_punch_lightning_zm" )
									{
										self.str_punch_element = "lightning";
									}
									else
									{
										if( weapon == "one_inch_punch_upgraded_zm" )
										{
											self.str_punch_element = "upgraded";
										}
									}
								}
							}
						}
						self giveweapon( "zombie_one_inch_punch_upgrade_flourish" );
						self switchtoweapon( "zombie_one_inch_punch_upgrade_flourish" );
					}
					self waittill_any( "player_downed", "weapon_change_complete" );
					self enable_player_move_states();
					if( weapon == "one_inch_punch_zm" )
					{
						self takeweapon( "zombie_one_inch_punch_flourish" );
					}
					else
					{
						self takeweapon( "zombie_one_inch_punch_upgrade_flourish" );
					}
					gun = self change_melee_weapon( weapon, gun );
					self giveweapon( weapon );
					if( !(is_equipment( gun ))is_equipment( gun ) && !(is_placeable_mine( gun )) )
					{
						self switchtoweapon( gun );
						self waittill( "weapon_change_complete" );
					}
					else
					{
						primaryweapons = self getweaponslistprimaries();
						if( primaryweapons.size > 0 && IsDefined( primaryweapons ) )
						{
							self switchtoweapon( primaryweapons[ 0] );
							self waittill( "weapon_change_complete" );
						}
					}
					self thread create_and_play_dialog( "perk", "one_inch" );
				}
				else
				{
					if( issubstr( weapon, "_melee_zm" ) && issubstr( weapon, "staff_" ) && level.script == "zm_tomb" )
					{
						self play_sound_on_ent( "purchase" );
						gun = self getcurrentweapon();
						gun = self change_melee_weapon( weapon, gun );
						self giveweapon( weapon );
						if( !(is_equipment( gun ))is_equipment( gun ) && !(is_placeable_mine( gun )) )
						{
							self switchtoweapon( gun );
							self waittill( "weapon_change_complete" );
						}
						else
						{
							primaryweapons = self getweaponslistprimaries();
							if( primaryweapons.size > 0 && IsDefined( primaryweapons ) )
							{
								self switchtoweapon( primaryweapons[ 0] );
								self waittill( "weapon_change_complete" );
							}
						}
						self play_weapon_vo( weapon );
					}
					else
					{
						if( issubstr( weapon, "staff_" ) && level.script == "zm_tomb" )
						{
							if( issubstr( weapon, "_upgraded_zm" ) )
							{
								if( !(self hasweapon( "staff_revive_zm" )) )
								{
									self setactionslot( 3, "weapon", "staff_revive_zm" );
									self giveweapon( "staff_revive_zm" );
								}
								self givemaxammo( "staff_revive_zm" );
							}
							else
							{
								if( self hasweapon( "staff_revive_zm" ) )
								{
									self takeweapon( "staff_revive_zm" );
									self setactionslot( 3, "altmode" );
								}
							}
							self weapon_give( weapon, undefined, undefined, 0 );
						}
						else
						{
							if( issubstr( weapon, "equip_dieseldrone_zm" ) && level.script == "zm_tomb" )
							{
								if( IsDefined( level.zombie_custom_equipment_setup ) )
								{
									players = getplayers();
									i = 0;
									while( i < players.size )
									{
										if( players[ i] hasweapon( weapon ) )
										{
											self stealth_iprintln( "^1ERROR: ^7Diesel Drone is already equiped by one player" );
										}
										i++;
									}
									quadrotor = getentarray( "quadrotor_ai", "targetname" );
									if( quadrotor.size >= 1 )
									{
										self stealth_iprintln( "^1ERROR: ^7Diesel Drone is already active, can't spawn another yet" );
									}
									// customequipgiver = spawn( "script_model", self normalisedtrace( "position" ) );
									// customequipgiver setmodel( "veh_t6_dlc_zm_quadrotor" );
									// customequipgiver.stub = spawnstruct();
									// customequipgiver.stub.weaponname = "equip_dieseldrone_zm";
									// customequipgiver.stub.craftablestub = spawnstruct();
									// customequipgiver.stub.craftablestub.use_actionslot = 2;
									// customequipgiver [[  ]]( self );
									// customequipgiver delete();
								}
							}
							else
							{
								if( self is_melee_weapon( weapon ) )
								{
									if( weapon == "bowie_knife_zm" || weapon == "tazer_knuckles_zm" )
									{
										// self give_melee_weapon_by_name( weapon );
                                        self give_melee_weapon_instant( weapon );
									}
									else
									{
										self play_sound_on_ent( "purchase" );
										gun = self getcurrentweapon();
										gun = self change_melee_weapon( weapon, gun );
										self giveweapon( weapon );
										if( !(is_equipment( gun ))is_equipment( gun ) && !(is_placeable_mine( gun )) )
										{
											self switchtoweapon( gun );
											self waittill( "weapon_change_complete" );
										}
										else
										{
											primaryweapons = self getweaponslistprimaries();
											if( primaryweapons.size > 0 && IsDefined( primaryweapons ) )
											{
												self switchtoweapon( primaryweapons[ 0] );
												self waittill( "weapon_change_complete" );
											}
										}
										self play_weapon_vo( weapon );
									}
								}
								else
								{
									if( self is_equipment( weapon ) )
									{
										self play_sound_on_ent( "purchase" );
										if( level.destructible_equipment.size > 0 && IsDefined( level.destructible_equipment ) )
										{
											i = 0;
											while( i < level.destructible_equipment.size )
											{
												equip = level.destructible_equipment[ i];
												if( equip.name == weapon && IsDefined( equip.name ) && equip.owner == self && IsDefined( equip.owner ) )
												{
													equip item_damage( 9999 );
													break;
												}
												else
												{
													if( equip.name == weapon && IsDefined( equip.name ) && weapon == "jetgun_zm" )
													{
														equip item_damage( 9999 );
														break;
													}
													else
													{
														i++;
													}
												}
												i++;
											}
										}
										self equipment_take( weapon );
										self equipment_buy( weapon );
										self play_weapon_vo( weapon );
									}
									else
									{
										if( self is_weapon_upgraded( weapon ) )
										{
											self weapon_give( weapon, 1, undefined, 0 );
										}
										else
										{
											self weapon_give( weapon, undefined, undefined, 0 );
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	self stealth_iprintln( "Weapon: " + ( weapon + " ^2Given" ) );

}

stealth_iprintln( message )
{
    // self iprintln( message );
}

give_melee_weapon_instant( weapon_name )
{
	self giveweapon( weapon_name );
	gun = change_melee_weapon( weapon_name, "knife_zm" );
	if ( self hasweapon( "knife_zm" ) )
	{
		self takeweapon( "knife_zm" );
	}
    gun = self getcurrentweapon();
	if ( gun != "none" && !is_placeable_mine( gun ) && !is_equipment( gun ) )
	{
		self switchtoweapon( gun );
	}
}


/*
* *****************************************************
*	
* ******************* Persistent **********************
*
* *****************************************************
*/

set_persistent_stats()
{
	if( !isVictisMap() )
		return;
	
	flag_wait("initial_blackscreen_passed");

	set_perma_perks();
	set_bank_points();
	set_fridge_weapon();
}

set_perma_perks() // Huthtv
{
	persistent_upgrades = array("pers_revivenoperk", "pers_multikill_headshots", "pers_insta_kill", "pers_jugg", "pers_perk_lose_counter", "pers_sniper_counter", "pers_box_weapon_counter");
	
	persistent_upgrade_values = [];
	persistent_upgrade_values["pers_revivenoperk"] = 17;
	persistent_upgrade_values["pers_multikill_headshots"] = 5;
	persistent_upgrade_values["pers_insta_kill"] = 2;
	persistent_upgrade_values["pers_jugg"] = 3;
	persistent_upgrade_values["pers_perk_lose_counter"] = 3;
	persistent_upgrade_values["pers_sniper_counter"] = 1;
	persistent_upgrade_values["pers_box_weapon_counter"] = 5;
	persistent_upgrade_values["pers_flopper_counter"] = 1;
	if(level.script == zm_buried)
		persistent_upgrades = combinearrays(persistent_upgrades, array("pers_flopper_counter"));

	foreach(pers_perk in persistent_upgrades)
	{
		upgrade_value = self getdstat("playerstatslist", pers_perk, "StatValue");
		if(upgrade_value != persistent_upgrade_values[pers_perk])
		{
			maps/mp/zombies/_zm_stats::set_client_stat(pers_perk, persistent_upgrade_values[pers_perk]);
		}	
	}
}

set_bank_points()
{
	if(self.account_value < 250)
	{
		self maps/mp/zombies/_zm_stats::set_map_stat("depositBox", 250, level.banking_map);
		self.account_value = 250;
	}
}

set_fridge_weapon()
{
	self clear_stored_weapondata();
	if( level.script == "zm_highrise" )
	{
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "an94_upgraded_zm+mms" );
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 600 );
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 50 );
	}
	else if ( level.script == "zm_transit" || level.script == "zm_buried" )
	{
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "m32_upgraded_zm" );
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 48 );
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 6 );
	}
}

isVictisMap()
{
	switch(level.script)
	{
		case "zm_transit":
		case "zm_highrise":
		case "zm_buried":
			return true;
		default:
			return false;
	}	
}


/*
* *****************************************************
*	
* *********************** HUD *************************
*
* *****************************************************
*/

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

	flag_wait( "initial_blackscreen_passed" );
	self.timer_hud setTimerUp(0);

	level waittill( "end_game" );

	level.total_time -= .1; // need to set it below the number or it shows the next number
	while( 1 )
	{	
		self.timer_hud setTimer(level.total_time);
		self.timer_hud.alpha = 1;
		self.round_timer_hud.alpha = 0;
		wait 0.1;
	}
}

set_hud_offset()
{
	self.timer_hud_offset = 0;
	self.zone_hud_offset = 15;
}

timer_hud_watcher()
{
	self endon("disconnect");
	level endon( "end_game" );

	while(1)
	{	
		while( !level.hud_timer )
		{
			wait 0.1;
		}
		self.timer_hud.y = (2 + self.timer_hud_offset);
		self.timer_hud.alpha = 1;

		while( level.hud_timer )
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
	self.round_timer_hud.y += (2 + (15 * level.hud_timer ) + self.timer_hud_offset );
	self.round_timer_hud.fontscale = 1.4;
	self.round_timer_hud.alpha = 0;
	self.round_timer_hud.color = ( 1, 1, 1 );
	self.round_timer_hud.hidewheninmenu = 1;

	flag_wait( "initial_blackscreen_passed" );

	self thread round_timer_hud_watcher();

	level.FADE_TIME = 0.2;
	level waittill("start_delay_over");
	while( 1 )
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

		if( level.hud_round_timer )
		{
			self.round_timer_hud FadeOverTime(level.FADE_TIME);
			self.round_timer_hud.alpha = 1;
		}
	}
}

round_timer_hud_watcher()
{	
	self endon("disconnect");
	level endon( "end_game" );

	while( 1 )
	{
		while( !level.hud_round_timer )
		{
			wait 0.1;
		}
		self.round_timer_hud.y = (2 + (15 * level.hud_timer ) + self.timer_hud_offset );
		self.round_timer_hud.alpha = 1;

		while( level.hud_round_timer )
		{
			wait 0.1;
		}
		self.round_timer_hud.alpha = 0;

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

	while(1)
	{
		while( !level.hud_zombie_counter )
		{
			wait 0.1;
		}
		self.zombie_counter_hud.alpha = 1;

		while( level.hud_zombie_counter )
		{
			wait 0.1;
		}
		self.zombie_counter_hud.alpha = 0;
	}
}

trap_timer_hud()
{
	if( level.script != "zm_prison" || !level.hud_trap_timer )
		return;

	self endon( "disconnect" );

	self.trap_timer_hud = newclienthudelem( self );
	self.trap_timer_hud.alignx = "left";
	self.trap_timer_hud.aligny = "top";
	self.trap_timer_hud.horzalign = "user_left";
	self.trap_timer_hud.vertalign = "user_top";
	self.trap_timer_hud.x += 4;
	self.trap_timer_hud.y += (2 + (15 * (level.hud_timer + level.hud_round_timer) ) + self.timer_hud_offset );
	self.trap_timer_hud.fontscale = 1.4;
	self.trap_timer_hud.alpha = 0;
	self.trap_timer_hud.color = ( 1, 1, 1 );
	self.trap_timer_hud.hidewheninmenu = 1;
	self.trap_timer_hud.hidden = 0;
	self.trap_timer_hud.label = &"";

	while( 1 )
	{
		level waittill( "trap_activated" );
		if( !level.trap_activated )
		{
			wait 0.5;
			self.trap_timer_hud.alpha = 1;
			self.trap_timer_hud settimer( 50 );
			wait 50;
			self.trap_timer_hud.alpha = 0;
		}
	}
}

zone_hud()
{
	if( !level.hud_zone_names )
		return;

	self endon("disconnect");

	x = 8;
	y = -111;
	if (level.script == "zm_buried")
	{
		y -= 25;
	}
	else if (level.script == "zm_tomb")
	{
		y -= 30;
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
		while( !level.hud_zone_names )
		{
			wait 0.1;
		}

		while( level.hud_zone_names )
		{
			self.zone_hud.y = (y + (self.zone_hud_offset * !level.hud_health_bar ) );

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


/*
* *****************************************************
*	
* ******************** Buildables *********************
*
* *****************************************************
*/

tomb_give_shovel()
{
	if( level.script != "zm_tomb" )
		return;

	self.dig_vars[ "has_shovel" ] = 1;
	n_player = self getentitynumber() + 1;
	level setclientfield( "shovel_player" + n_player, 1 );
}

buildbuildables()
{
	// need a wait or else some buildables dont build
	wait 1;

	if(is_classic())
	{
		if(level.scr_zm_map_start_location == "transit")
		{
			buildbuildable( "turbine" );
			buildbuildable( "electric_trap" );
			buildbuildable( "turret" );
			buildbuildable( "riotshield_zm" );
			buildbuildable( "jetgun_zm" );
			buildbuildable( "powerswitch", 1 );
			buildbuildable( "pap", 1 );
			buildbuildable( "sq_common", 1 );
			buildbuildable( "dinerhatch", 1 );
			buildbuildable( "bushatch", 1 );
			buildbuildable( "busladder", 1 );
			// buildbuildable( "cattlecatcher", 1 );
			removebuildable( "dinerhatch" );
			removebuildable( "bushatch" );
			removebuildable( "busladder" );
			// removebuildable( "cattlecatcher" );

			getent( "powerswitch_p6_zm_buildable_pswitch_hand", "targetname" ) show();
			getent( "powerswitch_p6_zm_buildable_pswitch_body", "targetname" ) show();
			getent( "powerswitch_p6_zm_buildable_pswitch_lever", "targetname" ) show();
		}
		else if(level.scr_zm_map_start_location == "rooftop")
		{
			buildbuildable( "slipgun_zm" );
			buildbuildable( "springpad_zm" );
			buildbuildable( "sq_common", 1 );
			// removebuildable( "keys_zm" );
		}
		else if(level.scr_zm_map_start_location == "processing")
		{
			level waittill( "buildables_setup" ); // wait for buildables to randomize
			wait 0.05;

			level.buildables_available = array("subwoofer_zm", "springpad_zm", "headchopper_zm", "turbine");

			//removebuildable( "keys_zm" );
			buildbuildable( "turbine" );
			buildbuildable( "subwoofer_zm" );
			buildbuildable( "springpad_zm" );
			buildbuildable( "headchopper_zm" );
			buildbuildable( "sq_common", 1 );
		}
	}
}

buildbuildable( buildable, craft )
{
	if (!isDefined(craft))
	{
		craft = 0;
	}

	player = get_players()[ 0 ];
	foreach (stub in level.buildable_stubs)
	{
		if ( !isDefined( buildable ) || stub.equipname == buildable )
		{
			if ( isDefined( buildable ) || stub.persistent != 3 )
			{
				if (craft)
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_finish_build( player );
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					stub.model notsolid();
					stub.model show();
				}
				else
				{
					equipname = stub get_equipname();
					level.zombie_buildables[stub.equipname].hint = "Hold ^3[{+activate}]^7 to craft " + equipname;
					stub.prompt_and_visibility_func = ::buildabletrigger_update_prompt;
				}

				i = 0;
				foreach (piece in stub.buildablezone.pieces)
				{
					piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					if (!craft && i > 0)
					{
						stub.buildablezone maps/mp/zombies/_zm_buildables::buildable_set_piece_built(piece);
					}
					i++;
				}

				return;
			}
		}
	}
}

get_equipname()
{
	if (self.equipname == "turbine")
	{
		return "Turbine";
	}
	else if (self.equipname == "turret")
	{
		return "Turret";
	}
	else if (self.equipname == "electric_trap")
	{
		return "Electric Trap";
	}
	else if (self.equipname == "riotshield_zm")
	{
		return "Zombie Shield";
	}
	else if (self.equipname == "jetgun_zm")
	{
		return "Jet Gun";
	}
	else if (self.equipname == "slipgun_zm")
	{
		return "Sliquifier";
	}
	else if (self.equipname == "subwoofer_zm")
	{
		return "Subsurface Resonator";
	}
	else if (self.equipname == "springpad_zm")
	{
		return "Trample Steam";
	}
	else if (self.equipname == "headchopper_zm")
	{
		return "Head Chopper";
	}
}
buildabletrigger_update_prompt( player )
{
	can_use = 0;
	if (isDefined(level.buildablepools))
	{
		can_use = self.stub pooledbuildablestub_update_prompt( player, self );
	}
	else
	{
		can_use = self.stub buildablestub_update_prompt( player, self );
	}
	
	self sethintstring( self.stub.hint_string );
	if ( isDefined( self.stub.cursor_hint ) )
	{
		if ( self.stub.cursor_hint == "HINT_WEAPON" && isDefined( self.stub.cursor_hint_weapon ) )
		{
			self setcursorhint( self.stub.cursor_hint, self.stub.cursor_hint_weapon );
		}
		else
		{
			self setcursorhint( self.stub.cursor_hint );
		}
	}
	return can_use;
}

buildablestub_update_prompt( player, trigger )
{
	if ( !self maps/mp/zombies/_zm_buildables::anystub_update_prompt( player ) )
	{
		return 0;
	}

	if ( isDefined( self.buildablestub_reject_func ) )
	{
		rval = self [[ self.buildablestub_reject_func ]]( player );
		if ( rval )
		{
			return 0;
		}
	}

	if ( isDefined( self.custom_buildablestub_update_prompt ) && !( self [[ self.custom_buildablestub_update_prompt ]]( player ) ) )
	{
		return 0;
	}

	self.cursor_hint = "HINT_NOICON";
	self.cursor_hint_weapon = undefined;
	if ( isDefined( self.built ) && !self.built )
	{
		slot = self.buildablestruct.buildable_slot;
		piece = self.buildablezone.pieces[0];
		player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

		if ( !isDefined( player maps/mp/zombies/_zm_buildables::player_get_buildable_piece( slot ) ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_more ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_more;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
			}
			return 0;
		}
		else
		{
			if ( !self.buildablezone maps/mp/zombies/_zm_buildables::buildable_has_piece( player maps/mp/zombies/_zm_buildables::player_get_buildable_piece( slot ) ) )
			{
				if ( isDefined( level.zombie_buildables[ self.equipname ].hint_wrong ) )
				{
					self.hint_string = level.zombie_buildables[ self.equipname ].hint_wrong;
				}
				else
				{
					self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
				}
				return 0;
			}
			else
			{
				if ( isDefined( level.zombie_buildables[ self.equipname ].hint ) )
				{
					self.hint_string = level.zombie_buildables[ self.equipname ].hint;
				}
				else
				{
					self.hint_string = "Missing buildable hint";
				}
			}
		}
	}
	else
	{
		if ( self.persistent == 1 )
		{
			if ( maps/mp/zombies/_zm_equipment::is_limited_equipment( self.weaponname ) && maps/mp/zombies/_zm_equipment::limited_equipment_in_use( self.weaponname ) )
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_ONLY_ONE";
				return 0;
			}

			if ( player has_player_equipment( self.weaponname ) )
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_HAVE_ONE";
				return 0;
			}

			self.hint_string = self.trigger_hintstring;
		}
		else if ( self.persistent == 2 )
		{
			if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.weaponname, undefined ) )
			{
				self.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
				return 0;
			}
			else
			{
				if ( isDefined( self.bought ) && self.bought )
				{
					self.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
					return 0;
				}
			}
			self.hint_string = self.trigger_hintstring;
		}
		else
		{
			self.hint_string = "";
			return 0;
		}
	}
	return 1;
}

pooledbuildablestub_update_prompt( player, trigger )
{
	if ( !self maps/mp/zombies/_zm_buildables::anystub_update_prompt( player ) )
	{
		return 0;
	}

	if ( isDefined( self.custom_buildablestub_update_prompt ) && !( self [[ self.custom_buildablestub_update_prompt ]]( player ) ) )
	{
		return 0;
	}

	self.cursor_hint = "HINT_NOICON";
	self.cursor_hint_weapon = undefined;
	if ( isDefined( self.built ) && !self.built )
	{
		trigger thread buildablestub_build_succeed();

		if (level.buildables_available.size > 1)
		{
			self thread choose_open_buildable(player);
		}

		slot = self.buildablestruct.buildable_slot;

		if (self.buildables_available_index >= level.buildables_available.size)
		{
			self.buildables_available_index = 0;
		}

		foreach (stub in level.buildable_stubs)
		{
			if (stub.buildablezone.buildable_name == level.buildables_available[self.buildables_available_index])
			{
				piece = stub.buildablezone.pieces[0];
				break;
			}
		}

		player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

		piece = player maps/mp/zombies/_zm_buildables::player_get_buildable_piece(slot);

		if ( !isDefined( piece ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_more ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_more;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
			}

			if ( isDefined( level.custom_buildable_need_part_vo ) )
			{
				player thread [[ level.custom_buildable_need_part_vo ]]();
			}
			return 0;
		}
		else
		{
			if ( isDefined( self.bound_to_buildable ) && !self.bound_to_buildable.buildablezone maps/mp/zombies/_zm_buildables::buildable_has_piece( piece ) )
			{
				if ( isDefined( level.zombie_buildables[ self.bound_to_buildable.equipname ].hint_wrong ) )
				{
					self.hint_string = level.zombie_buildables[ self.bound_to_buildable.equipname ].hint_wrong;
				}
				else
				{
					self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
				}

				if ( isDefined( level.custom_buildable_wrong_part_vo ) )
				{
					player thread [[ level.custom_buildable_wrong_part_vo ]]();
				}
				return 0;
			}
			else
			{
				if ( !isDefined( self.bound_to_buildable ) && !self.buildable_pool pooledbuildable_has_piece( piece ) )
				{
					if ( isDefined( level.zombie_buildables[ self.equipname ].hint_wrong ) )
					{
						self.hint_string = level.zombie_buildables[ self.equipname ].hint_wrong;
					}
					else
					{
						self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
					}
					return 0;
				}
				else
				{
					if ( isDefined( self.bound_to_buildable ) )
					{
						if ( isDefined( level.zombie_buildables[ piece.buildablename ].hint ) )
						{
							self.hint_string = level.zombie_buildables[ piece.buildablename ].hint;
						}
						else
						{
							self.hint_string = "Missing buildable hint";
						}
					}
					
					if ( isDefined( level.zombie_buildables[ piece.buildablename ].hint ) )
					{
						self.hint_string = level.zombie_buildables[ piece.buildablename ].hint;
					}
					else
					{
						self.hint_string = "Missing buildable hint";
					}
				}
			}
		}
	}
	else
	{
		return trigger [[ self.original_prompt_and_visibility_func ]]( player );
	}
	return 1;
}

pooledbuildable_has_piece( piece )
{
	return isDefined( self pooledbuildable_stub_for_piece( piece ) );
}

pooledbuildable_stub_for_piece( piece )
{
	foreach (stub in self.stubs)
	{
		if ( !isDefined( stub.bound_to_buildable ) )
		{
			if ( stub.buildablezone maps/mp/zombies/_zm_buildables::buildable_has_piece( piece ) )
			{
				return stub;
			}
		}
	}

	return undefined;
}

choose_open_buildable( player )
{
	self endon( "kill_choose_open_buildable" );

	n_playernum = player getentitynumber();
	b_got_input = 1;
	hinttexthudelem = newclienthudelem( player );
	hinttexthudelem.alignx = "center";
	hinttexthudelem.aligny = "middle";
	hinttexthudelem.horzalign = "center";
	hinttexthudelem.vertalign = "bottom";
	hinttexthudelem.y = -100;
	hinttexthudelem.foreground = 1;
	hinttexthudelem.font = "default";
	hinttexthudelem.fontscale = 1;
	hinttexthudelem.alpha = 1;
	hinttexthudelem.color = ( 1, 1, 1 );
	hinttexthudelem settext( "Press [{+actionslot 1}] or [{+actionslot 2}] to change item" );

	if (!isDefined(self.buildables_available_index))
	{
		self.buildables_available_index = 0;
	}

	while ( isDefined( self.playertrigger[ n_playernum ] ) && !self.built )
	{
		if (!player isTouching(self.playertrigger[n_playernum]))
		{
			hinttexthudelem.alpha = 0;
			wait 0.05;
			continue;
		}

		hinttexthudelem.alpha = 1;

		if ( player actionslotonebuttonpressed() )
		{
			self.buildables_available_index++;
			b_got_input = 1;
		}
		else
		{
			if ( player actionslottwobuttonpressed() )
			{
				self.buildables_available_index--;

				b_got_input = 1;
			}
		}

		if ( self.buildables_available_index >= level.buildables_available.size )
		{
			self.buildables_available_index = 0;
		}
		else
		{
			if ( self.buildables_available_index < 0 )
			{
				self.buildables_available_index = level.buildables_available.size - 1;
			}
		}

		if ( b_got_input )
		{
			piece = undefined;
			foreach (stub in level.buildable_stubs)
			{
				if (stub.buildablezone.buildable_name == level.buildables_available[self.buildables_available_index])
				{
					piece = stub.buildablezone.pieces[0];
					break;
				}
			}
			slot = self.buildablestruct.buildable_slot;
			player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

			self.equipname = level.buildables_available[self.buildables_available_index];
			self.hint_string = level.zombie_buildables[self.equipname].hint;
			self.playertrigger[n_playernum] sethintstring(self.hint_string);
			b_got_input = 0;
		}

		if ( player is_player_looking_at( self.playertrigger[n_playernum].origin, 0.76 ) )
		{
			hinttexthudelem.alpha = 1;
		}
		else
		{
			hinttexthudelem.alpha = 0;
		}

		wait 0.05;
	}

	hinttexthudelem destroy();
}

buildablestub_build_succeed()
{
	self notify("buildablestub_build_succeed");
	self endon("buildablestub_build_succeed");

	self waittill( "build_succeed" );

	self.stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
	arrayremovevalue(level.buildables_available, self.stub.buildablezone.buildable_name);
	if (level.buildables_available.size == 0)
	{
		foreach (stub in level.buildable_stubs)
		{
			switch(stub.equipname)
			{
				case "turbine":
				case "subwoofer_zm":
				case "springpad_zm":
				case "headchopper_zm":
					maps/mp/zombies/_zm_unitrigger::unregister_unitrigger(stub);
					break;
			}
		}
	}
}

removebuildable( buildable, after_built )
{
	if (!isDefined(after_built))
	{
		after_built = 0;
	}

	if (after_built)
	{
		foreach (stub in level._unitriggers.trigger_stubs)
		{
			if(IsDefined(stub.equipname) && stub.equipname == buildable)
			{
				stub.model hide();
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
				return;
			}
		}
	}
	else
	{
		foreach (stub in level.buildable_stubs)
		{
			if ( !isDefined( buildable ) || stub.equipname == buildable )
			{
				if ( isDefined( buildable ) || stub.persistent != 3 )
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					foreach (piece in stub.buildablezone.pieces)
					{
						piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					}
					maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
					return;
				}
			}
		}
	}
}

buildable_piece_remove_on_last_stand()
{
	self endon( "disconnect" );

	self thread buildable_get_last_piece();

	while (1)
	{
		self waittill("entering_last_stand");

		if (isDefined(self.last_piece))
		{
			self.last_piece maps/mp/zombies/_zm_buildables::piece_unspawn();
		}
	}
}

buildable_get_last_piece()
{
	self endon( "disconnect" );

	while (1)
	{
		if (!self maps/mp/zombies/_zm_laststand::player_is_in_laststand())
		{
			self.last_piece = maps/mp/zombies/_zm_buildables::player_get_buildable_piece(0);
		}

		wait 0.05;
	}
}


/*
* *****************************************************
*	
* ********** MOTD/Origins style buildables ************
*
* *****************************************************
*/

buildcraftables()
{
	// need a wait or else some buildables dont build
	wait 1;

	if(is_classic())
	{
		if(level.scr_zm_map_start_location == "prison")
		{
			buildcraftable( "alcatraz_shield_zm" );
			buildcraftable( "packasplat" );
			if(level.is_forever_solo_game)
				buildcraftable( "plane" );
			changecraftableoption( 0 );
		}
		else if(level.scr_zm_map_start_location == "tomb")
		{
			buildcraftable( "tomb_shield_zm" );
			buildcraftable( "equip_dieseldrone_zm" );
			takecraftableparts( "gramophone" );
			//buildcraftable( "elemental_staff_water" );
		}
	}
}

changecraftableoption( index )
{
	foreach (craftable in level.a_uts_craftables)
	{
		if (craftable.equipname == "open_table")
		{
			craftable thread setcraftableoption( index );
		}
	}
}

setcraftableoption( index )
{
	self endon("death");

	while (self.a_uts_open_craftables_available.size <= 0)
	{
		wait 0.05;
	}

	if (self.a_uts_open_craftables_available.size > 1)
	{
		self.n_open_craftable_choice = index;
		self.equipname = self.a_uts_open_craftables_available[self.n_open_craftable_choice].equipname;
		self.hint_string = self.a_uts_open_craftables_available[self.n_open_craftable_choice].hint_string;
		foreach (trig in self.playertrigger)
		{
			trig sethintstring( self.hint_string );
		}
	}
}

takecraftableparts( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.zombie_include_craftables)
	{
		if ( stub.name == buildable )
		{
			foreach (piece in stub.a_piecestubs)
			{
				piecespawn = piece.piecespawn;
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece_gramophone( piecespawn );
				}
			}

			return;
		}
	}
}

buildcraftable( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.a_uts_craftables)
	{
		if ( stub.craftablestub.name == buildable )
		{
			foreach (piece in stub.craftablespawn.a_piecespawns)
			{
				piecespawn = get_craftable_piece( stub.craftablestub.name, piece.piecename );
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}

			return;
		}
	}
}

get_craftable_piece( str_craftable, str_piece )
{
	foreach (uts_craftable in level.a_uts_craftables)
	{
		if ( uts_craftable.craftablestub.name == str_craftable )
		{
			foreach (piecespawn in uts_craftable.craftablespawn.a_piecespawns)
			{
				if ( piecespawn.piecename == str_piece )
				{
					return piecespawn;
				}
			}
		}
	}
	return undefined;
}

player_take_piece_gramophone( piecespawn )
{
	piecestub = piecespawn.piecestub;
	damage = piecespawn.damage;

	if ( isDefined( piecestub.onpickup ) )
	{
		piecespawn [[ piecestub.onpickup ]]( self );
	}

	// if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	// {
	// 	if ( isDefined( piecestub.client_field_id ) )
	// 	{
	// 		level setclientfield( piecestub.client_field_id, 1 );
	// 	}
	// }
	// else
	// {
	// 	if ( isDefined( piecestub.client_field_state ) )
	// 	{
	// 		self setclientfieldtoplayer( "craftable", piecestub.client_field_state );
	// 	}
	// }

	piecespawn piece_unspawn();
	piecespawn notify( "pickup" );

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		piecespawn.in_shared_inventory = 1;
	}

	self adddstat( "buildables", piecespawn.craftablename, "pieces_pickedup", 1 );
}

player_take_piece( piecespawn )
{
	piecestub = piecespawn.piecestub;
	damage = piecespawn.damage;

	if ( isDefined( piecestub.onpickup ) )
	{
		piecespawn [[ piecestub.onpickup ]]( self );
	}

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		if ( isDefined( piecestub.client_field_id ) )
		{
			level setclientfield( piecestub.client_field_id, 1 );
		}
	}
	else
	{
		if ( isDefined( piecestub.client_field_state ) )
		{
			self setclientfieldtoplayer( "craftable", piecestub.client_field_state );
		}
	}

	piecespawn piece_unspawn();
	piecespawn notify( "pickup" );

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		piecespawn.in_shared_inventory = 1;
	}

	self adddstat( "buildables", piecespawn.craftablename, "pieces_pickedup", 1 );
}

piece_unspawn()
{
	if ( isDefined( self.model ) )
	{
		self.model delete();
	}
	self.model = undefined;
	if ( isDefined( self.unitrigger ) )
	{
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger );
	}
	self.unitrigger = undefined;
}

remove_buildable_pieces( buildable_name )
{
	foreach (buildable in level.zombie_include_buildables)
	{
		if(IsDefined(buildable.name) && buildable.name == buildable_name)
		{
			pieces = buildable.buildablepieces;
			for(i = 0; i < pieces.size; i++)
			{
				pieces[i] maps/mp/zombies/_zm_buildables::piece_unspawn();
			}
			return;
		}
	}
}

enemies_ignore_equipments()
{
	equipment = getFirstArrayKey(level.zombie_include_equipment);
	while (isDefined(equipment))
	{
		maps/mp/zombies/_zm_equipment::enemies_ignore_equipment(equipment);
		equipment = getNextArrayKey(level.zombie_include_equipment, equipment);
	}
}


/*
* *****************************************************
*	
* ********************** MOTD *************************
*
* *****************************************************
*/

mob_map_changes()
{
	if( level.script != "zm_prison" )
		return;
	
	open_warden_fence();
	turn_on_perks();
}

infinite_afterlifes()
{
	if( level.script != "zm_prison" )
		return;

	self endon( "disconnect" );

	while( 1 )
	{
		self waittill( "player_revived", reviver );
		wait 2;
		self.lives++;
	}
}
open_warden_fence()
{
	m_lock = getent( "masterkey_lock_2", "targetname" );
	m_lock delete();
	t_warden_fence_damage = getent( "warden_fence_damage", "targetname" );
	t_warden_fence_damage delete();
	admin_powerhouse_puzzle_door_clip = getent( "admin_powerhouse_puzzle_door_clip", "targetname" );
	admin_powerhouse_puzzle_door_clip delete();
	admin_powerhouse_puzzle_door = getent( "admin_powerhouse_puzzle_door", "targetname" );
	admin_powerhouse_puzzle_door rotateyaw( 90, 0.5 );
	exploder( 2000 );
	flag_set( "generator_challenge_completed" );
	wait 0.1;
	level clientnotify( "sndWard" );
	level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "piece_mid" );
	t_warden_fence_damage = getent( "warden_fence_damage", "targetname" );
	t_warden_fence_damage delete();
	level setclientfield( "warden_fence_down", 1 );
	array_delete( getentarray( "generator_wires", "script_noteworthy" ) );
	wait 3;
	stop_exploder( 2000 );
	wait 1;
}

turn_on_perks()
{
	// flag_wait( "initial_blackscreen_passed" );
	// maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	// flag_wait( "start_zombie_round_logic" );
	// level thread maps/mp/zm_alcatraz_traps::init_fan_trap_trigs();
	// level thread maps/mp/zm_alcatraz_traps::init_acid_trap_trigs();
	wait 1;
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "electric_cherry_on" );
	wait_network_frame();
	level notify( "deadshot_on" );
	wait_network_frame();
	level notify( "divetonuke_on" );
	wait_network_frame();
	level notify( "additionalprimaryweapon_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
}