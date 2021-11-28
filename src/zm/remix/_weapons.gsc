#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_melee_weapon;

wallbuy_increase_trigger_radius()
{
	for(i = 0; i < level._unitriggers.trigger_stubs.size; i++)
	{
		if(IsDefined(level._unitriggers.trigger_stubs[i].zombie_weapon_upgrade))
		{
			level._unitriggers.trigger_stubs[i].script_length = 96;
		}
	}
}

wallbuy_dynamic_increase_trigger_radius()
{
	if(!(is_classic() && level.scr_zm_map_start_location == "processing"))
	{
		return;
	}

	while (!isDefined(level.built_wallbuys))
	{
		wait 0.5;
	}

	prev_built_wallbuys = 0;

	while (1)
	{
		if (level.built_wallbuys > prev_built_wallbuys)
		{
			prev_built_wallbuys = level.built_wallbuys;
			wallbuy_increase_trigger_radius();
		}

		if (level.built_wallbuys == -100)
		{
			wallbuy_increase_trigger_radius();
			return;
		}

		wait 0.5;
	}
}

spawn_wallbuy_weapon( weapon_angles, weapon_coordinates, chalk_fx, weapon_name, weapon_model, target, targetname )
{
	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );
	precachemodel( weapon_model );
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = weapon_coordinates;
	unitrigger_stub.angles = weapon_angles;
	tempmodel.origin = weapon_coordinates;
	tempmodel.angles = weapon_angles;
	mins = undefined;
	maxs = undefined;
	absmins = undefined;
	absmaxs = undefined;
	tempmodel setmodel( weapon_model );
	tempmodel useweaponhidetags( weapon_name );
	mins = tempmodel getmins();
	maxs = tempmodel getmaxs();
	absmins = tempmodel getabsmins();
	absmaxs = tempmodel getabsmaxs();
	bounds = absmaxs - absmins;
	unitrigger_stub.script_length = bounds[ 0 ] * 0.25;
	unitrigger_stub.script_width = bounds[ 1 ];
	unitrigger_stub.script_height = bounds[ 2 ];
	unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
	unitrigger_stub.target = target;
	unitrigger_stub.targetname = targetname;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	if ( unitrigger_stub.targetname == "weapon_upgrade" )
	{
		unitrigger_stub.cost = get_weapon_cost( weapon_name );
		if ( !is_true( level.monolingustic_prompt_format ) )
		{
			unitrigger_stub.hint_string = get_weapon_hint( weapon_name );
			unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
		}
		else
		{
			unitrigger_stub.hint_parm1 = get_weapon_display_name( weapon_name );
			if ( !isDefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" || unitrigger_stub.hint_parm1 == "none" )
			{
				unitrigger_stub.hint_parm1 = "missing weapon name " + weapon_name;
			}
			unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
			unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
		}
	}
	unitrigger_stub.weapon_upgrade = weapon_name;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
	unitrigger_stub.require_look_from = 0;
	unitrigger_stub.zombie_weapon_upgrade = weapon_name;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( is_melee_weapon( weapon_name ) )
	{
		if ( weapon_name == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
		{
			unitrigger_stub.origin += level.taser_trig_adjustment;
		}
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::melee_weapon_think );
	}
	else if ( weapon_name == "claymore_zm" )
	{
		unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buy_claymores );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
	}
	tempmodel delete();
    thread playchalkfx( chalk_fx, weapon_coordinates, weapon_angles );
}

playchalkfx( effect, origin, angles ) //custom function
{
	while ( 1 )
	{
		fx = SpawnFX( level._effect[ effect ], origin, AnglesToForward( angles ), AnglesToUp( angles ) );
		TriggerFX( fx );
		level waittill( "connected", player );
		fx Delete();
	}
}