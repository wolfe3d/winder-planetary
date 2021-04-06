$fn = 50;
use <mcad/involute_gears.scad>

//Tested only for NEMA 17 frame so far. Default dimensions match this, while output shaft diameter is set for
//a 10-turn variable resistor. 

//I suggest following usage:
//Disable all but annulus, planets and suns, select the direct-downward view orthogonal, then experiment...
//  - Set intended gearbox diameter
//  - Set desired gear ratio
//  - Preview and see if teeth mesh
//  - If not, try different numbers of planet gears
//  - If still no luck, try varying number of teeth in annulus and return to above step
//  - When you get a mesh, take careful note of echoed information - it will tell you the *actual* gear ratio!
//  - Once you have a good mesh, look closely to check that there are no overlaps between tooth tips and annulus
//  - Modify other parameters to match output shaft, etc.

Planetary(
            Annulus = true,
            Planets = true,
            Sun = true,
            CarrierT = true,
            CarrierB = true,
            TopPlate = false,
            BottomPlate = false,
            BL = 0.5
);

module Planetary(   OD = 80,                //Outer diameter (motor width)
                    ScrewDistance = 31,     //Distance between screws in x or y axis (assume sqare arrangement)
                    ScrewDia = 3,           //Dimater of screwholes
                    ID = 75,                //Annulus pitch-diameter
                    Na = 72,                //Number of teeth on Annulus
                    Height = 18,            //Height of geared section
                    BL = 0.4,               //Gear backlash (I find 0.2 works well on my printer)
                    TargetRatio = 10,      //Intended reduction ratio
                    InnerBore = 3.2,          //Bore of motor shaft
                    IBoreClearence = 1,     //Clearence around motor shaft for planet carrier
                    PlanetBore = 3.4,       //Bore of holes in planet carrier for shafts
					PlanetBoreScrewHead = 6,       //Bore of screw holes in planet carrier for shafts
                    PBoreClearance = 0.5,   //Clearence added for planet gears        
                    NumPlanets = 3,         //number of planets in gearbox
                    LwrCarrierThk = 5,      //Thickness of lower carrier
                    UprCarrierThk = 3,      //Thickness of upper carrier
                    CarrierClearanceB = 0.5,//Clearence between lower carrier and planet gears
                    CarrierClearanceT = 0.5,//Clearence between upper carrier and planet gears
                    OutputBore = 6.3+0.4,       //Output shaft diameter    
                    OutputShaftLen = 5,     //Length of output shaft
                    MotorShaftLen = 24,     //Length of motor shaft
                    PressureAngle = 28,     //Gear pressure angle (in case it's useful to change it)
                    TopPlateH = 1.5,        //Height of top cover plate
                    BottomPlateH = 1.8,     //Height of bottom plate (butts against motor)
                    BottomPlateHole = 23,   //Diameter of hole in bottom plate (to accomodate motor shoulder)
                    PlateClearence = 0.5,   //Clearence between plates and planet carrier
                    DblHelixTwist = 30,
                    Annulus = true,         //Enable Annulus rendering
                    Planets = true,         //Enable Planet gears rendering
                    Sun = true,             //Enable Sun gear rendering
                    CarrierT = true,        //Enable top carrier rendering
                    CarrierB = true,        //Enable bottom carrier rendering    
                    TopPlate = true,        //Enable top plate rendering    
                    BottomPlate = true      //Enable bottom plate rendering
                )
{
    //Intended for annulus to be stationary.
    //Ratio is 1/(1+Na/Ns)
    //100 = 1+Na/Ns
    //100-1 = Na/Ns
    //Ns = Na/(100-1)
    ACP = (ID/Na)*180;
    Ns = ceil(Na/(TargetRatio-1));  //Number of teeth on Sun Gear
    SD = Ns*(ACP/180);              //Sun Diameter
    PD = (ID-SD)/2;                 //Planet Diameter
    Np = round(PD/(ACP/180));       //Number of teeth on Planet Gear
    
    POr = ACP/180 + PD/2;   //Planet outer rad
    SOr = ACP/180 + SD/2;   //Sun outer rad
    
    PHeight = Height-((LwrCarrierThk+CarrierClearanceB)+(UprCarrierThk+CarrierClearanceT));
    
    if(Planets)
    {
        //render()
        color([0, 1, 0])
        for(i = [0:NumPlanets-1])
        {
            rotate(i*(360/NumPlanets), [0, 0, 1])
            translate([(SD+PD)/2, 0, LwrCarrierThk+CarrierClearanceB])
            {
                
                rotate((i*(360/NumPlanets))*(Na*Na/Np), [0, 0, 1])
                
                intersection()
                {
                    if(DblHelixTwist)
                    {
                        translate([0, 0, PHeight/2])
                        {
                            mirror([0, 1, 0])
                            {
                                gear(   number_of_teeth = Np, 
                                        circular_pitch = ACP, 
                                        gear_thickness = PHeight/2, 
                                        rim_thickness = PHeight/2, 
                                        hub_thickness = PHeight/2, 
                                        circles = 0, 
                                        bore_diameter = PlanetBore+PBoreClearance, 
                                        backlash = BL,
                                        pressure_angle = PressureAngle,
                                        twist = DblHelixTwist/(Np/(PHeight/2)));

                                mirror([0,0,1])
                                gear(   number_of_teeth = Np, 
                                        circular_pitch = ACP, 
                                        gear_thickness = PHeight/2, 
                                        rim_thickness = PHeight/2, 
                                        hub_thickness = PHeight/2, 
                                        circles = 0, 
                                        bore_diameter = PlanetBore+PBoreClearance, 
                                        backlash = BL,
                                        pressure_angle = PressureAngle,
                                        twist = DblHelixTwist/(Np/(PHeight/2)));
                                    }
                            }
                    }
                    else
                    {
                        gear(   number_of_teeth = Np, 
                                circular_pitch = ACP, 
                                gear_thickness = PHeight, 
                                rim_thickness = PHeight, 
                                hub_thickness = PHeight, 
                                circles = 0, 
                                bore_diameter = PlanetBore+PBoreClearance, 
                                backlash = BL,
                                pressure_angle = PressureAngle);
                    }
                    translate([0, 0, -0.01])
                        cylinder(r = POr-BL, h = PHeight+0.02);
                }
            }
        }
    }
    
    if(CarrierT)
    {
        color([0, 0, 1])
        translate([0, 0, Height-UprCarrierThk])
        {
            difference()
            {
                union()
                {
                    for(i = [0:NumPlanets-1])
                    {
                        hull()
                        {
                            cylinder(r = (SOr+2.5), h = UprCarrierThk);
                            
                            rotate(i*(360/NumPlanets), [0, 0, 1])
                                translate([(SD+PD)/2, 0, 0])
                                    cylinder(r = (PlanetBoreScrewHead+4)/2, h = UprCarrierThk); //edited by wolfe from r=(PlanetBore+5)/2
                        }
                    }
                    translate([0, 0, UprCarrierThk-0.01])
                    {
						hull() //added by wolfe
						{
							cylinder(r1 = SOr+2.5, r2 = OutputBore/2+2.5, h = MotorShaftLen-Height);
                       // translate([0, 0, MotorShaftLen-(Height+0.01)])
                          //  cylinder(r = OutputBore/2+2.5, h = OutputShaftLen);
						//rotate([0, 0, 45])
							difference() { //added by wolfe, this produces a stem for the crank arm
								linear_extrude(8)
								square([8,8], center=true);
							}
						}
						translate([0, 0, 8]) //added by wolfe this produces the crank arm stem
						difference() {
							linear_extrude(8)
							square([8,8], center=true);
						}
                    }
                }
                translate([0, 0, -0.05])
                {
                    cylinder(r = SOr+0.5, h = UprCarrierThk+1);
                    translate([0, 0, UprCarrierThk+0.9])
                        cylinder(r1 = SOr+0.55, r2 = OutputBore/2, h = SOr+0.5 - OutputBore/2);
                    
                    cylinder(r = (InnerBore+IBoreClearence)/2, h = MotorShaftLen-Height);
                    /*translate([0, 0, (MotorShaftLen-Height)-0.01])
                        cylinder(r = OutputBore/2, h = OutputShaftLen+10);*/ //removed from wolfe
                }


                for(i = [0:NumPlanets-1])
                {
                    rotate(i*(360/NumPlanets), [0, 0, 1])
                        translate([(SD+PD)/2, 0, -0.5])
                            cylinder(r = (PlanetBore)/2, h = UprCarrierThk+1);
                }
            }
            
        }        
    }
    
    if(CarrierB)
    {
        //render()
        color([0, 1, 1])
        difference()
        {
            for(i = [0:NumPlanets-1])
            {
                hull()
                {
                    cylinder(r = (SOr+2.5), h = LwrCarrierThk);
                    
                    rotate(i*(360/NumPlanets), [0, 0, 1])
                        translate([(SD+PD)/2, 0, 0])
						cylinder(r = (PlanetBoreScrewHead+4)/2, h = LwrCarrierThk);//edited by wolfe from r=(PlanetBore+5)/2
                }
            }
            translate([0, 0, -0.05])
                cylinder(r = SOr+0.5, h = LwrCarrierThk+0.1);

            for(i = [0:NumPlanets-1])
            {
                rotate(i*(360/NumPlanets), [0, 0, 1])
                    translate([(SD+PD)/2, 0, -0.5]){
                        cylinder(r = (PlanetBore)/2, h = LwrCarrierThk+1);
						cylinder(r = (PlanetBoreScrewHead+1)/2, h = LwrCarrierThk-2); //added by wolfe
					}
            }
        }    
    }    
 
    
    EOP = 1-Np%2;     //Even/odd teeth on planet
    
    if(Sun)
    {
        //render()
        color([1, 1, 0])
        rotate( (180/Ns)*EOP, [0, 0, 1])
        intersection()
        {
            if(DblHelixTwist)
            {

                translate([0, 0, Height/2])
                {
                    //mirror([1, 0, 0])
                    {
                        gear(   number_of_teeth = Ns, 
                                circular_pitch = ACP, 
                                gear_thickness = Height/2, 
                                rim_thickness = Height/2, 
                                hub_thickness = Height/2, 
                                circles = 0, 
                                bore_diameter = InnerBore, 
                                backlash = BL,
                                pressure_angle = PressureAngle,
                                twist = DblHelixTwist/(Ns/(Height/2)));

                        mirror([0,0,1])
                        gear(   number_of_teeth = Ns, 
                                circular_pitch = ACP, 
                                gear_thickness = Height/2, 
                                rim_thickness = Height/2, 
                                hub_thickness = Height/2, 
                                circles = 0, 
                                bore_diameter = InnerBore, 
                                backlash = BL,
                                pressure_angle = PressureAngle,
                                twist = DblHelixTwist/(Ns/(Height/2)));
                            }
                    }
            }
            else
            {
                gear(   number_of_teeth = Ns, 
                        circular_pitch = ACP, 
                        gear_thickness = Height, 
                        rim_thickness = Height, 
                        hub_thickness = Height, 
                        circles = 0, 
                        bore_diameter = InnerBore, 
                        backlash = BL,
                        pressure_angle = PressureAngle);
            }
            translate([0, 0, -0.05])
                cylinder(r = SOr-BL, h = Height+0.1);
            
        }
    }    
    
    if(Annulus)
    {
        //render()
        color([1, 0, 0])
        union()
        {
            difference()
            {
                translate([0, 0, 0.01])
                    for(i = [-1:2:1])
                    {
                        for(j = [-1:2:1])
                        {
                            hull()
                            {
                                translate([i*ScrewDistance/2, j*ScrewDistance/2, 0])
                                    cylinder(r = ScrewDia/2+2, h = Height-0.02);
                                
                                cylinder(r = OD/2, h = Height-0.02);
                            }                        
                        }
                    }

                translate([0, 0, -1])
                {

                    if(DblHelixTwist)
                    {

                        translate([0, 0, (Height+2)/2])
                        {
                            
                            mirror([1, 0, 0])
                            {
                                gear(   number_of_teeth = Na, 
                                        circular_pitch = ACP, 
                                        gear_thickness = (Height+2)/2, 
                                        rim_thickness = (Height+2)/2, 
                                        hub_thickness = (Height+2)/2, 
                                        circles = 0, 
                                        bore_diameter = 0, 
                                        backlash = -BL,
                                        clearance = -0.2,
                                        pressure_angle = PressureAngle,
                                        twist = DblHelixTwist/(Na/((Height+2)/2)));

                                mirror([0,0,1])
                                gear(   number_of_teeth = Na, 
                                        circular_pitch = ACP, 
                                        gear_thickness = (Height+2)/2, 
                                        rim_thickness = (Height+2)/2, 
                                        hub_thickness = (Height+2)/2, 
                                        circles = 0, 
                                        bore_diameter = 0, 
                                        backlash = -BL,
                                        clearance = -0.2,
                                        pressure_angle = PressureAngle,
                                        twist = DblHelixTwist/(Na/((Height+2)/2)));
                                    }
                            }
                    }
                    else
                    {

                        gear(   number_of_teeth = Na, 
                                circular_pitch = ACP, 
                                gear_thickness = Height+2, 
                                rim_thickness = Height+2, 
                                hub_thickness = Height+2, 
                                circles = 0, 
                                bore_diameter = 0, 
                                backlash = -BL,
                                clearance = -0.2,
                                pressure_angle = PressureAngle);
                    }
                    
                    for(i = [-1:2:1])
                    {
                        for(j = [-1:2:1])
                        {
                            translate([i*ScrewDistance/2, j*ScrewDistance/2, 0])
                                cylinder(r = ScrewDia/2+0.25, h = Height+2);
                        }
                    }
                }
            }
        }
    }
    
    if(TopPlate)
    {
        color([1, 0, 1])
        translate([0, 0, Height+0.05])
        union()
        {
            difference()
            {
                translate([0, 0, 0.01])
                    for(i = [-1:2:1])
                    {
                        for(j = [-1:2:1])
                        {
                            hull()
                            {
                                translate([i*ScrewDistance/2, j*ScrewDistance/2, 0])
                                    cylinder(r = ScrewDia/2+2, h = BottomPlateH-0.02);
                                
                                cylinder(r = OD/2, h = BottomPlateH-0.02);
                            }                        
                        }
                    }

                translate([0, 0, -1])
                {
                    cylinder(r = SOr+3, h = BottomPlateH+2);
                    for(i = [-1:2:1])
                    {
                        for(j = [-1:2:1])
                        {
                            translate([i*ScrewDistance/2, j*ScrewDistance/2, 0])
                                cylinder(r = ScrewDia/2+0.25, h = BottomPlateH+2);
                        }
                    }
                }
                translate([0, 0, -0.05])
                    cylinder(r = (SD+PD+PlanetBore+5.5)/2, h = PlateClearence);
            }
        }
        
    }
    
    if(BottomPlate)
    {
        color([1, 0, 1])
        translate([0, 0, -(BottomPlateH+0.05)])
        union()
        {
            difference()
            {
                translate([0, 0, 0.01])
                    for(i = [-1:2:1])
                    {
                        for(j = [-1:2:1])
                        {
                            hull()
                            {
                                translate([i*ScrewDistance/2, j*ScrewDistance/2, 0])
                                    cylinder(r = ScrewDia/2+2, h = BottomPlateH-0.02);
                                
                                cylinder(r = OD/2, h = BottomPlateH-0.02);
                            }                        
                        }
                    }

                translate([0, 0, -1])
                {
                    cylinder(r = BottomPlateHole/2, h = BottomPlateH+2);
                    for(i = [-1:2:1])
                    {
                        for(j = [-1:2:1])
                        {
                            translate([i*ScrewDistance/2, j*ScrewDistance/2, 0])
                                cylinder(r = ScrewDia/2+0.25, h = BottomPlateH+2);
                        }
                    }
                }
                translate([0, 0, BottomPlateH-PlateClearence])
                    cylinder(r = (SD+PD+PlanetBore+5.5)/2, h = BottomPlateH);
            }
        }
        
    }
    
    echo ("----------------------------------------------->  Target Ratio: ", TargetRatio, " Actual Ratio: ", 1+Na/Ns);
    echo ("----------------------------------------------->  Sun Teeth: ", Ns);
    echo ("----------------------------------------------->  Planet Teeth: ", Np);
    echo ("----------------------------------------------->  Annulus Teeth: ", Na);
}