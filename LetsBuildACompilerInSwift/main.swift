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

func isBoolean(c: Character) -> Bool {
    return "t" == c || "T" == c || "f" == c || "F" == c
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

func isOrop(c: Character) -> Bool {
    return "|" == c || "~" == c
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

func getBoolean() -> Bool {
    guard isBoolean(look) else {
        expected("Boolean Literal")
        exit(-1)
    }

    let boolC = String(look).capitalizedString.characters.first!
    getChar()
    return boolC == "T"
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
    guard isBoolean(look) else {
        expected("Boolean Literal")
        exit(-1)
    }

    if getBoolean() {
        emit("d0 = -1")
    } else {
        emit("d0 = 0")
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

//Output a string with a leading tab
func emit(s: String) {
    print("\t\(s)")
}

func start() {
    emit("// Compiler Output")
    emit("var d0: Int = 0")
    emit("var stack = [Int]()")
    getChar()
}

// MARK: Main
start()
print(boolExpression())
