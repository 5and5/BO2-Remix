#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_weap_staff_water;
#include maps/mp/zombies/_zm_weap_staff_fire;
#include maps/mp/zombies/_zm_weap_staff_air;
#include maps/mp/zombies/_zm_weap_staff_lightning;
#include maps/mp/zombies/_zm_challenges;
#include maps/mp/zm_tomb_challenges;


sndplaystaffstingeronce( type ) //checked matches cerberus output
{
	if( type == "ice" )
	{
		flag_set( "ice_puzzle_1_complete" );
		flag_set( "ice_puzzle_2_complete" );
		flag_set( "staff_water_zm_upgrade_unlocked" );
	}
	else if ( type == "lightning" )
	{
		flag_set( "electric_puzzle_1_complete" );
		flag_set( "electric_puzzle_2_complete" );
		flag_set( "staff_lightning_zm_upgrade_unlocked" );
	}
	else if ( type == "wind" )
	{
		flag_set( "air_puzzle_1_complete" );
		flag_set( "air_puzzle_2_complete" );
		flag_set( "staff_air_zm_upgrade_unlocked" );
	}
	else if ( type == "fire" )
	{
		flag_set( "fire_puzzle_1_complete" );
		flag_set( "fire_puzzle_2_complete" );
		flag_set( "staff_fire_zm_upgrade_unlocked" );
	}

	if ( !isDefined( level.sndstaffbuilt ) )
	{
		level.sndstaffbuilt = [];
	}
	if ( !isinarray( level.sndstaffbuilt, type ) )
	{
		level.sndstaffbuilt[ level.sndstaffbuilt.size ] = type;
		level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "staff_" + type );
	}
}

staff_lightning_ball_damage_over_time( e_source, e_target, e_attacker ) //checked changed at own discretion
{
	e_attacker endon( "disconnect" );
	e_target setclientfield( "lightning_impact_fx", 1 );
	e_target thread maps/mp/zombies/_zm_audio::do_zombies_playvocals( "electrocute", e_target.animname );
	n_range_sq = e_source.n_range * e_source.n_range;
	e_target.is_being_zapped = 1;
	e_target setclientfield( "lightning_arc_fx", 1 );
	wait 0.25;
	while ( isDefined( e_source ) && isalive( e_target ) )
	{
		e_target thread stun_zombie();
		wait 0.5;
		if ( !isDefined( e_source ) || !isalive( e_target ) )
		{
			continue;
		}
		n_dist_sq = distancesquared( e_source.origin, e_target.origin );
		if ( n_dist_sq > n_range_sq )
		{
			continue;
		}
		if ( isalive( e_target ) && isDefined( e_source ) )
		{
			e_target thread zombie_shock_eyes();
			e_target thread staff_lightning_kill_zombie( e_attacker, e_source.str_weapon );
		}
	}
	if ( isDefined( e_target ) )
	{
		e_target.is_being_zapped = 0;
		e_target setclientfield( "lightning_arc_fx", 0 );
	}
}

challenges_init_override() //checked matches cerberus output
{
	level.challenges_add_stats = ::tomb_challenges_add_stats_custom;
	maps/mp/zombies/_zm_challenges::init();
}

tomb_challenges_add_stats_custom() //checked matches cerberus output
{
	n_kills = 115;
	n_zone_caps = 6;
	n_points_spent = 30000;
	n_boxes_filled = 4;
	/*
/#
	if ( getDvarInt( "zombie_cheat" ) > 0 )
	{
		n_kills = 1;
		n_zone_caps = 2;
		n_points_spent = 500;
		n_boxes_filled = 1;
#/
	}
	*/
	add_stat( "zc_headshots", 0, &"ZM_TOMB_CH1", n_kills, undefined, ::reward_packed_weapon_custom );
	add_stat( "zc_zone_captures", 0, &"ZM_TOMB_CH2", n_zone_caps, undefined, ::reward_powerup_max_ammo );
	add_stat( "zc_points_spent", 0, &"ZM_TOMB_CH3", n_points_spent, undefined, ::reward_double_tap, ::track_points_spent );
	add_stat( "zc_boxes_filled", 1, &"ZM_TOMB_CHT", n_boxes_filled, undefined, ::reward_one_inch_punch, ::init_box_footprints );
}

reward_packed_weapon_custom( player, s_stat ) //checked matches cerberus output
{
	if ( !isDefined( s_stat.str_reward_weapon ) )
	{
		// a_weapons = array( "raygun_mark2_upgraded_zm" );
		s_stat.str_reward_weapon = maps/mp/zombies/_zm_weapons::get_upgrade_weapon( "raygun_mark2_upgraded_zm" );
	}
	m_weapon = spawn( "script_model", self.origin );
	m_weapon.angles = self.angles + vectorScale( ( 0, 1, 0 ), 180 );
	m_weapon playsound( "zmb_spawn_powerup" );
	m_weapon playloopsound( "zmb_spawn_powerup_loop", 0.5 );
	str_model = getweaponmodel( s_stat.str_reward_weapon );
	options = player maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( s_stat.str_reward_weapon );
	m_weapon useweaponmodel( s_stat.str_reward_weapon, str_model, options );
	wait_network_frame();
	if ( !reward_rise_and_grab( m_weapon, 50, 2, 2, 10 ) )
	{
		return 0;
	}
	weapon_limit = get_player_weapon_limit( player );
	primaries = player getweaponslistprimaries();
	if ( isDefined( primaries ) && primaries.size >= weapon_limit )
	{
		player maps/mp/zombies/_zm_weapons::weapon_give( s_stat.str_reward_weapon );
	}
	else
	{
		player giveweapon( s_stat.str_reward_weapon, 0, player maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( s_stat.str_reward_weapon ) );
		player givestartammo( s_stat.str_reward_weapon );
	}
	player switchtoweapon( s_stat.str_reward_weapon );
	m_weapon stoploopsound( 0.1 );
	player playsound( "zmb_powerup_grabbed" );
	m_weapon delete();
	return 1;
}

// fire_staff_area_of_effect( e_attacker, str_weapon )
// {
// 	self waittill( "explode", v_pos );
// 	ent = spawn( "script_origin", v_pos );
// 	ent playloopsound( "wpn_firestaff_grenade_loop", 1 );
// 	n_alive_time = 5;
// 	aoe_radius = 80;
// 	if ( str_weapon == "staff_fire_upgraded3_zm" )
// 	{
// 		aoe_radius = 100;
// 	}
// 	n_step_size = 0.2;
// 	while ( n_alive_time > 0 )
// 	{
// 		if ( ( n_alive_time - n_step_size ) <= 0 )
// 		{
// 			aoe_radius *= 2;
// 		}
// 		a_targets = getaiarray( "axis" );
// 		a_targets = get_array_of_closest( v_pos, a_targets, undefined, undefined, aoe_radius );
// 		wait n_step_size;
// 		n_alive_time -= n_step_size;
// 		_a213 = a_targets;
// 		_k213 = getFirstArrayKey( _a213 );
// 		while ( isDefined( _k213 ) )
// 		{
// 			e_target = _a213[ _k213 ];
// 			if ( isDefined( e_target ) && isalive( e_target ) )
// 			{
// 				if ( !is_true( self.is_on_fire ) )
// 				{
// 					e_target thread flame_damage_fx( str_weapon, e_attacker );
// 				}
// 			}
// 			_k213 = getNextArrayKey( _a213, _k213 );
// 		}
// 	}
// 	ent playsound( "wpn_firestaff_proj_impact" );
// 	ent delete();
// }

// add_staffs_to_box()
// {
//     staffs = array("staff_fire_zm", "staff_lightning_zm", "staff_air_zm", "staff_water_zm");
//     foreach(staff in staffs)
//     {
//         level thread add_staff_to_box( staff );
//     }
// }

// add_staff_to_box( staff )
// {
//     level waittill( staff + "_crafted" );
//     level.zombie_weapons[ staff ].is_in_box = 1;
// }

// include_weapons_override() //checked matches cerberus output
// {
// 	include_weapon( "hamr_zm" );
// 	include_weapon( "hamr_upgraded_zm", 0 );
// 	include_weapon( "mg08_zm" );
// 	include_weapon( "mg08_upgraded_zm", 0 );
// 	include_weapon( "type95_zm" );
// 	include_weapon( "type95_upgraded_zm", 0 );
// 	include_weapon( "galil_zm" );
// 	include_weapon( "galil_upgraded_zm", 0 );
// 	include_weapon( "fnfal_zm" );
// 	include_weapon( "fnfal_upgraded_zm", 0 );
// 	include_weapon( "m14_zm", 0 );
// 	include_weapon( "m14_upgraded_zm", 0 );
// 	include_weapon( "mp44_zm", 0 );
// 	include_weapon( "mp44_upgraded_zm", 0 );
// 	include_weapon( "scar_zm" );
// 	include_weapon( "scar_upgraded_zm", 0 );
// 	include_weapon( "870mcs_zm", 0 );
// 	include_weapon( "870mcs_upgraded_zm", 0 );
// 	include_weapon( "ksg_zm" );
// 	include_weapon( "ksg_upgraded_zm", 0 );
// 	include_weapon( "srm1216_zm" );
// 	include_weapon( "srm1216_upgraded_zm", 0 );
// 	include_weapon( "ak74u_zm", 0 );
// 	include_weapon( "ak74u_upgraded_zm", 0 );
// 	include_weapon( "ak74u_extclip_zm" );
// 	include_weapon( "ak74u_extclip_upgraded_zm", 0 );
// 	include_weapon( "pdw57_zm" );
// 	include_weapon( "pdw57_upgraded_zm", 0 );
// 	include_weapon( "thompson_zm" );
// 	include_weapon( "thompson_upgraded_zm", 0 );
// 	include_weapon( "qcw05_zm" );
// 	include_weapon( "qcw05_upgraded_zm", 0 );
// 	include_weapon( "mp40_zm", 0 );
// 	include_weapon( "mp40_upgraded_zm", 0 );
// 	include_weapon( "mp40_stalker_zm" );
// 	include_weapon( "mp40_stalker_upgraded_zm", 0 );
// 	include_weapon( "evoskorpion_zm" );
// 	include_weapon( "evoskorpion_upgraded_zm", 0 );
// 	include_weapon( "ballista_zm", 0 );
// 	include_weapon( "ballista_upgraded_zm", 0 );
// 	include_weapon( "dsr50_zm" );
// 	include_weapon( "dsr50_upgraded_zm", 0 );
// 	include_weapon( "beretta93r_zm", 0 );
// 	include_weapon( "beretta93r_upgraded_zm", 0 );
// 	include_weapon( "beretta93r_extclip_zm" );
// 	include_weapon( "beretta93r_extclip_upgraded_zm", 0 );
// 	include_weapon( "kard_zm" );
// 	include_weapon( "kard_upgraded_zm", 0 );
// 	include_weapon( "fiveseven_zm", 0 );
// 	include_weapon( "fiveseven_upgraded_zm", 0 );
// 	include_weapon( "python_zm" );
// 	include_weapon( "python_upgraded_zm", 0 );
// 	include_weapon( "c96_zm", 0 );
// 	include_weapon( "c96_upgraded_zm", 0 );
// 	include_weapon( "fivesevendw_zm" );
// 	include_weapon( "fivesevendw_upgraded_zm", 0 );
// 	include_weapon( "m32_zm" );
// 	include_weapon( "m32_upgraded_zm", 0 );
// 	include_weapon( "beacon_zm", 0 );
// 	include_weapon( "claymore_zm", 0 );
// 	include_weapon( "cymbal_monkey_zm" );
// 	include_weapon( "frag_grenade_zm", 0 );
// 	include_weapon( "knife_zm", 0 );
// 	include_weapon( "ray_gun_zm" );
// 	include_weapon( "ray_gun_upgraded_zm", 0 );
// 	include_weapon( "sticky_grenade_zm", 0 );
// 	include_weapon( "tomb_shield_zm", 0 );
// 	add_limited_weapon( "c96_zm", 0 );
// 	add_limited_weapon( "ray_gun_zm", 4 );
// 	add_limited_weapon( "ray_gun_upgraded_zm", 4 );
// 	include_weapon( "staff_air_zm", 0 );
// 	include_weapon( "staff_air_upgraded_zm", 0 );
// 	precacheitem( "staff_air_upgraded2_zm" );
// 	precacheitem( "staff_air_upgraded3_zm" );
// 	include_weapon( "staff_fire_zm", 0 );
// 	include_weapon( "staff_fire_upgraded_zm", 0 );
// 	precacheitem( "staff_fire_upgraded2_zm" );
// 	precacheitem( "staff_fire_upgraded3_zm" );
// 	include_weapon( "staff_lightning_zm", 0 );
// 	include_weapon( "staff_lightning_upgraded_zm", 0 );
// 	precacheitem( "staff_lightning_upgraded2_zm" );
// 	precacheitem( "staff_lightning_upgraded3_zm" );
// 	include_weapon( "staff_water_zm", 0 );
// 	include_weapon( "staff_water_zm_cheap", 0 );
// 	include_weapon( "staff_water_upgraded_zm", 0 );
// 	precacheitem( "staff_water_upgraded2_zm" );
// 	precacheitem( "staff_water_upgraded3_zm" );
// 	include_weapon( "staff_revive_zm", 0 );
// 	add_limited_weapon( "staff_air_zm" );
// 	add_limited_weapon( "staff_air_upgraded_zm" );
// 	add_limited_weapon( "staff_fire_zm" );
// 	add_limited_weapon( "staff_fire_upgraded_zm" );
// 	add_limited_weapon( "staff_lightning_zm" );
// 	add_limited_weapon( "staff_lightning_upgraded_zm" );
// 	add_limited_weapon( "staff_water_zm" );
// 	add_limited_weapon( "staff_water_zm_cheap" );
// 	add_limited_weapon( "staff_water_upgraded_zm" );
// 	if ( isDefined( level.raygun2_included ) && level.raygun2_included )
// 	{
// 		include_weapon( "raygun_mark2_zm", 1 );
// 		include_weapon( "raygun_mark2_upgraded_zm", 0 );
// 		add_weapon_to_content( "raygun_mark2_zm", "dlc3" );
// 		add_limited_weapon( "raygun_mark2_zm", 1 );
// 		add_limited_weapon( "raygun_mark2_upgraded_zm", 1 );
// 	}
// }