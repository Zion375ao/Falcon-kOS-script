//Falcon Heavy Library Ver2

//-------------------------------------------------------------------

//List

//LZ
set LZlist to list().

//Expendable
LZlist:add(list(
    "Expendable", //LZ status
    "Expendable Booster", //LZ title
    false, //LZ latlng
    false //LZ alt
)).

//LZ 1
LZlist:add(list(
    "RTLS",
    "LZ 1",
    latlng(-0.28127, -74.38598),
    0
)).

//LZ2
LZlist:add(list(
    "RTLS",
    "LZ 2",
    latlng(-0.25853, -74.39241),
    0
)).

//LZ3
LZlist:add(list(
    "RTLS",
    "LZ 3",
    latlng(-0.29223, -74.39222),
    0
)).

//Just Read the Instructions
LZlist:add(list(
    "ASDS",
    "Just Read the Instructions",
    latlng(-0.138750, -30.071447),
    3.48
)).

//-------------------------------------------------------------------

//Function

function Line {
    parameter x1, y1, x2, y2, variable.
    parameter minValue to false.
    parameter maxValue to false.

    local ansA to 0.
    local ansB to 0.

    if x1 = 0 {
        set ansB to y1.
        set ansA to (y2 - ansB) / x2.
    }
    else {
        local mul to - (x2 / x1).
        local result_y to y1 * mul + y2.
        local result_b to mul + 1.

        set ansB to result_y / result_b.
        set ansA to (y1 - ansB) / x1.
    }

    local value to variable * ansA + ansB.

    if minValue <> false and value < minValue {
        return minValue.
    }
    else if maxValue <> false and value > maxValue {
        return maxValue.
    }
    else {
        return value.
    }
}

function TrueAlt {
    parameter Negative to True.

    local Result to alt:radar - exAlt.

    if Result < 0 and Negative = false {
        return 0.
    }
    else {
        return Result.
    }
}

function FuelAmount {
    parameter tag, res.

    local fuelRemain to 0.

    for tank in ship:partstagged(tag) {
        for fuel in tank:resources {
            if fuel:name = res {
                set fuelRemain to fuelRemain + fuel:amount.
            }
        }
    }

    return fuelRemain.
}

function ACC {
    parameter power.

    local NormalACC to power / ship:mass.
    local VerticalACC to power * cos(180 - vAng(ship:velocity:surface, ship:up:vector)) / ship:mass.
    local HorizontalACC to power * sin(180 - vAng(ship:velocity:surface, ship:up:vector)) / ship:mass.

    return list(
        NormalACC, //[0]
        VerticalACC, //[1]
        HorizontalACC //[2]
    ).
}

function PitchAngle {
    return 90 - arctan2(vdot(vcrs(ship:up:vector, ship:north:vector), facing:forevector), vdot(ship:up:vector, facing:forevector)).
}

function ImpactData {
    parameter minError to 1.

    if defined ImpactHeight = false {
        global ImpactHeight to 0.
    }

    local startTime to time:seconds.
    local craftOrbit to ship:orbit.

    local sma to craftOrbit:semimajoraxis.
    local ecc to craftOrbit:eccentricity.
    local craftTA to craftOrbit:trueanomaly.
    local orbitalPeriod to craftOrbit:period.
    local ap to craftOrbit:apoapsis.
    local pe to craftOrbit:periapsis.
    local tillImpact to timeTA(ecc, orbitalPeriod, craftTA, ALTtoTA(sma, ecc, ship:body, max(min(ImpactHeight, ap - 1), pe + 1))[1]).
    if addons:tr:hasimpact {
        set tillImpact to addons:tr:timetillimpact.
    }
    local impactUTs to tillImpact + startTime.
    local newImpactHeight to ImpactPoint(positionAt(ship, impactUTs), impactUTs):terrainheight.
    set ImpactHeight to (ImpactHeight + newImpactHeight) / 2.

    function ALTtoTA {
        parameter sma, ecc, bodyIn, altIn.

        local rad is altIn + bodyIn:radius.
        local TAofAlt to arcCos((-sma * ecc^2 + sma - rad) / (ecc * rad)).

        return list(TAofAlt, 360 - TAofAlt).
    }
    function timeTA {
        parameter ecc, periodIn, taDeg1, taDeg2.

        local maDeg1 to TAtoMA(ecc, taDeg1).
        local maDeg2 to TAtoMA(ecc, taDeg2).

        local timeDiff to periodIn * ((maDeg2 - maDeg1) / 360).

        return mod(timeDiff + periodIn, periodIn).
    }
    function TAtoMA {
        parameter ecc, taDeg.

        local eaDeg to arcTan2(sqrt(1 - ecc^2) * sin(taDeg), ecc + cos(taDeg)).
        local maDeg to eaDeg - (ecc * sin(eaDeg) * constant:radtodeg).

        return mod(maDeg + 360, 360).
    }

    return lex(
        "time", impactUTs,
        "tillImpact", tillImpact,
        "impactHeight", ImpactHeight,
        "converged", ((abs(ImpactHeight - newImpactHeight) * 2) < minError)
    ).
}

function ImpactPoint { //ImpactPoint(positionAt(ship, impactData["time"]),impactData["time"]).
    parameter pos,posTime,localBody to ship:body.

    if addons:tr:hasimpact {
        return addons:tr:impactpos.
    }

	local bodyNorth to v(0, 1, 0).
	local rotationalDir to vDot(bodyNorth, localBody:angularvel) * constant:radtodeg.
	local posLATLNG to localBody:geopositionof(pos).
	local timeDif to posTime - time:seconds.
	local longitudeShift to rotationalDir * timeDif.
	local newLNG to mod(posLATLNG:lng + longitudeShift, 360).
	
    if newLNG < - 180 {
        set newLNG to newLNG + 360.
    }
	if newLNG > 180 {
        set newLNG to newLNG - 360.
    }

	return latlng(posLATLNG:LAT,newLNG).
}

function CorrPoint {
    parameter tgt, mag to 0.

    return latlng((tgt:lat + (tgt:lat - ship:geoPosition:lat) * mag), (tgt:lng + (tgt:lng - ship:geoPosition:lng) * mag)).
}

function LatLngError {
    parameter tgt.

    local Data to ImpactData().

    local ImpactPos to ImpactPoint(positionAt(ship, Data["time"]), Data["time"]).

    local ErrorVector to ImpactPos:position - tgt:position.
    local ErrorDiff to sqrt((ErrorVector:Z)^2 + (ErrorVector:X)^2).
    local LatError to ImpactPos:lat - tgt:lat.
    local LngError to ImpactPos:lng - tgt:lng.

    return list(
        ErrorVector, //[0]
        ErrorDiff, //[1]
        LatError, //[2]
        LngError //[3]
    ).
}

function LandTh {
    parameter Power, tgAlt, tgSpeed.

    local LandACC to ACC(Power)[1] - constant:g * body:mass / body:radius^2.
    local StopDist to (ship:verticalspeed^2 - tgSpeed^2) / (2 * LandACC).

    return (StopDist + tgAlt) / truealt().
}

set boostbackyaw to pidloop(15, 0, 0, -15, 15).
set boostbackyaw:setpoint to 0.
function boostbackpid {
    parameter tgt.
    
    return r(boostbackyaw:update(time:seconds, LatLngError(tgt)[2]), 0, 0).
}

function LandPid {
    parameter aoa, mag, vel, pos.

    local velvector to - vel.

    local result to (velvector + pos) * mag.
    if vAng(result, velvector) > aoa {
        set result to velvector:normalized + tan(aoa) * pos:normalized.
    }
    return lookDirup(result, facing:topvector).
}

function GravityTurn {
    return heading(90, 90 - (ship:apoapsis / 1500)).
}

function CreateNode {
    local gm to constant:g * kerbin:mass.
    local rap to ship:apoapsis + 600000.
    local vap to sqrt(gm * ((2 / rap) - (1 / ship:orbit:semimajoraxis))).
    local tgv to sqrt(gm * ((2 / rap) - (1 / rap))).
    local burnV to tgv - vap.

    set tgNode to node(timespan(eta:apoapsis), 0, 0, burnV).
    add tgNode.

    set burntime to (tgNode:deltav:mag / acc(ship:maxthrust)[0]) / 2.
}

function Fairing {
    parameter tag.

    for decoupler in ship:partstagged(tag) {
        if decoupler:hasmodule("proceduralfairingdecoupler") {
            decoupler:getmodule("proceduralfairingdecoupler"):doevent("jettison fairing").
        }
        else if decoupler:hasmodule("ModuleDecouple") {
            decoupler:getmodule("ModuleDecouple"):doevent("Decouple").
        }
    }
}

function EngineMode {
    parameter tag, mode.

    local engine to ship:partstagged(tag).
    local engineTE to engine[0]:getmodule("ModuleTundraEngineSwitch").
    local engineFX to engine[0]:getmodule("ModuleEnginesFX").

    if defined eng = false {
        set eng to "Full".
        if engineFX:hasevent("Activate Engine") {
            engineFX:doevent("Activate Engine").

            set enginestatus to true.
        }
    }

    if mode = "Shutdown" and eng <> mode {
        if engineFX:hasevent("Shutdown Engine") {
            engineFX:doevent("Shutdown Engine").
        }

        set enginestatus to false.
    }
    else if eng <> mode {

        if mode = "Center" {
            if eng = "Three" {
                nextmode().
            }
            else if eng = "Full" {
                previousmode().
            }
        }
        else if mode = "Three" {
            if eng = "Full" {
                nextmode().
            }
            else if eng = "Center" {
                previousmode().
            }
        }
        else if mode = "Full" {
            if eng = "Center" {
                nextmode().
            }
            else if eng = "Three" {
                previousmode().
            }
        }

        set eng to mode.
    }

    function nextmode {
        if engineTE:hasevent("Next Engine Mode") {
                engineTE:doevent("Next Engine Mode").
        }
    }

    function previousmode {
        if engineTE:hasevent("Previous Engine Mode") {
                engineTE:doevent("Previous Engine Mode").
        }
    }
}

function ThrustLimit {
    parameter tag, thrott.

    local engine to ship:partstagged(tag).
    local engineFX to engine[0]:getmodule("ModuleEnginesFX").

    engineFX:setField("Thrust Limiter", thrott).
}

function GridFinLimit {
    parameter tag, limit.

    local Fins to ship:partstagged(tag).

    for Fin in Fins {
        if Fin:hasmodule("ModuleControlSurface") {
            Fin:getmodule("ModuleControlSurface"):SetField("authority limiter", limit).
        }
        else if Fin:hasmodule("SyncModuleControlSurface") {
            Fin:getmodule("SyncModuleControlSurface"):SetField("authority limiter", limit).
        }
    }
}

function WaterDeluge {
    local base to ship:partstagged("LaunchPadBase").
    local baseFX to base[0]:getmodule("ModuleEnginesFX").
    if baseFX:hasevent("Activate Engine") {
        baseFX:doevent("Activate Engine").
    }
}

function ToggleSoot {
    parameter tag.

    local TGtank to ship:partstagged(tag).
    local tankTX to TGtank[0]:getmodule("ModuleTundraSoot").

    tankTX:doaction("Toggle Soot", true).
}

function ControlPoint {
    parameter tag.

    local commandpart to ship:partstagged(tag).
    commandpart[0]:getmodule("ModuleCommand"):doevent("Control From Here").
}

function Separation {
    parameter tag.

    for SepPart in ship:partstagged(tag) {
        if SepPart:hasmodule("ModuleDecouple") {
            SepPart:getmodule("ModuleDecouple"):doevent("Decouple").
        }
        else if SepPart:hasmodule("ModuleTundraAnchoredDecoupler") {
            SepPart:getmodule("ModuleTundraAnchoredDecoupler"):doevent("Decouple").
        }
        else if SepPart:hasmodule("ModuleTundraDecoupler") {
            SepPart:getmodule("ModuleTundraDecoupler"):doevent("Decouple").
        }
    }
}

function EngineToggle {
    parameter tag.

    for Engine in ship:partstagged(tag) {
        local EngineFX to Engine:getmodule("ModuleEnginesFX").

        if EngineFX:hasevent("Activate Engine") {
            EngineFX:doevent("Activate Engine").
        }
        else if EngineFX:hasevent("Shutdown Engine") {
            EngineFX:doevent("Shutdown Engine").
        }
    }
}

function RCSToggle {
    parameter tag, mode.

    for RCS in ship:partstagged(tag) {
        if RCS:hasmodule("ModuleRCS") {
            RCS:getmodule("ModuleRCS"):doaction("Toggle RCS Thrust", mode).
        }
        else if RCS:hasmodule("ModuleRCSFX") {
            RCS:getmodule("ModuleRCSFX"):doaction("Toggle RCS Thrust", mode).
        }
    }
}