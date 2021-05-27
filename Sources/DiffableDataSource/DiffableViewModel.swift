//
//  DiffableViewModel.swift
//  
//
//  Created by Jaime Azevedo on 17/03/2021.
//

import Combine
import Foundation

public protocol DiffableViewModel {
    associatedtype Row: Diffable
    associatedtype Section: Diffable

    var content: CurrentValueSubject<[DiffableSection<Section, Row>], Never> { get }
}

extension DiffableViewModel {
    private var sections: [DiffableSection<Section, Row>] {
        content.value
    }

    // MARK: - Public API

    public func section(at index: Int) -> Section {
        sections[index].identifier
    }

    public func row(at indexPath: IndexPath) -> Row {
        sections[indexPath.section].rows[indexPath.row]
    }

    public func indexPath(for row: Row) -> IndexPath? {
        for sectionIndex in 0..<sections.count {
            if let rowIndex = sections[sectionIndex].rows.firstIndex(of: row) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }
}
