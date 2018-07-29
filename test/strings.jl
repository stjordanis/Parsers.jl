@testset "Strings" begin

@testset "String Parsers.Sentinel" begin

r = Parsers.parse(Parsers.Sentinel(["NA"]), IOBuffer("NA"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('A')
r = Parsers.parse(Parsers.Sentinel(["\\N"]), IOBuffer("\\N"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('N')
r = Parsers.parse(Parsers.Sentinel(["NA"]), IOBuffer("NA2"), String)
@test r.result === "NA2"
@test r.code === Parsers.OK
@test r.b === UInt8('2')
r = Parsers.parse(Parsers.Sentinel(["-", "NA", "\\N"]), IOBuffer("-"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('-')
r = Parsers.parse(Parsers.Sentinel(["£"]), IOBuffer("£"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === 0xa3
r = Parsers.parse(Parsers.Sentinel(["NA"]), IOBuffer("null"), String)
@test r.result === "null"
@test r.code === Parsers.OK
@test r.b === UInt8('l')
r = Parsers.parse(Parsers.Sentinel(String[]), IOBuffer("null"), String)
@test r.result === "null"
@test r.code === Parsers.OK
@test r.b === UInt8('l')
r = Parsers.parse(Parsers.Sentinel(String[]), IOBuffer(""), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Sentinel(String["NA"]), IOBuffer(""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Sentinel(String[]), IOBuffer(","), String)
@test r.result === ","
@test r.code === Parsers.OK
@test r.b === UInt8(',')
r = Parsers.parse(Parsers.Sentinel(String[]), IOBuffer("1,"), String)
@test r.result === "1,"
@test r.code === Parsers.OK
@test r.b === UInt8(',')

end # @testset

@testset "String Parsers.Quoted" begin

r = Parsers.parse(Parsers.Quoted(), IOBuffer(""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"\""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("1"), String)
@test r.result === "1"
@test r.code === Parsers.OK
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"1\""), String)
@test r.result === "1"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"1a\""), String)
@test r.result === "1a"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"1abc\""), String)
@test r.result === "1abc"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("1a"), String)
@test r.result === "1a"
@test r.code === Parsers.OK
@test r.b === UInt8('a')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"1"), String)
@test r.result == "1"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"1a"), String)
@test r.result == "1a"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('a')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"1abc"), String)
@test r.result == "1abc"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('c')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"1\\"), String)
@test r.result == "1"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('\\')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"1\\\""), String)
@test r.result == "1\\\""
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(), IOBuffer("\"1\\\"\""), String)
@test r.result == "1\\\""
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted('"', '"'), IOBuffer("\"1ab\"\"c\""), String)
@test r.result === "1ab\"\"c"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted('"', '"'), IOBuffer("\"1ab\""), String)
@test r.result === "1ab"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted('"', '"'), IOBuffer("\"1ab\"\""), String)
@test r.result === "1ab\"\""
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('"')

end # @testset

@testset "String Parsers.Quoted + Parsers.Sentinel" begin

r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer(""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("\"\""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(String[])), IOBuffer("\"\""), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("NA"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('A')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("\"NA\""), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("\"NA"), String)
@test r.result === missing
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('A')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("\"NA2"), String)
@test r.result === "NA2"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('2')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("\"NA2\""), String)
@test r.result === "NA2"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("\"+1\""), String)
@test r.result === "+1"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("\"+1"), String)
@test r.result === "+1"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("\"NAabc\""), String)
@test r.result === "NAabc"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(["NA"])), IOBuffer("\"NA\\\"abc\""), String)
@test r.result === "NA\\\"abc"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(String[]), '"', '"'), IOBuffer("\"1ab\"\"c\""), String)
@test r.result === "1ab\"\"c"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(String[]), '"', '"'), IOBuffer("\"1ab\""), String)
@test r.result === "1ab"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Quoted(Parsers.Sentinel(String[]), '"', '"'), IOBuffer("\"1ab\"\""), String)
@test r.result === "1ab\"\""
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('"')

end # @testset

@testset "String Parsers.Delimited" begin

r = Parsers.parse(Parsers.Delimited(), IOBuffer(""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Delimited(), IOBuffer("1"), String)
@test r.result === "1"
@test r.code === Parsers.OK
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Delimited(), IOBuffer("1,"), String)
@test r.result === "1"
@test r.code === Parsers.OK
@test r.b === UInt8(',')
r = Parsers.parse(Parsers.Delimited(), IOBuffer("1;"), String)
@test r.result === "1;"
@test r.code === Parsers.OK
@test r.b === UInt8(';')
r = Parsers.parse(Parsers.Delimited(',', '\n'), IOBuffer("1\n"), String)
@test r.result === "1"
@test r.code === Parsers.OK
@test r.b === UInt8('\n')
r = Parsers.parse(Parsers.Delimited(',', '\n'), IOBuffer("1abc\n"), String)
@test r.result === "1abc"
@test r.code === Parsers.OK
@test r.b === UInt8('\n')

end # @testset

@testset "String Parsers.Delimited + Parsers.Sentinel" begin

r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(["NA"])), IOBuffer("NA"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('A')
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(["\\N"])), IOBuffer("\\N"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('N')
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(["NA"])), IOBuffer("NA2"), String)
@test r.result === "NA2"
@test r.code === Parsers.OK
@test r.b === UInt8('2')
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(["-", "NA", "\\N"])), IOBuffer("-"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('-')
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(["£"])), IOBuffer("£"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === 0xa3
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(["NA"])), IOBuffer("null"), String)
@test r.result === "null"
@test r.code === Parsers.OK
@test r.b === UInt8('l')
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(String[])), IOBuffer("null"), String)
@test r.result === "null"
@test r.code === Parsers.OK
@test r.b === UInt8('l')
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(String[])), IOBuffer(""), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(String["NA"])), IOBuffer(""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(String[])), IOBuffer(","), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8(',')
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(String[])), IOBuffer("1,"), String)
@test r.result === "1"
@test r.code === Parsers.OK
@test r.b === UInt8(',')
r = Parsers.parse(Parsers.Delimited(Parsers.Sentinel(String[])), IOBuffer("1abc,"), String)
@test r.result === "1abc"
@test r.code === Parsers.OK
@test r.b === UInt8(',')

end # @testset

@testset "String Parsers.Delimited + Parsers.Quoted" begin

r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer(""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"\""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("1"), String)
@test r.result === "1"
@test r.code === Parsers.OK
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1\""), String)
@test r.result === "1"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1a\""), String)
@test r.result === "1a"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1abc\""), String)
@test r.result === "1abc"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("1a"), String)
@test r.result === "1a"
@test r.code === Parsers.OK
@test r.b === UInt8('a')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1"), String)
@test r.result == "1"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1a"), String)
@test r.result == "1a"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('a')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1abc"), String)
@test r.result == "1abc"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('c')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1\\"), String)
@test r.result == "1"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('\\')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1\\\""), String)
@test r.result == "1\\\""
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1\\\"\""), String)
@test r.result == "1\\\""
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted()), IOBuffer("\"1\"abc,"), String)
@test r.result === "1"
@test r.code === Parsers.INVALID
@test r.b === UInt8(',')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted('"', '"')), IOBuffer("\"1ab\"\"c\""), String)
@test r.result === "1ab\"\"c"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted('"', '"')), IOBuffer("\"1ab\""), String)
@test r.result === "1ab"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted('"', '"')), IOBuffer("\"1ab\"\""), String)
@test r.result === "1ab\"\""
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('"')

end # @testset

@testset "String Parsers.Delimited + Parsers.Quoted + Parsers.Sentinel" begin

r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer(""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === 0x00
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"\""), String)
@test r.result === ""
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(String[]))), IOBuffer("\"\""), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("NA"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('A')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA\""), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA"), String)
@test r.result === missing
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('A')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA2"), String)
@test r.result === "NA2"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('2')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA2\""), String)
@test r.result === "NA2"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"+1\""), String)
@test r.result === "+1"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"+1"), String)
@test r.result === "+1"
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('1')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NAabc\""), String)
@test r.result === "NAabc"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NA"]))), IOBuffer("\"NA\\\"abc\""), String)
@test r.result === "NA\\\"abc"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(String[]), '"', '"')), IOBuffer("\"1ab\"\"c\""), String)
@test r.result === "1ab\"\"c"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(String[]), '"', '"')), IOBuffer("\"1ab\""), String)
@test r.result === "1ab"
@test r.code === Parsers.OK
@test r.b === UInt8('"')
r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(String[]), '"', '"')), IOBuffer("\"1ab\"\""), String)
@test r.result === "1ab\"\""
@test r.code === Parsers.INVALID_QUOTED_FIELD
@test r.b === UInt8('"')

r = Parsers.parse(Parsers.Delimited(Parsers.Quoted(Parsers.Sentinel(["NULL"]), '"', '\\')), IOBuffer("NULL,6.0\n7.0,8.0,9.0"), String)
@test r.result === missing
@test r.code === Parsers.OK
@test r.b === UInt8(',')

end # @testset

end # @testset
