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
        look = "\n"
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
    if look != c {
        expected("'\(c)'")
        return
    }

    getChar()
    skipWhite()
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
func getName() -> String {
    guard isAlpha(look) else {
        expected("Name")
        exit(-1) // won't actually run but we have to make the compiler happy
    }

    var token = ""

    while isAlNum(look) {
        let upper = String(look).capitalizedString.characters.first!
        token = "\(token)\(upper)"
        getChar()
    }

    skipWhite()
    return token
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

    skipWhite()
    return value
}

//Output a string with a leading tab
func emit(s: String) {
    print("\t\(s)")
}

func factor() {
    if look == "(" { // recursively build the expression inside this factor
        match("(")
        expression()
        match(")")
    } else if isAlpha(look) {
        ident()
    } else {
        emit("d0 = \(getNum())")
    }
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

func ident() {
    let name = getName()
    if look == "(" {
        match("(")
        match(")")
        emit("functions[\"\(name)\"]!()")
    } else {
        emit("variables[\"\(name)\"]")
    }
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

func assignment() {
    let name = getName()
    match("=")
    expression()
    emit("variables[\"\(name)\"] = d0")
}

func start() {
    emit("// Compiler output")
    emit("var d0: Int")
    emit("var d1: Int")
    emit("var stack = [Int]()")
    emit("var variables = [String:Int]()")
    emit("typealias voidFn = (()->())")
    emit("var functions = [String:voidFn]()")
    getChar()
    skipWhite()
}

// MARK: Main
start()
assignment()
