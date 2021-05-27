//
//  DiffableTableViewDataSource+Replace.swift
//  
//
//  Created by Jaime Azevedo on 17/03/2021.
//

import UIKit

extension DiffableTableViewDataSource {
    // MARK: - Public API

    public func replace(with sections: [DiffableSection<SectionID, RowID>], animatingDifferences: Bool = true) {
        switch checkUniqueDiffableSections(sections: sections) {
        case let .success(sections):
            self.unsafeReplace(sections: sections, animatingDifferences: animatingDifferences)

        case let .failure(error):
            logFault(error: error)
        }
    }

    public func checkUniqueDiffableSections(
        sections: [DiffableSection<SectionID, RowID>]
    ) -> Result<[DiffableSection<SectionID, RowID>], DiffableError> {
        let sectionIDs = sections.map { $0.identifier }
        let rowIDs = sections.flatMap { $0.rows }

        if sectionIDs.unique().count != sectionIDs.count {
            return .failure(DiffableError.sectionsNotUnique)
        } else if rowIDs.unique().count != rowIDs.count {
            return .failure(DiffableError.rowsNotUnique)
        } else {
            return .success(sections)
        }
    }

    // MARK: - Private API

    private func unsafeReplace(sections: [DiffableSection<SectionID, RowID>], animatingDifferences: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionID, RowID>()

        snapshot.appendSections(sections.map(\.identifier))

        sections.forEach {
            snapshot.appendItems($0.rows, toSection: $0.identifier)
        }

        apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
