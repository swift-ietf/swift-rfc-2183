import ASCII
import Byte

extension IETF.RFC.`2183`.Token {
    enum Failure {
        case empty

        case notASCII

        case invalidCharacter(ASCII.Code)
    }
}
