import XCTest
@testable import DiffableDataSource

final class DiffableTests: XCTestCase {
    enum Section: Diffable {
        case top
        case middle
        case bottom

        var id: Section {
            self
        }
    }

    enum Row: Diffable {
        case item(UUID)
        case headerElement
        case footerElement

        var id: Row {
            self
        }
    }

    let tableView = UITableView()
    var dataSource: DiffableTableViewDataSource<Section, Row>!

    let topSection = DiffableSection<Section, Row>(identifier: .top, rows: [.headerElement])
    let middleSection = DiffableSection<Section, Row>(identifier: .middle, rows: [.item(UUID()), .item(UUID())])
    let bottomSection = DiffableSection<Section, Row>(identifier: .bottom, rows: [.footerElement])

    lazy var content = [topSection, middleSection, bottomSection]

    // MARK: - Overrides

    override func setUpWithError() throws {
        try super.setUpWithError()

        dataSource = DiffableTableViewDataSource<Section, Row>(
            tableView: UITableView(),
            cellProvider: { _, _, _ in
                nil
            },
            canEditProvider: { [unowned self] indexPath in
                self.dataSource.section(at: indexPath.section) == .middle
            }
        )
    }

    func testReplaceEmpty() {
        XCTAssertNoThrow(try dataSource.replace(with: []))
        XCTAssertTrue(dataSource.snapshot().sectionIdentifiers.isEmpty)
        XCTAssertTrue(dataSource.snapshot().itemIdentifiers.isEmpty)
    }

    func testReplaceWithNonUniqueSectionIdentifiers() {
        XCTAssertThrowsError(try dataSource.replace(with: [topSection, topSection]))
    }

    func testReplaceWithNonUniqueRowIdentifiers() {
        let wrongBottomSection = DiffableSection<Section, Row>(identifier: .bottom, rows: [.headerElement])

        XCTAssertThrowsError(
            try dataSource.replace(with: [topSection, wrongBottomSection], animatingDifferences: false)
        )
    }

    func testReplace() {
        let content = [topSection, middleSection, bottomSection]

        XCTAssertNoThrow(try dataSource.replace(with: content, animatingDifferences: false))

        XCTAssert(dataSource.snapshot().sectionIdentifiers == content.map { $0.identifier })
        XCTAssert(dataSource.snapshot().itemIdentifiers == content.flatMap { $0.rows })
    }

    func testCanEdit() {
        XCTAssertNoThrow(try dataSource.replace(with: content, animatingDifferences: false))

        XCTAssertFalse(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 0)))
        XCTAssertTrue(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 1)))
        XCTAssertTrue(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 1, section: 1)))
        XCTAssertFalse(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 2)))
    }

    func testSectionAt() {
        XCTAssertNoThrow(try dataSource.replace(with: content, animatingDifferences: false))

        for index in 0..<content.count {
            XCTAssertTrue(dataSource.section(at: index) == content[index].identifier)
        }
    }

    func testRowAt() {
        let content = [topSection, middleSection, bottomSection]

        XCTAssertNoThrow(try dataSource.replace(with: content, animatingDifferences: false))

        for section in 0..<content.count {
            for row in 0..<content[section].rows.count {
                XCTAssertTrue(dataSource.row(at: IndexPath(row: row, section: section)) == content[section].rows[row])
            }
        }
    }
}
