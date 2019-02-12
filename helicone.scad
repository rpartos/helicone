// Customisable Helicone
// author: christophe.garde@gmail.com
// licence: GPL-3.0-or-later
// 
// play with the parameters below and change the functions to create different helicone styles !
// made in Lou FabiLoub https://loufabiloub.fr
//
// the code is probably not optimized, but it works !
// feel free to contribute on github

total_angle=60;
nb_of_wings=16;
axis_diam=6.3;
int_circle_diam=25;
mat_thickness=3;
rod_width=3;
total_width=100;
ext_circle_diam=20;
centering_hole_diameter=1;

out_of_wings=total_width/2+ext_circle_diam/2+2*int_circle_diam;
// draw the helicone
// projection = true allows dxf export
// projection = false for the 3d model
// at this time OpenSCAD cannot export multiple layers / colors, so the wings numbers are printed outside: you have to MANUALLY take the numbers back on the wing in the dxf.
draw(projection=false);
//draw(projection=true);

// function that gives the angle considering the position of the current level 0 < x < 1
//
function r(x)=total_angle*cos(-90+90*x);
//function r(x)=(total_angle*cos(90+total_angle*x));
//function r(x)=(total_angle*x);

// function that gives the wing width considering the position of the current level 0 < x < 1
//
function e(x)=int_circle_diam*2+abs((int_circle_diam+total_width)*cos(90+180*x));
//function e(x)=int_circle_diam*2+int_circle_diam+total_width;
//function e(x)=int_circle_diam*2+x*abs((int_circle_diam+total_width));
//function e(x)=int_circle_diam*2+abs(0.5-x)*abs((int_circle_diam+total_width));


// makes a wing
//

module wing(e,projection)
{
    linear_extrude(mat_thickness){
        difference(){
            union(){
                circle(d=int_circle_diam,$fn=72);
                translate([e/2,0,0]) circle(d=ext_circle_diam,$fn=72);
                translate([-e/2,0,0]) circle(d=ext_circle_diam,$fn=72);
                square([e,rod_width],center=true);
            }   
            circle(d=axis_diam,$fn=36);
        }
    }
}

//!wing(100,true);

// a single centering hole
module hole(){
 translate([(axis_diam/2+int_circle_diam/2)/2,0,0]) cylinder(h=5*mat_thickness,d=centering_hole_diameter,center=true,$fn=16);
}


// a set of holes
module holes(){
    rotate([0,0,15]) hole();
    rotate([0,0,120]) hole();
    rotate([0,0,-15]) hole();
    rotate([0,0,-120]) hole();
}

// little spacer between wings
//
module spacer(projection){
    int_circle_diam2=int_circle_diam+10;
    difference(){
        linear_extrude(mat_thickness*1.5){
            difference(){
                difference(){
                    circle(d=int_circle_diam*0.8,$fn=36);
                    translate([-int_circle_diam2,0,0]) square(int_circle_diam2*2);
                    rotate([0,0,135]) square(int_circle_diam2);
                    circle(d=axis_diam*1.2,$fn=36);
                }
            }
        }
        if (projection) {
            holes();
        }
    }
}

//!text("coucou",size=10);
// spacer between the wings
//
module spacers(projection=false){
    union(){
        color("red") rotate([0,0,projection ? -22 : 0]) translate([0,0,projection ? 0 : -mat_thickness]) spacer(projection);
        color("orange") translate([0,projection ? int_circle_diam/2 : 0,0]) rotate([0,0,projection ? -22 : 135]) translate([0,0,projection ? 0 : mat_thickness*0.5]) spacer(projection);
    }
}

// a full level : 1 spacer / 1 wing / 1 spacer and centering holes
//
module level(angle,e,i,projection=false){
    a1=projection ? 0 : angle;
    a2=projection ? - angle : 0;
    difference(){
        union(){
            if (!projection) { spacers();}
            rotate([0,0,a1]) wing(e,projection); 
        }
        rotate([0,0,a2]) holes();
    }
   if (projection) {
     
     translate([-out_of_wings,0,0]) linear_extrude(1) rotate([0,0,a2]) translate([-axis_diam*1.2,0,0]) rotate([0,0,90]) text(str(i),size=(int_circle_diam-axis_diam)*0.5*0.6,halign="center",valign="center");
    }

}

//!level(45,100,6,true);

// the full helicone
// set projection to true to get a flat projectable model
//
module helicone(projection=false){
    for (i = [0:nb_of_wings]) {
        if (projection)
            {
                translate([0,1.1*i*int_circle_diam,0]) {
                    level(r(i/nb_of_wings),e(i/nb_of_wings),i,projection);
                    translate([out_of_wings,0,0]) spacers(projection);
                }
            }
            else
            {
                translate([0,0,i*2*mat_thickness]) level(r(i/nb_of_wings),e(i/nb_of_wings),i);
            }
        }
    }


module draw(projection=false){
    if (projection){
        projection(cut=true) helicone(projection=true);
    }
    else
    {
        helicone(projection=false);
    }
}


