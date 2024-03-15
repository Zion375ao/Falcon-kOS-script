//Falcon9 Setup Ver1
//Script Ver1

//-------------------------------------------------------------------

//Landing Zone Info (List is in "Library_Ver1")
//LZ[0(Ground Pad) or 1(ASDS)][LZ list number]

//LZ list
//Ground Pad (0)
//0: Triple Pad Side 1 (M)
//1: Triple Pad Side 2 (M)
//2: Triple Pad Center (S)
//3: Main Pad (L)
//4: Double Pad 1 (M)
//5: Double Pad 2 (M)

//ASDS (1)
//0: Just Read the Instructions
//1: Of Course I Still Love You

//Expendable Booster
//Space

//-------------------------------------------------------------------

//Main Setting
//Mission Name
set MissionName to "Falcon9 Test Flight".

//Countdown Time (s)
set CountdownT to 5.

//Time needed for Ignition (s)
set IgnitionT to 1.

//Gravity turn limit angle
set GTAngle to 15.

//Grabity turn shape (%) (0% is Vertical Ascent)
set GTShape to 150.

//Fairing Decouple Altitude (m)
set FairingAlt to 60000.

//-------------------------------------------------------------------

//Orbital Info
//Pariking Orbit (m)
set POrbit to 150000.

//Target Apoapsis (m)
set tgAp to 150000.
//Target Periapsis (m)
set tgPe to 130000.
//Target Inclination
set tgInc to 0.
//Target longitude of Ascending node
set tgLan to 0.
//Target argument of Periapsis
set tgAop to 0.

//-------------------------------------------------------------------

//Falcon9 Setting

//-------------------------------------------------------------------

//Falcon9 Booster Setting
//Ship Radar (m)
set exAlt_T to 31.2205.

//Engine thrust
set engineTh to 226.688.

//Boostback angle
set bbAngle_T to 175.

//Landing Zone
set LZ_T to LZlist[1][1].

//-------------------------------------------------------------------

//Static Fire Test
//Static Fire Time (s)
set SFTime to 15.

//Static Fire Throttle (%)
set SFThrottle to 100.