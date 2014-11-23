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

function _iterxsv(io::IO; delimiter=','::Char, quotechar='"'::Char, strtype="ascii", close_io=false::Bool)
    string_type = get_string_type(strtype)
    state = FieldState.not_in_field
    delimiter_n = uint8(delimiter)
    quotechar_n = uint8(quotechar)
    r_newline_n = 0x0d
    n_newline_n = 0x0a
    row     = Array(string_type, 0)
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
                push!(row, string_type(field))
                produce(row)
                field = Array(Uint8, 1024)
                n_field = 0
                row = Array(string_type, 0)
                state = FieldState.not_in_field
            elseif c==delimiter_n
                resize!(field, n_field)
                push!(row, string_type(field))
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
                push!(row, string_type(field))
                field = Array(Uint8, 1024)
                n_field = 0
                produce(row)
                row = Array(string_type, 0)
                state = FieldState.not_in_field
            elseif c==delimiter_n
                resize!(field, n_field)
                push!(row, string_type(field))
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
        push!(row, string_type(field))
    end
    if length(row)>0
    	produce(row)
    end
    if close_io
    	close(io)
    end
end

function clean_col_names(field_names::Array{ASCIIString,1})
    cleaned_field_names = Array(ASCIIString, 0)
    for field_name=field_names
        cleaned_field_name = field_name
        if "type"==field_name
            cleaned_field_name = "type_0"
        end
        push!(cleaned_field_names, cleaned_field_name)
    end
    cleaned_field_names
end

abstract XsvRow
function create_xsv_row_type(field_names::Array{ASCIIString,1}; strtype="ascii"::ASCIIString, type_name=""::ASCIIString)
    field_names = clean_col_names(field_names)
    string_type = get_string_type(strtype::String)
    if type_name==""
        num = 1
        while isdefined(symbol("Xsv" * string(num) * "Row"))
            num += 1
        end
        type_name = "Xsv" * string(num) * "Row"
    end
    type_string = "type $type_name <: XsvRow\n";

    for field_name = field_names
        type_string = type_string*"    $field_name::$string_type\n"
    end
    eval(parse(type_string*"end"))
    eval(parse(type_name))
end

iterxsv(io::IO; delimiter=','::Char, quotechar='"'::Char, strtype="ascii"::String, close_io=false::Bool) = @task _iterxsv(io, delimiter=delimiter, quotechar=quotechar, strtype=strtype, close_io=close_io)
iterxsv(data::String; delimiter=','::Char, quotechar='"'::Char, strtype="ascii"::String) = iterxsv(IOBuffer(data), delimiter=delimiter, quotechar=quotechar, strtype=strtype)
function _iterxsvh(io::IO; delimiter=','::Char, quotechar='"'::Char, strtype="ascii"::String, close_io=false::Bool) 
    xsv_stream = iterxsv(io, delimiter=delimiter, quotechar=quotechar, strtype=strtype, close_io=close_io)
    header = consume(xsv_stream)
    xsv_row = create_xsv_row_type(header, strtype=strtype)
    for row in xsv_stream
       produce(xsv_row(row...))
    end
end
iterxsvh(data::String; delimiter=','::Char, quotechar='"'::Char, strtype="ascii"::String) = @task _iterxsvh(IOBuffer(data), delimiter=delimiter, quotechar=quotechar, strtype=strtype)

function readxsv(io::IO; delimiter=','::Char, quotechar='"'::Char, strtype="ascii"::String, close_io=false::Bool)
	string_type = get_string_type(strtype)
	rows = Array(Vector{string_type}, 0)
	for row in iterxsv(io, delimiter=delimiter, quotechar=quotechar, strtype=strtype, close_io=close_io)
		push!(rows, row)
	end
	rows
end
readxsv(data::String; delimiter=',', quotechar='"', strtype="ascii"::String) = readxsv(IOBuffer(data), delimiter=delimiter, quotechar=quotechar, strtype=strtype)

fiterxsv(xsv_file::String; delimiter=',', quotechar='"', strtype="ascii"::String) = @task _iterxsv(open(xsv_file), delimiter=delimiter, quotechar=quotechar, strtype=strtype, close_io=true)
fiterxsvh(xsv_file::String; delimiter=',', quotechar='"', strtype="ascii"::String) = @task _iterxsvh(open(xsv_file), delimiter=delimiter, quotechar=quotechar, strtype=strtype, close_io=true)
freadxsv(xsv_file::String; delimiter=',', quotechar='"', strtype="ascii"::String) = readxsv(open(xsv_file), delimiter=delimiter, quotechar=quotechar, strtype=strtype, close_io=true)
