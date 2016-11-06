# Shunting-Yard Algorithm (parser-based version)

### Description

It's a slightly advanced implementation of the shunting-yard algorithm.  
It reads expression from the `input.txt`, parses it, asks for variable values (if needed), then evaluates and prints result step-by-step.  

That it supports:  
* Numbers in decimal notation (dot `.` should be used as decimal separator).  
* Arithmetic operations: addition `+`, subtraction `-`, multiplication `*`, division `/`, exponentiation `^`.  
* Math functions as `function(x)`: sine `sin`, cosine `cos`, exponential `exp`, natural logarithm `log`, square root `sqrt`.  
* Variables.  
* Precedence of operations (using parentheses: `(` and `)`).  
* Automatically skipping whitespace.  
* Reporting errors in the expression.  

Unfortunately, it doesn't support expressions as functions arguments.  
