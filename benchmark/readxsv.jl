using XSV

# Run on a small sample first
xsv_string, xsv_data = genxsv(num_rows=5, num_cols=2)
xsv_string_h = join(["C"*string(i) for i=1:length(xsv_data[1])], ",") * "\n" * xsv_string 
xsv = readxsv(xsv_string)
for row in iterxsv(xsv_string) end
for row in iterxsvh(xsv_string_h) end
for row in iterxsvht(xsv_string_h, row_type_name="XsvTestRow") end

xsv_string, xsv_data = genxsv(num_rows=20_000, num_cols=20)
println("readxsv:")
@time xsv = readxsv(xsv_string)
println("\niterxsv:")
@time for row in iterxsv(xsv_string) end

xsv_string_h = join(["C"*string(i) for i=1:length(xsv_data[1])], ",") * "\n" * xsv_string 
println("\niterxsvh:")
@time for row in iterxsvh(xsv_string_h) end

println("\niterxsvht:")
@time for row in iterxsvht(xsv_string_h) end
