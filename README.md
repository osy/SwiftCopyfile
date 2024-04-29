SwiftCopyfile
==============
A modern Swift interface for [copyfile][1]. The main advantage over NSFileManager is that this supports APFS sparse file copying (even across different mount points) and also provides a callback for progress indication. You can also use other features of "copyfile" and "fcopyfile" without having to write your own C wrapper calls.

## Usage

### APFS sparse copy

```swift
try await CopyManager.default.copyItem(at: srcURL, to: dstURL, flags: [.all, .recursive, .clone, .dataSparse])
```

### Progress callback

```swift
let startTime = Date()
try await CopyManager.default.copyItem(at: srcURL, to: dstURL) { srcPath, dstPath, bytesCopied in
    let elapsed = Date().timeIntervalSince(startTime)
    let speed = Double(bytesCopied) / elapsed / 1048576
    print("\(speed) MB/s (copied \(bytesCopied) bytes)")
}
```

## License

This project is licensed under the Apache 2.0 license. It includes code licensed under Apple Public Source License.

[1]: https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/copyfile.3.html
