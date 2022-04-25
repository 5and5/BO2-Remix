#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;

increase_perk_limit( limit )
{
	level.perk_purchase_limit = limit;
}

mulekick_additional_perks()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill_any("perk_acquired", "perk_lost");

		if (self HasPerk("specialty_additionalprimaryweapon"))
		{
			self SetPerk("specialty_fastads");
			self SetPerk("specialty_fastweaponswitch");
			self Setperk("specialty_fasttoss");
		}
		else
		{
			self UnsetPerk("specialty_fastads");
			self UnsetPerk("specialty_fastweaponswitch");
			self Unsetperk("specialty_fasttoss");
		}
	}
}

staminup_additional_perks()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill_any("perk_acquired", "perk_lost");

		if (self HasPerk("specialty_longersprint"))
		{
			self setperk( "specialty_unlimitedsprint" );
		}
		else
		{
			self unsetperk( "specialty_unlimitedsprint" );
		}
	}
	
}

perk_machine_quarter_change()
{
	if(level.script == "zm_tomb")
		return;
	a_triggers = getentarray( "audio_bump_trigger", "targetname" );
	_a43 = a_triggers;
	_k43 = getFirstArrayKey( _a43 );
	while ( isDefined( _k43 ) )
	{
		trigger = _a43[ _k43 ];
		if ( isDefined( trigger.script_sound ) && trigger.script_sound == "zmb_perks_bump_bottle" )
		{
			trigger thread check_for_change();
		}
		_k43 = getNextArrayKey( _a43, _k43 );
	}
}

check_for_change()
{
	while ( 1 )
	{
		self waittill( "trigger", e_player );
		if ( e_player getstance() == "prone" )
		{
			e_player maps/mp/zombies/_zm_score::add_to_player_score( 100 );
			play_sound_at_pos( "purchase", e_player.origin );
			return;
		}
		else
		{
			wait 0.1;
		}
	}
}

disable_electric_cherry_on_laststand()
{
	level.custom_laststand_func = undefined;
}