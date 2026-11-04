# swift-rfc-2183

Use this package when you read or write a `Content-Disposition` header field, for a MIME attachment, an inline part or a form field. Start from `RFC_2183.ContentDisposition`. Parameter values here are US-ASCII only. For non-ASCII filenames encoded with RFC 2231, use swift-rfc-2231. For whole multipart/form-data bodies, use swift-rfc-7578. For `Codable`, add the `RFC 2183 Foundation Integration` product.

## Laws

- Reading a header fails only when the input is not ASCII or the disposition type is empty or not a token. A parameter whose name is not a token, or whose value fails validation, is dropped and the rest of the header is kept. A filename such as `../etc/passwd` or a name that carries CR LF comes back as nil rather than as an error.
- Disposition types and parameter names compare without regard to case and keep the case they were written in. `ATTACHMENT` equals `RFC_2183.DispositionType.attachment`.
- A semicolon inside a quoted value does not end the parameter, and a backslash escape inside quotes is undone, so `"file\"with\"quotes.txt"` reads as the filename with plain quotes.
- A parameter that is not one of the six RFC 2183 parameters goes into `RFC_2183.Parameters.extensionParameters`.
- `RFC_2183.Filename` refuses any value containing `..`, `/` or `\`, as well as control characters. Spaces are allowed.
- `RFC_2183.ParameterValue` accepts printable ASCII and space, and the empty string. Tab, CR, LF, DEL and every other control byte are refused.
- `RFC_2183.Size` text is one or more decimal digits and nothing else: no sign, no spaces.
- Written out, parameters always come in the same order: `filename`, `creation-date`, `modification-date`, `read-date`, `size`, `name`, then extension parameters sorted by name. Every value is quoted except `size`, with `"` and `\` escaped by a backslash.
- The coders read only their own part and leave the rest of the input. `RFC_2183.ContentDisposition.coder` stops at CR or LF. When parsing fails, the cursor goes back to where it started.
- With the Foundation integration, a disposition type, filename, parameter name and parameter value each encode as a string, and a size as an integer. Decoding validates them the same way the initializers do.
