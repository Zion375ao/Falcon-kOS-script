//Falcon Heavy Ascent Ver2

if ship:status = "prelaunch" {
    StartUp().
}
else {
    Restart().
}

set ship:name to MissionName.
lock throttle to Thrott().
lock steering to Steer().
set steeringManager:rollts to 30.

wait 10.

ag1 on.
wait 5.

until RunMode = 0 {
    //Countdown
    if RunMode = 1 {
        //Water Deluge System Activate
        if CountdownT = IgnitionT + 1 {
            WaterDeluge().
        }

        //Ignition
        if CountdownT = IgnitionT {
            EngineMode("FHCenterEngine", "Full").
            EngineMode("FHSideEngine1", "Full").
            EngineMode("FHSideEngine2", "Full").
        }

        //Lift Off
        if CountdownT = 0 {
            stage.

            set RunMode to 2.
        }

        //Wait 1s
        else {
            set CountdownT to CountdownT - 1.

            wait 1.
        }
    }

    //Vertical Ascent
    else if RunMode = 2 {
        if ship:airspeed > 50 {
            ThrustLimit("FHCenterEngine", 75).

            set RunMode to 3.
        }
    }

    //BECO
    else if RunMode = 3 {
        if (LZInfo["Side1"][0] = "RTLS" and FuelAmount("FHSideTank1", "liquidfuel") < BecoFuel) or (LZInfo["Side1"][0] = "ASDS") or (LZInfo["Side1"][0] = "Expendable" and FuelAmount("FHSideTank1", "liquidfuel") = 0) {
            ThrustLimit("FHSideEngine1", 0).
            ThrustLimit("FHSideEngine2", 0).

            wait 1.

            SideBoosterCPU1:connection:sendmessage("BECO").
            SideBoosterCPU2:connection:sendmessage("BECO").

            RCSToggle("FHSideRCS", true).
            Separation("FHSideDecoupler").
            ThrustLimit("FHCenterEngine", 100).

            set RunMode to 4.
        }
    }

    //MECO
    else if RunMode = 4 {
        if (LZInfo["Center"][0] = "RTLS" and FuelAmount("FHCenterTank", "liquidfuel") < MecoFuel) or (LZInfo["Center"][0] = "ASDS" and LatLngError(CorrPoint(LZInfo["Center"][2], 0.045))[3] > 0) or (LZInfo["Center"][0] = "Expendable" and FuelAmount("FHCenterTank", "liquidfuel") = 0) {
            set MecoSteer to ship:facing.
            set MECO to true.

            rcs on.

            wait 1.

            CenterBoosterCPU:connection:sendmessage("MECO").

            RCSToggle("FHCenterRCS", true).
            RCSToggle("FHUpperRCS", true).
            Separation("FHCenterBooster").
            EngineToggle("FHS2Engine").
            set ship:control:fore to 1.

            wait 2.

            set ship:control:fore to 0.

            set RunMode to 5.
        }
    }

    //SECO
    else if RunMode = 5 {
        if ship:apoapsis > POrbit {
            set RunMode to 6.
        }
    }

    //Manuver Node
    else if RunMode = 6 {
        //create node
        if not hasNode and addons:tr:hasimpact {
            if ship:altitude > 70000 {
                wait 0.

                CreateNode().

                set dv0 to tgNode:deltav.
            }
        }

        //execute node
        else {
            if tgNode:eta < burntime + 60 and warp <> 0 {
                set warp to 0.
            }
            if vdot(dv0, tgNode:deltav) < 0 or tgNode:deltav:mag < 0.1 {
                remove tgNode.

                unlock all.
                set RunMode to 0.
            }
        }
    }

    //fairing separation
    if not FairingJet and ship:altitude > FairingAlt {
        Fairing("FHFairing").

        set fairingjet to true.
    }

    wait 0.
}

reboot.

function Thrott {
    if RunMode = 1 or RunMode = 2 or RunMode = 3 or (RunMode = 4 and not MECO) or RunMode = 5 {
        return 1.
    }
    else if RunMode = 6 {
        if hasNode and tgNode:eta < BurnTime {
            return min(tgNode:deltav:mag / (ACC(ship:maxThrust)[0] / 5), 1).
        }
    }

    return 0.
}

function Steer {
    if RunMode = 1 {
        return ship:facing.
    }
    else if RunMode = 2 {
        //return heading(90, 90, AscentRoll).
        return lookDirUp(ship:up:vector, ship:facing:topvector).
    }
    else if RunMode = 3 or RunMode = 4 or RunMode = 5 {
        if RunMode = 4 and MECO {
            return MecoSteer.
        }
        else {
            if PitchAngle() >GTAngle {
                return GravityTurn().
            }
            else {
                return heading(90, GTAngle, 0).
            }
        }
    }
    else if RunMode = 6 {
        if hasNode {
            if tgNode:deltav:mag < 5 {
                return ship:facing.
            }
            else {
                return lookDirUp(tgNode:deltav, facing:topvector).
            }
        }
        else {
            return lookDirUp(ship:prograde:vector, facing:topvector).
        }
    }

    return heading(90, 90, 0).
}

function StartUp {
    set RunMode to 1.

    set MECO to false.
    set FairingJet to false.

    set CenterBoosterCPU to processor("FHCenterBooster").
    set SideBoosterCPU1 to processor("FHSideBooster1").
    set SideBoosterCPU2 to processor("FHSideBooster2").

    if IgnitionT > CountdownT {
        set CountdownT to IgnitionT.
    }

    if LZInfo["Center"][0] = "RTLS" {
        set MecoFuel to FuelAmount("FHCenterTank", "liquidfuel") * 0.33.
    }
    if LZInfo["Side1"][0] = "RTLS" {
        set BecoFuel to FuelAmount("FHSideTank1", "liquidfuel") * 0.25.
    }
}

function Restart {
}