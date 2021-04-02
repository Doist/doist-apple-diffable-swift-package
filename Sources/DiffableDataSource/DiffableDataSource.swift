//
//  DiffableDataSource.swift
//  
//
//  Created by Jaime Azevedo on 02/04/2021.
//

public final class DiffableDataSource {
    public static func configureLogging(onError block: @escaping (DiffableError) -> Void) {
        Logger.shared.logBlock = block
    }
}
