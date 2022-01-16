#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

disable_screechers()
{
	level.is_player_in_screecher_zone = ::is_player_in_screencher_zone;
}

is_player_in_screencher_zone()
{
	return 0;
}

spawn_maxammo_on_avogadro_death()
{
	level waittill( "avogadro_defeated" );
}
