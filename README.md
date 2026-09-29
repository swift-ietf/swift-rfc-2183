# swift-rfc-2183

Domain model for RFC 2183, the Content-Disposition header field: `RFC_2183.ContentDisposition` with its `DispositionType` (`inline`, `attachment`, the RFC 7578 `form-data` extension and any other token) and `Parameters` (`Filename`, `Size`, the RFC 5322 creation, modification and read dates, the `form-data` field `name`, and extension parameters keyed by `ParameterName`), plus the `RFC_5322.Header.Name.contentDisposition` field name. `ContentDisposition`, `DispositionType`, `ParameterName`, `Filename` and `Size` validate on construction and read their RFC text form through `init(_:)` / `init(ascii:)`; the `RFC 2183 Foundation Integration` product bridges every type to `Codable`. Byte-level serialization and the rendered text forms (`ASCII.Parseable`, `ASCII.Serializable`, `Binary.Serializable`, `ContentDisposition.description`, the nested `Coder` types and the `RFC_5322.Header` construction) live in [swift-rfc-2183-coder](https://github.com/swift-ietf/swift-rfc-2183-coder).

```swift
import RFC_2183

let attachment = RFC_2183.ContentDisposition.attachment(
    filename: try RFC_2183.Filename("report.pdf"),
    size: try RFC_2183.Size(bytes: 1_048_576)
)
attachment.filename?.value                                   // "report.pdf"
attachment.size?.bytes                                       // 1048576

let upload = try RFC_2183.ContentDisposition(#"form-data; name="avatar"; filename="photo.jpg""#)
upload.type == .formData                                     // true
upload.name                                                  // "avatar"

try RFC_2183.Filename("../etc/passwd")                       // throws Filename.Error.containsPathTraversal
```
