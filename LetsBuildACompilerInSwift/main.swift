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
func emit(s: String, newline: Bool = true) {

    let terminator = newline ? "\n" : ""
    print("\t\(s)", terminator: terminator)
}

func alloc(n: Character) {
    emit("variables[\"\(n)\"] = ", newline: false)

    if look == "=" {
        match("=")
        emit(String(getNum()))
    } else {
        emit("0")
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
    match("e")
    epilog()
}

func epilog() {
    emit("// END COMPILER OUTPUt")
}

func prolog() {

}

func header() {
    emit("// COMPILER OUTPUT")
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
