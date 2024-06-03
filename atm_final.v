`timescale 1ns/1ps
`define current_date 11'b010_00110101 // MAY 24 = 010_00110101
`define min_balance 10'd100

module account(card_no, expiry_date, index, is_exist);
    input [9:0] card_no;
    input [10:0] expiry_date;
    output [3:0] index;
    output reg is_exist;

    reg [9:0] card_number_with_bank [0:15];

    initial begin
        card_number_with_bank[0] =  10'd100;
        card_number_with_bank[1] =  10'd200;
        card_number_with_bank[2] =  10'd300;
        card_number_with_bank[3] =  10'd400;
        card_number_with_bank[4] =  10'd500;
        card_number_with_bank[5] =  10'd600;
        card_number_with_bank[6] =  10'd700;
        card_number_with_bank[7] =  10'd800;
        card_number_with_bank[8] =  10'd900;
        card_number_with_bank[9] =  10'd1000;
        card_number_with_bank[10] = 10'd1003;
        card_number_with_bank[11] = 10'd1006;
        card_number_with_bank[12] = 10'd1009;
        card_number_with_bank[13] = 10'd1012;
        card_number_with_bank[14] = 10'd1015;
        card_number_with_bank[15] = 10'd1018;
    end

    integer i;
    reg [3:0] index_temp;

    always @(card_no) begin
        is_exist = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            if (card_no == card_number_with_bank[i]) begin
                index_temp = i;
                is_exist = 1'b1;
            end
        end
    end

    assign index = index_temp;
endmodule

module top_module(
    clk, reset,operation,deposit_money, card_no, transfer_no,transfer_amount,withdraw_amount,card_pin,new_pin,expiry_date,card_declined);
    input clk;
    input [9:0] card_no, transfer_no, withdraw_amount,transfer_amount, card_pin, new_pin;
    input [10:0] expiry_date;
    input [9:0] deposit_money;
    input [2:0] operation;
    input reset;
    output reg card_declined;

    reg [2:0] state = 3'b111;
    reg [9:0] bank_balance [0:15];
    reg [9:0] amount_deposited [0:15];
    reg [9:0] passcode [0:15];

    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1) 
        begin
            bank_balance[i] = `min_balance;
            amount_deposited[i] = 10'd0;
        end

        passcode[0] = 10'd100;
        passcode[1] = 10'd200;
        passcode[2] = 10'd300;
        passcode[3] = 10'd400;
        passcode[4] = 10'd500;
        passcode[5] = 10'd600;
        passcode[6] = 10'd700;
        passcode[7] = 10'd800;
        passcode[8] = 10'd900;
        passcode[9] = 10'd1000;
        passcode[10] = 10'd1003;
        passcode[11] = 10'd1006;
        passcode[12] = 10'd1009;
        passcode[13] = 10'd1012;
        passcode[14] = 10'd1015;
        passcode[15] = 10'd1018;
    end

    wire [3:0] senders_index;
    wire sender_exist;
    account senders_account(card_no, expiry_date, senders_index, sender_exist);
    wire [3:0] sendee_index;
    wire sendee_exist;
    account sendee_account(transfer_no, expiry_date, sendee_index, sendee_exist);

    always @(negedge clk or posedge reset) begin
        if (reset == 1'b1) begin
            card_declined <= 1'b0;
            state <= 3'b111;
            $display("ATM Reset.\n");
        end else if (!sender_exist || card_pin != passcode[senders_index] || expiry_date < `current_date)
        begin
            state <= 3'b111;
            card_declined <= 1'b1;
            if (!sender_exist) $display("Authentication Failed\n");
            else if (card_pin != passcode[senders_index]) $display("Wrong Password\n");
            else if (expiry_date <= `current_date) $display("Expired Card\n");
        end else begin
            card_declined <= 1'b0;
            case (operation)
                3'b001: state <= 3'b001; // Check balance
                3'b010: state <= 3'b010; // Withdraw money
                3'b011: state <= 3'b011; // Transfer money
                3'b100: state <= 3'b100; // Account report
                3'b101: state <= 3'b101; // Change password
                3'b110: state <= 3'b110; // Deposit money
                default: state <= 3'b000; // Stay idle
            endcase
        end
    end

    always @(posedge clk) begin
        case (state)
            3'b000: begin
                // Idle state
            end
            3'b001: begin // Check balance
                $display("Balance: %d\n", bank_balance[senders_index]);
                state <= 3'b000;
            end
            3'b010: begin // Withdraw money
                if (withdraw_amount <= bank_balance[senders_index]) begin
                    bank_balance[senders_index] = bank_balance[senders_index] - withdraw_amount;
                    $display("₹%d withdrawn!\n", withdraw_amount);
                    $display("Current Balance: %d\n", bank_balance[senders_index]);
                end else begin
                    $display("Insufficient Balance!\n");
                    card_declined <= 1'b1;
                end
                state <= 3'b000;
            end
            3'b011: begin // Transfer money
                if (sendee_exist == 1'b1) begin
                    if (transfer_amount <= bank_balance[senders_index] && transfer_amount + bank_balance[sendee_index] < 1024) begin
                        bank_balance[senders_index] = bank_balance[senders_index] - transfer_amount;
                        bank_balance[sendee_index] = bank_balance[sendee_index] + transfer_amount;
                        amount_deposited[sendee_index] = amount_deposited[sendee_index] + transfer_amount;
                        $display("Amount of %d sent!\n", transfer_amount);
                        $display("New balance: %d\n", bank_balance[senders_index]);
                    end else if (transfer_amount > bank_balance[senders_index]) begin
                        $display("Insufficient Balance\n");
                    end else if (transfer_amount + bank_balance[sendee_index] >= 1024) begin
                        $display("Reached the limit\n");
                    end
                end else begin
                    $display("Sendee Account does not exist\n");
                end
                state <= 3'b000;
            end
            3'b100: begin // Account report
                $display("Account report --> Deposited: +%d, Withdrawn: -%d, Account Balance: %d\n", 
                        amount_deposited[senders_index], 
                        `min_balance + amount_deposited[senders_index] - bank_balance[senders_index], 
                        bank_balance[senders_index]);
                state <= 3'b000;
            end
            3'b101: begin // Change password
                passcode[senders_index] = new_pin;
                $display("Changed your password\n");
                state <= 3'b000;
            end
            3'b110: begin // Deposit money
                if (bank_balance[senders_index] + deposit_money < 1024) begin
                    bank_balance[senders_index] = bank_balance[senders_index] + deposit_money;
                    amount_deposited[senders_index] = amount_deposited[senders_index] + deposit_money;
                    $display("₹%d deposited!\n", deposit_money);
                    $display("New Balance: %d\n", bank_balance[senders_index]);
                end else begin
                    $display("Reached the limit\n");
                end
                state <= 3'b000;
            end
        endcase
    end
endmodule
