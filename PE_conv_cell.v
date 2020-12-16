module PE_conv_cell #(
parameter BW_PER_ACT = 8,
parameter BW_PER_WT = 8,
parameter BW_PER_Psum = 17
)
(
input clk,                           //clock input
input rst_n,                         //synchronous reset (active low)

input enable,

input [BW_PER_ACT-1:0] input_act,
input [BW_PER_WT-1:0] input_weight,

input load_act,
input load_weight,

input VF_store_ctrl,          //control signal for store in V buffer

output reg [BW_PER_ACT-1:0] H_buffer,
output reg [BW_PER_ACT-1:0] V_buffer,

output reg [BW_PER_Psum-1:0] Psum
);

reg [BW_PER_ACT-1:0] n_H_buffer;
reg [BW_PER_ACT-1:0] n_V_buffer;
reg [BW_PER_ACT-1:0] n_act_buffer, act_buffer;
reg [BW_PER_WT-1:0] n_weight_buffer, weight_buffer;
reg [BW_PER_Psum-1:0] n_Psum;


//load weight
always @(*) begin
    if (load_weight) begin
        n_weight_buffer = input_weight;
    end else begin
        n_weight_buffer = weight_buffer;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weight_buffer <= 0;
    end else begin
        weight_buffer <= n_weight_buffer;
    end
end

//load activation
always @(*) begin
    if (load_act) begin
        n_act_buffer = input_act;
    end else begin
        n_act_buffer = act_buffer;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        act_buffer <= 0;
    end else begin
        act_buffer <= n_act_buffer;
    end
end

//load to H/V buffer
always @(*) begin
    if (load_act) begin
        n_H_buffer = input_act;
        if (VF_store_ctrl==1'b1) begin
            n_V_buffer = input_act;
        end else begin
            n_V_buffer = V_buffer;
        end
    end else begin
        n_H_buffer = H_buffer;
        n_V_buffer = V_buffer;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        H_buffer <= 0;
        V_buffer <= 0;
    end else begin
        H_buffer <= n_H_buffer;
        V_buffer <= n_V_buffer;
    end
end

//calculate Partial sum
always @* begin
    if (!enable) begin
        n_Psum = 0;
    end else begin
        n_Psum = $signed(act_buffer) * $signed(weight_buffer);     
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Psum <= 0;
    end else begin
        Psum <= n_Psum;
    end
end

endmodule
