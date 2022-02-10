using CSV
using DataFrames

csv_reader = CSV.File("small.csv")
println(typeof(csv_reader))

for row in csv_reader
    println(typeof(row))
end

for row in csv_reader
    println("$row.col1")
end

