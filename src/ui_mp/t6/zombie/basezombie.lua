CoD.Zombie = {}
CoD.Zombie.PlayerColors = {}
CoD.Zombie.TeamPlayerCount = 8
CoD.Zombie.PlayerColors[1] = {
	r = 1,
	g = 1,
	b = 1,
	a = 1
}
CoD.Zombie.PlayerColors[2] = {
	r = 0.49,
	g = 0.81,
	b = 0.93,
	a = 1
}
CoD.Zombie.PlayerColors[3] = {
	r = 0.96,
	g = 0.79,
	b = 0.31,
	a = 1
}
CoD.Zombie.PlayerColors[4] = {
	r = 0.51,
	g = 0.93,
	b = 0.53,
	a = 1
}
CoD.Zombie.GAMETYPE_ZCLASSIC = "zclassic"
CoD.Zombie.GAMETYPE_ZSTANDARD = "zstandard"
CoD.Zombie.GAMETYPE_ZGRIEF = "zgrief"
CoD.Zombie.GAMETYPE_ZCLEANSED = "zcleansed"
CoD.Zombie.GAMETYPE_ZMEAT = "zmeat"
CoD.Zombie.GameTypes = {}
CoD.Zombie.GameTypes[1] = CoD.Zombie.GAMETYPE_ZCLASSIC
CoD.Zombie.GameTypes[2] = CoD.Zombie.GAMETYPE_ZSTANDARD
CoD.Zombie.GameTypes[3] = CoD.Zombie.GAMETYPE_ZGRIEF
CoD.Zombie.GameTypes[4] = CoD.Zombie.GAMETYPE_ZCLEANSED
CoD.Zombie.GameTypes[5] = CoD.Zombie.GAMETYPE_ZMEAT
CoD.Zombie.GAMETYPEGROUP_ZCLASSIC = "zclassic"
CoD.Zombie.GAMETYPEGROUP_ZSURVIVAL = "zsurvival"
CoD.Zombie.GAMETYPEGROUP_ZENCOUNTER = "zencounter"
CoD.Zombie.GameTypeGroups = {}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZCLASSIC] = {
	maxPlayers = 4,
	minPlayers = 1,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4
}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZSTANDARD] = {
	maxPlayers = 4,
	minPlayers = 1,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4
}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZGRIEF] = {
	maxPlayers = 8,
	minPlayers = 2,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4,
	maxTeamPlayers = 4,
	minTeamPlayers = 1
}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZCLEANSED] = {
	maxPlayers = 4,
	minPlayers = 2,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4,
	maxTeamPlayers = 1,
	minTeamPlayers = 1
}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZMEAT] = {
	maxPlayers = 8,
	minPlayers = 2,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4,
	maxTeamPlayers = 4,
	minTeamPlayers = 1
}
CoD.Zombie.START_LOCATION_TRANSIT = "transit"
CoD.Zombie.START_LOCATION_FARM = "farm"
CoD.Zombie.START_LOCATION_TOWN = "town"
CoD.Zombie.START_LOCATION_DINER = "diner"
CoD.Zombie.START_LOCATION_TUNNEL = "tunnel"
CoD.Zombie.MAP_ZM_TRANSIT = "zm_transit"
CoD.Zombie.MAP_ZM_NUKED = "zm_nuked"
CoD.Zombie.MAP_ZM_HIGHRISE = "zm_highrise"
CoD.Zombie.MAP_ZM_TRANSIT_DR = "zm_transit_dr"
CoD.Zombie.MAP_ZM_TRANSIT_TM = "zm_transit_tm"
CoD.Zombie.MAP_ZM_PRISON = "zm_prison"
CoD.Zombie.MAP_ZM_BURIED = "zm_buried"
CoD.Zombie.MAP_ZM_TOMB = "zm_tomb"
CoD.Zombie.Maps = {}
CoD.Zombie.Maps[1] = CoD.Zombie.MAP_ZM_TRANSIT
CoD.Zombie.Maps[2] = CoD.Zombie.MAP_ZM_NUKED
CoD.Zombie.Maps[3] = CoD.Zombie.MAP_ZM_HIGHRISE
CoD.Zombie.Maps[4] = CoD.Zombie.MAP_ZM_PRISON
CoD.Zombie.Maps[5] = CoD.Zombie.MAP_ZM_BURIED
CoD.Zombie.Maps[6] = CoD.Zombie.MAP_ZM_TOMB
CoD.Zombie.DLC0Maps = {
	CoD.Zombie.MAP_ZM_NUKED
}
CoD.Zombie.DLC1Maps = {
	CoD.Zombie.MAP_ZM_HIGHRISE
}
CoD.Zombie.DLC2Maps = {
	CoD.Zombie.MAP_ZM_PRISON
}
CoD.Zombie.DLC3Maps = {
	CoD.Zombie.MAP_ZM_BURIED
}
CoD.Zombie.DLC4Maps = {
	CoD.Zombie.MAP_ZM_TOMB
}
CoD.Zombie.AllDLCMaps = {
	CoD.Zombie.MAP_ZM_NUKED,
	CoD.Zombie.MAP_ZM_HIGHRISE,
	CoD.Zombie.MAP_ZM_PRISON,
	CoD.Zombie.MAP_ZM_BURIED,
	CoD.Zombie.MAP_ZM_TOMB
}
CoD.Zombie.SideQuestMaps = {
	CoD.Zombie.MAP_ZM_TRANSIT,
	CoD.Zombie.MAP_ZM_HIGHRISE,
	CoD.Zombie.MAP_ZM_BURIED
}
CoD.Zombie.CharacterNameDisplayMaps = {
	CoD.Zombie.MAP_ZM_PRISON,
	CoD.Zombie.MAP_ZM_BURIED,
	CoD.Zombie.MAP_ZM_TOMB
}
CoD.Zombie.PlayListCurrentSuperCategoryIndex = nil
CoD.Zombie.IsSurvivalUsingCIAModel = nil
CoD.Zombie.miniGameDisabled = true
CoD.Zombie.AllowRoundAnimation = 1
CoD.Zombie.GameOptions = {
	{
		id = "zmDifficulty",
		name = "ZMUI_DIFFICULTY_CAPS",
		hintText = "ZMUI_DIFFICULTY_DESC",
		labels = {
			"ZMUI_DIFFICULTY_EASY_CAPS",
			"ZMUI_DIFFICULTY_NORMAL_CAPS"
		},
		values = {
			0,
			1
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZCLASSIC,
			CoD.Zombie.GAMETYPE_ZSTANDARD,
			CoD.Zombie.GAMETYPE_ZGRIEF
		}
	},
	{
		id = "startRound",
		name = "ZMUI_STARTING_ROUND_CAPS",
		hintText = "ZMUI_STARTING_ROUND_DESC",
		labels = {
			"1",
			"5",
			"10",
			"15",
			"20"
		},
		values = {
			1,
			5,
			10,
			15,
			20
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZSTANDARD,
			CoD.Zombie.GAMETYPE_ZGRIEF
		}
	},
	{
		id = "magic",
		name = "ZMUI_MAGIC_CAPS",
		hintText = "ZMUI_MAGIC_DESC",
		labels = {
			"MENU_ENABLED_CAPS",
			"MENU_DISABLED_CAPS"
		},
		values = {
			1,
			0
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZSTANDARD,
			CoD.Zombie.GAMETYPE_ZGRIEF
		}
	},
	{
		id = "headshotsonly",
		name = "ZMUI_HEADSHOTS_ONLY_CAPS",
		hintText = "ZMUI_HEADSHOTS_ONLY_DESC",
		labels = {
			"MENU_DISABLED_CAPS",
			"MENU_ENABLED_CAPS"
		},
		values = {
			0,
			1
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZSTANDARD,
			CoD.Zombie.GAMETYPE_ZGRIEF
		}
	},
	{
		id = "allowdogs",
		name = "ZMUI_DOGS_CAPS",
		hintText = "ZMUI_DOGS_DESC",
		labels = {
			"MENU_DISABLED_CAPS",
			"MENU_ENABLED_CAPS"
		},
		values = {
			0,
			1
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZSTANDARD
		},
		maps = {
			CoD.Zombie.MAP_ZM_TRANSIT
		}
	},
	{
		id = "cleansedLoadout",
		name = "ZMUI_CLEANSED_LOADOUT_CAPS",
		hintText = "ZMUI_CLEANSED_LOADOUT_DESC",
		labels = {
			"ZMUI_CLEANSED_LOADOUT_SHOTGUN_CAPS",
			"ZMUI_CLEANSED_LOADOUT_GUN_GAME_CAPS"
		},
		values = {
			0,
			1
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZCLEANSED
		}
	}
}
CoD.Zombie.SingleTeamColor = {
	r = 0,
	g = 0.5,
	b = 1
}
CoD.Zombie.FullScreenSize = {
	w = 1280,
	h = 720,
	sw = 960
}
CoD.Zombie.SplitscreenMultiplier = 1.2
CoD.Zombie.OpenMenuEventMenuNames = {}
CoD.Zombie.OpenMenuEventMenuNames.PublicGameLobby = 1
CoD.Zombie.OpenMenuEventMenuNames.PrivateOnlineGameLobby = 1
CoD.Zombie.OpenMenuEventMenuNames.MainLobby = 1
CoD.Zombie.OpenMenuSelfMenuNames = {}
CoD.Zombie.OpenMenuSelfMenuNames.PublicGameLobby = 1
CoD.Zombie.OpenMenuSelfMenuNames.PrivateOnlineGameLobby = 1
CoD.Zombie.PLAYLIST_CATEGORY_FILTER_SOLOMATCH = "solomatch"
CoD.Zombie.GetUIMapName = function ()
	return CoD.Zombie.GetMapName(UIExpression.DvarString(nil, "ui_mapname"))
end

CoD.Zombie.GetMapName = function (f2_arg0)
	if f2_arg0 == nil or map == "" or string.find(f2_arg0, CoD.Zombie.MAP_ZM_TRANSIT) ~= nil then
		f2_arg0 = CoD.Zombie.MAP_ZM_TRANSIT
	end
	return f2_arg0
end

CoD.Zombie.GetDefaultStartLocationForMap = function ()
	local f3_local0 = Dvar.ui_mapname:get()
	local f3_local1 = CoD.Zombie.START_LOCATION_TRANSIT
	if f3_local0 then
		f3_local1 = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 6, 2, f3_local0, 7, "YES", 3)
	end
	return f3_local1
end

CoD.Zombie.GetDefaultGameTypeForMap = function ()
	local f4_local0 = Dvar.ui_mapname:get()
	local f4_local1 = CoD.Zombie.GAMETYPE_ZCLASSIC
	if f4_local0 then
		f4_local1 = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 6, 2, f4_local0, 7, "YES", 4)
	end
	return f4_local1
end

CoD.Zombie.GetDefaultGameTypeGroupForMap = function ()
	local f5_local0 = Dvar.ui_mapname:get()
	local f5_local1 = CoD.Zombie.GAMETYPEGROUP_ZCLASSIC
	local f5_local2 = CoD.Zombie.GAMETYPE_ZCLASSIC
	if f5_local0 then
		f5_local2 = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 6, 2, f5_local0, 7, "YES", 4)
		if f5_local2 then
			f5_local1 = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 0, 1, f5_local2, 9)
		end
	end
	return f5_local1
end

CoD.Zombie.IsDLCMap = function (f6_arg0)
	local f6_local0 = Dvar.ui_mapname:get()
	if f6_local0 then
		if not f6_arg0 then
			f6_arg0 = CoD.Zombie.AllDLCMaps
		end
		for f6_local1 = 1, #f6_arg0, 1 do
			if f6_local0 == f6_arg0[f6_local1] then
				return true
			end
		end
	end
	return false
end

CoD.Zombie.IsSideQuestMap = function (f7_arg0)
	if not f7_arg0 then
		f7_arg0 = Dvar.ui_mapname:get()
	end
	if f7_arg0 then
		for f7_local0 = 1, #CoD.Zombie.SideQuestMaps, 1 do
			if f7_arg0 == CoD.Zombie.SideQuestMaps[f7_local0] then
				return true
			end
		end
	end
	return false
end

CoD.Zombie.IsCharacterNameDisplayMap = function (f8_arg0)
	if not f8_arg0 then
		f8_arg0 = Dvar.ui_mapname:get()
	end
	if f8_arg0 then
		for f8_local0 = 1, #CoD.Zombie.CharacterNameDisplayMaps, 1 do
			if f8_arg0 == CoD.Zombie.CharacterNameDisplayMaps[f8_local0] then
				return true
			end
		end
	end
	return false
end

CoD.Zombie.ColorRichtofen = function (f9_arg0, f9_arg1)
	f9_arg0:beginAnimation("color_rich", f9_arg1)
	f9_arg0:setRGB(CoD.Zombie.SideQuestStoryLine[1].color.r, CoD.Zombie.SideQuestStoryLine[1].color.g, CoD.Zombie.SideQuestStoryLine[1].color.b)
end

CoD.Zombie.ColorMaxis = function (f10_arg0, f10_arg1)
	f10_arg0:beginAnimation("color_maxis", f10_arg1)
	f10_arg0:setRGB(CoD.Zombie.SideQuestStoryLine[2].color.r, CoD.Zombie.SideQuestStoryLine[2].color.g, CoD.Zombie.SideQuestStoryLine[2].color.b)
end

CoD.Zombie.SideQuestStoryLine = {}
CoD.Zombie.SideQuestStoryLine[1] = {
	name = "Richtofen",
	color = CoD.playerBlue,
	colorFunction = CoD.Zombie.ColorRichtofen
}
CoD.Zombie.SideQuestStoryLine[2] = {
	name = "Maxis",
	color = CoD.BOIIOrange,
	colorFunction = CoD.Zombie.ColorMaxis
}
CoD.CACUtility = {}
CoD.CACUtility.denySFX = "cac_cmn_deny"
CoD.CACUtility.carouselLRSFX = "cac_slide_nav_lr"
CoD.CACUtility.carouselUpSFX = "cac_slide_nav_up"
CoD.CACUtility.carouselDownSFX = "cac_slide_nav_down"
CoD.CACUtility.carouselEquipSFX = "cac_slide_equip_item"
CoD.PlaylistCategoryFilter = nil
