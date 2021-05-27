//
//  Dependency.swift
//  
//
//  Created by Jaime Azevedo on 02/04/2021.
//

import Foundation

public struct Dependency {
    public static var logFault: ((DiffableError) -> Void) = { _ in }
}

func logFault(error: DiffableError) {
    Dependency.logFault(error)
}
