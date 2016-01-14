import Foundation

var inputBuffer: String! = readLine()
var look: Character!

var symTable = [String : String]()
for c in "abcdefghijklmnopqrstuvwxyz".uppercaseString.characters {
    let s = String(c)
    symTable[s] = ""
}

//Report an error
func error(message: String) {
    print("Error: \(message)")
}

//Report error and halt
func fail(message: String) {
    error(message)
    exit(-1)
}

func undefined(n: Character) {
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

// Match a specific input character
func match(c: Character) {
    if look == c {
        getChar()
    } else {
        expected("'\(c)'")
    }
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
    return " " == c || "\t" == c
}

//Skip leading white space
func skipWhite() {
    while isWhite(look) {
        getChar()
    }
}

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

func inTable(c: Character) -> Bool {
    let s = String(c)

    if let symVal = symTable[s] where symVal == "" {
        return false
    } else {
        return true
    }
}

//Get an identifier
func getName() -> Character {
    guard isAlpha(look) else {
        expected("Name")
        exit(-1) // won't actually run but we have to make the compiler happy
    }

    let upper = String(look).capitalizedString.characters.first!
    getChar()
    return upper
}

//Get a number
func getNum() -> String {
    guard isDigit(look) else {
        expected("Integer")
        exit(-1) // won't actually run but we have to make the compiler happy
    }

    var value = ""

    while isDigit(look) {
        value = "\(value)\(look)"
        getChar()
    }

    return value
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

func loadVar(n: Character) {
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

func store(name: Character) {
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

// ## END CODE GENERATION

func doIf() {
    match("i")
    boolExpression()
    emit("if d0 != 0 {")
    block()
    if look == "l" {
        match("l")
        emit("} else {")
        block()
    }
    match("e")
    emit("}")
}

func doWhile() {
    match("w")
    emit("while true {")
    boolExpression()
    emit("if d0 == 0 { break }")
    block()
    match("e")
    emit("}")
}

func equals() {
    match("=")
    expression()
    popCompareSetEqual()
}

func notEquals() {
    match("#")
    expression()
    popCompareSetNEqual()
}

func less() {
    match("<")
    expression()
    popCompareSetLess()
}

func greater() {
    match(">")
    expression()
    popCompareSetGreater()
}

func relation() {
    expression()
    if isRelop(look) {
        push()
        switch look {
        case "=":
            equals()
        case "#":
            notEquals()
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
    if look == "!" {
        match("!")
        relation()
        notIt()
    } else {
        relation()
    }
}

func boolTerm() {
    notFactor()
    while look == "&" {
        push()
        match("&")
        notFactor()
        popAnd()
    }
}

func boolOr() {
    match("|")
    boolTerm()
    popOr()
}

func boolXor() {
    match("~")
    boolTerm()
    popXor()
}

func boolExpression() {
    boolTerm()
    while isOrop(look) {
        push()
        switch look {
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
    if look == "(" {
        match("(")
        boolExpression()
        match(")")
    } else if isAlpha(look) {
        loadVar(getName())
    } else {
        loadConst(getNum())
    }
}

func negFactor() {
    match("-")
    if isDigit(look) {
        loadConst(getNum())
    } else {
        factor()
    }

    negate()
}

func firstFactor() {
    switch look {
    case "+":
        match("+")
        factor()
    case "-":
        negFactor()
    default:
        factor()
    }
}

func multiply() {
    match("*")
    factor()
    popMul()
}

func divide() {
    match("/")
    factor()
    popDiv()
}

func term1() {
    while isMulop(look) {
        push()
        switch look {
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
    match("+")
    term()
    popAdd()
}

func subtract() {
    match("-")
    term()
    popSub()
}

func expression() {
    firstTerm()
    while isAddop(look) {
        push()
        switch look {
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
    let name = getName()
    match("=")
    boolExpression()
    store(name)
}

func block() {
    while look != "e" && look != "l" {
        switch look {
        case "i":
            doIf()
        case "w":
            doWhile()
        default:
            assignment()
        }
    }
}

func alloc(n: Character) {
    if inTable(n) {
        fail("Duplicate Variable Name: \(n)")
    }

    let s = String(n)
    symTable[s] = "v"

    emit("variables[\"\(n)\"] = ", newline: false)

    if look == "=" {
        match("=")

        if look == "-" {
            emit("-", newline: false, leadtab: false)
            match("-")
        }

        emit(String(getNum()), leadtab: false)
    } else {
        emit("0", leadtab: false)
    }
}

func decl() {
    match("v")
    alloc(getName())
    while look == "," {
        getChar()
        alloc(getName())
    }
}

func topDecls() {
    while look != "b" {
        switch look {
        case "v":
            decl()
        default:
            fail("Unrecognized keyword '\(look)'")
        }
    }
}

func main() {
    match("b")
    prolog()
    block()
    match("e")
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
    match("p")
    header()
    topDecls()
    main()
    match(".")
}

func start() {
    getChar()
}

// MARK: Main
start()
prog()
