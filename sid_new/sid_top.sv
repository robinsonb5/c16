
module sid_top 
#(
	parameter MULTI_FILTERS = 1, 
	parameter USE_8580_TABLES  = 1
)
(
	input         reset,

	input         clk,
	input         ce_1m,

	input         we,
	input   [4:0] addr,
	input   [7:0] data_in,
	output [ 7:0] data_out,

	input   [7:0] pot_x,
	input   [7:0] pot_y,
	input  [13:0] ext_in,

	output [17:0] audio_data,

	input         filter_en,
	input         mode,
	input   [1:0] mixctl,
	input   [2:0] cfg,
	input         ld_clk,
	input  [11:0] ld_addr,
	input  [15:0] ld_data,
	input         ld_wr
);

// Internal Signals
reg  [15:0] Voice_1_Freq;
reg  [11:0] Voice_1_Pw;
reg   [7:0] Voice_1_Control;
reg   [7:0] Voice_1_Att_dec;
reg   [7:0] Voice_1_Sus_Rel;

reg  [15:0] Voice_2_Freq;
reg  [11:0] Voice_2_Pw;
reg   [7:0] Voice_2_Control;
reg   [7:0] Voice_2_Att_dec;
reg   [7:0] Voice_2_Sus_Rel;

reg  [15:0] Voice_3_Freq;
reg  [11:0] Voice_3_Pw;
reg   [7:0] Voice_3_Control;
reg   [7:0] Voice_3_Att_dec;
reg   [7:0] Voice_3_Sus_Rel;

reg  [10:0] Filter_Fc;
reg   [7:0] Filter_Res_Filt;
reg   [7:0] Filter_Mode_Vol;

wire  [7:0] Misc_Osc3;
wire  [7:0] Misc_Env3;

wire [13:0] voice_1;
wire [13:0] voice_2;
wire [13:0] voice_3;

wire        voice_1_PA_MSB;
wire        voice_2_PA_MSB;
wire        voice_3_PA_MSB;

wire  [7:0] _st_out[3];
wire  [7:0] p_t_out[3];
wire  [7:0] ps__out[3];
wire  [7:0] pst_out[3];
wire [11:0] acc_ps[3];
wire [11:0] acc_t[3];


sid_voice v1
(
	.clock(clk),
	.ce_1m(ce_1m),
	.reset(reset),
	.mode(mode),
	.freq(Voice_1_Freq),
	.pw(Voice_1_Pw),
	.control(Voice_1_Control),
	.att_dec(Voice_1_Att_dec),
	.sus_rel(Voice_1_Sus_Rel),
	.osc_msb_in(voice_3_PA_MSB),
	.osc_msb_out(voice_1_PA_MSB),
	.voice_out(voice_1),
	._st_out(_st_out[0]),
	.p_t_out(p_t_out[0]),
	.ps__out(ps__out[0]),
	.pst_out(pst_out[0]),
	.acc_ps(acc_ps[0]),
	.acc_t(acc_t[0])
);


sid_voice v2
(
	.clock(clk),
	.ce_1m(ce_1m),
	.reset(reset),
	.mode(mode),
	.freq(Voice_2_Freq),
	.pw(Voice_2_Pw),
	.control(Voice_2_Control),
	.att_dec(Voice_2_Att_dec),
	.sus_rel(Voice_2_Sus_Rel),
	.osc_msb_in(voice_1_PA_MSB),
	.osc_msb_out(voice_2_PA_MSB),
	.voice_out(voice_2),
	._st_out(_st_out[1]),
	.p_t_out(p_t_out[1]),
	.ps__out(ps__out[1]),
	.pst_out(pst_out[1]),
	.acc_ps(acc_ps[1]),
	.acc_t(acc_t[1])
);


sid_voice v3
(
	.clock(clk),
	.ce_1m(ce_1m),
	.reset(reset),
	.mode(mode),
	.freq(Voice_3_Freq),
	.pw(Voice_3_Pw),
	.control(Voice_3_Control),
	.att_dec(Voice_3_Att_dec),
	.sus_rel(Voice_3_Sus_Rel),
	.osc_msb_in(voice_2_PA_MSB),
	.osc_msb_out(voice_3_PA_MSB),
	.voice_out(voice_3),
	.osc_out(Misc_Osc3),
	.env_out(Misc_Env3),
	._st_out(_st_out[2]),
	.p_t_out(p_t_out[2]),
	.ps__out(ps__out[2]),
	.pst_out(pst_out[2]),
	.acc_ps(acc_ps[2]),
	.acc_t(acc_t[2])
);


wire [17:0] sound;
sid_filters #(MULTI_FILTERS) filters
(
	.clk(clk),
	.rst(reset),
	.Fc(Filter_Fc),
	.Res_Filt(Filter_Res_Filt),
	.Mode_Vol(Filter_Mode_Vol),
	.voice1({{4{voice_1[13]}},voice_1}),
	.voice2({{4{voice_2[13]}},voice_2}),
	.voice3({{4{voice_3[13]}},voice_3}),
	.ext_in({{4{ext_in[13]}},ext_in}),
	.input_valid(ce_1m),
	.sound(sound),
	.enable(filter_en),

	.mode(mode),
	.mixctl(mixctl),
	.cfg(cfg),
	.ld_clk(ld_clk),
	.ld_addr(ld_addr),
	.ld_data(ld_data),
	.ld_wr(ld_wr)
);

sid_tables #(USE_8580_TABLES) sid_tables
(
	.clock(clk),
	.mode(mode),
	.acc_ps(f_acc_ps),
	.acc_t(f_acc_t),
	._st_out(f__st_out),
	.p_t_out(f_p_t_out),
	.ps__out(f_ps__out),
	.pst_out(f_pst_out)
);

wire  [7:0] f__st_out;
wire  [7:0] f_p_t_out;
wire  [7:0] f_ps__out;
wire  [7:0] f_pst_out;
reg  [11:0] f_acc_ps;
reg  [11:0] f_acc_t;

// AMR - move the three channels' table lookups further apart
// to allow for table indirection, to reduce BRAM usage.
always @(posedge clk) begin
	reg [4:0] state;
	
	if(~&state) state <= state + 1'd1;
	if(ce_1m) state <= 0;

	case(state)
		1,9,17: begin
			f_acc_ps <= acc_ps[state[4:3]];
			f_acc_t  <= acc_t[state[4:3]];
		end
	endcase

	case(state)
		5,13,21: begin
			_st_out[state[4:3]] <= f__st_out;
			p_t_out[state[4:3]] <= f_p_t_out;
			ps__out[state[4:3]] <= f_ps__out;
			pst_out[state[4:3]] <= f_pst_out;
		end
	endcase
end


always_comb begin
	case (addr)
		  5'h19: data_out = pot_x;
		  5'h1a: data_out = pot_y;
		  5'h1b: data_out = Misc_Osc3;
		  5'h1c: data_out = Misc_Env3;
		default: data_out = last_wr;
	endcase
end


// Register Decoding
reg       dac_mode;
reg [7:0] last_wr;
always @(posedge clk) begin
	if (reset) begin
		Voice_1_Freq    <= 0;
		Voice_1_Pw      <= 0;
		Voice_1_Control <= 0;
		Voice_1_Att_dec <= 0;
		Voice_1_Sus_Rel <= 0;
		Voice_2_Freq    <= 0;
		Voice_2_Pw      <= 0;
		Voice_2_Control <= 0;
		Voice_2_Att_dec <= 0;
		Voice_2_Sus_Rel <= 0;
		Voice_3_Freq    <= 0;
		Voice_3_Pw      <= 0;
		Voice_3_Control <= 0;
		Voice_3_Att_dec <= 0;
		Voice_3_Sus_Rel <= 0;
		Filter_Fc       <= 0;
		Filter_Res_Filt <= 0;
		Filter_Mode_Vol <= 0;
	end
	else begin
		if (we) begin
			last_wr <= data_in;
			case (addr)
				5'h00: Voice_1_Freq[7:0] <= data_in;
				5'h01: Voice_1_Freq[15:8]<= data_in;
				5'h02: Voice_1_Pw[7:0]   <= data_in;
				5'h03: Voice_1_Pw[11:8]  <= data_in[3:0];
				5'h04: Voice_1_Control   <= data_in;
				5'h05: Voice_1_Att_dec   <= data_in;
				5'h06: Voice_1_Sus_Rel   <= data_in;
				5'h07: Voice_2_Freq[7:0] <= data_in;
				5'h08: Voice_2_Freq[15:8]<= data_in;
				5'h09: Voice_2_Pw[7:0]   <= data_in;
				5'h0a: Voice_2_Pw[11:8]  <= data_in[3:0];
				5'h0b: Voice_2_Control   <= data_in;
				5'h0c: Voice_2_Att_dec   <= data_in;
				5'h0d: Voice_2_Sus_Rel   <= data_in;
				5'h0e: Voice_3_Freq[7:0] <= data_in;
				5'h0f: Voice_3_Freq[15:8]<= data_in;
				5'h10: Voice_3_Pw[7:0]   <= data_in;
				5'h11: Voice_3_Pw[11:8]  <= data_in[3:0];
				5'h12: Voice_3_Control   <= data_in;
				5'h13: Voice_3_Att_dec   <= data_in;
				5'h14: Voice_3_Sus_Rel   <= data_in;
				5'h15: Filter_Fc[2:0]    <= data_in[2:0];
				5'h16: Filter_Fc[10:3]   <= data_in;
				5'h17: Filter_Res_Filt   <= data_in;
				5'h18: Filter_Mode_Vol   <= data_in;
			endcase
		end
		
		dac_mode <= ((Voice_1_Control & 8'hf9) == 8'h49 && (Voice_2_Control & 8'hf9) == 8'h49 && (Voice_3_Control & 8'hf9) == 8'h49);
	end
end

wire [17:0] dac_out;
sid8580_dac dac
(
	.clock(clk),
	.mode(mode),
	.addr(Filter_Mode_Vol),
	.dout(dac_out)
);

assign audio_data = dac_mode ? dac_out : sound;

endmodule
