using Base.Test
using XSV

@test readxsv("1,2,3\n4,5,6")[1][1]=="1"
