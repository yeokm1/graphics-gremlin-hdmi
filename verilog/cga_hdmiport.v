module cga_hdmiport(
    input clk,
    input[3:0] video,
    input display_enable,

    input hsync,
    input vsync,

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
    reg[0:0] current_hs;
    reg[0:0] current_vs;
    reg[0:0] current_red;
    reg[0:0] current_blue;
    reg[0:0] current_grn;
    reg[0:0] current_grn_int;
    reg[0:0] current_de;

    always @(posedge clk)
    begin
        // Offset bug in image being shifted one pixel to the right.
        current_de <= prev_de;
        prev_de <= display_enable;

        current_vs <= vsync;
        current_hs <= hsync;

        current_red <= video[2];
        current_blu <= video[0];
        current_int <= video[3];

        // To generate brown value
        current_grn <= video[1] ^ (hdmi_red & video[1] & (hdmi_blu ^ 1) & (hdmi_int ^ 1));
        current_grn_int <= hdmi_int ^ (hdmi_red & video[1] & (hdmi_blu ^ 1) & (hdmi_int ^ 1));
    end


    assign hdmi_clk = clk;

    assign hdmi_de = current_de;

    assign hdmi_vs = current_vs;
    assign hdmi_hs = current_hs;

    assign hdmi_red = current_red;
    assign hdmi_blu = current_blu;
    assign hdmi_int = current_int;

    assign hdmi_grn = current_grn;
    assign hdmi_grn_int = current_grn_int;
    
endmodule