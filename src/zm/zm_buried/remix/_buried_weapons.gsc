#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

#include scripts/zm/remix/_weapons;

spawn_semtex_wallbuy()
{
 	// spawn_wallbuy_weapon( ( 0, 90, 0 ), (204.874, -735.33, 30.2423), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5k", "weapon_upgrade" );
    spawn_wallbuy_weapon( ( 0, 270, 0 ), (129, -739.5, 40), "tazer_knuckles_zm_fx", "frag_grenade_zm", "t6_wpn_claymore_world", "frag_grenade", "weapon_upgrade" );
    // spawn_wallbuy_weapon( ( 0, 180, 0 ), (204.874, -735.33, 30.2423), "sticky_grenade_zm_fx", "sticky_grenade_zm", "t6_wpn_grenade_sticky_grenade_world", "sticky_grenade", "weapon_upgrade" );
}