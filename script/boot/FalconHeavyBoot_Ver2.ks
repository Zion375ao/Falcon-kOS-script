//Falcon Heavy Boot Ver2

//-------------------------------------------------------------------

//Computer Role
set Role to core:part:getmodule("kOSProcessor"):tag.

//-------------------------------------------------------------------

//File Loading
runOncePath("0:/Falcon/FalconHeavy/Ver2/FalconHeavyLibrary_Ver2.ks").
runOncePath("0:/Falcon/FalconHeavy/Ver2/FalconHeavyInfo_Ver2.ks").

//-------------------------------------------------------------------

clearScreen.

//Boot File
if Role = "FHUpper" {
    //LZ Info List
    set LZInfo to lex(
        "Center", LZlist[LZC], //Center Core Booster
        "Side1", LZlist[LZB1], //Side Booster 1
        "Side2", LZlist[LZB2]  //Side Booster 2
    ).
    
    runOncePath("0:/Falcon/FalconHeavy/Ver2/FalconHeavyMain_Ver2.ks").
}
else {
    if Role = "FHCenterBooster" {
        ListLoad(LZC).

        set exAlt to exAltC.
        set bbAngle to bbAngleC.
        set MyEngine to "FHCenterEngine".
        set MyTank to "FHCenterTank".
    }
    else if Role = "FHSideBooster1" {
        ListLoad(LZB1).

        set exAlt to exAltB.
        set bbAngle to bbAngleB.
        set MyEngine to "FHSideEngine1".
        set MyTank to "FHSideTank1".
    }
    else if Role = "FHSideBooster2" {
        ListLoad(LZB2).

        set exAlt to exAltB.
        set bbAngle to bbAngleB.
        set MyEngine to "FHSideEngine2".
        set MyTank to "FHSideTank2".
    }

    if LZSt = "Expendable" {
    }
    else if LZSt = "RTLS" {
        runOncePath("0:/Falcon/FalconHeavy/Ver2/FalconHeavy_RTLS_Ver2.ks").
    }
    else if LZSt = "ASDS" {
        runOncePath("0:/Falcon/FalconHeavy/Ver2/FalconHeavy_ASDS_Ver2.ks").
    }
}

function ListLoad {
    parameter Number.

    set LZSt to LZlist[Number][0].
    set LZTitle to LZlist[Number][1].
    set LZPo to LZlist[Number][2].
    set LZAlt to LZlist[Number][3].
}