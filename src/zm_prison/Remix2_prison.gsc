#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_weapons;

main()
{
    replaceFunc( maps/mp/zm_prison::include_weapons, ::include_weapons_override );
	replaceFunc( maps/mp/zm_alcatraz_sq::setup_master_key, ::setup_master_key );

    level.initial_spawn_prison = true;
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
    self.initial_spawn_prison = true;
    
    for(;;)
    {
        self waittill("spawned_player");

        if(self.initial_spawn_prison)
		{
            self.initial_spawn_prison = true;
        }

        if(level.initial_spawn_prison)
        {
            level.initial_spawn_prison = false;
        }
    }
}

include_weapons_override() //checked changed to match cerberus output
{
	include_weapon( "knife_zm", 0 );
	include_weapon( "knife_zm_alcatraz", 0 );
	include_weapon( "spoon_zm_alcatraz", 0 );
	include_weapon( "spork_zm_alcatraz", 0 );
	include_weapon( "frag_grenade_zm", 0 );
	include_weapon( "claymore_zm", 0 );
	include_weapon( "willy_pete_zm", 0 );
	include_weapon( "m1911_zm", 0 );
	include_weapon( "m1911_upgraded_zm", 0 );
	include_weapon( "judge_zm" );
	include_weapon( "judge_upgraded_zm", 0 );
	include_weapon( "beretta93r_zm", 0 );
	include_weapon( "beretta93r_upgraded_zm", 0 );
	include_weapon( "fivesevendw_zm" );
	include_weapon( "fivesevendw_upgraded_zm", 0 );
	include_weapon( "fivesevendw_zm" );
	include_weapon( "fivesevendw_upgraded_zm", 0 );
	include_weapon( "uzi_zm", 0 );
	include_weapon( "uzi_upgraded_zm", 0 );
	if ( is_classic() )
	{
		include_weapon( "thompson_zm", 0 );
		include_weapon( "870mcs_zm", 0 );
	}
	else
	{
		include_weapon( "870mcs_zm" );
		include_weapon( "thompson_zm" );
	}
	include_weapon( "thompson_upgraded_zm", 0 );
	include_weapon( "mp5k_zm", 0 );
	include_weapon( "mp5k_upgraded_zm", 0 );
	include_weapon( "pdw57_zm" );
	include_weapon( "pdw57_upgraded_zm", 0 );
	include_weapon( "870mcs_upgraded_zm", 0 );
	include_weapon( "saiga12_zm" );
	include_weapon( "saiga12_upgraded_zm", 0 );
	include_weapon( "rottweil72_zm", 0 );
	include_weapon( "rottweil72_upgraded_zm", 0 );
	include_weapon( "m14_zm", 0 );
	include_weapon( "m14_upgraded_zm", 0 );
	include_weapon( "ak47_zm" );
	include_weapon( "ak47_upgraded_zm", 0 );
	include_weapon( "tar21_zm" );
	include_weapon( "tar21_upgraded_zm", 0 );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", 0 );
	include_weapon( "fnfal_zm" );
	include_weapon( "fnfal_upgraded_zm", 0 );
	include_weapon( "dsr50_zm" );
	include_weapon( "dsr50_upgraded_zm", 0 );
	include_weapon( "barretm82_zm" );
	include_weapon( "barretm82_upgraded_zm", 0 );
	include_weapon( "minigun_alcatraz_zm" );
	include_weapon( "minigun_alcatraz_upgraded_zm", 0 );
	include_weapon( "lsat_zm" );
	include_weapon( "lsat_upgraded_zm", 0 );
	include_weapon( "usrpg_zm" );
	include_weapon( "usrpg_upgraded_zm", 0 );
	include_weapon( "ray_gun_zm" );
	include_weapon( "ray_gun_upgraded_zm", 0 );
	include_weapon( "bouncing_tomahawk_zm", 0 );
	include_weapon( "upgraded_tomahawk_zm", 0 );
	include_weapon( "blundergat_zm" );
	include_weapon( "blundergat_upgraded_zm", 0 );
	include_weapon( "blundersplat_zm", 0 );
	include_weapon( "blundersplat_upgraded_zm", 0 );
	level._uses_retrievable_ballisitic_knives = 1;
	include_weapon( "alcatraz_shield_zm", 0 );
	add_limited_weapon( "m1911_zm", 4 );
	add_limited_weapon( "minigun_alcatraz_zm", 1 );
	//add_limited_weapon( "blundergat_zm", 1 );
	add_limited_weapon( "ray_gun_zm", 4 );
	add_limited_weapon( "ray_gun_upgraded_zm", 4 );
	include_weapon( "tower_trap_zm", 0 );
	include_weapon( "tower_trap_upgraded_zm", 0 );
	if ( isdefined( level.raygun2_included ) && level.raygun2_included )
	{
		include_weapon( "raygun_mark2_zm" );
		include_weapon( "raygun_mark2_upgraded_zm", 0 );
		add_weapon_to_content( "raygun_mark2_zm", "dlc3" );
		add_limited_weapon( "raygun_mark2_zm", 1);
		add_limited_weapon( "raygun_mark2_upgraded_zm", 1 );
	}
}

setup_master_key()
{
	level.is_master_key_west = 0;
	setclientfield( "fake_master_key", level.is_master_key_west + 1 );
	if ( level.is_master_key_west )
	{
		level thread maps/mp/zm_alcatraz_sq::key_pulley( "west" );
		exploder( 101 );
		array_delete( getentarray( "wires_pulley_east", "script_noteworthy" ) );
	}
	else
	{
		level thread maps/mp/zm_alcatraz_sq::key_pulley( "east" );
		exploder( 100 );
		array_delete( getentarray( "wires_pulley_west", "script_noteworthy" ) );
	}
}