#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_pers_upgrades_system;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_equipment;

#include scripts/zm/remix/_players;
#include scripts/zm/remix/_visual;
#include scripts/zm/remix/_hud;
#include scripts/zm/remix/_weapons;
#include scripts/zm/remix/_powerups;
#include scripts/zm/remix/_perks;
#include scripts/zm/remix/_persistent;
#include scripts/zm/remix/_buildables;
#include scripts/zm/remix/_equipment;
#include scripts/zm/remix/_magicbox;
#include scripts/zm/remix/_sharedbox;
#include scripts/zm/remix/_reset;
#include scripts/zm/remix/_utility;
#include scripts/zm/remix/_zombies;
#include scripts/zm/remix/_debug;


main()
{ 
	level.VERSION = "1.0.1";

	replaceFunc( maps/mp/zombies/_zm_powerups::powerup_drop, ::powerup_drop_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::insta_kill_powerup, ::insta_kill_powerup_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::insta_kill_on_hud, ::insta_kill_on_hud_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::double_points_powerup, ::double_points_powerup_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::point_doubler_on_hud, ::point_doubler_on_hud_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::full_ammo_powerup, ::full_ammo_powerup );
	replaceFunc( maps/mp/zombies/_zm_powerups::free_perk_powerup, ::free_perk_powerup );
	replaceFunc( maps/mp/zombies/_zm_powerups::nuke_powerup, ::nuke_powerup );
	replaceFunc( maps/mp/zombies/_zm_utility::disable_player_move_states, ::disable_player_move_states_override );
	replaceFunc( maps/mp/zombies/_zm_utility::set_run_speed, ::set_run_speed_override );
	replaceFunc( maps/mp/zombies/_zm_utility::get_player_weapon_limit, ::get_player_weapon_limit );
	replaceFunc( maps/mp/zombies/_zm_magicbox::treasure_chest_canplayerreceiveweapon, ::treasure_chest_canplayerreceiveweapon_override);
	replaceFunc( maps/mp/zombies/_zm_magicbox::treasure_chest_weapon_spawn, ::treasure_chest_weapon_spawn_override );
	replaceFunc( maps/mp/zombies/_zm_magicbox::treasure_chest_move, ::treasure_chest_move );
	replaceFunc( maps/mp/zombies/_zm_weapons::weapon_give, ::weapon_give );
	replaceFunc( maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options, ::get_pack_a_punch_weapon_options_override );
	replaceFunc( maps/mp/zombies/_zm_weap_claymore::claymore_safe_to_plant, ::claymore_safe_to_plant );
	replaceFunc( maps/mp/zombies/_zm_pers_upgrades_functions::pers_treasure_chest_choosespecialweapon, ::pers_treasure_chest_choosespecialweapon_override );
	replaceFunc( maps/mp/zombies/_zm::actor_damage_override, ::actor_damage_override_override );
	replaceFunc( maps/mp/zombies/_zm_spawner::zombie_rise_death, ::zombie_rise_death_override );
	replaceFunc( maps/mp/zombies/_zm::round_think, ::round_think_override );
	replaceFunc( maps/mp/zombies/_zm::ai_calculate_health, ::ai_calculate_health_override );
	replaceFunc( maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_should_we_give_raygun, ::pers_nube_should_we_give_raygun );
	
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

    	if(self.initial_spawn)
		{
            self.initial_spawn = false;

			self thread debug( 0 );

			self iprintln("Welcome to Remix!");
			self iPrintLn("Version " + level.VERSION);

			self set_players_score( 555 );
			self set_movement_dvars();
			self set_client_dvars();
			self set_character_option();

			self graphic_tweaks();
			self thread night_mode();

	    	self thread timer_hud();
			self thread health_bar_hud();
			self thread zombie_remaining_hud();
			self thread zone_hud();

			self thread inspect_weapon();

			self thread max_ammo_refill_clip();
			self thread carpenter_repair_shield();

			self thread give_perma_perks();
			self thread give_bank_fridge();

			self thread mulekick_additional_perks();
			self thread staminup_additional_perks();

			self thread rapid_fire();
			self thread disable_player_quotes();
        }

        if(level.inital_spawn)
		{
			level.inital_spawn = false;

			level thread coop_pause();
			level thread fake_reset();

			level thread shared_box();

			flag_wait( "start_zombie_round_logic" );
   			wait 0.05;

			set_startings_chests();
			set_visionset();
			set_claymores_max( 10 );

			raygun_mark2_probabilty();
			remove_fire_sales();

			electric_trap_always_kill();
			disable_high_round_walkers();
			disable_electric_cherry_on_laststand();
			
			enable_free_perks_before_power();
			perk_machine_find_change();

			level thread buildbuildables();
			level thread buildcraftables();

			buildable_increase_trigger_radius();
			wallbuy_increase_trigger_radius();
			level thread wallbuy_dynamic_increase_trigger_radius();

		}
	}
}

/*
* *****************************************************
*	
* ********************* Overrides **********************
*
* *****************************************************
*/

set_run_speed_override()
{
	self.zombie_move_speed = "sprint";
}

round_think_override( restart ) //checked changed to match cerberus output
{
	if ( !isDefined( restart ) )
	{
		restart = 0;
	}
	level endon( "end_round_think" );
	if ( !is_true( restart ) )
	{
		if ( isDefined( level.initial_round_wait_func ) )
		{
			[[ level.initial_round_wait_func ]]();
		}
		players = get_players();
		foreach ( player in players )
		{
			if ( is_true( player.hostmigrationcontrolsfrozen ) ) 
			{
				player freezecontrols( 0 );
			}
			player maps/mp/zombies/_zm_stats::set_global_stat( "rounds", level.round_number );
		}
	}
	setroundsplayed( level.round_number );
	for ( ;; )
	{
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
		{
			maxreward = 500;
		}
		level.zombie_vars[ "rebuild_barrier_cap_per_round" ] = maxreward;
		level.pro_tips_start_time = getTime();
		level.zombie_last_run_time = getTime();
		if ( isDefined( level.zombie_round_change_custom ) )
		{
			[[ level.zombie_round_change_custom ]]();
		}
		else
		{
			level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
			round_one_up();
		}
		maps/mp/zombies/_zm_powerups::powerup_round_start();
		players = get_players();
		array_thread( players, ::rebuild_barrier_reward_reset );
		if ( !is_true( level.headshots_only ) && !restart )
		{
			level thread award_grenades_for_survivors();
		}
		level.round_start_time = getTime();
		while ( level.zombie_spawn_locations.size <= 0 )
		{
			wait 0.1;
		}
		level thread [[ level.round_spawn_func ]]();
		level notify( "start_of_round" );
		recordzombieroundstart();
		players = getplayers();
		for ( index = 0; index < players.size; index++  )
		{
			zonename = players[ index ] get_current_zone();
			if ( isDefined( zonename ) )
			{
				players[ index ] recordzombiezone( "startingZone", zonename );
			}
		}
		if ( isDefined( level.round_start_custom_func ) )
		{
			[[ level.round_start_custom_func ]]();
		}
		[[ level.round_wait_func ]]();
		level.first_round = 0;
		level notify( "end_of_round" );
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
		uploadstats();
		if ( isDefined( level.round_end_custom_logic ) )
		{
			[[ level.round_end_custom_logic ]]();
		}
		players = get_players();
		if ( is_true( level.no_end_game_check ) )
		{
			level thread last_stand_revive();
			level thread spectators_respawn();
		}
		else if ( players.size != 1 )
		{
			level thread spectators_respawn();
		}
		players = get_players();
		array_thread( players, ::round_end );
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
		}
		else if ( timer < 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
		}
		if ( level.gamedifficulty == 0 )
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
		}
		else
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier" ];
		}
		level.round_number++;
		// if ( level.round_number >= 255 )
		// {
		// 	level.round_number = 255;
		// }
		setroundsplayed( level.round_number );
		matchutctime = getutc();
		players = get_players();
		foreach ( player in players )
		{
			if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
			{
				player maps/mp/zombies/_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );
			}
			player maps/mp/zombies/_zm_stats::set_global_stat( "rounds", level.round_number );
			player maps/mp/zombies/_zm_stats::update_playing_utc_time( matchutctime );
		}
		check_quickrevive_for_hotjoin(); //was commented out
		level round_over();
		level notify( "between_round_over" );
		restart = 0;
	}
}

disable_player_move_states_override( forcestancechange ) //checked matches cerberus output
{
	self allowcrouch( 1 );
	self allowlean( 0 );
	self allowads( 0 );
	self allowsprint( 1 );
	self allowprone( 0 );
	self allowmelee( 0 );
	if ( isDefined( forcestancechange ) && forcestancechange == 1 )
	{
		if ( self getstance() == "prone" )
		{
			self setstance( "crouch" );
		}
	}
}

treasure_chest_canplayerreceiveweapon_override( player, weapon, pap_triggers ) //checked matches cerberus output
{
	if ( !get_is_in_box( weapon ) )
	{
		return 0;
	}
	if ( isDefined( player ) && player has_weapon_or_upgrade( weapon ) )
	{
		return 0;
	}
	if ( !limited_weapon_below_quota( weapon, player, pap_triggers ) )
	{
		return 0;
	}
	if ( !player player_can_use_content( weapon ) )
	{
		return 0;
	}
	if ( isDefined( level.custom_magic_box_selection_logic ) )
	{
		if ( !( [[ level.custom_magic_box_selection_logic ]]( weapon, player, pap_triggers ) ) )
		{
			return 0;
		}
	}
	if ( isDefined( player ) && isDefined( level.special_weapon_magicbox_check ) )
	{
		return player [[ level.special_weapon_magicbox_check ]]( weapon );
	}
	return 1;
}

is_setup_weapon( weapon )
{
	if( weapon == "raygun_mark2_zm" || weapon == "ray_gun_zm" || weapon == "cymbal_monkey_zm" || weapon == "blundergat_zm" || weapon == "slowgun_zm" || weapon == "m32_zm" )
	{
		return 1;
	}
	return 0;
}

treasure_chest_weapon_spawn_override( chest, player, respin ) //checked changed to match cerberus output
{
	if ( is_true( level.using_locked_magicbox ) )
	{
		self.owner endon( "box_locked" );
		self thread maps/mp/zombies/_zm_magicbox_lock::clean_up_locked_box();
	}
	self endon( "box_hacked_respin" );
	self thread clean_up_hacked_box();
	/*
/#
	assert( isDefined( player ) );
#/
	*/
	self.weapon_string = undefined;
	modelname = undefined;
	rand = undefined;
	number_cycles = 40;
	if ( isDefined( chest.zbarrier ) )
	{
		if ( isDefined( level.custom_magic_box_do_weapon_rise ) )
		{
			chest.zbarrier thread [[ level.custom_magic_box_do_weapon_rise ]]();
		}
		else
		{
			chest.zbarrier thread magic_box_do_weapon_rise();
		}
	}
	for ( i = 0; i < number_cycles; i++ )
	{

		if ( i < 20 )
		{
			wait 0.05 ; 
		}
		else if ( i < 30 )
		{
			wait 0.1 ; 
		}
		else if ( i < 35 )
		{
			wait 0.2 ; 
		}
		else if ( i < 38 )
		{
			wait 0.3 ; 
		}
	}


	// first box level vars
	if ( !isDefined(level.chest_max_move_usage) )
	{
		level.chest_max_move_usage = 8;
	}
	if ( !isDefined(level.weapons_needed) )
	{	
		level.weapons_needed = 2;

		if( level.players.size > 1 )
		{
			level.weapons_needed += 2;
		}
		if( level.default_start_location == "processing" || level.default_start_location == "tomb" )
		{
			level.weapons_needed += 1;
		}
		if( level.default_start_location == "prison" && level.players.size > 1 )
		{
			level.weapons_needed += 1;
		}
	}

	if ( isDefined( level.custom_magic_box_weapon_wait ) )
	{
		[[ level.custom_magic_box_weapon_wait ]]();
	}

	rand = treasure_chest_chooseweightedrandomweapon( player );

	// iPrintLn("weapon: " + rand);

	// first box
	if ( level.chest_moves == 0 )
	{
		ran = randomInt( (level.chest_max_move_usage - level.weapons_needed) - level.chest_accessed );
		if ( ran == 0 && level.chest_accessed <= level.chest_max_move_usage && level.weapons_needed > 0)
		{	
			pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );

			if ( treasure_chest_canplayerreceiveweapon( player, "raygun_mark2_zm", pap_triggers ) )
			{
				rand = "raygun_mark2_zm";
			}
			else if( treasure_chest_canplayerreceiveweapon( player, "ray_gun_zm", pap_triggers ) )
			{
				rand = "ray_gun_zm";
			}
			else if( treasure_chest_canplayerreceiveweapon( player, "cymbal_monkey_zm", pap_triggers ) && getDvar("mapname") != "zm_prison")
			{
				rand = "cymbal_monkey_zm";
			}
			else if( treasure_chest_canplayerreceiveweapon( player, "blundergat_zm", pap_triggers ) && getDvar("mapname") == "zm_prison")
			{
				rand = "blundergat_zm";
			}
			else if( treasure_chest_canplayerreceiveweapon( player, "slowgun_zm", pap_triggers ) && getDvar( "mapname" ) == "zm_buried")
			{
				rand = "slowgun_zm";
			}
			else if( treasure_chest_canplayerreceiveweapon( player, "emp_grenade_zm", pap_triggers ) && getDvar("mapname") == "zm_transit" && is_classic() )
			{
				rand = "emp_grenade_zm";
			}
			else if( treasure_chest_canplayerreceiveweapon( player, "m32_zm", pap_triggers ) && getDvar("mapname") == "zm_tomb")
			{
				rand = "m32_zm";
			}

			if( level.weapons_needed != 0 )
			{
				level.weapons_needed--;
			}
			// iprintln("ran modified: " + rand);
		}
	}

	// iprintln("weapons needed: " + level.weapons_needed);
	// iprintln("ran: " + ran);
	
	self.weapon_string = rand;
	wait 0.1;
	if ( isDefined( level.custom_magicbox_float_height ) )
	{
		v_float = anglesToUp( self.angles ) * level.custom_magicbox_float_height;
	}
	else
	{
		v_float = anglesToUp( self.angles ) * 40;
	}
	self.model_dw = undefined;
	self.weapon_model = spawn_weapon_model( rand, undefined, self.origin + v_float, self.angles + vectorScale( ( 0, 1, 0 ), 180 ) );
	if ( weapon_is_dual_wield( rand ) )
	{
		self.weapon_model_dw = spawn_weapon_model( rand, get_left_hand_weapon_model_name( rand ), self.weapon_model.origin - vectorScale( ( 0, 1, 0 ), 3 ), self.weapon_model.angles );
	}
	if ( getDvar( "magic_chest_movable" ) == "1" && !is_true( chest._box_opened_by_fire_sale ) && !is_true( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() )
	{
		random = randomint( 100 );
		if ( !isDefined(level.chest_max_move_usage) )
		{
			level.chest_max_move_usage = 8;
		}
		if ( !isDefined( level.chest_min_move_usage ) )
		{
			level.chest_min_move_usage = 4;
		}
		if ( level.chest_accessed < level.chest_min_move_usage )
		{
			chance_of_joker = -1;
		}
		else
		{
			chance_of_joker = level.chest_accessed + 20;
			if ( level.chest_moves == 0 && level.chest_accessed >= level.chest_max_move_usage )
			{
				chance_of_joker = 100;
			}
			if ( level.chest_accessed >= 4 && level.chest_accessed < 8 )
			{
				if ( random < 15 && !is_setup_weapon( rand ) ) // always get setup before the box moves
				{
					chance_of_joker = 100;
				}
				else
				{
					chance_of_joker = -1;
				}
			}
			if ( level.chest_moves > 0 )
			{
				if ( level.chest_accessed >= 8 && level.chest_accessed < 13 )
				{
					if ( random < 30 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}
				if ( level.chest_accessed >= 13 )
				{
					if ( random < 50 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}
			}
		}
		if ( isDefined( chest.no_fly_away ) )
		{
			chance_of_joker = -1;
		}
		if ( isDefined( level._zombiemode_chest_joker_chance_override_func ) )
		{
			chance_of_joker = [[ level._zombiemode_chest_joker_chance_override_func ]]( chance_of_joker );
		}
		if ( chance_of_joker > random )
		{
			self.weapon_string = undefined;
			self.weapon_model setmodel( level.chest_joker_model );
			self.weapon_model.angles = self.angles + vectorScale( ( 0, 1, 0 ), 90 );
			if ( isDefined( self.weapon_model_dw ) )
			{
				self.weapon_model_dw delete();
				self.weapon_model_dw = undefined;
			}
			self.chest_moving = 1;
			flag_set( "moving_chest_now" );
			level.chest_accessed = 0;
			level.chest_moves++;
		}
	}
	self notify( "randomization_done" );
	if ( flag( "moving_chest_now" ) && !level.zombie_vars[ "zombie_powerup_fire_sale_on" ] && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() )
	{
		if ( isDefined( level.chest_joker_custom_movement ) )
		{
			self [[ level.chest_joker_custom_movement ]]();
		}
		else
		{
			wait 0.5;
			level notify( "weapon_fly_away_start" );
			wait 2;
			if ( isDefined( self.weapon_model ) )
			{
				v_fly_away = self.origin + ( anglesToUp( self.angles ) * 500 );
				self.weapon_model moveto( v_fly_away, 4, 3 );
			}
			if ( isDefined( self.weapon_model_dw ) )
			{
				v_fly_away = self.origin + ( anglesToUp( self.angles ) * 500 );
				self.weapon_model_dw moveto( v_fly_away, 4, 3 );
			}
			self.weapon_model waittill( "movedone" );
			self.weapon_model delete();
			if ( isDefined( self.weapon_model_dw ) )
			{
				self.weapon_model_dw delete();
				self.weapon_model_dw = undefined;
			}
			self notify( "box_moving" );
			level notify( "weapon_fly_away_end" );
		}
	}
	else
	{
		acquire_weapon_toggle( rand, player );
		if ( rand == "tesla_gun_zm" || rand == "ray_gun_zm" )
		{
			if ( rand == "ray_gun_zm" )
			{
				level.pulls_since_last_ray_gun = 0;
			}
			if ( rand == "tesla_gun_zm" )
			{
				level.pulls_since_last_tesla_gun = 0;
				level.player_seen_tesla_gun = 1;
			}
		}
		if ( !isDefined( respin ) )
		{
			if ( isDefined( chest.box_hacks[ "respin" ] ) )
			{
				self [[ chest.box_hacks[ "respin" ] ]]( chest, player );
			}
		}
		else
		{
			if ( isDefined( chest.box_hacks[ "respin_respin" ] ) )
			{
				self [[ chest.box_hacks[ "respin_respin" ] ]]( chest, player );
			}
		}
		if ( isDefined( level.custom_magic_box_timer_til_despawn ) )
		{
			self.weapon_model thread [[ level.custom_magic_box_timer_til_despawn ]]( self );
		}
		else
		{
			self.weapon_model thread timer_til_despawn( v_float );
		}
		if ( isDefined( self.weapon_model_dw ) )
		{
			if ( isDefined( level.custom_magic_box_timer_til_despawn ) )
			{
				self.weapon_model_dw thread [[ level.custom_magic_box_timer_til_despawn ]]( self );
			}
			else
			{
				self.weapon_model_dw thread timer_til_despawn( v_float );
			}
		}
		self waittill( "weapon_grabbed" );
		if ( !chest.timedout )
		{
			if ( isDefined( self.weapon_model ) )
			{
				self.weapon_model delete();
			}
			if ( isDefined( self.weapon_model_dw ) )
			{
				self.weapon_model_dw delete();
			}
		}
	}
	self.weapon_string = undefined;
	self notify( "box_spin_done" );
}

ai_calculate_health_override( round_number ) //checked changed to match cerberus output
{
	// insta kill rounds staring at 99 then every 2 rounds after
	if( (round_number >= 99) && (round_number % 2) )
	{
		level.zombie_health = 150;
		return;
	}

	// more linearly health formula - health is about the same at 65
	if( round_number > 50 )
	{	
		round = (round_number - 50);
		multiplier = 1;
		zombie_health = 0;

		for( i = 0; i < round; i++ )
		{
			multiplier++;
			zombie_health += int(4000 + (500 * multiplier) );
		}
		level.zombie_health = int(zombie_health + 51780); // round 51 zombies health

		// iprintln( "health: " + level.zombie_health );
	}
	else
	{
		level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
		i = 2;
		while ( i <= round_number )
		{
			if ( i >= 10 )
			{
				old_health = level.zombie_health;
				level.zombie_health = level.zombie_health + int( level.zombie_health * level.zombie_vars[ "zombie_health_increase_multiplier" ] );
				if ( level.zombie_health < old_health )
				{
					level.zombie_health = old_health;
					return;
				}
				i++;
				continue;
			}
			level.zombie_health = int( level.zombie_health + level.zombie_vars[ "zombie_health_increase" ] );
			i++;
		}
	}
}

get_player_weapon_limit( player ) //checked matches cerberus output
{
	// if ( isDefined( level.get_player_weapon_limit ) )
	// {
	// 	return [[ level.get_player_weapon_limit ]]( player );
	// }
	weapon_limit = 3;

	return weapon_limit;
}


weapon_give( weapon, is_upgrade, magic_box, nosound ) //checked changed to match cerberus output
{
	primaryweapons = self getweaponslistprimaries();
	current_weapon = self getcurrentweapon();
	current_weapon = self maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( current_weapon );
	if ( !isDefined( is_upgrade ) )
	{
		is_upgrade = 0;
	}
	weapon_limit = get_player_weapon_limit( self );
	if ( is_equipment( weapon ) )
	{
		self maps/mp/zombies/_zm_equipment::equipment_give( weapon );
	}
	if ( weapon == "riotshield_zm" )
	{
		if ( isDefined( self.player_shield_reset_health ) )
		{
			self [[ self.player_shield_reset_health ]]();
		}
	}
	if ( self hasweapon( weapon ) )
	{
		if ( issubstr( weapon, "knife_ballistic_" ) )
		{
			self notify( "zmb_lost_knife" );
		}
		self givestartammo( weapon );
		if ( !is_offhand_weapon( weapon ) )
		{
			self switchtoweapon( weapon );
		}
		return;
	}
	if ( is_melee_weapon( weapon ) )
	{
		current_weapon = maps/mp/zombies/_zm_melee_weapon::change_melee_weapon( weapon, current_weapon );
	}
	else if ( is_lethal_grenade( weapon ) )
	{
		old_lethal = self get_player_lethal_grenade();
		if ( isDefined( old_lethal ) && old_lethal != "" )
		{
			self takeweapon( old_lethal );
			unacquire_weapon_toggle( old_lethal );
		}
		self set_player_lethal_grenade( weapon );
	}
	else if ( is_tactical_grenade( weapon ) )
	{
		old_tactical = self get_player_tactical_grenade();
		if ( isDefined( old_tactical ) && old_tactical != "" )
		{
			self takeweapon( old_tactical );
			unacquire_weapon_toggle( old_tactical );
		}
		self set_player_tactical_grenade( weapon );
	}
	else if ( is_placeable_mine( weapon ) )
	{
		old_mine = self get_player_placeable_mine();
		if ( isDefined( old_mine ) )
		{
			self takeweapon( old_mine );
			unacquire_weapon_toggle( old_mine );
		}
		self set_player_placeable_mine( weapon );
	}
	if ( !is_offhand_weapon( weapon ) )
	{
		self maps/mp/zombies/_zm_weapons::take_fallback_weapon();
	}
	if ( primaryweapons.size >= weapon_limit )
	{
		if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) )
		{
			current_weapon = undefined;
		}
		if ( isDefined( current_weapon ) )
		{
			if ( !is_offhand_weapon( weapon ) )
			{
				if ( current_weapon == "tesla_gun_zm" )
				{
					level.player_drops_tesla_gun = 1;
				}
				if ( issubstr( current_weapon, "knife_ballistic_" ) )
				{
					self notify( "zmb_lost_knife" );
				}
				self takeweapon( current_weapon );
				unacquire_weapon_toggle( current_weapon );
			}
		}
	}
	if ( isDefined( level.zombiemode_offhand_weapon_give_override ) )
	{
		if ( self [[ level.zombiemode_offhand_weapon_give_override ]]( weapon ) )
		{
			return;
		}
	}
	if ( weapon == "cymbal_monkey_zm" )
	{
		self maps/mp/zombies/_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
		self play_weapon_vo( weapon, magic_box );
		return;
	}
	else if ( issubstr( weapon, "knife_ballistic_" ) )
	{
		weapon = self maps/mp/zombies/_zm_melee_weapon::give_ballistic_knife( weapon, issubstr( weapon, "upgraded" ) );
	}
	else if ( weapon == "claymore_zm" )
	{
		self thread maps/mp/zombies/_zm_weap_claymore::claymore_setup();
		self play_weapon_vo( weapon, magic_box );
		return;
	}
	if ( isDefined( level.zombie_weapons_callbacks ) && isDefined( level.zombie_weapons_callbacks[ weapon ] ) )
	{
		self thread [[ level.zombie_weapons_callbacks[ weapon ] ]]();
		play_weapon_vo( weapon, magic_box );
		return;
	}
	if ( !is_true( nosound ) )
	{
		self play_sound_on_ent( "purchase" );
	}
	if ( weapon == "ray_gun_zm" )
	{
		playsoundatposition( "mus_raygun_stinger", ( 0, 0, 0 ) );
	}
	if ( !is_weapon_upgraded( weapon ) )
	{
		self giveweapon( weapon );
	}
	else
	{
		self giveweapon( weapon, 0, self get_pack_a_punch_weapon_options( weapon ) );
	}
	acquire_weapon_toggle( weapon, self );
	self givestartammo( weapon );
	if ( !is_offhand_weapon( weapon ) )
	{
		if ( !is_melee_weapon( weapon ) )
		{
			self switchtoweapon( weapon );
		}
		else
		{
			self switchtoweapon( current_weapon );
		}
	}
	if( weapon == "blundersplat_upgraded_zm" )
	{
		self setweaponammostock( "blundersplat_upgraded_zm", 100 );
	}
	else if( weapon == "blundersplat_zm" )
	{
		self setweaponammostock( "blundersplat_zm", 100 );
	}

	if ( self hasweapon( "blundergat_upgraded_zm" ) )
	{
		self setweaponammostock( "blundergat_upgraded_zm", 80 );
	}
	else if ( self hasweapon( "blundergat_zm" ) )
	{
		self setweaponammostock( "blundergat_zm", 80 );
	}

	self play_weapon_vo( weapon, magic_box );
}

full_ammo_powerup( drop_item, player ) //checked changed to match cerberus output
{
	players = get_players( player.team );
	if ( isdefined( level._get_game_module_players ) )
	{
		players = [[ level._get_game_module_players ]]( player );
	}
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			i++;
			continue;
		}
		primary_weapons = players[ i ] getweaponslist( 1 );
		players[ i ] notify( "zmb_max_ammo" );
		players[ i ] notify( "zmb_lost_knife" );
		players[ i ] notify( "zmb_disable_claymore_prompt" );
		players[ i ] notify( "zmb_disable_spikemore_prompt" );
		x = 0;
		while ( x < primary_weapons.size )
		{
			if ( level.headshots_only && is_lethal_grenade(primary_weapons[ x ] ) )
			{
				x++;
				continue;
			}
			if ( isdefined( level.zombie_include_equipment ) && isdefined( level.zombie_include_equipment[ primary_weapons[ x ] ] ) )
			{
				x++;
				continue;
			}
			if ( isdefined( level.zombie_weapons_no_max_ammo ) && isdefined( level.zombie_weapons_no_max_ammo[ primary_weapons[ x ] ] ) )
			{
				x++;
				continue;
			}
			if ( players[ i ] hasweapon( primary_weapons[ x ] ) )
			{
				players[ i ] givemaxammo( primary_weapons[ x ] );

				if ( players[ i ] hasweapon( "blundergat_upgraded_zm" ) )
				{
					players[ i ] setweaponammostock( "blundergat_upgraded_zm", 80 );
				}
				else if ( players[ i ] hasweapon( "blundergat_zm" ) )
				{
					players[ i ] setweaponammostock( "blundergat_zm", 80 );
				}

				if ( players[ i ] hasweapon( "blundersplat_upgraded_zm" ) )
				{
					players[ i ] setweaponammostock( "blundersplat_upgraded_zm", 100 );
				}
				else if ( players[ i ] hasweapon( "blundersplat_zm" ) )
				{
					players[ i ] setweaponammostock( "blundersplat_zm", 100 );
				}
			}
			x++;
		}
		i++;
	}
	level thread full_ammo_on_hud( drop_item, player.team );
}

free_perk_powerup( item ) //checked changed to match cerberus output
{
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( !players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() && players[ i ].sessionstate != "spectator" )
		{
			player = players[ i ];
			if ( isDefined( item.ghost_powerup ) )
			{
				player maps/mp/zombies/_zm_stats::increment_client_stat( "buried_ghost_perk_acquired", 0 );
				player maps/mp/zombies/_zm_stats::increment_player_stat( "buried_ghost_perk_acquired" );
				player notify( "player_received_ghost_round_free_perk" );
			}
			else
			{
				free_perk = player maps/mp/zombies/_zm_perks::give_random_perk();
			}
			if ( is_true( level.disable_free_perks_before_power ) )
			{
				player thread disable_perk_before_power( free_perk );
			}

			// increase perk limit
			if ( level.perk_purchase_limit < 8 )
			{
				level.perk_purchase_limit++;
			}
		}
	}
}

pers_treasure_chest_choosespecialweapon_override( player ) //checked changed to match cerberus output
{
	if ( !isDefined( player.pers_magic_box_weapon_count ) )
	{
		player.pers_magic_box_weapon_count = 0;
	}

	rval = randomfloat( 1 );
	//if ( rval < 0.5 && player.pers_magic_box_weapon_count < 1 )
	if ( player.pers_magic_box_weapon_count < 1 )
	{
		player.pers_magic_box_weapon_count++;

		if ( !isDefined( level.pers_box_weapons ) )
		{
			level.pers_box_weapons = [];
			level.pers_box_weapons[ level.pers_box_weapons.size ] = "cymbal_monkey_zm";
			level.pers_box_weapons[ level.pers_box_weapons.size ] = "raygun_mark2_zm";
		}

		keys = array_randomize( level.pers_box_weapons );

		pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );
		for ( i = 0; i < keys.size; i++ )
		{
			if ( maps/mp/zombies/_zm_magicbox::treasure_chest_canplayerreceiveweapon( player, keys[ i ], pap_triggers ) )
			{
				if( level.weapons_needed != 0 )
				{
					level.weapons_needed--;
				}
				return keys[ i ];
			}
		}
	}

	weapon = maps/mp/zombies/_zm_magicbox::treasure_chest_chooseweightedrandomweapon( player );
	return weapon;
}

get_pack_a_punch_weapon_options_override( weapon ) //checked changed to match cerberus output
{
	if ( !isDefined( self.pack_a_punch_weapon_options ) )
	{
		self.pack_a_punch_weapon_options = [];
	}
	if ( !is_weapon_upgraded( weapon ) )
	{
		return self calcweaponoptions( 0, 0, 0, 0, 0 );
	}
	if ( isDefined( self.pack_a_punch_weapon_options[ weapon ] ) )
	{
		return self.pack_a_punch_weapon_options[ weapon ];
	}
	smiley_face_reticle_index = 1;
	base = get_base_name( weapon );
	camo_index = 39;
	if ( level.script == "zm_prison" )
	{
		camo_index = 40;
	}
	else if ( level.script == "zm_buried" )
	{
		camo_index = 40;
	}
	else if ( level.script == "zm_tomb" )
	{
		camo_index = 45;
	}
	lens_index = randomintrange( 0, 6 );
	reticle_index = randomintrange( 0, 16 );
	reticle_color_index = randomintrange( 0, 6 );
	plain_reticle_index = 16;
	r = randomint( 10 );
	use_plain = r < 3;
	if ( base == "saritch_upgraded_zm" )
	{
		reticle_index = smiley_face_reticle_index;
	}
	else if ( use_plain )
	{
		reticle_index = plain_reticle_index;
	}
	scary_eyes_reticle_index = 8;
	purple_reticle_color_index = 3;
	if ( reticle_index == scary_eyes_reticle_index )
	{
		reticle_color_index = purple_reticle_color_index;
	}
	letter_a_reticle_index = 2;
	pink_reticle_color_index = 6;
	if ( reticle_index == letter_a_reticle_index )
	{
		reticle_color_index = pink_reticle_color_index;
	}
	letter_e_reticle_index = 7;
	green_reticle_color_index = 1;
	if ( reticle_index == letter_e_reticle_index )
	{
		reticle_color_index = green_reticle_color_index;
	}
	self.pack_a_punch_weapon_options[ weapon ] = self calcweaponoptions( camo_index, lens_index, reticle_index, reticle_color_index );
	return self.pack_a_punch_weapon_options[ weapon ];
}

actor_damage_override_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked changed to match cerberus output //checked against bo3 _zm.gsc partially changed to match
{
	if ( !isDefined( self ) || !isDefined( attacker ) )
	{
		return damage;
	}
	if ( weapon == "tazer_knuckles_zm" || weapon == "jetgun_zm" )
	{
		self.knuckles_extinguish_flames = 1;
	}
	else if ( weapon != "none" )
	{
		self.knuckles_extinguish_flames = undefined;
	}
	if ( isDefined( attacker.animname ) && attacker.animname == "quad_zombie" )
	{
		if ( isDefined( self.animname ) && self.animname == "quad_zombie" )
		{
			return 0;
		}
	}
	if ( !isplayer( attacker ) && isDefined( self.non_attacker_func ) )
	{
		if ( is_true( self.non_attack_func_takes_attacker ) )
		{
			return self [[ self.non_attacker_func ]]( damage, weapon, attacker );
		}
		else
		{
			return self [[ self.non_attacker_func ]]( damage, weapon );
		}
	}
	if ( !isplayer( attacker ) && !isplayer( self ) )
	{
		return damage;
	}
	if ( !isDefined( damage ) || !isDefined( meansofdeath ) )
	{
		return damage;
	}
	if ( meansofdeath == "" )
	{
		return damage;
	}
	old_damage = damage;
	final_damage = damage;
	if ( isDefined( self.actor_damage_func ) )
	{
		final_damage = [[ self.actor_damage_func ]]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	if ( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
	{
		attacker = attacker.owner;
	}
	if ( is_true( self.in_water ) )
	{
		if ( int( final_damage ) >= self.health )
		{
			self.water_damage = 1;
		}
	}
	attacker thread maps/mp/gametypes_zm/_weapons::checkhit( weapon );
	if ( attacker maps/mp/zombies/_zm_pers_upgrades_functions::pers_mulit_kill_headshot_active() && is_headshot( weapon, shitloc, meansofdeath ) )
	{
		final_damage *= 2;
	}
	if ( is_true( level.headshots_only ) && isDefined( attacker ) && isplayer( attacker ) )
	{
		//changed to match bo3 _zm.gsc behavior
		if ( meansofdeath == "MOD_MELEE" && shitloc == "head" || meansofdeath == "MOD_MELEE" && shitloc == "helmet" )
		{
			return int( final_damage );
		}
		if ( is_explosive_damage( meansofdeath ) )
		{
			return int( final_damage );
		}
		else if ( !is_headshot( weapon, shitloc, meansofdeath ) )
		{
			return 0;
		}
	}


	if ( ( weapon == "blundergat_zm" || weapon == "blundergat_upgraded_zm" ) && ( meansofdeath == "MOD_PISTOL_BULLET" || meansofdeath == "MOD_RIFLE_BULLET" ) )
	{
		final_damage = (self.maxhealth / 12) + 5;
		if(damage >= final_damage)
		{
			final_damage = damage;
		}
	}
	if( weapon == "claymore_zm" ) 
	{
		if( meansofdeath == "MOD_GRENADE" || meansofdeath == "MOD_GRENADE_SPLASH" )
		{
			if(flags == 5) // fix for grenades doing increased damage when holding claymores
			{
				final_damage = int(self.maxhealth / 2) + 55;
			}
			if(damage >= final_damage)
			{
				final_damage = damage;
			}
		}
	}
	if( attacker HasPerk("specialty_deadshot") && meansofdeath == "MOD_PISTOL_BULLET" || meansofdeath == "MOD_RIFLE_BULLET" && WeaponClass(weapon) != "spread" && sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck" )
	{
		final_damage = int(final_damage * 2);
	}

	// if ( weapon == "quadrotorturret_zm" )
	// {
	// 	iPrintLn("equip_dieseldrone_zm");
	// 	final_damage = int(self.maxhealth / 3) + 55;
	// }

	return int( final_damage );
}

treasure_chest_move( player_vox )
{
	level waittill( "weapon_fly_away_start" );
	players = get_players();
	array_thread( players, maps/mp/zombies/_zm_magicbox::play_crazi_sound );
	if ( isDefined( player_vox ) )
	{
		player_vox delay_thread( randomintrange( 2, 7 ), maps/mp/zombies/_zm_audio::create_and_play_dialog, "general", "box_move" );
	}
	level waittill( "weapon_fly_away_end" );
	if ( isDefined( self.zbarrier ) )
	{
		self maps/mp/zombies/_zm_magicbox::hide_chest( 1 );
	}
	wait 0.1;
	if ( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] == 1 && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() )
	{
		current_sale_time = level.zombie_vars[ "zombie_powerup_fire_sale_time" ];
		wait_network_frame();
		self thread maps/mp/zombies/_zm_magicbox::fire_sale_fix();
		level.zombie_vars[ "zombie_powerup_fire_sale_time" ] = current_sale_time;
		while ( level.zombie_vars[ "zombie_powerup_fire_sale_time" ] > 0 )
		{
			wait 0.1;
		}
	}
	level.verify_chest = 0;
	if ( isDefined( level._zombiemode_custom_box_move_logic ) )
	{
		[[ level._zombiemode_custom_box_move_logic ]]();
	}
	else
	{
		maps/mp/zombies/_zm_magicbox::default_box_move_logic();
	}
	if ( isDefined( level.chests[ level.chest_index ].box_hacks[ "summon_box" ] ) )
	{
		level.chests[ level.chest_index ] [[ level.chests[ level.chest_index ].box_hacks[ "summon_box" ] ]]( 0 );
	}
	playfx( level._effect[ "poltergeist" ], level.chests[ level.chest_index ].zbarrier.origin );
	level.chests[ level.chest_index ] maps/mp/zombies/_zm_magicbox::show_chest();
	flag_clear( "moving_chest_now" );
	self.zbarrier.chest_moving = 0;
}