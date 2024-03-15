//Falcon9 Boot Ver6

//-------------------------------------------------------------------

//Computer Role
set role to core:part:getmodule("kOSProcessor"):tag.

//-------------------------------------------------------------------

//File Loading
runoncepath("0:Falcon/Falcon9/Ver6/Falcon9Library_Ver6.ks").
runoncepath("0:/Falcon/Falcon9/Ver6/Falcon9Info_Ver6.ks").

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
    runoncepath("0:/Falcon/Falcon9/Ver6/Falcon9Main_Ver6.ks").
}
//Falcon9 Booster Boot
else if role = "Falcon9Booster" {
    if LZLoc = "Expendable" {
    }
    else if LZLoc = "RTLS" {
        runoncepath("0:/Falcon/Falcon9/Ver6/Falcon9_RTLS_Ver6.ks").
    }
    else if LZLoc = "ASDS" {
        runoncepath("0:/Falcon/Falcon9/Ver6/Falcon9_ASDS_Ver6.ks").
    }
}