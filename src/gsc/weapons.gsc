// Check if weapon box has picked can actually be received by player.
// Note Mark 2 gets weighted in this function instead of in chooseweightedrandomweapon()
// likey because Treyarch didn't want to add duplicate keys for every weapon except mark 2.

register_weapon_mods() {
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


    if(map == "zm_alcatraz") {
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
    while ( weapon == "time_bomb_zm" )
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
}

alcatraz_special_weapon_check(weapon) {

    if ( weapon != "blundergat_zm" && weapon != "minigun_alcatraz_zm" )
    {
        return 1;
    }
    players = get_players();
    count = 0;
    if ( weapon == "blundergat_zm" )
    {
        if ( self maps/mp/zombies/_zm_weapons::has_weapon_or_upgrade( "blundersplat_zm" ) )
        {
            return 0;
        }
        if ( self afterlife_weapon_limit_check( "blundergat_zm" ) )
        {
            return 0;
        }
        limit = level.limited_weapons[ "blundergat_zm" ];
    }
    else
    {
        if ( self afterlife_weapon_limit_check( "minigun_alcatraz_zm" ) )
        {
            return 0;
        }
        limit = level.limited_weapons[ "minigun_alcatraz_zm" ];
    }
    i = 0;
    while ( i < players.size )
    {
        if ( weapon == "blundergat_zm" )
        {
            if ( players[ i ] has_weapon_or_upgrade( "blundersplat_zm" ) || isDefined( players[ i ].is_pack_splatting ) && players[ i ].is_pack_splatting )
            {
                count++;
                i++;
                continue;
            }
        }
        else
        {
            if ( players[ i ] afterlife_weapon_limit_check( weapon ) )
            {
                count++;
            }
        }
        i++;
    }
    if ( count >= limit )
    {
        return 0;
    }
    return 1;
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

// To my knowledge, there is no good way to #include a file 
// that is part of a different map than the one we're playing, so we unfortunately
// have to bring an extra function we don't need to change
// in order to keep MOTD's weapon limit checks in place
// until we decide to fine tune this logic later
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