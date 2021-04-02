//
//  Logger.swift
//  
//
//  Created by Jaime Azevedo on 02/04/2021.
//

import Foundation

final class Logger {
    private(set) static var shared = Logger()

    var logBlock: ((DiffableError) -> Void)?

    func log(error: DiffableError) {
        logBlock?(error)
    }
}
