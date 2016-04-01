import Foundation

typealias Symbol = String

var line: String! = readLine()
var inputBuffer = ""

while line.characters.first != "." {
    inputBuffer.appendContentsOf("\(line)\n")
    line = readLine()
}

inputBuffer.append(Character("."))

var look: Character!
var token: Character!
var value: String!

let kwList = ["X", "IF", "ELSE", "ENDIF", "WHILE", "ENDWHILE",
                "READ", "WRITE", "VAR", "BEGIN", "END", "PROGRAM"]

let kwCode = "xileweRWvbep"

var symTable = [Symbol : String]()

//Report an error
func error(message: String) {
    print("Error: \(message)")
}

//Report error and halt
func fail(message: String) {
    error(message)
    exit(-1)
}

func undefined(n: Symbol) {
    fail("Undefined Identifier: \(n)")
}

//Read new character from input stream
func getChar() {
    struct Static { static var index = 0 }

    let i = inputBuffer.startIndex.advancedBy(Static.index)
    guard i != inputBuffer.endIndex else {
        return
    }

    Static.index += 1
    look = inputBuffer.characters[i]
}

//Report what was expected and halt
func expected(thing: String) {
    fail("Expected \(thing)")
}

//Recognize an Alpha character
func isAlpha(c: Character) -> Bool {
    switch c {
    case "a"..."z":
        return true
    case "A"..."Z":
        return true
    default:
        return false
    }
}

//Recognize a decimal digit
func isDigit(c: Character) -> Bool {
    switch c {
    case "0"..."9":
        return true
    default:
        return false
    }
}

//Recognize alphanumeric character
func isAlNum(c: Character) -> Bool {
    return isAlpha(c) || isDigit(c)
}

//Recognize whitespace
func isWhite(c: Character) -> Bool {
    return " " == c || "\t" == c || "\n" == c
}

//Skip leading white space
func skipWhite() {
    while isWhite(look) {
        getChar()
    }
}

//func newLine() {
//    while look == "\n" {
//        getChar()
//        skipWhite()
//    }
//}

//Recognize an Addop
func isAddop(c: Character) -> Bool {
    return "+" == c || "-" == c
}

func isMulop(c: Character) -> Bool {
    return "*" == c || "/" == c
}

func isOrop(c: Character) -> Bool {
    return "|" == c || "~" == c
}

func isRelop(c: Character) -> Bool {
    return "=" == c || "#" == c || "<" == c || ">" == c
}

func inTable(n: Symbol) -> Bool {
    if let _ = symTable[n] {
        return true
    } else {
        return false
    }
}

//  Get an identifier
func getName() {
    skipWhite()

    guard isAlpha(look) else {
        expected("Identifier")
        exit(-1) // won't actually run but we have to make the compiler happy
    }

    var localValue = ""

    while isAlNum(look) {
        localValue = "\(localValue)\(look)"
        getChar()
    }

    token = "x"
    value = localValue.uppercaseString
}

//  Get a number
func getNum()  {
    skipWhite()

    guard isDigit(look) else {
        expected("Number")
        exit(-1)
    }

    var localValue = ""

    while isDigit(look) {
        localValue = "\(localValue)\(look)"
        getChar()
    }

    token = "#"
    value = localValue.uppercaseString
}

// Get an Operator
func getOp() {
    skipWhite()
    token = look
    value = "\(look)"
    getChar()
}

// Read the ` input and update token
func next() {
    skipWhite()

    if isAlpha(look) {
        getName()
    } else if isDigit(look) {
        getNum()
    } else {
        getOp()
    }
}

func lookup(s: String) -> Int {
    if let index = kwList.indexOf(s) {
        return index
    } else {
        return 0;
    }
}

func scan() {
    if token == "x" {
        let index = kwCode.startIndex.advancedBy(lookup(value))
        token = kwCode[index]
    }
}

func matchString(x: String) {
    if value != x {
        expected("\"\(x)\"")
    }

    next()
}

//Output a string with a leading tab
func emit(s: String, newline: Bool = true, leadtab: Bool = true) {

    let terminator = newline ? "\n" : ""
    let lead = leadtab ? "\t" : ""

    print("\(lead)\(s)", terminator: terminator)
}

// ## CODE GENERATION ROUTINES ##

func clear() {
    emit("d0 = 0")
}

func negate() {
    emit("d0 = -d0")
}

func loadConst(n: String) {
    emit("d0 = \(n)")
}

func loadVar(n: Symbol) {
    if !inTable(n) {
        undefined(n)
    }

    emit("d0 = variables[\"\(n)\"]!")
}

func push() {
    emit("stack.append(d0)")
}

func popAdd() {
    emit("d0 += stack.removeLast()")
}

func popSub() {
    emit("d0 -= stack.removeLast()")
    emit("d0 = -d0")
}

func popMul() {
    emit("d0 *= stack.removeLast()")
}

func popDiv() {
    emit("d1 = stack.removeLast()")
    emit("d0 = d1 / d0")
}

func store(name: Symbol) {
    if !inTable(name) {
        undefined(name)
    }

    emit("variables[\"\(name)\"] = d0")
}

func notIt() {
    emit("d0 = !d0")
}

func popAnd() {
    emit("d0 = d0 != 0 && stack.removeLast() != 0 ? -1 : 0")
}

func popOr() {
    emit("d0 = d0 != 0 || stack.removeLast() != 0 ? -1 : 0")
}

func popXor() {
    emit("d0 = d0 != stack.removeLast() ? -1 : 0")
}

func popCompareSetEqual() {
     emit("d0 = d0 == stack.removeLast() ? -1 : 0")
}

func popCompareSetNEqual() {
    emit("d0 = d0 != stack.removeLast() ? -1 : 0")
}

func popCompareSetGreater() {
    emit("d0 = stack.removeLast() > d0 ? -1 : 0")
}

func popCompareSetLess() {
    emit("d0 = stack.removeLast() < d0 ? -1 : 0")
}

func popCompareSetLessOrEqual() {
    emit("d0 = stack.removeLast() <= d0 ? -1 : 0")
}

func popCompareSetGreaterOrEqual() {
    emit("d0 = stack.removeLast() >= d0 ? -1 : 0")
}

func readVar() {
    emit("if let inputString = readLine(),")
    emit("let inputValue = Int(inputString) {")
    emit("d0 = inputValue")
    emit("} else {")
    emit("d0 = 0 }")
    store(value)
}

func writeVar() {
    emit("print(d0)")
}

// ## END CODE GENERATION

func doRead() {
    next()
    matchString("(")
    readVar()

    while token == "," {
        next()
        readVar()
    }

    matchString(")")
}

func doWrite() {
    next()
    matchString("(")
    `()
    writeVar()

    while token == "," {
        next()
        expression()
        writeVar()
    }

    matchString(")")
}

func doIf() {
    next()
    boolExpression()
    emit("if d0 != 0 {")
    block()
    if token == "l" {
        next()
        emit("} else {")
        block()
    }
    matchString("ENDIF")
    emit("}")
}

func doWhile() {
    //matchString("WHILE")
    emit("while true {")
    boolExpression()
    emit("if d0 == 0 { break }")
    block()
    matchString("ENDWHILE")
    emit("}")
}

func equals() {
    next()
    expression()
    popCompareSetEqual()
}

func notEquals() {
    next()
    expression()
    popCompareSetNEqual()
}

func lessOrEqual() {
    next()
    expression()
    popCompareSetLessOrEqual()
}

func less() {
    next()
    switch token {
    case "=":
        lessOrEqual()
    case ">":
        notEquals()
    default:
        expression()
        popCompareSetLess()
    }
}

func greater() {
    next()

    if token == "=" {
        next()
        expression()
        popCompareSetGreaterOrEqual()
    } else {
        expression()
        popCompareSetGreater()
    }
}

func relation() {
    expression()
    if isRelop(token) {
        push()
        switch token {
        case "=":
            equals()
        case "<":
            less()
        case ">":
            greater()
        default:
            break
        }
    }
}

func notFactor() {
    if token == "!" {
        next()
        relation()
        notIt()
    } else {
        relation()
    }
}

func boolTerm() {
    notFactor()
    while token == "&" {
        push()
        next()
        notFactor()
        popAnd()
    }
}

func boolOr() {
    next()
    boolTerm()
    popOr()
}

func boolXor() {
    next()
    boolTerm()
    popXor()
}

func boolExpression() {
    boolTerm()
    while isOrop(token) {
        push()
        switch token {
        case "|":
            boolOr()
        case "~":
            boolXor()
        default:
            break
        }
    }
}

func factor() {
    if token == "(" {
        next()
        boolExpression()
        matchString(")")
    } else if token == "x" {
        loadVar(value)
    } else if token == "#" {
        loadConst(value)
    }
}

func negFactor() {
    next()
    if isDigit(token) {
        loadConst(value)
    } else {
        factor()
    }

    negate()
}

func firstFactor() {
    switch token {
    case "+":
        next()
        factor()
    case "-":
        negFactor()
    default:
        factor()
    }
}

func multiply() {
    next()
    factor()
    popMul()
}

func divide() {
    next()
    factor()
    popDiv()
}

func term1() {
    while isMulop(token) {
        push()
        switch token {
        case "*":
            multiply()
        case "/":
            divide()
        default:
            break
        }
    }
}

func term() {
    factor()
    term1()
}

func firstTerm() {
    firstFactor()
    term1()
}

func add() {
    next()
    term()
    popAdd()
}

func subtract() {
    next()
    term()
    popSub()
}

func expression() {
    firstTerm()
    while isAddop(token) {
        push()
        switch token {
        case "+":
            add()
        case "-":
            subtract()
        default:
            break
        }
    }
}

func assignment() {
    let name = value
    next()
    boolExpression()
    store(name)
}

func block() {
    scan()

    while token != "e" && token != "l" {
        switch token {
        case "i":
            doIf()
        case "w":
            doWhile()
        case "R":
            doRead()
        case "W":
            doWrite()
        default:
            assignment()
        }

        scan()
    }
}

func addEntry(n: Symbol, t: Character) {
    if inTable(n) {
        fail("Duplicate Identifier: \(n)")
    }

    symTable[n] = String(t)
}

func alloc(n: Symbol) {
    if inTable(n) {
        fail("Duplicate Variable Name: \(n)")
    }

    let s = String(n)
    symTable[s] = "v"

    emit("variables[\"\(n)\"] = ", newline: false)

    if token == "=" {
        next()

        if token == "-" {
            emit("-", newline: false, leadtab: false)
            next()
        }

        emit(String(getNum()), leadtab: false)
    } else {
        emit("0", leadtab: false)
    }
}

func decl() {
    //match("v")
    getName()
    alloc(value)
    while token == "," {
        next()
        getName()
        alloc(value)
    }
}

func topDecls() {
    //newLine()
    scan()

    while token != "b" {
        switch token {
        case "v":
            decl()
        default:
            fail("Unrecognized keyword '\(look)'")
        }
        //newLine()
        scan()
    }
}

func main() {
    matchString("BEGIN")
    prolog()
    block()
    matchString("END")
    epilog()
}

func epilog() {
    emit("// END COMPILER OUTPUT")
}

func prolog() {

}

func header() {
    emit("// COMPILER OUTPUT")
    emit("var d0: Int")
    emit("var d1: Int")
    emit("var stack = [Int]()")
    emit("var variables = [String : Int]()")
}

func prog() {
    matchString("PROGRAM")
    header()
    topDecls()
    main()
    matchString(".")
}

func start() {
    getChar()
    next()
}

// MARK: Main
start()
prog()
