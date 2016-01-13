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

func loadConst(n: Int) {
    emit("d0 = \(n)")
}

func loadVar(n: Character) {
    if !inTable(n) {
        undefined(n)
    }

    emit("d0 = variables[\"\(n)\"]")
}

func push() {
    emit("stack.appened(d0)")
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

// ## END CODE GENERATION

func assignment() {
    getChar()
}

func block() {
    while look != "e" {
        assignment()
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
