//units in mm
//$fn=100;

carb_inlet_od = 58;
carb_inlet_edge_to_edge = 23.75;
carb_boot_height = 23.75;

inner_carb_edge_to_edge = 27.75;

tank_size = 100;
tank_thick = 20;

pattern = 2; //1 or 2, 1 for more flat, and 2 for more round
inlet = 1; //1 or 2

i_c_pipe = 2.5 * 25.4; //2.5 inches in mm

taper = 10;
t_height = 30;

module boots() {
    module rad() {
        fillet_r = 7;
        rotate_extrude() 
        translate([carb_inlet_od/2,0,0]) 
        difference() {
            square(fillet_r);
            translate([fillet_r,fillet_r,0]) circle(fillet_r);
        }
    }

    cylinder(r=carb_inlet_od/2,carb_boot_height);
    rad();
    translate([carb_inlet_od+carb_inlet_edge_to_edge,0,0]) {
        cylinder(r=carb_inlet_od/2,carb_boot_height);
        rad();
    }
}

module end(upper_dia) {
    rotate_extrude() translate([tank_size/2-tank_thick/2,0,0]) circle(tank_thick/2);
    if(pattern == 1) {
        translate([0,0,-t_height]) rotate_extrude() translate([tank_size/2-upper_dia/2-taper,0,0]) circle(upper_dia/2);
    }
    if(pattern == 2) {
        translate([0,0,-t_height]) sphere(upper_dia);
    }
}

module tank_half(upper_dia) {
    difference() {
        hull() {
            end(upper_dia);
            translate([carb_inlet_od*1.5+carb_inlet_edge_to_edge+inner_carb_edge_to_edge/2,0,0]) end(upper_dia);
        }
        translate([carb_inlet_od*1.5+carb_inlet_edge_to_edge+inner_carb_edge_to_edge/2,-tank_size/2,-t_height*2-upper_dia]) 
            cube([tank_size,tank_size,t_height*4+upper_dia]);
    }
}

module plenum_entrance() {
    if(inlet == 1) {
        translate([0,0,-10])
        hull() {
            end(tank_thick*2);
            translate([(carb_inlet_od*1.5+carb_inlet_edge_to_edge+inner_carb_edge_to_edge/2)*2,0,0]) end(tank_thick*2);
            translate([-20,-75,-22])
                rotate([0,90,20]) scale([1,1.1,1]) cylinder(r=i_c_pipe/2,10);
        }
    }
    if(inlet == 2) {
        translate([0,tank_thick*2.5-10,-t_height*2+32.32])
        rotate([0,0,14]) {
            hull() {
                translate([(carb_inlet_od*1.5+carb_inlet_edge_to_edge+inner_carb_edge_to_edge/2)*2-20,-10,-3])
                    sphere(i_c_pipe/2);
                translate([-8,2,i_c_pipe/2-5]) sphere(1);
                translate([(carb_inlet_od*1.5+carb_inlet_edge_to_edge+inner_carb_edge_to_edge/2)*2-5,-t_height*2,i_c_pipe/2-5]) 
                    sphere(1);
            }
        }
    }
}

module pipe() {
    bend_rad = i_c_pipe*1.5;
    pipe_len = 75;
    rotate([0,90,0]) cylinder(r=i_c_pipe/2,75);
    translate([pipe_len,-bend_rad,0]) 
    intersection() {
        rotate_extrude() translate([bend_rad,0,0]) circle(i_c_pipe/2);
        translate([0,0,-i_c_pipe]) cube(i_c_pipe*2);
    }
}

module plenum_half() {
    if(inlet == 2) {
        if(pattern == 1) translate([0,0,-10]) tank_half(tank_thick);
        if(pattern == 2) translate([0,0,-10]) tank_half(tank_thick*2);
    }
    boots();
}

module plenum() {
    plenum_half();
    translate([(carb_inlet_od*1.5+carb_inlet_edge_to_edge+inner_carb_edge_to_edge/2)*2,0,0])
    mirror([1,0,0]) plenum_half();

    plenum_entrance();
    scale([0.7,1.3,1])
    translate([-110,-68,137]) 
    rotate([-90,90,10]) 
    pipe();
}

plenum();
