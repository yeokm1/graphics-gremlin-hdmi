module mda_hdmiport(
    input clk,
    input video,
    input intensity,

    input hsync,
    input vsync,
    input display_enable,
    
    input switch2,
    input switch3,

    output hdmi_red,
    output hdmi_grn,
    output hdmi_blu,
    output hdmi_int,
    output hdmi_grn_int,

    output hdmi_vs,
    output hdmi_hs,

    output hdmi_clk,

    output hdmi_de,

    );

    reg[0:0] prev_de;
    reg[0:0] prev_de2;
    reg[0:0] current_hs;
    reg[0:0] current_vs;
    reg[0:0] current_red;
    reg[0:0] current_blue;
    reg[0:0] current_grn;
    reg[0:0] current_grn_int;
    reg[0:0] current_de;

    always @(posedge clk)
    begin
        //Cut clock in half to display as 720x350 instead of 1440x350
        hdmi_clk <= ~hdmi_clk;

        // Offset bug in image being shifted 2 pixels to the right.
        current_de <= prev_de;
        prev_de <= prev_de2;
        prev_de2 <= display_enable;

        current_vs <= vsync;
        current_hs <= hsync;

        // Use external switch 1 and 2 (internally mapped as switch 2 and 3) to select display colour
        /*
            switch2	switch3	colour	r	g	b
            0	    0	    green	0	1	0
            0	    1	    yellow  1	1	0
            1	    0	    white	1	1	1
            1	    1	    red     1	0	0
        */

        current_red <= video && (switch2 || switch3);
        current_grn <= video && ~(switch2 && switch3);
        current_blu <= video && (switch2 && ~(switch2 && switch3));

        current_int <= intensity;
        current_grn_int <= intensity;

    end

    assign hdmi_de = current_de;

    assign hdmi_vs = current_vs;
    assign hdmi_hs = current_hs;

    assign hdmi_red = current_red;
    assign hdmi_blu = current_blu;
    assign hdmi_int = current_int;

    assign hdmi_grn = current_grn;
    assign hdmi_grn_int = current_grn_int;

endmodule