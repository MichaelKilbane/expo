// Copyright 2022-present 650 Industries. All rights reserved.

import Foundation

public typealias PersistentLogFilter = (_: String) -> Bool

/**
 * A thread-safe class for reading and writing line-separated strings to a flat file. The main use case is for logging specific errors or events, and ensuring that the logs persist across application crashes and restarts (for example, OSLogReader can only read system logs for the current process, and cannot access anything logged before the current process started).
 *
 * On initialization with a filename, the file is created if it does not already exist. After that, all access to the file goes through asynchronous public methods managed by a serial dispatch queue.
 *
 * The dispatch queue is global, to ensure that multiple instances accessing the same file will have thread-safe access.
 *
 * The only operations supported are
 * - Read the file
 * - Append one or more entries to the file
 * - Filter the file (only retain entries that pass the filter check)
 * - Clear the file (remove all entries)
 *
 */
public class PersistentLog {
  private let fileName: String
  private let filePath: String

  public init(fileName: String) {
    self.fileName = fileName
    self.filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(self.fileName).path ?? ""
  }
  /**
   Read entries from log file
   */
  public func readEntries(_ promise: Promise) {
    PersistentLog.serialQueue.async {
      do {
        let contents = try self._readFileSync()
        promise.resolve(contents)
      } catch {
        promise.reject(error)
      }
    }
  }

  /**
   Append entry to the log file
   */
  public func appendEntry(entry: String, _ promise: Promise) {
    PersistentLog.serialQueue.async {
      do {
        var contents = try self._readFileSync()
        contents.append(entry)
        try self._writeFileSync(contents)
        promise.resolve(nil)
      } catch {
        promise.reject(error)
      }
    }
  }

  /**
   Filter existing entries and remove ones where filter(entry) == false
   */
  public func filterEntries(filter: @escaping PersistentLogFilter, _ promise: Promise) {
    PersistentLog.serialQueue.async {
      do {
        let contents = try self._readFileSync()
        let newcontents = contents.filter { entry in filter(entry) }
        try self._writeFileSync(newcontents)
        promise.resolve(nil)
      } catch {
        promise.reject(error)
      }
    }
  }

  /**
   Clean up (remove) the log file
   */
  public func clearEntries(_ promise: Promise) {
    PersistentLog.serialQueue.async {
      do {
        try self._deleteFileSync()
        promise.resolve(nil)
      } catch {
        promise.reject(error)
      }
    }
  }

  // MARK: - Private methods

  private static let EXPO_UPDATES_LOG_QUEUE_LABEL = "dev.expo.updates.logging"
  private static let serialQueue = DispatchQueue(label: EXPO_UPDATES_LOG_QUEUE_LABEL)

  private func _ensureFileExists() {
    if !FileManager.default.fileExists(atPath: filePath) {
      FileManager.default.createFile(atPath: filePath, contents: nil)
    }
  }

  private func _readFileSync() throws -> [String] {
    _ensureFileExists()
    return try _stringToList(String(contentsOfFile: filePath, encoding: .utf8))
  }

  private func _writeFileSync(_ contents: [String]) throws {
    if contents.isEmpty {
      try _deleteFileSync()
      return
    }
    _ensureFileExists()
    try contents.joined(separator: "\n").write(toFile: filePath, atomically: true, encoding: .utf8)
  }

  private func _deleteFileSync() throws {
    if FileManager.default.fileExists(atPath: filePath) {
      try FileManager.default.removeItem(atPath: filePath)
    }
  }

  private func _stringToList(_ contents: String?) -> [String] {
    // If null contents, or 0 length contents, return empty list
    return (contents != nil && contents?.lengthOfBytes(using: .utf8) ?? 0 > 0) ?
      contents?.components(separatedBy: "\n") ?? [] :
      []
  }
}
