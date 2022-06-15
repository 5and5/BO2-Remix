#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_pers_upgrades_system;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_equipment;

#include scripts/zm/remix/_players;
#include scripts/zm/remix/_visual;
#include scripts/zm/remix/_hud;
#include scripts/zm/remix/_weapons;
#include scripts/zm/remix/_powerups;
#include scripts/zm/remix/_perks;
#include scripts/zm/remix/_persistent;
#include scripts/zm/remix/_buildables;
#include scripts/zm/remix/_equipment;
#include scripts/zm/remix/_magicbox;
#include scripts/zm/remix/_sharedbox;
#include scripts/zm/remix/_reset;
#include scripts/zm/remix/_utility;
#include scripts/zm/remix/_zombies;
#include scripts/zm/remix/_debug;
#include scripts/zm/remix/_dogs;


main()
{ 
	level.VERSION = "1.7.1";

	replaceFunc( maps/mp/zombies/_zm_powerups::powerup_drop, ::powerup_drop_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::get_next_powerup, ::get_next_powerup_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::insta_kill_powerup, ::insta_kill_powerup_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::insta_kill_on_hud, ::insta_kill_on_hud_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::double_points_powerup, ::double_points_powerup_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::point_doubler_on_hud, ::point_doubler_on_hud_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::full_ammo_powerup, ::full_ammo_powerup_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::free_perk_powerup, ::free_perk_powerup_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::nuke_powerup, ::nuke_powerup_override );
	replaceFunc( maps/mp/zombies/_zm_utility::disable_player_move_states, ::disable_player_move_states_override );
	replaceFunc( maps/mp/zombies/_zm_utility::set_run_speed, ::set_run_speed_override );
	replaceFunc( maps/mp/zombies/_zm_utility::get_player_weapon_limit, ::get_player_weapon_limit_override );
	replaceFunc( maps/mp/zombies/_zm_magicbox::treasure_chest_canplayerreceiveweapon, ::treasure_chest_canplayerreceiveweapon_override);
	replaceFunc( maps/mp/zombies/_zm_magicbox::treasure_chest_weapon_spawn, ::treasure_chest_weapon_spawn_override );
	replaceFunc( maps/mp/zombies/_zm_magicbox::treasure_chest_move, ::treasure_chest_move_override );
	replaceFunc( maps/mp/zombies/_zm_weapons::weapon_give, ::weapon_give_override );
	replaceFunc( maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options, ::get_pack_a_punch_weapon_options_override );
	replaceFunc( maps/mp/zombies/_zm_weapons::ammo_give, ::ammo_give_override );
	replaceFunc( maps/mp/zombies/_zm::actor_damage_override, ::actor_damage_override_override );
	replaceFunc( maps/mp/zombies/_zm::take_additionalprimaryweapon, ::take_additionalprimaryweapon_overrride );
	replaceFunc( maps/mp/zombies/_zm_spawner::zombie_rise_death, ::zombie_rise_death_override );
	replaceFunc( maps/mp/zombies/_zm::round_think, ::round_think_override );
	replaceFunc( maps/mp/zombies/_zm::ai_calculate_health, ::ai_calculate_health_override );
	replaceFunc( maps/mp/zombies/_zm_pers_upgrades_functions::pers_nube_should_we_give_raygun, ::pers_nube_should_we_give_raygun_override );
	replaceFunc( maps/mp/zombies/_zm_utility::wait_network_frame, ::wait_network_frame_override );
	replaceFunc( maps/mp/zombies/_zm_score::add_to_player_score, ::add_to_player_score_override );

	
	
    level.initial_spawn = true;
    level thread onConnect();
}

init()
{
	level._effect["fx_zombie_powerup_caution_wave"] = loadfx("misc/fx_zombie_powerup_caution_wave");
}

onConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread connected();
    }
}

connected()
{
    level endon( "game_ended" );
    self endon("disconnect");

    self.initial_spawn = true;

    for(;;)
    {
        self waittill("spawned_player");

    	if(self.initial_spawn)
		{
            self.initial_spawn = false;

			self thread debug( 0 );

			self iprintln("Welcome to Remix!");
			self iPrintLn("Version " + level.VERSION);

			self set_players_score( 555 );
			self set_movement_dvars();
			self set_client_dvars();
			self set_character_option();
			self set_visionset();

			self graphic_tweaks();
			self thread night_mode();
			self thread rotate_skydome();

	    	self thread timer_hud();
			self thread trap_timer_hud();
			self thread health_bar_hud();
			self thread zombie_remaining_hud();
			self thread zone_hud();
			self thread color_hud();
			self thread all_hud_watcher();

			self thread max_ammo_refill_clip();
			self thread carpenter_repair_shield();

			self thread disable_player_quotes();
			self thread set_persistent_stats();

			self thread mulekick_additional_perks();
			self thread staminup_additional_perks();

			self thread inspect_weapon();
			self thread rapid_fire();
        }

        if(level.initial_spawn)
		{
			level.initial_spawn = false;

			if(GetDvar("customMap") == "")
			{
				SetDvar("customMap", "vanilla");
				level.customMap = GetDvar("customMap");
			}

			set_dog_rounds();

			level thread change_skydome();
			level thread eye_color_watcher();

			level thread coop_pause();
			level thread fake_reset();

			level thread shared_box();

			flag_wait( "start_zombie_round_logic" );
   			wait 0.05;

			set_startings_chests();
			set_anim_pap_camo_dvars();
			set_claymores_max( 10 );

			increase_perk_limit( 5 );
			reduce_player_fall_damage();
			raygun_mark2_probabilty();

			disable_fire_sales();
			disable_high_round_walkers();
			disable_electric_cherry_on_laststand();

			electric_trap_always_kill();
			perk_machine_quarter_change();

			level thread buildbuildables();
			level thread buildcraftables();

			buildable_increase_trigger_radius();
			wallbuy_increase_trigger_radius();
			level thread wallbuy_dynamic_increase_trigger_radius();
		}
	}
}