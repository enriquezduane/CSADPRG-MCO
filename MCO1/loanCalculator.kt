class LoanCalculator(
    private var loanAmount: Double,   // Loan amount in PHP
    private var annualIR: Double,     // Annual interest rate in percentage
    private val loanTerm: Int         // Loan term in years
) {

    val mLoanTerm = loanTerm * 12
    fun calculateMonthlyIR(): Double {
        return annualIR / 12
    }

    fun calculateTotalInterest(): Double {
        val monthlyIR = calculateMonthlyIR()
        return loanAmount * monthlyIR * mLoanTerm
    }

    fun calculateMonthlyRepayment(): Double {
        val totalInterest = calculateTotalInterest()
        return (loanAmount + totalInterest) / mLoanTerm
    }
    fun getLoanAmount(): Double {
        return loanAmount
    }

    fun setLoanAmount(amount: Double) {
        loanAmount = amount
    }

    fun getAnnualInterestRate(): Double {
        return annualIR * 100
    }

    fun setAnnualInterestRate(rate: Double) {
        annualIR = rate
    }
   
}
 
    fun main() {
        print("Enter loan amount (PHP): ")
        val loanAmount = readLine()?.toDoubleOrNull() ?: 0.0
        //val loanAmount = readln().toDouble
    
        print("Enter annual interest rate (%): ")
        val annualIR = readLine()?.toDoubleOrNull() ?: 0.0
        //val annualIR = readln().toDouble
    
        print("Enter loan term (years): ")
        val loanTerm = readLine()?.toIntOrNull() ?: 1
        //val loanTerm = readln().toInt()
    
        val calculator = LoanCalculator(loanAmount, annualIR, loanTerm)
   
        println("Loan Amount: PHP ${calculator.getLoanAmount()}")
        println("Annual Interest Rate: ${calculator.getAnnualInterestRate()}%")
        println("Loan Term: $loanTerm years")
        println("Monthly Repayment: PHP ${"%.2f".format(calculator.calculateMonthlyRepayment())}")
        println("Total Interest: PHP ${"%.2f".format(calculator.calculateTotalInterest())}")
    }
