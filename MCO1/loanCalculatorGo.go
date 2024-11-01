package main

import (
    "bufio"
    "fmt"
    "os"
    "strconv"
    "strings"
)

func main() {
    reader := bufio.NewReader(os.Stdin)

    fmt.Print("Enter Loan Amount (PHP): ")
    loanAmountStr, _ := reader.ReadString('\n')
    loanAmountStr = strings.ReplaceAll(loanAmountStr, "PHP", "")
    loanAmountStr = strings.ReplaceAll(loanAmountStr, ",", "")
    loanAmountStr = strings.TrimSpace(loanAmountStr)
    loanAmount, err := strconv.ParseFloat(loanAmountStr, 64)
    if err != nil {
        fmt.Println("Invalid input for Loan Amount.")
        return
    }

    fmt.Print("Enter Annual Interest Rate (%): ")
    interestRateStr, _ := reader.ReadString('\n')
    interestRateStr = strings.TrimSpace(interestRateStr)
    interestRateStr = strings.TrimSuffix(interestRateStr, "%")
    annualInterestRate, err := strconv.ParseFloat(interestRateStr, 64)
    if err != nil {
        fmt.Println("Invalid input for Annual Interest Rate.")
        return
    }

    fmt.Print("Enter Loan Term (years): ")
    loanTermStr, _ := reader.ReadString('\n')
    loanTermStr = strings.ReplaceAll(loanTermStr, "years", "")
    loanTermStr = strings.TrimSpace(loanTermStr)
    loanTermYears, err := strconv.Atoi(loanTermStr)
    if err != nil {
        fmt.Println("Invalid input for Loan Term.")
        return
    }

    monthlyInterestRate := (annualInterestRate / 100) / 12
    loanTermMonths := loanTermYears * 12
    totalInterest := loanAmount * monthlyInterestRate * float64(loanTermMonths)
    monthlyRepayment := (loanAmount + totalInterest) / float64(loanTermMonths)

    fmt.Printf("\nLoan Amount: PHP %.2f\n", loanAmount)
    fmt.Printf("Annual Interest Rate: %.2f%%\n", annualInterestRate)
    fmt.Printf("Loan Term: %d months\n", loanTermMonths)
    fmt.Printf("Monthly Repayment: PHP %.2f\n", monthlyRepayment)
    fmt.Printf("Total Interest: PHP %.2f\n", totalInterest)
}
