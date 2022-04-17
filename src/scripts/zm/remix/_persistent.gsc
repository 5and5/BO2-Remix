#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades_functions;

set_persistent_stats()
{
	if( !isVictisMap() )
		return;
	
	flag_wait("initial_blackscreen_passed");

	set_perma_perks();
	set_bank_points();
	set_fridge_weapon();
}

set_perma_perks() // Huthtv
{
	persistent_upgrades = array("pers_revivenoperk", "pers_multikill_headshots", "pers_insta_kill", "pers_jugg", "pers_perk_lose_counter", "pers_sniper_counter", "pers_box_weapon_counter", "pers_nube_counter");

	persistent_upgrade_values = [];
	persistent_upgrade_values["pers_revivenoperk"] = 17;
	persistent_upgrade_values["pers_multikill_headshots"] = 5;
	persistent_upgrade_values["pers_insta_kill"] = 2;
	persistent_upgrade_values["pers_jugg"] = 3;
	persistent_upgrade_values["pers_perk_lose_counter"] = 3;
	persistent_upgrade_values["pers_sniper_counter"] = 1;
	persistent_upgrade_values["pers_box_weapon_counter"] = 5;
	persistent_upgrade_values["pers_flopper_counter"] = 1;
	persistent_upgrade_values["pers_nube_counter"] = 1;
	if(level.script == zm_buried)
		persistent_upgrades = combinearrays(persistent_upgrades, array("pers_flopper_counter"));

	foreach(pers_perk in persistent_upgrades)
	{
		upgrade_value = self getdstat("playerstatslist", pers_perk, "StatValue");
		if(upgrade_value != persistent_upgrade_values[pers_perk])
		{
			maps/mp/zombies/_zm_stats::set_client_stat(pers_perk, persistent_upgrade_values[pers_perk]);
		}	
	}
}

set_bank_points()
{
	if(self.account_value < 250)
	{
		self maps/mp/zombies/_zm_stats::set_map_stat("depositBox", 250, level.banking_map);
		self.account_value = 250;
	}
}

set_fridge_weapon()
{
	self clear_stored_weapondata();
	if( level.script == "zm_highrise" )
	{
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "an94_upgraded_zm+mms" );
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 600 );
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 50 );
	}
	else if ( level.script == "zm_transit" || level.script == "zm_buried" )
	{
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "m32_upgraded_zm" );
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 48 );
		self setdstat( "PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 6 );
	}
}

isVictisMap()
{
	switch(level.script)
	{
		case "zm_transit":
		case "zm_highrise":
		case "zm_buried":
			return true;
		default:
			return false;
	}	
}

pers_nube_should_we_give_raygun_override( player_has_weapon, player, weapon_buy ) //checked partially changed to match cerberus output //changed at own discretion
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