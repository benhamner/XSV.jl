using Base.Test
using XSV

xsv_string, xsv_data = genxsv(num_rows=100, num_cols=10)

@test length(xsv_data)==100
@test length(xsv_data[1])==10

parsed_data = readxsv(xsv_string)

for i=1:100
	for j=1:10
		@test parsed_data[i][j]==xsv_data[i][j]
	end
end
