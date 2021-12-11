#include maps/mp/zombies/_zm_utility;

extra_perk_spawns() //custom function
{
	location = level.scr_zm_map_start_location;

	if ( location == "town" )
	{
		level.townPerkArray = array( "specialty_fastreload" );

		level.townPerks[ "specialty_fastreload" ] = spawnstruct();
		level.townPerks[ "specialty_fastreload" ].origin = (1776, -1130, -55);
		level.townPerks[ "specialty_fastreload" ].angles = ( 0, 270, 0 );
		level.townPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.townPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	}
	else if ( location == "farm" )
	{
		level.farmPerkArray = array( "specialty_weapupgrade" );

		level.farmPerks["specialty_weapupgrade"] = spawnstruct();
		level.farmPerks["specialty_weapupgrade"].origin = (7057, -5727, -49);
		level.farmPerks["specialty_weapupgrade"].angles = (0,90,0);
		level.farmPerks["specialty_weapupgrade"].model = "p6_anim_zm_buildable_pap_on";
		level.farmPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";
	}
	else if ( location == "transit" && !is_classic() )
	{
		level.busPerkArray = array( "specialty_quickrevive", "specialty_weapupgrade" );
		level.zombiemode_using_revive_perk = 1;
		
		level.busPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.busPerks[ "specialty_quickrevive" ].origin = (-6706, 5016, -56);
		level.busPerks[ "specialty_quickrevive" ].angles = (0, 180, 0 );
		level.busPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
		level.busPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		level.busPerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.busPerks[ "specialty_weapupgrade" ].origin = (-6834, 4553, -65);
		level.busPerks[ "specialty_weapupgrade" ].angles = (0,230,0);
		level.busPerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
		level.busPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	}
}