#include common_scripts/utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades_functions;

give_perma_perks()
{
	flag_wait("initial_blackscreen_passed");
	permaperks = strTok("pers_revivenoperk,pers_insta_kill,pers_jugg,pers_sniper_counter,pers_flopper_counter,pers_perk_lose_counter,pers_box_weapon_counter,pers_multikill_headshots", ",");
	for (i = 0; i < permaperks.size; i++)
	{
		self increment_client_stat(permaperks[i], 0);
		wait 0.25;
	}
}

give_bank_fridge()
{
	flag_wait("initial_blackscreen_passed");
	self set_map_stat("depositBox", 250, level.banking_map);
	self.account_value = 250000;

	self clear_stored_weapondata();
	self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "an94_upgraded_zm+mms" ); //setting new weapon
	self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 50 );
	self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 600 );
}

pers_nube_should_we_give_raygun( player_has_weapon, player, weapon_buy ) //checked partially changed to match cerberus output //changed at own discretion
{
	if ( !maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active() )
	{
		return player_has_weapon;
	}
	if ( player.pers[ "pers_max_round_reached" ] >= level.pers_nube_lose_round )
	{
		return player_has_weapon;
	}
	if ( isDefined( weapon_buy ) && getsubstr( weapon_buy, 0, 11 ) != "rottweil72_" )
	{
		return player_has_weapon;
	}
	if ( player hasweapon( "rottweil72_zm" ) || player hasweapon( "rottweil72_upgraded_zm" ) )
	{
		player_has_olympia = 1;
	}
	if ( player hasweapon( "ray_gun_zm" ) || player hasweapon( "ray_gun_upgraded_zm" ) )
	{
		player_has_raygun = 1;
	}
	if ( player_has_olympia && player_has_raygun )
	{
		player_has_weapon = 1;
	}
	else if ( is_true( player.pers_upgrades_awarded[ "nube" ] ) && player_has_raygun )
	{
		player_has_weapon = 1;
	}
	return player_has_weapon;
}