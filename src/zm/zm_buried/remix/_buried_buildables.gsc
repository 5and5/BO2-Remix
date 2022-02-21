#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;


spawn_turbine_bench( origin, angles )
{
	level endon("end_game");
	level endon("disconnect");

	precachemodel( "collision_clip_64x64x64" );
	bench = spawn("script_model", origin);
	bench SetModel("p6_zm_work_bench");
	bench.angles = angles;
	col = spawn("script_model", origin + (15, 0, 0));
	col SetModel("collision_clip_64x64x64");
	col.angles = angles;
	shieldModel = spawn("script_model", origin + ( 0, 0, 44 ) );
	shieldModel SetModel("p6_zm_buildable_turbine_mannequin");
	shieldModel.angles = ( angles + vectorScale( ( 0, 0, 0 ), 90 ) );
	trigger = spawn("trigger_radius", origin + (0,0,32), 20, 35, 70);
	trigger.targetname = "shield_trigger";
	trigger.angles = angles;
	trigger SetCursorHint("HINT_NOICON");
	trigger SetHintString("Hold ^3&&1^7 for Turbine");
	wait 5;
	level thread update_hint_string( trigger );
	while( 1 )
	{
		trigger waittill( "trigger", player );
		if( player UseButtonPressed() )
		{
			if( !player hasWeapon( "equip_turbine_zm" ) )
			{
				player maps/mp/zombies/_zm_equipment::equipment_buy( "equip_turbine_zm" );
			}
		}
		wait 0.1;
	}
}

update_hint_string( trig )
{
	level endon("end_game");
	level endon("disconnect");

	while( 1 )
	{
		foreach(player in level.players)
		{	
			//if ( isDefined( player.buildableturbine.owner ) && player.buildableturbine.owner.name == player.name || player hasweapon( "equip_turbine_zm" ) )
			if( player hasWeapon( "equip_turbine_zm" ) )
			{
				trig SetHintString("Took Turbine");
			}
			else
			{
				trig SetHintString("Hold ^3&&1^7 for Turbine");
			}
		}
		wait 0.1;
	}
}