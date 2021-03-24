//
//  DiffableTableViewDataSource+Replace.swift
//  
//
//  Created by Jaime Azevedo on 17/03/2021.
//

import UIKit

extension DiffableTableViewDataSource {
    // MARK: - Public API

    public func replace(with sections: [DiffableSection<SectionID, RowID>], animatingDifferences: Bool = true) throws {
        try checkUniqueDiffableSections(sections: sections)

        var snapshot = NSDiffableDataSourceSnapshot<SectionID, RowID>()

        snapshot.appendSections(sections.map(\.identifier))

        sections.forEach {
            snapshot.appendItems($0.rows, toSection: $0.identifier)
        }

        apply(snapshot, animatingDifferences: animatingDifferences)
    }

    public func checkUniqueDiffableSections(sections: [DiffableSection<SectionID, RowID>]) throws {
        let sectionIDs = sections.map { $0.identifier }
        let rowIDs = sections.flatMap { $0.rows }

        guard sectionIDs.unique().count == sectionIDs.count else {
            throw DiffableError.sectionsNotUnique
        }

        guard rowIDs.unique().count == rowIDs.count else {
            throw DiffableError.rowsNotUnique
        }
    }
}
