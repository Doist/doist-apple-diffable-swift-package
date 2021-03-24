//
//  DiffableError.swift
//  
//
//  Created by Jaime Azevedo on 24/03/2021.
//

public enum DiffableError: Error {
    case sectionsNotUnique
    case rowsNotUnique

    public var description: String {
        switch self {
        case .sectionsNotUnique:
            return "DiffableDataSource: Section identifiers are not unique."

        case .rowsNotUnique:
            return "DiffableDataSource: Row identifiers are not unique."
        }
    }
}
