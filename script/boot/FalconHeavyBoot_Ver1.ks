//Falcon Heavy Boot Ver1
//Script Ver1

//-------------------------------------------------------------------

//Computer Role
set role to core:part:getmodule("kOSProcessor"):tag.

//-------------------------------------------------------------------

//File Loading
runoncepath("0:Falcon/FalconHeavy/Ver1/FalconHeavyLibrary_Ver1.ks").
runoncepath("0:/Falcon/FalconHeavy/Ver1/FalconHeavyInfo_Ver1.ks").

for LZinfo_C in LZlist[LZ_No_C] {
    if defined LZLoc_C  = false {
        set LZLoc_C to LZinfo_C.
    }
    else if defined LZTitle_C = false {
        set LZTitle_C to LZinfo_C.
    }
    else if defined LZPo_C = false {
        set LZPo_C to LZinfo_C.
    }
    else if defined LZAlt_C = false {
        set LZAlt_C to LZinfo_C.
    }
}

for LZinfo_S in SideLZlist[LZ_No_S] {
    if defined LZLoc_S  = false {
        set LZLoc_S to LZinfo_S.
    }
    else if defined LZTitle_S = false {
        set LZTitle_S to LZinfo_S.
    }
    else if defined LZPo_S1 = false {
        set LZPo_S1 to LZinfo_S.
    }
    else if defined LZAlt_S1 = false {
        set LZAlt_S1 to LZinfo_S.
    }
    else if defined LZPo_S2 = false {
        set LZPo_S2 to LZinfo_S.
    }
    else if defined LZAlt_S2 = false {
        set LZAlt_S2 to LZinfo_S.
    }
}

//Falcon Heavy upper stage Boot
if role = "FHUpperStage" {
    runoncepath("0:/Falcon/FalconHeavy/Ver1/FalconHeavyMain_Ver1.ks").
}

//Falcon Heavy Center Booster Boot
else if role = "FHCenterBooster" {
    set exAlt to exAlt_C.
    set bbAngle to bbAngle_C.
    set LZLoc to LZLoc_C.
    set LZTitle to LZTitle_C.
    set LZPo to LZPo_C.
    set LZAlt to LZAlt_C.

    if LZLoc_C = "Expendable" {
    }
    else if LZLoc_C = "LZ" {
        runoncepath("0:/Falcon/FalconHeavy/Ver1/FalconHeavy_GroundPad_Ver1.ks").
    }
    else if LZLoc_C = "ASDS" {
        runoncepath("0:/Falcon/FalconHeavy/Ver1/FalconHeavy_ASDS_Ver1.ks").
    }
}

//Falcon Heavy Side Booster Boot
else if role = "FHSideBooster1" {
    set exAlt to exAlt_S.
    set bbAngle to bbAngle_S.
    set LZLoc to LZLoc_S.
    set LZTitle to LZTitle_S.
    set LZPo to LZPo_S1.
    set LZAlt to LZAlt_S1.

    set MyEngine to "FHSideEngine1".

    if LZLoc_S = "Expendable" {
    }
    else if LZLoc_S = "LZ" {
        runoncepath("0:/Falcon/FalconHeavy/Ver1/FalconHeavy_GroundPad_Ver1.ks").
    }
    else if LZLoc_S = "ASDS" {
        runoncepath("0:/Falcon/FalconHeavy/Ver1/FalconHeavy_ASDS_Ver1.ks").
    }
}
else if role = "FHSideBooster2" {
    set exAlt to exAlt_S.
    set bbAngle to bbAngle_S.
    set LZLoc to LZLoc_S.
    set LZTitle to LZTitle_S.
    set LZPo to LZPo_S2.
    set LZAlt to LZAlt_S2.

    set MyEngine to "FHSideEngine2".

    if LZLoc_S = "Expendable" {
    }
    else if LZLoc_S = "LZ" {
        runoncepath("0:/Falcon/FalconHeavy/Ver1/FalconHeavy_GroundPad_Ver1.ks").
    }
    else if LZLoc_S = "ASDS" {
        runoncepath("0:/Falcon/FalconHeavy/Ver1/FalconHeavy_ASDS_Ver1.ks").
    }
}