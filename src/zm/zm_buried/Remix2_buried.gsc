#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_perks;

#include scripts/zm/remix/_debug;
#include scripts/zm/zm_buried/remix/_buried_ai_sloth;
#include scripts/zm/zm_buried/remix/_buried_buildables;
#include scripts/zm/zm_buried/remix/_buried_weapons;
#include scripts/zm/zm_buried/remix/_buried_zones;


main()
{
    replaceFunc( maps/mp/zombies/_zm_perks::give_random_perk, ::give_random_perk_override );

    level.initial_spawn_buried = true;
    level thread onplayerconnect();
	
	level thread spawn_turbine_bench( (457.209, -489, 8.125), ( 0, 0, 0 ) );
}

init()
{
	change_initial_spawnpoints();
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
    self.initial_spawn_buried = true;

    for(;;)
    {
        self waittill("spawned_player");

        if(self.initial_spawn_buried)
		{
            self.initial_spawn_buried = false;

			//debug
			// self thread print_origin();
			// self thread print_angles();
			// self thread teleport_players((-293.211, -1193.89, 187.517));
        }

        if(level.initial_spawn_buried)
        {
            level.initial_spawn_buried = false;

			remove_barricade_jug();
			buried_zone_changes();
			level thread override_sloth_damage_func();
        }
    }
}

change_initial_spawnpoints()
{
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( ( location == "default" || location == "" ) && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype + "_" + location;
	spawnpoints = [];
	structs = getstructarray( "initial_spawn", "script_noteworthy" );
	if ( isdefined( structs ) )
	{
		for ( i = 0; i < structs.size; i++ )
		{
			if ( isdefined( structs[ i ].script_string ) )
			{
				tokens = strtok( structs[ i ].script_string, " " );
				foreach ( token in tokens )
				{
					if ( token == match_string )
					{
						spawnpoints[ spawnpoints.size ] = structs[ i ];
					}
				}
			}
		}
	}
	// remove existing initial spawns
	array_delete(structs, true);
	level.struct_class_names["script_noteworthy"]["initial_spawn"] = [];
	// new initial spawns
	register_map_initial_spawnpoint( (-3094.58, -51.693, 1360.13), (0, -50, 0) );
	register_map_initial_spawnpoint( (-3099.5, -187.302, 1360.13), (0, -50, 0) );
	register_map_initial_spawnpoint( (-3075.48, -563.981, 1360.13), (0, 50, 0) );
	register_map_initial_spawnpoint( (-3082.85, -667.263, 1360.13), (0, 50, 0) );
}

register_map_initial_spawnpoint( origin, angles )
{
	spawnpoint_struct = spawnStruct();
	spawnpoint_struct.origin = origin;
	if ( isDefined( angles ) )
	{
		spawnpoint_struct.angles = angles;
	}
	else
	{
		spawnpoint_struct.angles = ( 0, 0, 0 );
	}
	spawnpoint_struct.radius = 32;
	spawnpoint_struct.script_noteworthy = "initial_spawn";
	spawnpoint_struct.script_string = getDvar( "g_gametype" ) + "_" + getDvar( "ui_zm_mapstartlocation" );
	spawnpoint_struct.locked = 0;
	player_respawn_point_size = level.struct_class_names[ "targetname" ][ "player_respawn_point" ].size;
	player_initial_spawnpoint_size = level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ].size;
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ][ player_respawn_point_size ] = spawnpoint_struct;
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ][ player_initial_spawnpoint_size ] = spawnpoint_struct;
}


/*
* *****************************************************
*	
* ********************* Overrides *********************
*
* *****************************************************
*/

give_random_perk_override() //checked partially changed to match cerberus output
{
	random_perk = undefined;
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	perks = [];
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ].script_noteworthy;
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		if ( perk == "specialty_weapupgrade" )
		{
			i++;
			continue;
		}
		if ( !self hasperk( perk ) && !self has_perk_paused( perk ) )
		{
			perks[ perks.size ] = perk;
		}
		i++;
	}
	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		random_perk = perks[ 0 ];
		while ( random_perk == "specialty_nomotionsensor" && perks.size > 1 )
		{
			perks = array_randomize( perks );
			random_perk = perks[ 0 ];
		}
		self give_perk( random_perk );
	}
	else
	{
		self playsoundtoplayer( level.zmb_laugh_alias, self );
	}
	return random_perk;
}