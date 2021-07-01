//
//  Persister.swift
//  Vintage
//
//  Created by Nick Nguyen on 2/16/21.
//

import UIKit

struct Persister {

  static let shared = Persister(withFileName: "Fav")

  let fileURL: URL

  let plistEncoder = PropertyListEncoder()

  let plistDecoder = PropertyListDecoder()


  init?(withFileName fileName: String) {
    guard let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
    ).first?.appendingPathComponent(fileName) else {
      return nil
    }
    fileURL = url
  }

  func save<T: Codable>(_ object: T) {
    do {
      let quotesData = try plistEncoder.encode(object)
      try quotesData.write(to: fileURL)
    } catch let err as NSError {
      print(err.localizedDescription)
    }
  }

  func fetch<T: Codable>() throws -> T {
    let quotesData = try Data(contentsOf: fileURL)
    let quotes = try plistDecoder.decode(T.self, from: quotesData)
    return quotes
  }
}
