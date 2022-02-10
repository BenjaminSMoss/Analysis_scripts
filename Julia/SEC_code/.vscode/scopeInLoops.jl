# RUN ONLY ONE OF THESE EXAMPLES AT A TIME - CLEAR MEMORY BETWEEN RUNS

# This is problematic
x = 1
for i = 1:10 
    x += i
end
println(x)
#=
#this gives an error specifically pointing out the scope issue
x = 1
for i = 1:10 
    x = x + i
end

# this does not because the pre defined array is being mutated and 
# not re-declared 

x = ones(10)
for i = 1:10
    x[i] += i
end
=#