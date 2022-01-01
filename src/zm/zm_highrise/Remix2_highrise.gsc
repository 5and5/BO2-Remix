#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_ai_leaper;
#include maps/mp/zombies/_zm_pers_upgrades_system;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_pers_upgrades;

#include scripts/zm/remix/_debug;
#include scripts/zm/zm_highrise/remix/_highrise_elevators;
#include scripts/zm/zm_highrise/remix/_highrise_slipgun;
#include scripts/zm/zm_highrise/remix/_highrise_zones;
#include scripts/zm/zm_highrise/remix/_highrise_divetonuke;
#include scripts/zm/zm_highrise/remix/_highrise_weapons;


main()
{
    replaceFunc( maps/mp/zombies/_zm_ai_leaper::leaper_round_tracker, ::leaper_round_tracker_override );
	replaceFunc( maps/mp/zm_highrise_elevators::elevator_depart_early, ::elevator_depart_early );
	// replaceFunc( maps/mp/zombies/_zm_ai_faller::do_zombie_emerge, ::do_zombie_emerge_override );
	// replaceFunc( maps/mp/zombies/_zm_weap_slipgun::explode_to_near_zombies, ::explode_to_near_zombies_override );
	// replaceFunc( maps/mp/zm_highrise_elevators::elev_remove_corpses, ::elev_remove_corpses_override );
	// replaceFunc( maps/mp/zm_highrise_elevators::elevator_initial_wait, ::elevator_initial_wait );
	// replaceFunc( maps/mp/zm_highrise_buildables::elevator_key_prompt, ::elevator_key_prompt );
	// replaceFunc( maps/mp/zm_highrise_buildables::include_buildables, ::include_buildables_override );
    // replaceFunc( maps/mp/zm_highrise_elevators::init_elevator_perks, ::init_elevator_perks_override );

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

        self thread give_elevator_key();
		self.pers_custom_flopper = 1;

        if(self.initial_spawn_highrise)
		{
            self.initial_spawn_highrise = true;

        }

        if(level.initial_spawn_highrise)
        {
            level.initial_spawn_highrise = false;

			slipgun_disable_reslip();
			slipgun_always_kill();
			slipgun_kills_while_away();

			die_rise_zone_changes();
			spawn_semtex_wallbuy();

			init_divetonuke();
			player_damage_changes();
			
			level thread patch_shaft();

			elevator_key_on_use_override();
			
			// teleport_players((3715.49, 1712.41, 2226.97));
            // thread debug_print();
            // thread fix_slide_death_gltich();
        }
    }
}

debug_print()
{
    flag_wait( "start_zombie_round_logic" );

	for ( i = 0; i < level.random_perk_structs.size; i++ )
	{
		if ( isDefined( level.random_perk_structs[ i ] ) )
		{
            iprintln(i + " " + level.random_perk_structs[i].model);
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

init_elevator_perks_override()
{
    if( getDvar("die_rise_whoswho") == "")
    {
        setDvar("die_rise_whoswho", 0);
    }

	level.elevator_perks = [];
	level.elevator_perks_building = [];
	level.elevator_perks_building[ "green" ] = [];
	level.elevator_perks_building[ "blue" ] = [];
	level.elevator_perks_building[ "green" ][ 0 ] = spawnstruct();
	level.elevator_perks_building[ "green" ][ 0 ].model = "zombie_vending_revive";
	level.elevator_perks_building[ "green" ][ 0 ].script_noteworthy = "specialty_quickrevive";
	level.elevator_perks_building[ "green" ][ 0 ].turn_on_notify = "revive_on";
	a = 1;
	b = 2;
	if ( getDvar("die_rise_whoswho") == 1)
	{
		a = 2;
		b = 1;
	}
	level.elevator_perks_building[ "green" ][ a ] = spawnstruct();
	level.elevator_perks_building[ "green" ][ a ].model = "p6_zm_vending_chugabud";
	level.elevator_perks_building[ "green" ][ a ].script_noteworthy = "specialty_finalstand";
	level.elevator_perks_building[ "green" ][ a ].turn_on_notify = "chugabud_on";
	level.elevator_perks_building[ "green" ][ b ] = spawnstruct();
	level.elevator_perks_building[ "green" ][ b ].model = "zombie_vending_sleight";
	level.elevator_perks_building[ "green" ][ b ].script_noteworthy = "specialty_fastreload";
	level.elevator_perks_building[ "green" ][ b ].turn_on_notify = "sleight_on";
	level.elevator_perks_building[ "blue" ][ 0 ] = spawnstruct();
	level.elevator_perks_building[ "blue" ][ 0 ].model = "zombie_vending_jugg";
	level.elevator_perks_building[ "blue" ][ 0 ].script_noteworthy = "specialty_armorvest";
	level.elevator_perks_building[ "blue" ][ 0 ].turn_on_notify = "juggernog_on";
	level.elevator_perks_building[ "blue" ][ 1 ] = spawnstruct();
	level.elevator_perks_building[ "blue" ][ 1 ].model = "zombie_vending_three_gun";
	level.elevator_perks_building[ "blue" ][ 1 ].script_noteworthy = "specialty_additionalprimaryweapon";
	level.elevator_perks_building[ "blue" ][ 1 ].turn_on_notify = "specialty_additionalprimaryweapon_power_on";
	level.elevator_perks_building[ "blue" ][ 2 ] = spawnstruct();
	level.elevator_perks_building[ "blue" ][ 2 ].model = "p6_anim_zm_buildable_pap";
	level.elevator_perks_building[ "blue" ][ 2 ].script_noteworthy = "specialty_weapupgrade";
	level.elevator_perks_building[ "blue" ][ 2 ].turn_on_notify = "Pack_A_Punch_on";	players_expected = getnumexpectedplayers();
	level.elevator_perks_building[ "blue" ][ 3 ] = spawnstruct();
	level.elevator_perks_building[ "blue" ][ 3 ].model = "zombie_vending_doubletap2";
	level.elevator_perks_building[ "blue" ][ 3 ].script_noteworthy = "specialty_rof";
	level.elevator_perks_building[ "blue" ][ 3 ].turn_on_notify = "doubletap_on";
	level.override_perk_targetname = "zm_perk_machine_override";
	// level.elevator_perks_building[ "blue" ] = array_randomize( level.elevator_perks_building[ "blue" ] );
	level.elevator_perks = arraycombine( level.elevator_perks_building[ "green" ], level.elevator_perks_building[ "blue" ], 0, 0 );
	random_perk_structs = [];
	revive_perk_struct = getstruct( "force_quick_revive", "targetname" );
	revive_perk_struct = getstruct( revive_perk_struct.target, "targetname" );
	perk_structs = getstructarray( "zm_random_machine", "script_noteworthy" );
	i = 0;
	while ( i < perk_structs.size )
	{
		random_perk_structs[ i ] = getstruct( perk_structs[ i ].target, "targetname" );
		random_perk_structs[ i ].script_parameters = perk_structs[ i ].script_parameters;
		random_perk_structs[ i ].script_linkent = getent( "elevator_" + perk_structs[ i ].script_parameters + "_body", "targetname" );
		i++;
	}
	green_structs = [];
	blue_structs = [];
	_a1075 = random_perk_structs;
	_k1075 = getFirstArrayKey( _a1075 );
	while ( isDefined( _k1075 ) )
	{
		perk_struct = _a1075[ _k1075 ];
		if ( isDefined( perk_struct.script_parameters ) )
		{
			if ( issubstr( perk_struct.script_parameters, "bldg1" ) )
			{
				green_structs[ green_structs.size ] = perk_struct;
				break;
			}
			else
			{
				blue_structs[ blue_structs.size ] = perk_struct;
			}
		}
		_k1075 = getNextArrayKey( _a1075, _k1075 );
	}
	green_structs = array_exclude( green_structs, revive_perk_struct );
	green_structs = array_randomize( green_structs );
	blue_structs = array_randomize( blue_structs );

    // set_blue_structs = [];
	// perks = [];
	// perks[0] = "zombie_vending_doubletap2";
	// perks[1] = "p6_anim_zm_buildable_pap";
	// perks[2] = "zombie_vending_three_gun";
	// perks[3] = "zombie_vending_jugg";

	// for ( j = 0; j < perks.size; j++ )
    // {
	// 	for ( i = 0; i < blue_structs.size; i++ )
	// 	{
	// 		if ( issubstr( blue_structs[i].model, perks[i] ) )
	// 		{
	// 			set_blue_structs[j] = blue_structs[i];
	// 			break;
	// 		}
	// 	}
	// }

	level.random_perk_structs = array( revive_perk_struct );
	level.random_perk_structs = arraycombine( level.random_perk_structs, green_structs, 0, 0 );
	level.random_perk_structs = arraycombine( level.random_perk_structs, blue_structs, 0, 0 );
	i = 0;
	while ( i < level.elevator_perks.size )
	{
		if ( !isDefined( level.random_perk_structs[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			level.random_perk_structs[ i ].targetname = "zm_perk_machine_override";
			level.random_perk_structs[ i ].model = level.elevator_perks[ i ].model;
			level.random_perk_structs[ i ].script_noteworthy = level.elevator_perks[ i ].script_noteworthy;
			level.random_perk_structs[ i ].turn_on_notify = level.elevator_perks[ i ].turn_on_notify;
			if ( !isDefined( level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] ) )
			{
				level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] = [];
			}
			level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ][ level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ].size ] = level.random_perk_structs[ i ];
		}
		i++;
	}
}
