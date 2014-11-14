function readxsv(data)
    return [split(x, ",") for x=split(data, "\n")]
end
