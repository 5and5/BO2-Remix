#include maps/mp/zombies/_zm_weap_time_bomb;
#include maps/mp/zombies/_zm_weap_slowgun;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/animscripts/zm_run;
#include maps/mp/animscripts/zm_death;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_equip_headchopper;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_ai_sloth;
#include maps/mp/zombies/_zm_ai_sloth_ffotd;
#include maps/mp/zombies/_zm_ai_sloth_utility;
#include maps/mp/zombies/_zm_ai_sloth_magicbox;
#include maps/mp/zombies/_zm_ai_sloth_crawler;
#include maps/mp/zombies/_zm_ai_sloth_buildables;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;


override_sloth_damage_func() {
    while(!isDefined(level.sloth)) {
        wait(1);
    }

    print("attaching new script to sloth");
    sloth = level.sloth;
    sloth.actor_damage_func = ::sloth_damage_func_custom;
}


sloth_damage_func_custom( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    iprintln("super ow");
// 	if ( sweapon == "equip_headchopper_zm" )
// 	{
// 		self.damageweapon_name = sweapon;
// 		self check_zombie_damage_callbacks( smeansofdeath, shitloc, vpoint, eattacker, idamage );
// 		self.damageweapon_name = undefined;
// 	}
// 	if ( isDefined( self.sloth_damage_func ) )
// 	{
// 		damage = self [[ self.sloth_damage_func ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
// 		return damage;
// 	}
// 	if ( smeansofdeath == level.slowgun_damage_mod && sweapon == "slowgun_zm" )
// 	{
// 		return 0;
// 	}
	if ( smeansofdeath == "MOD_MELEE" )
	{
		self sloth_leg_pain();
		return 0;
	}
// 	if ( self.state == "jail_idle" )
// 	{
// 		self stop_action();
// 		self sloth_set_state( "jail_cower" );
// 		maps/mp/zombies/_zm_unitrigger::register_unitrigger( self.gift_trigger, ::maps/mp/zombies/_zm_buildables::buildable_place_think );
// 		return 0;
// 	}
// 	if ( smeansofdeath != "MOD_EXPLOSIVE" && smeansofdeath != "MOD_EXPLOSIVE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_PROJECTILE" && smeansofdeath == "MOD_PROJECTILE_SPLASH" )
// 	{
// 		do_pain = self sloth_pain_react();
// 		self sloth_set_state( "jail_run", do_pain );
// 		return 0;
// 	}
// 	if ( !is_true( self.damage_accumulating ) )
// 	{
// 		self thread sloth_accumulate_damage( idamage );
// 	}
// 	else
// 	{
// 		self.damage_taken += idamage;
// 		self.num_hits++;
// 	}
	return 0;
}

sloth_leg_pain_custom() {

    // if(weapon == "bowie_knife_zm") {
    //     iprintln("Bowie Ow!");
    //     self.leg_pain_time = getTime() + 6000;
    // }
    // else if(weapon = "tazer_knuckles_zm") {
    //     iprintln("Taser ow!");
    //     self.leg_pain_time = getTime() + 8000;
    // }
    // else {
        iprintln("Ow!");
        self.leg_pain_time = getTime() + 4000;
    // }
}