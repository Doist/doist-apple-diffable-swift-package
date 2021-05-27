import Combine
import XCTest
@testable import DiffableDataSource

final class DiffableTests: XCTestCase, DiffableViewModel {
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

    lazy var content: CurrentValueSubject<[DiffableSection<Section, Row>], Never> = .init(
        [topSection, middleSection, bottomSection]
    )

    let tableView = UITableView()
    var dataSource: DiffableTableViewDataSource<Section, Row>!

    var loggedError: DiffableError!

    let topSection = DiffableSection<Section, Row>(identifier: .top, rows: [.headerElement])
    let middleSection = DiffableSection<Section, Row>(identifier: .middle, rows: [.item(UUID()), .item(UUID())])
    let bottomSection = DiffableSection<Section, Row>(identifier: .bottom, rows: [.footerElement])

    // MARK: - Overrides

    override func setUpWithError() throws {
        try super.setUpWithError()

        dataSource = DiffableTableViewDataSource<Section, Row>(
            tableView: UITableView(),
            cellProvider: { _, _, _ in
                nil
            },
            canEditProvider: { [unowned self] indexPath in
                section(at: indexPath.section) == .middle
            }
        )

        loggedError = nil

        Dependency.logFault = { [weak self] error in
            self?.loggedError = error
        }
    }

    func testReplaceEmpty() throws {
        let content: [DiffableSection<Section, Row>] = []

        dataSource.replace(with: content)

        XCTAssertTrue(dataSource.snapshot().sectionIdentifiers.isEmpty)
        XCTAssertTrue(dataSource.snapshot().itemIdentifiers.isEmpty)
    }

    func testReplaceWithNonUniqueSectionIdentifiers() {
        let content: [DiffableSection<Section, Row>] = [topSection, topSection]

        dataSource.replace(with: content)

        XCTAssertEqual(loggedError, .sectionsNotUnique)
    }

    func testReplaceWithNonUniqueRowIdentifiers() {
        let wrongBottomSection = DiffableSection<Section, Row>(identifier: .bottom, rows: [.headerElement])
        let content: [DiffableSection<Section, Row>] = [topSection, wrongBottomSection]

        dataSource.replace(with: content, animatingDifferences: false)

        XCTAssertEqual(loggedError, .rowsNotUnique)
    }

    func testReplace() throws {
        let content = [topSection, middleSection, bottomSection]

        dataSource.replace(with: content, animatingDifferences: false)

        XCTAssertEqual(dataSource.snapshot().sectionIdentifiers, content.map { $0.identifier })
        XCTAssertEqual(dataSource.snapshot().itemIdentifiers, content.flatMap { $0.rows })
    }

    func testCanEdit() throws {
        let content = [topSection, middleSection, bottomSection]

        dataSource.replace(with: content, animatingDifferences: false)

        XCTAssertFalse(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 0)))
        XCTAssertTrue(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 1)))
        XCTAssertTrue(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 1, section: 1)))
        XCTAssertFalse(dataSource.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 2)))
    }

    func testSectionAt() throws {
        let content = self.content.value

        dataSource.replace(with: content, animatingDifferences: false)

        for index in 0..<self.content.value.count {
            XCTAssertEqual(section(at: index), content[index].identifier, "Wrong section at index (\(index))")
        }
    }

    func testRowAt() throws {
        let content = [topSection, middleSection, bottomSection]

        dataSource.replace(with: content, animatingDifferences: false)

        for section in 0..<content.count {
            for row in 0..<content[section].rows.count {
                let indexPath = IndexPath(row: row, section: section)

                XCTAssertEqual(self.row(at: indexPath), content[section].rows[row], "Wrong row at indexPath (\(row))")
            }
        }
    }
}
