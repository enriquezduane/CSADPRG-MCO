#!/usr/bin/env ruby

# ********************
# Last names: Enriquez, Gideon, Valenzuela
# Language: Ruby
# Paradigm(s): Object-Oriented
# ********************

# module that handles all currency formatting and calculations
module CurrencyHelper
  def format_currency(amount)

    # format with 2 decimal places inintially
    formatted = format('%.2f', amount)
    
    # regex to remove unnecessary decimal zeros
    formatted = formatted.sub(/\.?0+$/, '')
    
    # add commas for thousands
    whole, decimal = formatted.split('.')
    whole_with_commas = whole.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    
    # only add decimal part if exists
    final_amount = decimal ? "#{whole_with_commas}.#{decimal}" : whole_with_commas
    
    "PHP #{final_amount}"
  end

  def format_percentage(rate)
    # also handle unnecessary decimals in percentage
    formatted = format('%.2f', rate)
    formatted = formatted.sub(/\.?0+$/, '')
    "#{formatted}%"
  end
end

# validate user inputs
class InputValidator
  def self.validate_positive_number(input)
    # remove currency symbol, commas, and whitespace, then convert to float
    cleaned_input = input.gsub(/[PHP,\s]/, '')
    number = cleaned_input.to_f
    raise ArgumentError, "value must be positive" if number <= 0
    number
  rescue ArgumentError => e
    puts "Error: #{e.message}"
    nil
  end
end

# class that handles loan calculations
class LoanCalculator
  include CurrencyHelper

  def initialize(loan_amount, annual_rate, loan_years)
    @loan_amount = loan_amount
    @annual_rate = annual_rate
    @loan_years = loan_years
  end

  def monthly_interest_rate
    @annual_rate / (12 * 100)
  end

  def loan_term_months
    @loan_years * 12
  end

  def total_interest
    @loan_amount * monthly_interest_rate * loan_term_months
  end

  def monthly_repayment
    (@loan_amount + total_interest) / loan_term_months
  end

  def format_months(months)
    # remove .0 from the months display if it's a whole number
    formatted = format('%.2f', months)
    formatted = formatted.sub(/\.?0+$/, '')
    "#{formatted} months"
  end

  def loan_summary
    {
      loan_amount: format_currency(@loan_amount),
      annual_rate: format_percentage(@annual_rate),
      loan_term: format_months(loan_term_months),
      monthly_repayment: format_currency(monthly_repayment),
      total_interest: format_currency(total_interest)
    }
  end
end

# handle user interface
class LoanCalculatorUI
  def self.get_user_input(prompt)
    print prompt
    gets.chomp
  end

  def self.display_summary(summary)
    puts "\n"
    puts "Loan Amount: #{summary[:loan_amount]}"
    puts "Annual Interest Rate: #{summary[:annual_rate]}"
    puts "Loan Term: #{summary[:loan_term]}"
    puts "Monthly Repayment: #{summary[:monthly_repayment]}"
    puts "Total Interest: #{summary[:total_interest]}"
  end

  def self.run
    loan_amount = nil
    until loan_amount
      input = get_user_input("Loan Amount: ")
      loan_amount = InputValidator.validate_positive_number(input)
    end

    annual_rate = nil
    until annual_rate
      input = get_user_input("Annual Interest Rate: ")
      annual_rate = InputValidator.validate_positive_number(input)
    end

    loan_years = nil
    until loan_years
      input = get_user_input("Loan Term: ")
      loan_years = InputValidator.validate_positive_number(input)
    end

    calculator = LoanCalculator.new(loan_amount, annual_rate, loan_years)
    display_summary(calculator.loan_summary)
  end
end

# run the app
if __FILE__ == $PROGRAM_NAME
  LoanCalculatorUI.run
end
