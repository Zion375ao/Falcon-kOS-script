//Falcon9 Boot Ver1
//Script Ver1

//-------------------------------------------------------------------

//Computer Role
set role to core:part:getmodule("kOSProcessor"):tag.

//-------------------------------------------------------------------

//File Loading
runoncepath("0:Falcon/Falcon9/Ver1/Library_Ver1.ks").
runoncepath("0:/Falcon/Falcon9/Ver1/Falcon9Info_Ver1.ks").

//Falcon9 Boot
if role = "Falcon9Upper" {
    runoncepath("0:/Falcon/Falcon9/Ver1/Falcon9Main_Ver1.ks").
}
//Falcon9 Boot
else if role = "Falcon9Booster" {
    set exAlt to exAlt_T.
    set bbAngle to bbAngle_T.
    set LZ to LZ_T.

    //Booster Expendable
    if defined LZ_T = false {
    }
    else {
        for LZ_Ground in LZlist[0] {
            //Ground Pad
            if LZ_Ground = LZ_T {
                runoncepath("0:/Falcon/Falcon9/Ver1/Falcon9_GroundPad_Ver1.ks").
                break.
            }
            else {
                //ASDS
                for LZ_ASDS in LZlist[1] {
                    if LZ_ASDS = LZ_T {
                        runoncepath("0:/Falcon/Falcon9/Ver1/Falcon9_ASDS_Ver1.ks").
                        break.
                    }
                }
            }
        }
    }
}