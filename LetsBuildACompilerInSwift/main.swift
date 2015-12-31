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

func condition() {
    emit("<condition>", newLine: false)
}

func doLoop() {
    match("p")
    emit("while true {")
    block()
    match("e")
    emit("}")
}

func doWhile() {
    match("w")
    emit("while ", newLine: false)
    condition()
    emit(" {")
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
    emit("if ", newLine: false)
    condition()
    emit(" {")
    block()
    match("e")
    emit("}")
}

func other() {
    emit("\(getName())")
}

func block() {
    while look != "e" {
        switch look {
        case "i":
            doIf()
        case "l":
            doElse()
        case "w":
            doWhile()
        case "p":
            doLoop()
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
    getChar()
}

// MARK: Main
start()
doProgram()