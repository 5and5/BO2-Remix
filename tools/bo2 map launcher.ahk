; Numpad map loading for bo2
; by 5and5


; Tranzit
Numpad1::
Send, g_gametype zclassic;ui_zm_gamemodegroup zclassic;ui_zm_mapstartlocation transit;map zm_transit {Enter}
return

; Die Rise
Numpad2::
Send, g_gametype zclassic;ui_zm_gamemodegroup zclassic;ui_zm_mapstartlocation rooftop;map zm_highrise {Enter}
return

; Mob
Numpad3::
Send, g_gametype zclassic;ui_zm_gamemodegroup zclassic;ui_zm_mapstartlocation prison;map zm_prison {Enter}
return

; Buried
Numpad4::
Send, g_gametype zclassic;ui_zm_gamemodegroup zclassic;ui_zm_mapstartlocation processing;map zm_buried {Enter}
return

; Origins
Numpad5::
Send, g_gametype zclassic;ui_zm_gamemodegroup zclassic;ui_zm_mapstartlocation tomb;map zm_tomb {Enter}
return

; Nuketown
Numpad6::
Send, g_gametype zstandard;ui_zm_gamemodegroup zsurvival;ui_zm_mapstartlocation nuked;map zm_nuked {Enter}
return

; Depot
Numpad7::
Send, g_gametype zstandard;ui_zm_gamemodegroup zsurvival;ui_zm_mapstartlocation transit;map zm_transit {Enter}
return

; Farm
Numpad8::
Send, g_gametype zstandard;ui_zm_gamemodegroup zsurvival;ui_zm_mapstartlocation farm;map zm_transit {Enter}
return

; Town
Numpad9::
Send, g_gametype zstandard;ui_zm_gamemodegroup zsurvival;ui_zm_mapstartlocation town;map zm_transit {Enter}
return

    
;To exit the script press win + alt + x
#!x::                                     ;win alt x
    ExitApp                              ;Exit script

;To suspend the script press alt + c
!c::                                     ;alt c
    Suspend                              ;Suspend script