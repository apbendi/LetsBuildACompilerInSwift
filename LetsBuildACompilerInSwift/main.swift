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
func getNum() -> Int {
    guard isDigit(look) else {
        expected("Integer")
        exit(-1) // won't actually run but we have to make the compiler happy
    }

    guard let num = Int("\(look)") else {
        print("FATAL ERROR: \(look) passed isDigit but did not convert to Int")
        exit(-1)
    }

    getChar()
    return num
}

//Output a string with a leading tab
func emit(s: String) {
    print("\t\(s)")
}

func term() -> Int {
    var value = getNum()

    while look == "*" || look == "/" {
        switch look {
        case "*":
            match("*")
            value *= getNum()
        case "/":
            match("/")
            value = value / getNum()
        default:
            print("FATAL ERROR: \(look) appeared to be mulop but did not match")
            exit(-1)
        }
    }

    return value
}

func expression() -> Int {
    var value: Int = 0

    if isAddop(look) {
        // initialized to 0
    } else {
        value = term()
    }

    while isAddop(look) {
        switch look {
        case "+":
            match("+")
            value += term()
        case "-":
            match("-")
            value -= term()
        default:
            print("FATAL ERROR: \(look) passed isAddop but didn't match")
            exit(-1)
        }
    }

    return value
}

func start() {
    getChar()
}

// MARK: Main
start()
print(expression())
