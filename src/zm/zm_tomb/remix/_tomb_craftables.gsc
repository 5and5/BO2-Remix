#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_ai_quadrotor;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zm_tomb_vo;
#include maps/mp/zm_tomb_main_quest;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zm_tomb_craftables;


include_craftables() //checked matches cerberus output
{
	level thread run_craftables_devgui();
	craftable_name = "equip_dieseldrone_zm";
	quadrotor_body = generate_zombie_craftable_piece( craftable_name, "body", "veh_t6_dlc_zm_quad_piece_body", 32, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_quadrotor_zm_body", 1, "build_dd" );
	quadrotor_brain = generate_zombie_craftable_piece( craftable_name, "brain", "veh_t6_dlc_zm_quad_piece_brain", 32, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_quadrotor_zm_brain", 1, "build_dd_brain" );
	quadrotor_engine = generate_zombie_craftable_piece( craftable_name, "engine", "veh_t6_dlc_zm_quad_piece_engine", 32, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_quadrotor_zm_engine", 1, "build_dd" );
	quadrotor = spawnstruct();
	quadrotor.name = craftable_name;
	quadrotor add_craftable_piece( quadrotor_body );
	quadrotor add_craftable_piece( quadrotor_brain );
	quadrotor add_craftable_piece( quadrotor_engine );
	quadrotor.triggerthink = ::quadrotorcraftable;
	include_zombie_craftable( quadrotor );
	level thread add_craftable_cheat( quadrotor );
	craftable_name = "tomb_shield_zm";
	riotshield_top = generate_zombie_craftable_piece( craftable_name, "top", "t6_wpn_zmb_shield_dlc4_top", 48, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_dolly", 1, "build_zs" );
	riotshield_door = generate_zombie_craftable_piece( craftable_name, "door", "t6_wpn_zmb_shield_dlc4_door", 48, 15, 25, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_door", 1, "build_zs" );
	riotshield_bracket = generate_zombie_craftable_piece( craftable_name, "bracket", "t6_wpn_zmb_shield_dlc4_bracket", 48, 15, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_clamp", 1, "build_zs" );
	riotshield = spawnstruct();
	riotshield.name = craftable_name;
	riotshield add_craftable_piece( riotshield_top );
	riotshield add_craftable_piece( riotshield_door );
	riotshield add_craftable_piece( riotshield_bracket );
	riotshield.onbuyweapon = ::onbuyweapon_riotshield;
	riotshield.triggerthink = ::riotshieldcraftable;
	include_craftable( riotshield );
	level thread add_craftable_cheat( riotshield );
	craftable_name = "elemental_staff_air";
	staff_air_gem = generate_zombie_craftable_piece( craftable_name, "gem", "t6_wpn_zmb_staff_crystal_air_part", 48, 64, 0, undefined, ::onpickup_aircrystal, ::ondrop_aircrystal, undefined, undefined, undefined, undefined, 2, 0, "crystal", 1 );
	staff_air_upper_staff = generate_zombie_craftable_piece( craftable_name, "upper_staff", "t6_wpn_zmb_staff_tip_air_world", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_ustaff_air", 1, "staff_part" );
	staff_air_middle_staff = generate_zombie_craftable_piece( craftable_name, "middle_staff", "t6_wpn_zmb_staff_stem_air_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_mstaff_air", 1, "staff_part" );
	staff_air_lower_staff = generate_zombie_craftable_piece( craftable_name, "lower_staff", "t6_wpn_zmb_staff_revive_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_lstaff_air", 1, "staff_part" );
	staff = spawnstruct();
	staff.name = craftable_name;
	staff add_craftable_piece( staff_air_gem );
	staff add_craftable_piece( staff_air_upper_staff );
	staff add_craftable_piece( staff_air_middle_staff );
	staff add_craftable_piece( staff_air_lower_staff );
	staff.triggerthink = ::staffcraftable_air;
	staff.custom_craftablestub_update_prompt = ::tomb_staff_update_prompt;
	include_zombie_craftable( staff );
	level thread add_craftable_cheat( staff );
	count_staff_piece_pickup( array( staff_air_upper_staff, staff_air_middle_staff, staff_air_lower_staff ) );
	craftable_name = "elemental_staff_fire";
	staff_fire_gem = generate_zombie_craftable_piece( craftable_name, "gem", "t6_wpn_zmb_staff_crystal_fire_part", 48, 64, 0, undefined, ::onpickup_firecrystal, ::ondrop_firecrystal, undefined, undefined, undefined, undefined, 1, 0, "crystal", 1 );
	staff_fire_upper_staff = generate_zombie_craftable_piece( craftable_name, "upper_staff", "t6_wpn_zmb_staff_tip_fire_world", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_ustaff_fire", 1, "staff_part" );
	staff_fire_middle_staff = generate_zombie_craftable_piece( craftable_name, "middle_staff", "t6_wpn_zmb_staff_stem_fire_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_mstaff_fire", 1, "staff_part" );
	staff_fire_lower_staff = generate_zombie_craftable_piece( craftable_name, "lower_staff", "t6_wpn_zmb_staff_revive_part", 64, 128, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_lstaff_fire", 1, "staff_part" );
	level thread maps/mp/zm_tomb_main_quest::staff_mechz_drop_pieces( staff_fire_lower_staff );
	level thread maps/mp/zm_tomb_main_quest::staff_biplane_drop_pieces( array( staff_fire_middle_staff ) );
	level thread maps/mp/zm_tomb_main_quest::staff_unlock_with_zone_capture( staff_fire_upper_staff );
	staff = spawnstruct();
	staff.name = craftable_name;
	staff add_craftable_piece( staff_fire_gem );
	staff add_craftable_piece( staff_fire_upper_staff );
	staff add_craftable_piece( staff_fire_middle_staff );
	staff add_craftable_piece( staff_fire_lower_staff );
	staff.triggerthink = ::staffcraftable_fire;
	staff.custom_craftablestub_update_prompt = ::tomb_staff_update_prompt;
	include_zombie_craftable( staff );
	level thread add_craftable_cheat( staff );
	count_staff_piece_pickup( array( staff_fire_upper_staff, staff_fire_middle_staff, staff_fire_lower_staff ) );
	craftable_name = "elemental_staff_lightning";
	staff_lightning_gem = generate_zombie_craftable_piece( craftable_name, "gem", "t6_wpn_zmb_staff_crystal_bolt_part", 48, 64, 0, undefined, ::onpickup_lightningcrystal, ::ondrop_lightningcrystal, undefined, undefined, undefined, undefined, 3, 0, "crystal", 1 );
	staff_lightning_upper_staff = generate_zombie_craftable_piece( craftable_name, "upper_staff", "t6_wpn_zmb_staff_tip_lightning_world", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_ustaff_lightning", 1, "staff_part" );
	staff_lightning_middle_staff = generate_zombie_craftable_piece( craftable_name, "middle_staff", "t6_wpn_zmb_staff_stem_bolt_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_mstaff_lightning", 1, "staff_part" );
	staff_lightning_lower_staff = generate_zombie_craftable_piece( craftable_name, "lower_staff", "t6_wpn_zmb_staff_revive_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_lstaff_lightning", 1, "staff_part" );
	staff = spawnstruct();
	staff.name = craftable_name;
	staff add_craftable_piece( staff_lightning_gem );
	staff add_craftable_piece( staff_lightning_upper_staff );
	staff add_craftable_piece( staff_lightning_middle_staff );
	staff add_craftable_piece( staff_lightning_lower_staff );
	staff.triggerthink = ::staffcraftable_lightning;
	staff.custom_craftablestub_update_prompt = ::tomb_staff_update_prompt;
	include_zombie_craftable( staff );
	level thread add_craftable_cheat( staff );
	count_staff_piece_pickup( array( staff_lightning_upper_staff, staff_lightning_middle_staff, staff_lightning_lower_staff ) );
	craftable_name = "elemental_staff_water";
	staff_water_gem = generate_zombie_craftable_piece( craftable_name, "gem", "t6_wpn_zmb_staff_crystal_water_part", 48, 64, 0, undefined, ::onpickup_watercrystal, ::ondrop_watercrystal, undefined, undefined, undefined, undefined, 4, 0, "crystal", 1 );
	staff_water_upper_staff = generate_zombie_craftable_piece( craftable_name, "upper_staff", "t6_wpn_zmb_staff_tip_water_world", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_ustaff_water", 1, "staff_part" );
	staff_water_middle_staff = generate_zombie_craftable_piece( craftable_name, "middle_staff", "t6_wpn_zmb_staff_stem_water_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_mstaff_water", 1, "staff_part" );
	staff_water_lower_staff = generate_zombie_craftable_piece( craftable_name, "lower_staff", "t6_wpn_zmb_staff_revive_part", 32, 64, 0, undefined, ::onpickup_staffpiece, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_staff_zm_lstaff_water", 1, "staff_part" );
	a_ice_staff_parts = array( staff_water_lower_staff, staff_water_middle_staff, staff_water_upper_staff );
	level thread maps/mp/zm_tomb_main_quest::staff_ice_dig_pieces( a_ice_staff_parts );
	staff = spawnstruct();
	staff.name = craftable_name;
	staff add_craftable_piece( staff_water_gem );
	staff add_craftable_piece( staff_water_upper_staff );
	staff add_craftable_piece( staff_water_middle_staff );
	staff add_craftable_piece( staff_water_lower_staff );
	staff.triggerthink = ::staffcraftable_water;
	staff.custom_craftablestub_update_prompt = ::tomb_staff_update_prompt;
	include_zombie_craftable( staff );
	level thread add_craftable_cheat( staff );
	count_staff_piece_pickup( array( staff_water_upper_staff, staff_water_middle_staff, staff_water_lower_staff ) );
	craftable_name = "gramophone";
	vinyl_pickup_player = vinyl_add_pickup( craftable_name, "vinyl_player", "p6_zm_tm_gramophone", "piece_record_zm_player", undefined, "gramophone" );
	vinyl_pickup_master = vinyl_add_pickup( craftable_name, "vinyl_master", "p6_zm_tm_record_master", "piece_record_zm_vinyl_master", undefined, "record" );
	vinyl_pickup_air = vinyl_add_pickup( craftable_name, "vinyl_air", "p6_zm_tm_record_wind", "piece_record_zm_vinyl_air", "quest_state2", "record" );
	vinyl_pickup_ice = vinyl_add_pickup( craftable_name, "vinyl_ice", "p6_zm_tm_record_ice", "piece_record_zm_vinyl_water", "quest_state4", "record" );
	vinyl_pickup_fire = vinyl_add_pickup( craftable_name, "vinyl_fire", "p6_zm_tm_record_fire", "piece_record_zm_vinyl_fire", "quest_state1", "record" );
	vinyl_pickup_elec = vinyl_add_pickup( craftable_name, "vinyl_elec", "p6_zm_tm_record_lightning", "piece_record_zm_vinyl_lightning", "quest_state3", "record" );
	vinyl_pickup_player.sam_line = "gramophone_found";
	vinyl_pickup_master.sam_line = "master_found";
	vinyl_pickup_air.sam_line = "first_record_found";
	vinyl_pickup_ice.sam_line = "first_record_found";
	vinyl_pickup_fire.sam_line = "first_record_found";
	vinyl_pickup_elec.sam_line = "first_record_found";
	level thread maps/mp/zm_tomb_vo::watch_one_shot_samantha_line( "vox_sam_1st_record_found_0", "first_record_found" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_samantha_line( "vox_sam_gramophone_found_0", "gramophone_found" );
	level thread maps/mp/zm_tomb_vo::watch_one_shot_samantha_line( "vox_sam_master_found_0", "master_found" );
	gramophone = spawnstruct();
	gramophone.name = craftable_name;
	gramophone add_craftable_piece( vinyl_pickup_player );
	gramophone add_craftable_piece( vinyl_pickup_master );
	gramophone add_craftable_piece( vinyl_pickup_air );
	gramophone add_craftable_piece( vinyl_pickup_ice );
	gramophone add_craftable_piece( vinyl_pickup_fire );
	gramophone add_craftable_piece( vinyl_pickup_elec );
	gramophone.triggerthink = ::gramophonecraftable;
	include_zombie_craftable( gramophone );
	level thread add_craftable_cheat( gramophone );
	staff_fire_gem thread watch_part_pickup( "quest_state1", 2 );
	staff_air_gem thread watch_part_pickup( "quest_state2", 2 );
	staff_lightning_gem thread watch_part_pickup( "quest_state3", 2 );
	staff_water_gem thread watch_part_pickup( "quest_state4", 2 );

	staff_gems = array(staff_fire_gem, staff_air_gem, staff_lightning_gem, staff_water_gem);
	level thread staff_gems_init(staff_gems);
	// staff_fire_gem thread staff_crystal_wait_for_teleport( 1 );
	// staff_air_gem thread staff_crystal_wait_for_teleport( 2 );
	// staff_lightning_gem thread staff_crystal_wait_for_teleport( 3 );
	// staff_water_gem thread staff_crystal_wait_for_teleport( 4 );
	level thread maps/mp/zm_tomb_vo::staff_craft_vo();
	level thread maps/mp/zm_tomb_vo::samantha_discourage_think();
	level thread maps/mp/zm_tomb_vo::samantha_encourage_think();
	level thread craftable_add_glow_fx();
}

staff_gems_init( staff_gems )
{
	level waittill( "player_teleported", e_player, n_teleport_enum );
	for(i = 0; i < 4; i++)
	{
		element = staff_gems[i];
		element thread staff_crystal_wait_for_teleport( i + 1 );
	}
}

staff_crystal_wait_for_teleport( n_element_enum ) //checked partially changed to match cerberus output changed at own discretion
{
	flag_init( "charger_ready_" + n_element_enum );
	self craftable_waittill_spawned();
	self.origin = self.piecespawn.model.origin;
	self.piecespawn.model ghost();
	self.piecespawn.model movez( -1000, 0.05 );
	e_plinth = getent( "crystal_plinth" + n_element_enum, "targetname" );
	e_plinth.v_start = e_plinth.origin;
	e_plinth.v_start = ( e_plinth.v_start[ 0 ], e_plinth.v_start[ 1 ], e_plinth.origin[ 2 ] - 78 );
	e_plinth.v_crystal = e_plinth.origin;
	e_plinth.v_crystal = ( e_plinth.v_crystal[ 0 ], e_plinth.v_crystal[ 1 ], e_plinth.origin[ 2 ] - 40 );
	e_plinth.v_staff = e_plinth.origin;
	e_plinth.v_staff = ( e_plinth.v_staff[ 0 ], e_plinth.v_staff[ 1 ], e_plinth.origin[ 2 ] + 15 );
	e_plinth moveto( e_plinth.v_start, 0,05 );
	e_plinth moveto( e_plinth.v_crystal, 6 );
	e_plinth thread sndmoveplinth( 6 );
	lookat_dot = cos( 90 );
	dist_sq = 250000;
	lookat_time = 0;
	while ( lookat_time < 1 && isDefined( self.piecespawn.model ) )
	{
		wait 0.1;
		if ( !isDefined( self.piecespawn.model ) )
		{
			continue;
		}
		if ( self.piecespawn.model any_player_looking_at_plinth( lookat_dot, dist_sq ) )
		{
			lookat_time += 0.1;
		}
		else
		{
			lookat_time = 0;
		}
	}
	if ( isDefined( self.piecespawn.model ) )
	{
		self.piecespawn.model movez( 985, 0.05 );
		self.piecespawn.model waittill( "movedone" );
		self.piecespawn.model show();
		self.piecespawn.model thread rotate_forever();
		self.piecespawn.model movez( 15, 2 );
		self.piecespawn.model playloopsound( "zmb_squest_crystal_loop", 4.25 );
	}
	flag_wait( "charger_ready_" + n_element_enum );
	while ( !maps/mp/zm_tomb_chamber::is_chamber_occupied() )
	{
		wait_network_frame();
	}
	e_plinth moveto( e_plinth.v_staff, 3 );
	e_plinth thread sndmoveplinth( 3 );
	e_plinth waittill( "movedone" );
}