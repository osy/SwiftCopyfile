//
// Copyright © 2024 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import CCopyfile
import Foundation

public class CopyManager {
    /// Callback to handle copy progress
    /// - Parameters:
    ///   - srcPath: The path to the file or directory that the copy manager wants to copy. If unavailable, it will be nil.
    ///   - dstPath: The new path for the copied file or directory. If unavailable, it will be nil.
    ///   - bytesCopied: The total number of bytes copied so far.
    public typealias ProgressCallback = (_ srcPath: String?, _ dstPath: String?, _ bytesCopied: Int64) -> Void

    public struct Flags: OptionSet {
        public let rawValue: Int32

        var copyfileFlags: copyfile_flags_t {
            copyfile_flags_t(rawValue)
        }

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Copy the source file's access control lists.
        public static let acl = Flags(rawValue: COPYFILE_ACL)

        /// Copy the source file's POSIX information (mode, modification time, etc.).
        public static let stat = Flags(rawValue: COPYFILE_STAT)

        /// Copy the source file's extended attributes.
        public static let xattr = Flags(rawValue: COPYFILE_XATTR)

        /// Copy the source file's data.
        public static let data = Flags(rawValue: COPYFILE_DATA)

        /// Copy the source file's POSIX and ACL information; equivalent to
        /// `(COPYFILE_STAT|COPYFILE_ACL)`.
        public static let security = Flags(rawValue: COPYFILE_SECURITY)

        /// Copy the metadata; equivalent to `(COPYFILE_SECURITY|COPYFILE_XATTR)`.
        public static let metadata = Flags(rawValue: COPYFILE_METADATA)

        /// Copy the entire file; equivalent to `(COPYFILE_METADATA|COPYFILE_DATA)`.
        public static let all = Flags(rawValue: COPYFILE_ALL)

        /// Causes `copyfile()` to recursively copy a hierarchy.  This flag is not
        /// used by `fcopyfile()`
        public static let recursive = Flags(rawValue: COPYFILE_RECURSIVE)

        /// Return a bitmask (corresponding to the `flags` argument) indicating which
        /// contents would be copied; no data are actually copied.  (E.g., if `flags`
        /// was set to `COPYFILE_CHECK|COPYFILE_METADATA`, and the `from` file had
        /// extended attributes but no ACLs, the return value would be
        /// `COPYFILE_XATTR` .)
        public static let check = Flags(rawValue: COPYFILE_CHECK)

        /// Serialize the `from` file.  The `to` file is an AppleDouble-format file.
        public static let pack = Flags(rawValue: COPYFILE_PACK)

        /// Unserialize the `from` file.  The `from` file is an AppleDouble-format file;
        /// the `to` file will have the extended attributes, ACLs, resource fork, and
        /// FinderInfo data from the `to` file, regardless of the `flags` argument
        /// passed in.
        public static let unpack = Flags(rawValue: COPYFILE_UNPACK)

        /// Fail if the `to` file already exists.  (This is only applicable for the
        /// `copyfile()` function.)
        public static let exclusive = Flags(rawValue: COPYFILE_EXCL)

        /// Do not follow the `from` file, if it is a symbolic link.  (This is only
        /// applicable for the `copyfile()` function.)
        public static let noFollowSource = Flags(rawValue: COPYFILE_NOFOLLOW_SRC)

        /// Do not follow the `to` file, if it is a symbolic link.  (This is only
        /// applicable for the `copyfile()` function.)
        public static let noFollowDestination = Flags(rawValue: COPYFILE_NOFOLLOW_DST)

        /// Unlink (using remove(3)) the `from` file.  (This is only applicable for
        /// the `copyfile()` function.)  No error is returned if remove(3) fails.
        /// Note that remove(3) removes a symbolic link itself, not the target of
        /// the link.
        public static let move = Flags(rawValue: COPYFILE_MOVE)

        /// Unlink the `to` file before starting.  (This is only applicable for the
        /// `copyfile()` function.)
        public static let unlink = Flags(rawValue: COPYFILE_UNLINK)

        /// Clone the file instead.  This is a force flag i.e. if cloning fails, an
        /// error is returned.  This flag is equivalent to `(COPYFILE_EXCL |`
        /// `COPYFILE_ACL | COPYFILE_STAT | COPYFILE_XATTR | COPYFILE_DATA |`
        /// `COPYFILE_NOFOLLOW_SRC)`.  Note that if cloning is successful, progress
        /// callbacks will not be invoked.  Note also that there is no support for
        /// cloning directories: if a directory is provided as the source, an error
        /// will be returned.  Since this flag implies `COPYFILE_NOFOLLOW_SRC`,
        /// symbolic links themselves will be cloned instead of their targets.
        /// (This is only applicable for the `copyfile()` function.)
        public static let cloneForce = Flags(rawValue: COPYFILE_CLONE_FORCE)

        /// Try to clone the file instead.  This is a best try flag i.e. if cloning
        /// fails, fallback to copying the file.  This flag is equivalent to
        /// `(COPYFILE_EXCL | COPYFILE_ACL | COPYFILE_STAT | COPYFILE_XATTR |`
        /// `COPYFILE_DATA | COPYFILE_NOFOLLOW_SRC)`.  Note that if cloning is
        /// successful, progress callbacks will not be invoked.  Note also that
        /// there is no support for cloning directories: if a directory is provided
        /// as the source and `COPYFILE_CLONE_FORCE` is not passed, this will instead
        /// copy the directory.  Since this flag implies `COPYFILE_NOFOLLOW_SRC`,
        /// symbolic links themselves will be cloned instead of their targets.
        /// Recursive copying however is supported.
        /// (This is only applicable for the `copyfile()` function.)
        public static let clone = Flags(rawValue: COPYFILE_CLONE)

        /// Copy a file sparsely.  This requires that the source and destination
        /// file systems support sparse files with hole sizes at least as large as
        /// their block sizes.  This also requires that the source file is sparse,
        /// and for `fcopyfile()` the source file descriptor's offset be a multiple of
        /// the minimum hole size.  If `COPYFILE_DATA` is also specified, this will
        /// fall back to a full copy if sparse copying cannot be performed for any
        /// reason; otherwise, an error is returned.
        public static let dataSparse = Flags(rawValue: COPYFILE_DATA_SPARSE)

        /// This is a convenience macro, equivalent to `(COPYFILE_NOFOLLOW_DST |`
        /// `COPYFILE_NOFOLLOW_SRC)`.
        public static let noFollow = Flags(rawValue: COPYFILE_NOFOLLOW)

        /// If the `src` file has quarantine information, add the
        /// `QTN_FLAG_DO_NOT_TRANSLOCATE` flag to the quarantine information of the
        /// `dst` file.  This allows a bundle to run in place instead of being
        /// translocated.
        public static let runInPlace = Flags(rawValue: COPYFILE_RUN_IN_PLACE)

        /// Preserve the `UF_TRACKED` flag at to when copying metadata, regardless of
        /// whether from has it set.  This flag is used in conjunction with
        /// `COPYFILE_STAT`, or `COPYFILE_CLONE` (for its fallback case).
        public static let preserveDestinationTracked = Flags(rawValue: COPYFILE_PRESERVE_DST_TRACKED)
    }
    
    /// The delegate of the copy manager object.
    public weak var delegate: (any CopyManagerDelegate)?
    
    /// Dispatch queue to handle I/O operations.
    let ioQueue: DispatchQueue
    
    /// The shared copy manager object for the process.
    ///
    /// You should create a new manager if you intend to use the `delegate` to handle copy events.
    public static var `default`: CopyManager = CopyManager()

    /// Initializes a copy manager with a new I/O dispatch queue.
    public init() {
        self.ioQueue = DispatchQueue(label: "CopyManager IO Queue", qos: .userInitiated, attributes: .concurrent)
    }
    
    /// Initializes a copy manager with a specified I/O dispatch queue.
    /// - Parameter queue: Dispatch queue for I/O operations.
    public init(usingQueue queue: DispatchQueue) {
        self.ioQueue = queue
    }
}

public extension CopyManager {
    /// Copies the file at the specified URL to a new location.
    ///
    /// If the manager's `delegate` is set, it will be invoked before a file is copied as well as during an error.
    /// - Parameters:
    ///   - srcURL: The file URL that identifies the file you want to copy.
    ///   - dstURL: The URL at which to place the copy of `srcURL`.
    ///   - flags: Additional options.
    ///   - onProgress: Optional callback which is invoked each time a block is written.
    func copyItem(at srcURL: URL, to dstURL: URL, flags: Flags = [.all, .recursive], onProgress: ProgressCallback? = nil) async throws {
        try await withCopyfile({ copyfile(srcURL.path, dstURL.path, $0, flags.copyfileFlags)}, onProgress: onProgress)
    }
    
    /// Copies the data from a file handle to another file handle.
    ///
    /// If the manager's `delegate` is set, it will be invoked before a file is copied as well as during an error.
    /// - Parameters:
    ///   - srcHandle: A file handle open for reading which the data will come from.
    ///   - dstHandle: A file handle open for writing where the data will go to.
    ///   - flags: Additional options.
    ///   - onProgress: Optional callback which is invoked each time a block is written.
    func copyFileHandle(at srcHandle: FileHandle, to dstHandle: FileHandle, flags: Flags = [.all, .recursive], onProgress: ProgressCallback? = nil) async throws {
        try await withCopyfile({ fcopyfile(srcHandle.fileDescriptor, dstHandle.fileDescriptor, $0, flags.copyfileFlags)}, onProgress: onProgress)
    }

    private func withCopyfile(_ docopyfile: @escaping (copyfile_state_t) -> Int32, onProgress: ProgressCallback?) async throws {
        class CopyStatusContext {
            let manager: CopyManager
            let progresCallback: ProgressCallback?

            init(manager: CopyManager, progresCallback: ProgressCallback?) {
                self.manager = manager
                self.progresCallback = progresCallback
            }
        }
        let context = CopyStatusContext(manager: self, progresCallback: onProgress)
        let callback: copyfile_callback_t = { (what, stage, state, src, dst, ctx) -> Int32 in
            let context = Unmanaged<CopyStatusContext>.fromOpaque(ctx!).takeUnretainedValue()
            let srcPath: String?
            let dstPath: String?
            if let src = src {
                srcPath = String(cString: src)
            } else {
                srcPath = nil
            }
            if let dst = dst {
                dstPath = String(cString: dst)
            } else {
                dstPath = nil
            }
            if (what == COPYFILE_RECURSE_FILE || what == COPYFILE_RECURSE_DIR) && stage == COPYFILE_START {
                let isDirectory = what == COPYFILE_RECURSE_DIR
                if let srcPath = srcPath, let dstPath = dstPath {
                    if context.manager.delegate?.copyManager(context.manager, shouldCopyItemAtPath: srcPath, toPath: dstPath, isDirectory: isDirectory) ?? true {
                        return COPYFILE_CONTINUE
                    } else {
                        return COPYFILE_SKIP
                    }
                } else {
                    return COPYFILE_CONTINUE
                }
            }
            if what == COPYFILE_RECURSE_ERROR || stage == COPYFILE_ERR {
                let error = NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
                if context.manager.delegate?.copyManager(context.manager, shouldProceedAfterError: error, copyingItemAtPath: srcPath, toPath: dstPath) ?? true {
                    return COPYFILE_CONTINUE
                } else {
                    return COPYFILE_SKIP
                }
            }
            if what == COPYFILE_COPY_DATA && stage == COPYFILE_PROGRESS {
                var copied: off_t = 0
                copyfile_state_get(state, UInt32(COPYFILE_STATE_COPIED), &copied)
                context.progresCallback?(srcPath, dstPath, copied)
            }
            return COPYFILE_CONTINUE
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            ioQueue.async {
                let s = copyfile_state_alloc()
                guard s != nil else {
                    continuation.resume(throwing: NSError(domain: NSPOSIXErrorDomain, code: Int(ENOMEM)))
                    return
                }
                let ctx = Unmanaged.passRetained(context)
                defer {
                    copyfile_state_free(s)
                    ctx.release()
                }
                copyfile_state_set(s, UInt32(COPYFILE_STATE_STATUS_CB), unsafeBitCast(callback, to: UnsafeRawPointer.self))
                copyfile_state_set(s, UInt32(COPYFILE_STATE_STATUS_CTX), ctx.toOpaque())
                if docopyfile(s!) < 0 {
                    continuation.resume(throwing: NSError(domain: NSPOSIXErrorDomain, code: Int(errno)))
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
