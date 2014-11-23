# generate fake XSV data

function genxsv(;num_rows  = 100,
                 num_cols  = 10,
                 quotechar = '"',
                 delimiter = ',',
                 max_field = 20,
                 new_line  = "\n")
	field_data = Array(ASCIIString, 0)
    row_data   = Array(Vector{ASCIIString}, 0)
    rows       = Array(Vector{ASCIIString}, 0)

    for i=1:num_rows
        fields     = Array(ASCIIString, 0)
        field_data = Array(ASCIIString, 0) 
        for i=1:num_cols
            field = ASCIIString(rand(0x00:0x7f, rand(1:max_field)))
            push!(field_data, field)
            if in(quotechar, field)
            	field = join(split(field, quotechar), string(quotechar)*string(quotechar))
            end
            if in(quotechar, field) || in(delimiter, field) || contains(new_line, field) || in('\n', field) || in('\r', field)
                field = string(quotechar) * field * string(quotechar)
            end
            push!(fields, field)
        end
        push!(row_data, field_data)
        push!(rows, fields)
    end
    join([join(row, delimiter) for row in rows], new_line), row_data
end
