#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_weap_tomahawk;

main()
{
    replaceFunc( maps/mp/zm_prison::include_weapons, ::include_weapons_override );
	replaceFunc( maps/mp/zm_alcatraz_sq::setup_master_key, ::setup_master_key );
	replaceFunc( maps/mp/zombies/_zm_weap_tomahawk::tomahawk_attack_zombies, ::tomahawk_attack_zombies_override );

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

tomahawk_attack_zombies_override( m_tomahawk, a_zombies ) //checked changed to match cerberus output
{
	self endon( "disconnect" );

	max_attack_limit = 6;
	if ( !isDefined( a_zombies ) )
	{
		self thread tomahawk_return_player( m_tomahawk, 0 );
		return;
	}
	if ( a_zombies.size <= max_attack_limit )
	{
		n_attack_limit = a_zombies.size;
	}
	else
	{
		n_attack_limit = max_attack_limit;
	}
	for ( i = 0; i < n_attack_limit; i++ )
	{
		if ( isDefined( a_zombies[ i ] ) && isalive( a_zombies[ i ] ) )
		{
			tag = "J_Head";
			if ( a_zombies[ i ].isdog )
			{
				tag = "J_Spine1";
			}
			if ( isDefined( a_zombies[ i ].hit_by_tomahawk ) && !a_zombies[ i ].hit_by_tomahawk )
			{
				v_target = a_zombies[ i ] gettagorigin( tag );
				m_tomahawk moveto( v_target, 0.3 );
				m_tomahawk waittill( "movedone" );
				if ( isDefined( a_zombies[ i ] ) && isalive( a_zombies[ i ] ) )
				{
					if ( self.current_tactical_grenade == "upgraded_tomahawk_zm" )
					{
						playfxontag( level._effect[ "tomahawk_impact_ug" ], a_zombies[ i ], tag );
					}
					else
					{
						playfxontag( level._effect[ "tomahawk_impact" ], a_zombies[ i ], tag );
					}
					playfxontag( level._effect[ "tomahawk_fire_dot" ], a_zombies[ i ], "j_spineupper" );
					a_zombies[ i ] setclientfield( "play_tomahawk_hit_sound", 1 );
					n_tomahawk_damage = calculate_tomahawk_damage( a_zombies[ i ], m_tomahawk.n_grenade_charge_power, m_tomahawk );
					a_zombies[ i ] dodamage( n_tomahawk_damage, m_tomahawk.origin, self, m_tomahawk, "none", "MOD_GRENADE", 0, "bouncing_tomahawk_zm" );
					a_zombies[ i ].hit_by_tomahawk = 1;
					self maps/mp/zombies/_zm_score::add_to_player_score( 10 );
				}
			}
		}
		wait 0.2;
	}
	self thread tomahawk_return_player( m_tomahawk, n_attack_limit );
}