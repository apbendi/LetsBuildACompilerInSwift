import Foundation

var inputBuffer: String! = readLine()
var look: Character!

func getChar() {
    struct Static { static var index = 0 }
    let i = inputBuffer.startIndex.advancedBy(Static.index)
    Static.index
        += 1
    look = inputBuffer[i]
}

func start() {
    print("// Start")
    getChar()
}

// MARK: Main
start()