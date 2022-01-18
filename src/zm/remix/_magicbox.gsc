#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_magicbox;

set_startings_chests()
{
	switch(level.scr_zm_map_start_location)
	{
		case "tomb":
			start_chest = "bunker_tank_chest";
			break;
		case "prison":
			start_chest = "cafe_chest";
			break;
		case "town":
			start_chest = "town_chest_2";
			break;
		default:
			return;
			break;
	}

	for(i = 0; i < level.chests.size; i++)
	{
        if(level.chests[i].script_noteworthy == start_chest)
    		desired_chest_index = i; 
        else if(level.chests[i].hidden == 0)
     		nondesired_chest_index = i;               	
	}

	if( isdefined(nondesired_chest_index) && (nondesired_chest_index < desired_chest_index))
	{
		level.chests[nondesired_chest_index] hide_chest();
		level.chests[nondesired_chest_index].hidden = 1;

		level.chests[desired_chest_index].hidden = 0;
		level.chests[desired_chest_index] show_chest();
		level.chest_index = desired_chest_index;
	}
}

raygun_mark2_probabilty()
{
    level.special_weapon_magicbox_check = ::custom_special_weapon_magicbox_check;
}

custom_special_weapon_magicbox_check( weapon ) {

    map = getDvar("mapname");
    
    if ( weapon == "ray_gun_zm" )
	{
		if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) )
		{
			return 0;
		}
	}
	if ( weapon == "raygun_mark2_zm" )
	{
		if ( self has_weapon_or_upgrade( "ray_gun_zm" ) )
		{
			return 0;
		}

		// Always give Mark2 until the box moves for first time
		if ( level.chest_moves == 0 )
		{
			return 1;
		}

        // Buried has Mark 2 weighted equally to all others
        if( map == "zm_buried") {
            return 1;
        }
        
        // (# of weapons in box) * .5 = (odds of getting Mark 2 from box)
        // Not as even as every other weapon, but more probable than it already was
        if (randomint (100) >= 50) {
            return 0;
        }
	}


    if(map == "zm_prison") {
        return alcatraz_special_weapon_check(weapon);
    }
    else if( map == "zm_buried") {
        return buried_special_weapon_check(weapon);
    }
    else if(map == "zm_tomb") {
        return tomb_special_weapon_check(weapon);
    }

    return 1;
}

buried_special_weapon_check(weapon) {
    if ( weapon == "time_bomb_zm" )
    {
        players = get_players();
        i = 0;
        while ( i < players.size )
        {
            if ( is_player_valid( players[ i ], undefined, 1 ) && players[ i ] is_player_tactical_grenade( weapon ) )
            {
                return 0;
            }
            i++;
        }
    }
    return 1;
}

alcatraz_special_weapon_check(weapon) {

	return 1;
    // if ( weapon != "blundergat_zm" && weapon != "minigun_alcatraz_zm" )
    // {
    //     return 1;
    // }
    // players = get_players();
    // count = 0;
    // if ( weapon == "blundergat_zm" )
    // {
    //     if ( self maps/mp/zombies/_zm_weapons::has_weapon_or_upgrade( "blundersplat_zm" ) )
    //     {
    //         return 0;
    //     }
    //     if ( self afterlife_weapon_limit_check( "blundergat_zm" ) )
    //     {
    //         return 0;
    //     }
    //     limit = level.limited_weapons[ "blundergat_zm" ];
    // }
    // else
    // {
    //     if ( self afterlife_weapon_limit_check( "minigun_alcatraz_zm" ) )
    //     {
    //         return 0;
    //     }
    //     limit = level.limited_weapons[ "minigun_alcatraz_zm" ];
    // }
    // i = 0;
    // while ( i < players.size )
    // {
    //     if ( weapon == "blundergat_zm" )
    //     {
    //         if ( players[ i ] has_weapon_or_upgrade( "blundersplat_zm" ) || isDefined( players[ i ].is_pack_splatting ) && players[ i ].is_pack_splatting )
    //         {
    //             count++;
    //             i++;
    //             continue;
    //         }
    //     }
    //     else
    //     {
    //         if ( players[ i ] afterlife_weapon_limit_check( weapon ) )
    //         {
    //             count++;
    //         }
    //     }
    //     i++;
    // }
    // if ( count >= limit )
    // {
    //     return 0;
    // }
    // return 1;
}

tomb_special_weapon_check(weapon) {
    if ( weapon == "beacon_zm" )
    {
        if ( isDefined( self.beacon_ready ) && self.beacon_ready )
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    if ( isDefined( level.zombie_weapons[ weapon ].shared_ammo_weapon ) )
    {
        if ( self has_weapon_or_upgrade( level.zombie_weapons[ weapon ].shared_ammo_weapon ) )
        {
            return 0;
        }
    }
    return 1;
}

afterlife_weapon_limit_check( limited_weapon )
{
	while ( isDefined( self.afterlife ) && self.afterlife )
	{
		if ( limited_weapon == "blundergat_zm" )
		{
			_a1577 = self.loadout;
			_k1577 = getFirstArrayKey( _a1577 );
			while ( isDefined( _k1577 ) )
			{
				weapon = _a1577[ _k1577 ];
				if ( weapon != "blundergat_zm" && weapon != "blundergat_upgraded_zm" || weapon == "blundersplat_zm" && weapon == "blundersplat_upgraded_zm" )
				{
					return 1;
				}
				_k1577 = getNextArrayKey( _a1577, _k1577 );
			}
		}
		else while ( limited_weapon == "minigun_alcatraz_zm" )
		{
			_a1587 = self.loadout;
			_k1587 = getFirstArrayKey( _a1587 );
			while ( isDefined( _k1587 ) )
			{
				weapon = _a1587[ _k1587 ];
				if ( weapon == "minigun_alcatraz_zm" || weapon == "minigun_alcatraz_upgraded_zm" )
				{
					return 1;
				}
				_k1587 = getNextArrayKey( _a1587, _k1587 );
			}
		}
	}
	return 0;
}

