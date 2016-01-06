import Foundation

var inputBuffer: String! = readLine()
var look: Character!
var token: String!

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
func getName() -> String {
    guard isAlpha(look) else {
        expected("Name")
        exit(-1) // won't actually run but we have to make the compiler happy
    }

    var name = ""

    while isAlNum(look) {
        let upper = String(look).capitalizedString.characters.first!
        name =  "\(name)\(upper)"
        getChar()
    }

    skipWhite()
    return name
}

//Get a number
func getNum() -> String {
    guard isDigit(look) else {
        expected("Integer")
        exit(-1) // won't actually run but we have to make the compiler happy
    }

    var num = ""

    while isDigit(look) {
        num = "\(num)\(look)"
        getChar()
    }

    skipWhite()
    return num
}

func scan() -> String {
    let scanVal: String

    if isAlpha(look) {
        scanVal = getName()
    } else if isDigit(look) {
        scanVal = getNum()
    } else {
        scanVal = String(look)
        getChar()
    }

    skipWhite()
    return scanVal
}

//Output a string with a leading tab
func emit(s: String) {
    print("\t\(s)")
}

func start() {
    getChar()
}

// MARK: Main
start()
repeat {
    token = scan()
    print(token)
} while token != "\n"
