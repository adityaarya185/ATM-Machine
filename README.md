# ATM Module in Verilog

## Overview

This repository contains the implementation of an ATM module in Verilog. The ATM module supports various operations such as checking balance, withdrawing money, transferring money, depositing money, and changing the password.

## Features

- **Account Verification**: Verifies the existence of the account and checks the pin and expiry date.
- **Balance Check**: Allows checking the current balance of the account.
- **Money Withdrawal**: Supports withdrawing money from the account.
- **Money Transfer**: Supports transferring money to another account.
- **Account Report**: Provides a report of deposited, withdrawn, and current balance.
- **Password Change**: Allows changing the account pin.
- **Money Deposit**: Supports depositing money into the account.

## Files

- `atm.v`: Contains the ATM module and account module implementation.
- `atm_tb.v`: Testbench for the ATM module.

## Module Descriptions

### `account`

This module handles the verification of the account based on the card number and expiry date.

**Parameters:**
- `card_no`: Card number.
- `expiry_date`: Expiry date of the card.

**Outputs:**
- `index`: Index of the account in the bank database.
- `is_exist`: Indicates if the account exists.

### `top_module`

This is the main ATM module that integrates the account verification and supports various ATM operations.

**Inputs:**
- `clk`: Clock signal.
- `reset`: Reset signal.
- `operation`: Operation to be performed.
- `deposit_money`: Amount to be deposited.
- `card_no`: Card number.
- `transfer_no`: Transfer recipient card number.
- `transfer_amount`: Amount to be transferred.
- `withdraw_amount`: Amount to be withdrawn.
- `card_pin`: Current pin of the card.
- `new_pin`: New pin for the card.
- `expiry_date`: Expiry date of the card.

**Outputs:**
- `card_declined`: Indicates if the card is declined.

## Usage

1. **Instantiate the `top_module`** in your testbench or top-level design.
2. **Configure the inputs** (`clk`, `reset`, `operation`, `deposit_money`, `card_no`, `transfer_no`, `transfer_amount`, `withdraw_amount`, `card_pin`, `new_pin`, `expiry_date`).
3. **Monitor the outputs** (`card_declined`).

### Example Instantiation

```verilog
top_module uut (
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
```
### Testbench
### `top_module_tb`
This testbench verifies the functionality of the ATM module by simulating various operations.
