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

public protocol CopyManagerDelegate: AnyObject {
    /// Asks the delegate if the copy manager should copy the specified item to the new path.
    /// - Parameters:
    ///   - copyManager: The copy manager object that is attempting to copy the file or directory.
    ///   - srcPath: The path to the file or directory that the copy manager wants to copy.
    ///   - dstPath: The new path for the copied file or directory.
    ///   - isDirectory: Is the source path a directory?
    /// - Returns: true if the item should be copied or false if the file manager should stop copying
    ///  items associated with the current operation. If you do not implement this method, the file
    ///  manager assumes a response of true.
    func copyManager(_ copyManager: CopyManager, shouldCopyItemAtPath srcPath: String, toPath dstPath: String, isDirectory: Bool) -> Bool
    
    /// Asks the delegate if the move operation should continue after an error occurs while copying the item at the specified path.
    /// - Parameters:
    ///   - copyManager: The CopyManager object that sent this message.
    ///   - error: The error that occurred during the attempt to copy.
    ///   - srcPath: The path or a file or directory that copyManager is attempting to copy (if available).
    ///   - dstPath: The path or a file or directory to which copyManager is attempting to copy (if available).
    /// - Returns: true if the operation should proceed or false if it should be aborted. If you
    ///  do not implement this method, the copy manager assumes a response of false.
    func copyManager(_ copyManager: CopyManager, shouldProceedAfterError error: any Error, copyingItemAtPath srcPath: String?, toPath dstPath: String?) -> Bool
}

public extension CopyManagerDelegate {
    func copyManager(_ copyManager: CopyManager, shouldCopyItemAtPath srcPath: String, toPath dstPath: String, isDirectory: Bool) -> Bool {
        true
    }

    func copyManager(_ copyManager: CopyManager, shouldProceedAfterError error: any Error, copyingItemAtPath srcPath: String, toPath dstPath: String) -> Bool {
        false
    }
}
