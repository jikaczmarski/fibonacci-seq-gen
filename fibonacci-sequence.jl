# Required packages
using ArgParse, BenchmarkTools, Plots

# Setting up the arg parser
function parse_commandline()
    s = ArgParseSettings(version = "Version a0.2", add_version = true)
    @add_arg_table! s begin
        "n"
            help = "Specify n-th integer for the Fibonacci Sequence to calculate"
            arg_type = Int
            default = nothing
            required = true
        "--memoize"
            help = "Enables recursion with memoization"
            action = :store_const
            default = 0
            constant = 1
        "--binet"
            help = "Enables calculation with Binet's formula"
            action = :store_const
            default = 0
            constant = 1
        "--speed-test"
            help = "Computes each number 1000 times and compares average computational time across algorithms"
            action = :store_const
            default = 0
            constant = 1
        "--recursive-plotter"
            help = "Computes average speed of calculating F_{n}, for n = 1 to n, for each method and then plots the results."
            action = :store_const
            default = 0
            constant = 1
    end
    return parse_args(s)
end

parsed_args = parse_commandline()

# Defining the fibonacci sequence
function fib(n::Int)
    if n == 0 
        return 0 
    end
    if n == 1 
        return 1 
    end
    return fib(n - 1) + fib(n - 2)
end

# Defining the fibonacci sequence with memoization
function fibmemo(n::Int)
    known = zeros(BigInt, n) # Create an nx1 vector of zeros
    function memoize(k)
        if known[k] != 0
        elseif k == 1 || k == 2
            known[k] = 1
        else 
            known[k] = memoize(k-1) + memoize(k-2)
        end
        return known[k]
    end
    return memoize(n)
end

# Defining the binet formula
function fib_binet(n)
    phi = (1 + sqrt(5))/2
    gamma = (1 - sqrt(5))/2
    fib_n = 1/sqrt(5) * (phi^n - gamma^n)
    return BigInt(round(fib_n))
end

# Outputs
if parsed_args["memoize"] == 1
    println("Result for Memoized Recursion Fibonacci Sequence at F_{",parsed_args["n"],"}: ",fibmemo(parsed_args["n"]))
elseif parsed_args["binet"] == 1
    println("Result for Binet's Fibonacci Sequence Formula at F_{",parsed_args["n"],"}: ",fib_binet(parsed_args["n"]))
elseif parsed_args["speed-test"] == 1
    b_fib = @benchmark fib(parsed_args["n"])
    b_memoize = @benchmark fibmemo(parsed_args["n"])
    b_binet = @benchmark fib_binet(parsed_args["n"])
    println("Speed Test Results for F_{", parsed_args["n"],"}:\nFibonacci: ", round(median(b_fib).time, digits = 3)," ns\nMemoize: ", round(median(b_memoize).time, digits = 3), " ns\nBinet's: ", round(median(b_binet).time, digits = 3), " ns")
elseif parsed_args["recursive-plotter"] == 1
    n_array = Array{Int}(0:parsed_args["n"])
    fib_array = Array{Float64}(undef,0)
    memoize_array = Array{Float64}(undef,0)
    binet_array = Array{Float64}(undef,0)
    for i in eachindex(n_array)
        global b_fib = @benchmark fib(parsed_args["n"])
        push!(fib_array,round(median(b_fib).time,digits = 3))
        global b_memoize = @benchmark fibmemo(parsed_args["n"])
        push!(memoize_array,round(median(b_memoize).time,digits = 3))
        global b_binet = @benchmark fib_binet(parsed_args["n"])
        push!(binet_array,round(median(b_binet).time,digits = 3))
    end
    data = hcat(n_array, fib_array, memoize_array, binet_array)
    plot(n_array,[fib_array memoize_array binet_array], show = true)
else
    println("Result for Fibonacci Sequence at F_{",parsed_args["n"],"}: ",fib(parsed_args["n"]))
end
#exit()