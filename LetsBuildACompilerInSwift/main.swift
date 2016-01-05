import Foundation

var inputBuffer: String! = readLine()
var look: Character!

//Report an error
func error(message: String) {
    print("Error: \(message)")
}

//Report error and halt
func fail(message: String) {
    error(message)
    exit(-1)
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
func getNum() -> Character {
    guard isDigit(look) else {
        expected("Integer")
        exit(-1) // won't actually run but we have to make the compiler happy
    }

    let num = look
    getChar()
    return num
}

//Output a string with a leading tab
func emit(s: String, newLine: Bool = true) {
    var terminator = "\n"

    if !newLine {
        terminator = ""
    }

    print("\t\(s)", terminator: terminator)
}

func factor() {
    if look == "(" { // recursively build the expression inside this factor
        match("(")
        expression()
        match(")")
        return;
    }

    emit("d0 = \(getNum())")
}

func multiply() {
    match("*")
    factor()
    emit("d0 *= stack.removeLast()")
}

func divide() {
    match("/")
    factor()
    emit("d1 = stack.removeLast()")
    emit("d0 = d1 / d0")
}

func term() {
    factor()
    while look == "*" || look == "/" {
        emit("stack.append(d0)")
        switch look {
        case "*":
            multiply()
        case "/":
            divide()
        default:
            expected("MulOp")
        }
    }
}

func add() {
    match("+")
    term()
    emit("d0 += stack.removeLast()")
}

func subtract() {
    match("-")
    term()
    emit("d0 -= stack.removeLast()")
    emit("d0 = -d0")
}

func expression() {
    // This expression has a leading +/- so we "clear" our initial value
    // Note we could initialize the var d0 with 0 and clean this up, but we'll follow along
    if isAddop(look) {
        emit("d0 = 0")
    } else {
        term()
    }

    while isAddop(look) {
        emit("stack.append(d0)")
        switch look {
        case "+":
            add()
        case "-":
            subtract()
        default:
            expected("AddOp")
        }
    }
}

func isOrop(c: Character) -> Bool {
    return "|" == c || "~" == c
}

func isRelop(c: Character) -> Bool {
    return "=" == c || "#" == c || "<" == c || ">" == c
}

func isBoolean(c: Character) -> Bool {
    return "t" == c || "T" == c || "f" == c || "F" == c
}


func getBoolean() -> Bool {
    guard isBoolean(look) else {
        expected("Boolean Literal")
        exit(-1)
    }

    let boolC = String(look).capitalizedString.characters.first!
    getChar()
    return boolC == "T"
}

func equals() {
    match("=")
    expression()
    emit("d0 = d0 == stack.removeLast() ? -1 : 0")
}

func notEquals() {
    match("#")
    expression()
    emit("d0 = d0 != stack.removeLast() ? -1 : 0")
}

func less() {
    match("<")
    expression()
    emit("d0 = stack.removeLast() < d0 ? -1 : 0")
}

func greater() {
    match(">")
    expression()
    emit("d0 = stack.removeLast() > d0 ? -1 : 0")
}

func boolOr() {
    match("|")
    boolTerm()
    emit("d0 = d0 == -1 || stack.removeLast() == -1 ? -1 : 0")
}

func boolXor() {
    match("~")
    boolTerm()
    emit("d0 = d0 != stack.removeLast() ? -1 : 0")
}

func boolTerm() {
    notFactor()
    while look == "&" {
        emit("stack.append(d0)")
        match("&")
        notFactor()
        emit("d0 = d0 == -1 && stack.removeLast() == -1 ? -1 : 0")
    }
}

func notFactor() {
    if look == "!" {
        match("!")
        boolFactor()
        emit("d0 = d0 == -1 ? 0 : -1")
    } else {
        boolFactor()
    }
}

func boolFactor() {
    if isBoolean(look) {
        if getBoolean() {
            emit("d0 = -1")
        } else {
            emit("d0 = 0")
        }
    } else {
        relation()
    }
}

func boolExpression() {
    boolTerm()
    while isOrop(look) {
        emit("stack.append(d0)")
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

func relation() {
    expression()

    if isRelop(look) {
        emit("stack.append(d0)")
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

func doBreak() {
    match("b")
    emit("break")
}

func doDo() {
    match("d")
    expression()
    emit("for _ in 0..<d0")
    emit(" { ")
    block()
    match("e")
    emit("}")
}

func doFor() {
    match("f")
    let name = getName()
    match("=")
    expression()
    emit("d1 = d0")
    match("t")
    expression()
    emit("for \(name) in d1...d0 {")
    block()
    match("e")
    emit("}")
}

//func doRepeat() {
//    match("r")
//    emit("repeat {")
//    block()
//    match("u")
//    emit("} while ", newLine: false)
//    boolExpression()
//}

func doLoop() {
    match("p")
    emit("while true {")
    block()
    match("e")
    emit("}")
}

// This technically doesn't work right, because the 
// contents of block (were we actually supporting real
// statements inside the block) could overwrite d0. I'm
// not exactly sure how to fix it right now, though.
func doWhile() {
    match("w")
    boolExpression()
    emit("while d0 == -1 {")
    block()
    match("e")
    emit("}")
}

func doElse() {
    match("l")
    emit("} else {")
    block()
}

func doIf() {
    match("i")
    boolExpression()
    emit("if d0 == -1 {")
    block()
    match("e")
    emit("}")
}

func other() {
    emit("print(\"\(getName())\")")
}

func block() {
    while look != "e" && look != "u" && look != "t" {
        switch look {
        case "i":
            doIf()
        case "l":
            doElse()
        case "w":
            doWhile()
        case "p":
            doLoop()
//        case "r":
//            doRepeat()
        case "f":
            doFor()
        case "d":
            doDo()
        case "b":
            doBreak()
        default:
            other()
        }
    }
}

func doProgram() {
    block()

    if look != "e" {
        expected("END")
    }

    emit("// END")
}

func start() {
    emit("// Compiler Output")
    emit("var d0: Int = 0")
    emit("var d1: Int = 0")
    emit("var stack = [Int]()")
    getChar()
}

// MARK: Main
start()
doProgram()