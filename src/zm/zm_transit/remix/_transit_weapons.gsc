#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#include scripts/zm/remix/_weapons;

spawn_custom_wallbuys()
{
	location = level.scr_zm_map_start_location;

	if ( location == "town" )
	{
		spawn_wallbuy_weapon( ( 0, 0, 0 ), (550, -1363, 168), "claymore_zm_fx", "claymore_zm", "t6_wpn_claymore_world", "claymore", "weapon_upgrade" );

		for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
		{
			if(IsDefined(level._unitriggers.trigger_stubs[i].zombie_weapon_upgrade) && level._unitriggers.trigger_stubs[i].zombie_weapon_upgrade == "rottweil72_zm")
			{
				origin = level._unitriggers.trigger_stubs[i].origin;
			}
		}
		spawn_wallbuy_weapon( ( 0, 90, 0 ), origin, "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5k", "weapon_upgrade" );
		remove_wallbuy( "rottweil72_zm" );
	}
	else if ( location == "farm" )
	{
		spawn_wallbuy_weapon( ( 0, 90, 0 ), (8826, -5777, 105), "claymore_zm_fx", "claymore_zm", "t6_wpn_claymore_world", "claymore", "weapon_upgrade" );
	}
	else if ( location == "transit" && !is_classic() )
	{

	}
}

remove_wallbuy( name )
{
	// if ( level.scr_zm_map_start_location != map )
	// 	return;
	// spawnable_weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );
	// for(i = 0; i < spawnable_weapon_spawns.size; i++)
	// {
	// 	if( spawnable_weapon_spawns[i].zombie_weapon_upgrade == name )
	// 	{
	// 		spawnable_weapon_spawns[i].model delete();
	// 	}
	// }

	for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
	{
		if(IsDefined(level._unitriggers.trigger_stubs[i].zombie_weapon_upgrade) && level._unitriggers.trigger_stubs[i].zombie_weapon_upgrade == name)
		{
			maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( level._unitriggers.trigger_stubs[i] );
		}
	}
}

add_wallbuy( name )
{
	struct = undefined;
	spawnable_weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "bowie_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "sickle_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "tazer_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "buildable_wallbuy", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "claymore_purchase", "targetname" ), 1, 0 );
	for(i = 0; i < spawnable_weapon_spawns.size; i++)
	{
		if(IsDefined(spawnable_weapon_spawns[i].zombie_weapon_upgrade) && spawnable_weapon_spawns[i].zombie_weapon_upgrade == name)
		{
			struct = spawnable_weapon_spawns[i];
			break;
		}
	}

	if(!IsDefined(struct))
	{
		return;
	}

	target_struct = getstruct( struct.target, "targetname" );
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = struct.origin;
	unitrigger_stub.angles = struct.angles;

	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );
	tempmodel setmodel( target_struct.model );
	tempmodel useweaponhidetags( struct.zombie_weapon_upgrade );
	mins = tempmodel getmins();
	maxs = tempmodel getmaxs();
	absmins = tempmodel getabsmins();
	absmaxs = tempmodel getabsmaxs();
	bounds = absmaxs - absmins;
	tempmodel delete();
	unitrigger_stub.script_length = 64;
	unitrigger_stub.script_width = bounds[1];
	unitrigger_stub.script_height = bounds[2];

	unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( ( bounds[0] * 0.25 ) * 0.4 );
	unitrigger_stub.target = struct.target;
	unitrigger_stub.targetname = struct.targetname;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	if ( struct.targetname == "weapon_upgrade" )
	{
		unitrigger_stub.cost = maps/mp/zombies/_zm_weapons::get_weapon_cost( struct.zombie_weapon_upgrade );
		if ( isDefined( level.monolingustic_prompt_format ) && !level.monolingustic_prompt_format )
		{
			unitrigger_stub.hint_string = maps/mp/zombies/_zm_weapons::get_weapon_hint( struct.zombie_weapon_upgrade );
			unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
			return;
		}
		else
		{
			unitrigger_stub.hint_parm1 = maps/mp/zombies/_zm_weapons::get_weapon_display_name( struct.zombie_weapon_upgrade );
			if ( isDefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" && unitrigger_stub.hint_parm1 == "none" )
			{
				unitrigger_stub.hint_parm1 = "missing weapon name " + struct.zombie_weapon_upgrade;
			}
			unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
			unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
		}
	}
	unitrigger_stub.weapon_upgrade = struct.zombie_weapon_upgrade;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
	if ( isDefined( struct.require_look_from ) && struct.require_look_from )
	{
		unitrigger_stub.require_look_from = 1;
	}
	unitrigger_stub.zombie_weapon_upgrade = struct.zombie_weapon_upgrade;

	//unitrigger_stub.clientfieldname = clientfieldname;
	unitrigger_stub.clientfieldname = undefined;
	model = spawn( "script_model", struct.origin );
	//model.angles = struct.angles;
	model.angles = struct.angles + (0, 90, 0);
	//model.targetname = struct.target;
	model setmodel( target_struct.model );
	model useweaponhidetags( struct.zombie_weapon_upgrade );
	//model hide();

	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( is_melee_weapon( unitrigger_stub.zombie_weapon_upgrade ) )
	{
		if ( unitrigger_stub.zombie_weapon_upgrade == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
		{
			unitrigger_stub.origin += level.taser_trig_adjustment;
		}
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps/mp/zombies/_zm_weapons::weapon_spawn_think );
	}
	else if ( unitrigger_stub.zombie_weapon_upgrade == "claymore_zm" )
	{
		unitrigger_stub.prompt_and_visibility_func = maps/mp/zombies/_zm_weap_claymore::claymore_unitrigger_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps/mp/zombies/_zm_weap_claymore::buy_claymores );
		//model thread claymore_rotate_model_when_bought();
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = maps/mp/zombies/_zm_weapons::wall_weapon_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps/mp/zombies/_zm_weapons::weapon_spawn_think );
	}
	struct.trigger_stub = unitrigger_stub;
}