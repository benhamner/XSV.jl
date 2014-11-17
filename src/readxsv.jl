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

function get_string_type(strtype::String)
	if lowercase(strtype)=="ascii"
		return ASCIIString
	elseif lowercase(strtype)=="utf8"
		return UTF8String
	end
	throw(@sprintf("Invalid String Type %s", strtype))
end

function _iterxsv(io::IO; delimiter=','::Char, quotechar='"'::Char, strtype="ascii")
    stringType = get_string_type(strtype)
    state = FieldState.not_in_field
    delimiter_n = uint8(delimiter)
    quotechar_n = uint8(quotechar)
    r_newline_n = 0x0d
    n_newline_n = 0x0a
    row     = Array(stringType, 0)
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
                push!(row, stringType(field))
                produce(row)
                field = Array(Uint8, 1024)
                n_field = 0
                row = Array(stringType, 0)
                state = FieldState.not_in_field
            elseif c==delimiter_n
                resize!(field, n_field)
                push!(row, stringType(field))
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
                push!(row, stringType(field))
                field = Array(Uint8, 1024)
                n_field = 0
                produce(row)
                row = Array(stringType, 0)
                state = FieldState.not_in_field
            elseif c==delimiter_n
                resize!(field, n_field)
                push!(row, stringType(field))
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
        push!(row, stringType(field))
    end
    if length(row)>0
    	produce(row)
    end
end

iterxsv(io::IO; delimiter=','::Char, quotechar='"'::Char, strtype="ascii"::String) = @task _iterxsv(io, delimiter=delimiter, quotechar=quotechar, strtype=strtype)
iterxsv(data::String; delimiter=','::Char, quotechar='"'::Char, strtype="ascii"::String) = iterxsv(IOBuffer(data), delimiter=delimiter, quotechar=quotechar, strtype=strtype)
function readxsv(io::IO; delimiter=','::Char, quotechar='"'::Char, strtype="ascii"::String)
	stringType = get_string_type(strtype)
	rows = Array(Vector{stringType}, 0)
	for row in iterxsv(io, delimiter=delimiter, quotechar=quotechar, strtype=strtype)
		push!(rows, row)
	end
	rows
end
readxsv(data::String; delimiter=',', quotechar='"', strtype="ascii"::String) = readxsv(IOBuffer(data), delimiter=delimiter, quotechar=quotechar, strtype=strtype)

function freadxsv(xsv_file::String; delimiter=',', quotechar='"', strtype="ascii"::String)
	io = open(xsv_file)
	xsv = readxsv(io, delimiter=delimiter, quotechar=quotechar, strtype=strtype)
	close(io)
	xsv
end
