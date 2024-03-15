//Falcon9 Boot Ver2
//Script Ver1

//-------------------------------------------------------------------

//Computer Role
set role to core:part:getmodule("kOSProcessor"):tag.

//-------------------------------------------------------------------

//File Loading
runoncepath("0:Falcon/Falcon9/Ver2/Library_Ver2.ks").
runoncepath("0:/Falcon/Falcon9/Ver2/Falcon9Info_Ver2.ks").

for LZinfo in LZlist[LZ_No] {
    if defined LZPo  = false {
        set LZPo to LZinfo.
        print LZpo.
        //break.
    }
    else if defined LZTitle = false {
        set LZTitle to LZinfo.
        print LZTitle.
        //break.
    }
    else if defined LZ = false {
        set LZ to LZinfo.
        print LZ.
        //break.
    }
    else if defined LZAlt = false {
        set LZAlt to LZinfo.
        print LZAlt.
        //break.
    }
}

//Falcon9 upper stage Boot
if role = "Falcon9Upper" {
    runoncepath("0:/Falcon/Falcon9/Ver2/Falcon9Main_Ver2.ks").
}
//Falcon9 Booster Boot
else if role = "Falcon9Booster" {
    if LZPo = "Expendable" {
    }
    else if LZPo = "LZ" {
        runoncepath("0:/Falcon/Falcon9/Ver2/Falcon9_GroundPad_Ver2.ks").
    }
    else if LZPo = "ASDS" {
        runoncepath("0:/Falcon/Falcon9/Ver2/Falcon9_ASDS_Ver2.ks").
    }
}