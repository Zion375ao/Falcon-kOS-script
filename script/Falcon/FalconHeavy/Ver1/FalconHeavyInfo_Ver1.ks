//Falcon Heavy Setup Ver1
//Script Ver1

//-------------------------------------------------------------------

//Landing Zone Info (List is in "Library_Ver1")

//Center Booster LZ
//Expendable
//0: Expendable Booster

//Ground Pad
//1: Triple Pad Side 1 (M)
//2: Triple Pad Side 2 (M)
//3: Triple Pad Center (S)
//4: Main Pad (L)
//5: Double Pad 1 (M)
//6: Double Pad 2 (M)

//ASDS
//7: Of Course I Still Love You
//8: A Shortfall of Gravitas



//Side Booster LZ
//Expendable
//0: Expendable Side Booster

//Ground Pad
//1: Triple Pad Side Pad
//2: Double Pad

//ASDS

//-------------------------------------------------------------------

//Main Setting
//Mission Name
set MissionName to "Falcon Heavy Test Flight".

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

//FalconHeavy Setting

//-------------------------------------------------------------------

//Falcon Heavy Center Core Booster Setting
//Ship Radar (m)
set exAlt_C to 31.2205.

//Boostback angle
set bbAngle_C to 175.

//Landing Zone
set LZ_No_C to 1.

//-------------------------------------------------------------------

//Falcon Heavy Side Booster Setting
//Ship Radar (m)
set exAlt_S to 31.2205.

//Boostback angle
set bbAngle_S to 175.

//Landing Zone
set LZ_No_S to 1.

//-------------------------------------------------------------------
//Static Fire Test
//Static Fire Time (s)
set SFTime to 15.

//Static Fire Throttle (%)
set SFThrottle to 100.