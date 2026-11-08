import ASCII
import Byte


extension RFC_2183.Token {
    enum Failure {
        case empty

        case notASCII

        case invalidCharacter(ASCII.Code)
    }
}
