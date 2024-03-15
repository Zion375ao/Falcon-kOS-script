//Falcon9 Boot Ver5
//Script Ver1

//-------------------------------------------------------------------

//Computer Role
set role to core:part:getmodule("kOSProcessor"):tag.

//-------------------------------------------------------------------

//File Loading
runoncepath("0:Falcon/Falcon9/Ver5/Falcon9Library_Ver5.ks").
runoncepath("0:/Falcon/Falcon9/Ver5/Falcon9Info_Ver5.ks").

for LZinfo in LZlist[LZ] {
    if defined LZLoc  = false {
        set LZLoc to LZinfo.
    }
    else if defined LZTitle = false {
        set LZTitle to LZinfo.
    }
    else if defined LZPo = false {
        set LZPo to LZinfo.
    }
    else if defined LZAlt = false {
        set LZAlt to LZinfo.
    }
}

//Falcon9 upper stage Boot
if role = "Falcon9Upper" {
    runoncepath("0:/Falcon/Falcon9/Ver5/Falcon9Main_Ver5.ks").
}
//Falcon9 Booster Boot
else if role = "Falcon9Booster" {
    if LZLoc = "Expendable" {
    }
    else if LZLoc = "RTLS" {
        runoncepath("0:/Falcon/Falcon9/Ver5/Falcon9_GroundPad_Ver5.ks").
    }
    else if LZLoc = "ASDS" {
        runoncepath("0:/Falcon/Falcon9/Ver5/Falcon9_ASDS_Ver5.ks").
    }
}