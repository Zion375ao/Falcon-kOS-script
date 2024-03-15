//Falcon9 Boot Ver7

//-------------------------------------------------------------------

//Computer Role
set role to core:part:getmodule("kOSProcessor"):tag.

//-------------------------------------------------------------------

//File Loading
runoncepath("0:Falcon/Falcon9/Ver7/Falcon9Library_Ver7.ks").
runoncepath("0:/Falcon/Falcon9/Ver7/Falcon9Info_Ver7.ks").

clearScreen.

for LZinfo in LZlist[LZ] {
    if defined LZSt  = false {
        set LZSt to LZinfo.
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
    runoncepath("0:/Falcon/Falcon9/Ver7/Falcon9Main_Ver7.ks").
}
//Falcon9 Booster Boot
else if role = "Falcon9Booster" {
    if LZSt = "Expendable" {
    }
    else if LZSt = "RTLS" {
        runoncepath("0:/Falcon/Falcon9/Ver7/Falcon9_RTLS_Ver7.ks").
    }
    else if LZSt = "ASDS" {
        runoncepath("0:/Falcon/Falcon9/Ver7/Falcon9_ASDS_Ver7.ks").
    }
}