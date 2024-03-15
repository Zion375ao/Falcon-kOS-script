//Falcon Heavy Ascent Ver1
//Script Ver1

if ship:status = "prelaunch" {
    startup().
}
else {
    restart().
}

set ship:name to MissionName.
lock throttle to thrott().
lock steering to steer().
set steeringManager:rollts to 30.

set SettinCT to CountdownT.

ag1 on.
wait 5.

until runmode = 0 {
    //Countdown
    if runmode = 1 {
        //Water Deluge System
        if CountdownT = IgnitionT + 1 {
            WaterDeluge().
        }

        //Ignition
        if CountdownT = IgnitionT {
            enginemode("FHCenterEngine", "full").
            enginemode("FHSideEngine1", "full").
            enginemode("FHSideEngine2", "full").
        }

        //Lift off
        if CountdownT = 0 {
            stage.

            set runmode to 2.
        }

        //wait 1s
        else {
            set CountdownT to CountdownT - 1.

            wait 1.
        }
    }

    //Vertical Ascent
    else if runmode = 2 {
        if ship:airspeed > 50 {
            thrustlimit("FHCenterEngine", 75).

            set runmode to 3.
        }
    }

    //BECO
    else if runmode = 3 {
        if (LZLoc_S = "LZ" and fuelamount("FHSideTank1", "liquidfuel") < becofuel) or (LZLoc_S = "ASDS" and lngerrordiff(refpoint(0.07, LZPo_S1)) > 0) or (LZLoc_S = "Expendable" and fuelamount("FHSideTank1", "liquidfuel") = 0) {
            thrustlimit("FHSideEngine1", 0).
            thrustlimit("FHSideEngine2", 0).

            wait 1.

            SideBoosterCPU1:connection:sendmessage("BECO").
            SideBoosterCPU2:connection:sendmessage("BECO").

            stage.

            thrustlimit("FHCenterEngine", 100).

            set runmode to 4.
        }
    }

    //MECO
    else if runmode = 4 {
        if (LZLoc_C = "LZ" and fuelamount("FHCenterTank", "liquidfuel") < mecofuel) or (LZloc_C = "ASDS" and lngerrordiff(refpoint(0.07, LZPo_C)) > 0) or (LZLoc_C = "Expendable" and fuelamount("FHCenterTank", "liquidfuel") = 0) {
            set mecosteer to ship:facing.
            set meco to true.

            rcs on.

            wait 1.

            CenterBoosterCPU:connection:sendmessage("MECO").

            stage.
            set ship:control:fore to 1.

            wait 2.

            set ship:control:fore to 0.

            set runmode to 5.
        }
    }

    //SECO
    else if runmode = 5 {
        if ship:apoapsis > POrbit {
            set runmode to 6.
        }
    }

    //Manuver Node
    else if runmode = 6 {
        //create node
        if not hasNode {
            if ship:altitude > 70000 {
                wait 0.

                createnode().

                set dv0 to tgnode:deltav.
            }
        }

        //execute node
        else {
            if tgnode:eta < burntime + 60 and warp <> 0 {
                set warp to 0.
            }
            if vdot(dv0, tgnode:deltav) < 0 or tgnode:deltav:mag < 0.1 {
                remove tgnode.

                unlock all.
                set runmode to 0.
            }
        }
    }

    //fairing separation
    if not fairingjet and ship:altitude > fairingalt {
        fairing("FHFairing").
    }

    wait 0.
}

function thrott {
    if runmode = 1 or runmode = 2 or runmode = 3 or (runmode = 4 and not meco) or runmode = 5 {
        return 1.
    }
    else if runmode = 6 {
        if hasNode and tgnode:eta < burntime {
            return min(tgnode:deltav:mag / (acc(ship:maxthrust) / 5), 1).
        }
    }

    return 0.
}

function steer {
    if runmode = 1 or runmode = 2 {
        return heading(90, 90, ascentroll).
    }
    else if runmode = 3 or runmode = 4 or runmode = 5 {
        if runmode = 4 and meco {
            return mecosteer.
        }
        else {
            if pitchangle() > GTAngle {
                return gravityturn().
            }
            else {
                return heading(90, GTAngle, 0).
            }
        }
    }
    else if runmode = 6 {
        if hasNode {
            if tgnode:deltav:mag < 5 {
                return ship:facing.
            }
            else {
                return lookDirUp(tgnode:deltav, facing:topvector).
            }
        }
        else {
            return lookDirUp(ship:prograde:vector, facing:topvector).
        }
    }

    return heading(90, 90, 0).
}

function startup {
    set runmode to 1.

    set meco to false.
    set fairingjet to false.

    set ascentroll to ship:facing:roll.

    set CenterBoosterCPU to processor("FHCenterBooster").
    set SideBoosterCPU1 to processor("FHSideBooster1").
    set SideBoosterCPU2 to processor("FHSideBooster2").

    if IgnitionT > CountdownT {
        set CountdownT to IgnitionT.
    }

    if LZLoc_C = "LZ" {
        set mecofuel to fuelamount("FHCenterTank", "liquidfuel") * 0.3.
    }

    if LZLoc_S = "LZ" {
        set becofuel to fuelamount("FHSideTank1", "liquidfuel") * 0.25.
    }
}

function restart {

}