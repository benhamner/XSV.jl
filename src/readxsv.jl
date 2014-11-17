# abstract FieldState
# type NotInField          <: FieldState end
# type InQuotedField       <: FieldState end
# type InUnQuotedField     <: FieldState end
# type InDoubleQuotedField <: FieldState end

# not_in_field           = NotInField()
# in_quoted_field        = InQuotedField()
# in_un_quoted_field     = InUnQuotedField()
# in_double_quoted_field = InDoubleQuotedField()

baremodule FieldState
    not_in_field           = 1
    in_quoted_field        = 2
    in_un_quoted_field     = 3
    in_double_quoted_field = 4
end

function readxsv(io::IO, delimiter::Char, quotechar::Char)
    state = FieldState.not_in_field
    delimiter_n = uint8(delimiter)
    quotechar_n = uint8(quotechar)
    r_newline_n = 0x0d
    n_newline_n = 0x0a
    rows    = Array(Vector{ASCIIString}, 0)
    row     = Array(ASCIIString, 0)
    field   = Array(Uint8, 1024)
    n_field = 0

    while !eof(io)
        c = read(io, Uint8)
        if state==FieldState.not_in_field
            if c==quotechar_n
                state = FieldState.in_quoted_field
            elseif c==r_newline_n || c==n_newline_n
                # state remains the same
            elseif c==delimiter_n
                push!(row, "")
                # state remains the same
            else
            	n_field += 1
                field[n_field] = c
                state = FieldState.in_un_quoted_field
            end
        elseif state==FieldState.in_quoted_field
            if c==quotechar_n
                state = FieldState.in_double_quoted_field
            else
                if n_field==length(field)
                    resize!(field, length(field)*2)
                end
                n_field += 1
                field[n_field] = c # state remains the same
            end
        elseif state==FieldState.in_un_quoted_field
            if c==r_newline_n || c==n_newline_n
            	resize!(field, n_field)
                push!(row, ASCIIString(field))
                push!(rows, row)
                field = Array(Uint8, 1024)
                n_field = 0
                row = Array(ASCIIString, 0)
                state = FieldState.not_in_field
            elseif c==delimiter_n
                resize!(field, n_field)
                push!(row, ASCIIString(field))
                field = Array(Uint8, 1024)
                n_field = 0
                state = FieldState.not_in_field
            else 
                if n_field==length(field)
                    resize!(field, length(field)*2)
                end
                n_field += 1
                field[n_field] = c # state remains the same
            end
        elseif state==FieldState.in_double_quoted_field
            if c==quotechar_n
                if n_field==length(field)
                    resize!(field, length(field)*2)
                end
                n_field += 1
                field[n_field] = c
                state = FieldState.in_quoted_field        
            elseif c==r_newline_n || c==n_newline_n
                resize!(field, n_field)
                push!(row, ASCIIString(field))
                field = Array(Uint8, 1024)
                n_field = 0
                push!(rows, row)
                row = Array(ASCIIString, 0)
                state = FieldState.not_in_field
            elseif c==delimiter_n
                resize!(field, n_field)
                push!(row, ASCIIString(field))
                field = Array(Uint8, 1024)
                n_field = 0
                state = FieldState.not_in_field
            else
                throw(@sprintf("Invalid Byte In Double Quoted Field: %s", string(c)))
            end
        else
            throw("Invalid State")
        end
    end
    if n_field>0
        resize!(field, n_field)
        push!(row, ASCIIString(field))
    end
    if length(row)>0
    	push!(rows, row)
    end
    rows
end

function readxsvs(data::String; delimiter=',', quotechar='"')
	readxsv(IOBuffer(data), delimiter, quotechar)
end

function readxsv(data::String; delimiter=",")
    return [split(x, delimiter) for x=split(data, "\n")]
end


