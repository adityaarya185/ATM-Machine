`timescale 1ns/1ps
`include "atm_temp.v"
module top_module_tb;
    reg clk;
    reg reset;
    reg [9:0] card_no;
    reg [10:0] expiry_date;
    reg [9:0] transfer_no;
    reg [9:0] transfer_amount;
    reg [9:0] withdraw_amount;
    reg [9:0] card_pin;
    reg [9:0] new_pin;
    reg [9:0] deposit_money;
    reg [2:0] operation;
    wire card_declined;

    top_module uut
    (
        .clk(clk),
        .reset(reset),
        .operation(operation),
        .deposit_money(deposit_money),
        .card_no(card_no),
        .transfer_no(transfer_no),
        .transfer_amount(transfer_amount),
        .withdraw_amount(withdraw_amount),
        .card_pin(card_pin),
        .new_pin(new_pin),
        .expiry_date(expiry_date),
        .card_declined(card_declined)
    );

    initial
    begin
        // Initialize inputs
        $dumpfile("vcd_file.vcd");
        $dumpvars(0,top_module_tb);
        clk = 0;
        reset = 0;
        card_no = 10'd100;
        transfer_no = 10'd200;
        transfer_amount = 10'd50;
        withdraw_amount = 10'd20;
        card_pin = 10'd100;  // Correct initial pin
        new_pin = 10'd999;   // New pin
        deposit_money = 10'd30;
        expiry_date = `current_date;
        operation = 3'b000;  // Default operation

        // Wait 100 ns for global reset to finish
        #20;

        // Reseting ATM
        reset = 1;
        #10 reset = 0;

        // Performing some operations with the initial password
        // Checking balance
        operation = 3'b001;
        #10;

        // Withdrawing money
        operation = 3'b010;
        #10;

        // Depositing money
        operation = 3'b110;
        #10;

        // Changing password
        operation = 3'b101;
        #10;

        // Performing operations with the new password
        card_pin = new_pin;

        // Checking balance
        operation = 3'b001;
        #10;

        // Withdrawing money
        operation = 3'b010;
        #10;

        // Transfering money
        operation = 3'b011;
        #10;

        // Depositing money
        operation = 3'b110;
        #10;

        // Account report
        operation = 3'b100;
        #10;

        

        // Ending simulation
        $finish;
    end

    always #5 clk = ~clk; // Generate clock signal
endmodule
