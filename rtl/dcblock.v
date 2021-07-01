module dcblock # 
(
	parameter signalwidth = 16,
	parameter cbits = 24,	// Bits for coefficient
	parameter immediate = 0
)
(
	input clk,
	input reset_n,
	input ena,
	input [signalwidth-1:0] d,
	output reg [signalwidth-1:0] q
);

reg [signalwidth+cbits-1:0] acc = {signalwidth+cbits{1'b0}};
wire [signalwidth+cbits-1:0] acc_new;

wire [signalwidth+cbits:0] delta = {d,{cbits{1'b0}}} - acc;

assign acc_new = acc + {{cbits{delta[signalwidth+cbits]}},delta[signalwidth+cbits-1:cbits]};

always @(posedge clk, negedge reset_n)
begin
	if(!reset_n)
	begin
		acc[signalwidth+cbits-1:0]<={signalwidth+cbits{1'b0}};
	end
	else if(ena)
		acc <= acc_new;
end

always @(posedge clk)
	q<=d-acc[signalwidth+cbits-1:cbits];

endmodule
