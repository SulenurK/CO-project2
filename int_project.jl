using JuMP
using Gurobi


file_names = ["Inst1_20_4_win.txt", "RanInt_n030_ss_03.txt", "RanInt_n030_ss_05.txt", "RanInt_n040_ss_04.txt"]

for file in file_names

    computation_time = @elapsed begin

    f = open(dosya)
    lines = readlines(f)
    close(f)

    m, n = parse.(Int, split(lines[1]))

    matrix = zeros(m, m)
    for line in lines[2:end]
        i, j, value = parse.(Int, split(line))
        matrix[i, j] = value
        matrix[j, i] = value
    end

    # Model 
    model = Model(Gurobi.Optimizer)
    
    @variable(model, x[1:m, 1:n], Bin) # x[i,j] indicates if i is included by j th group
    
    @objective(model, Max, sum(matrix[i,j] * sum(x[i,:]) for i in 1:m, j in 1:n)) # objective function to maximize

    # each product belongs to only one group
    for i in 1:m
        @constraint(model, sum(x[i,:]) == 1)
    end

    # there are only m/n product in each group
    for j in 1:n
        @constraint(model, sum(x[:,j]) == m/n)
    end
    
    # solve the model
    optimize!(model)
    
    # Result
    println("Optimal value: ", objective_value(model))
    
    for j in 1:n
        println("Group ", j, ": ", sum(matrix[i,j]*value(x[i,j]) for i in 1:m))
    end

end
    println("Computation time for file $file: $computation_time sn")

end
