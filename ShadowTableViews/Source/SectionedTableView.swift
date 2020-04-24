//
//  SectionedTableView.swift
//  Sumanth
//
//  Created by Sumanth on 19/03/2020.
//

import UIKit

protocol SectionedTableViewProtocol: UITableViewDelegate, UITableViewDataSource {
    func cellIdentifiersToRegister() -> [String:AnyClass]
}

extension SectionedTableViewProtocol {
    func cellIdentifiersToRegister() -> [String:AnyClass]{
        return [:]
    }
}

public class SectionedTableView: UITableView {
    weak var groupedDelegate: (UITableViewDelegate & UITableViewDataSource)?

    var sectionTableViewHeights: [Int: CGFloat] = [:]
    
    private var childRegisterCells:[String:AnyClass] = [:]
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        initialize()
    }
    
    public override func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        childRegisterCells[identifier] = cellClass
    }
    
    private var canAllowSelection = true
    private var childSeparatorStyle: UITableViewCell.SeparatorStyle = .singleLine

    public override var separatorStyle: UITableViewCell.SeparatorStyle {
        set {
            super.separatorStyle = .none
            childSeparatorStyle = newValue
        }
        get {
            return super.separatorStyle
        }
    }

    public override var allowsSelection: Bool {
        set {
            super.allowsSelection = newValue
            canAllowSelection = newValue
        }
        get {
            return super.allowsSelection
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        super.register(SectionedTableViewCell.self, forCellReuseIdentifier: "SectionedTableViewCell")
//        separatorColor = ThemeSettings.theme.tableViewSeparatorColor
        separatorStyle = .none
        childSeparatorStyle = .singleLine
        backgroundColor = .clear
        dataSource = self
        delegate = self
    }

    public override func reloadData() {
        sectionTableViewHeights.removeAll()
        let sectionTableViewCell = getSectionedTableViewCell()
        setConfiguration(for: sectionTableViewCell)
        calculateHeights(with: sectionTableViewCell)
        super.reloadData()
        sectionTableViewCell.tableView.removeFromSuperview()
    }

    func calculateHeights(with cell: SectionedTableViewCell) {
        for section in 0 ..< numberOfSections(in: self) {
            let indexPath = IndexPath(row: 0, section: section)
            sectionTableViewHeights[section] = cell.calculateHeight(at: indexPath)
        }
    }

    func setConfiguration(for cell: SectionedTableViewCell) {
        cell.tableView.separatorStyle = childSeparatorStyle
        cell.tableView.allowsSelection = canAllowSelection
        cell.tableView.separatorColor = separatorColor
        cell.delegate = self
        cell.dataSource = groupedDelegate
    }

    func getSectionedTableViewCell() -> SectionedTableViewCell {
        let sectionTableViewCell = SectionedTableViewCell(contentHeight: self)
        sectionTableViewCell.delegate = self
        sectionTableViewCell.dataSource = groupedDelegate
        return sectionTableViewCell
    }
}

extension SectionedTableView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return groupedDelegate?.numberOfSections?(in: tableView) ??
            (groupedDelegate?.tableView(self, numberOfRowsInSection: 0) ?? 0 > 0 ? 1 : 0)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = groupedDelegate?.tableView(tableView, numberOfRowsInSection: section)
        return numberOfRows ?? 0 > 0 ? 1 : 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SectionedTableViewCell",
                                                       for: indexPath) as? SectionedTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }

    public func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SectionedTableViewCell else {
            return
        }
        cell.section = indexPath.section
        setConfiguration(for: cell)
        cell.tableView.reloadData()
    }

    public func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        sectionTableViewHeights[indexPath.section] ?? UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        groupedDelegate?.tableView?(tableView, viewForHeaderInSection: section) ?? UIView()
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        groupedDelegate?.tableView?(tableView, viewForFooterInSection: section)
    }

    public override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        guard let cell = super.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? SectionedTableViewCell else {
            return nil
        }
        let subIndexPath = IndexPath(row: indexPath.row, section: 0)
        return cell.tableView.cellForRow(at: subIndexPath)
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        groupedDelegate?.tableView?(tableView, heightForFooterInSection: section) ?? UITableView.automaticDimension
    }

    func deselectSelectedIndexPath(animated: Bool = true) {
        if let indexPath = indexPathForSelectedRow,
            let cell = super.cellForRow(at: indexPath) as? SectionedTableViewCell,
            let selectedIndexPath = cell.tableView.indexPathForSelectedRow {
            cell.tableView.deselectRow(at: selectedIndexPath, animated: animated)
            deselectRow(at: indexPath, animated: animated)
        }
    }
}

extension SectionedTableView: SectionedTableViewCellProtocol {
    func cellIdentifiersToRegister() -> [String:AnyClass] {
        return childRegisterCells
    }

    func cellForRowAt(index: Int, for cell: SectionedTableViewCell) -> UITableViewCell {
        let indexPath = IndexPath(row: index, section: cell.section)
        guard let cell = groupedDelegate?.tableView(cell.tableView,
                                                    cellForRowAt: indexPath) else {
            return UITableViewCell()
        }
        return cell
    }

    func heightForRowAt(index: Int, for cell: SectionedTableViewCell) -> CGFloat {
        let indexPath = IndexPath(row: index, section: cell.section)
        return groupedDelegate?.tableView?(cell.tableView, heightForRowAt: indexPath) ?? UITableView.automaticDimension
    }

    func numberOfRows(in cell: SectionedTableViewCell) -> Int {
        if numberOfSections(in: cell.tableView) > 0 {
            return groupedDelegate?.tableView(cell.tableView, numberOfRowsInSection: cell.section) ?? 0
        }
        return 0
    }

    func didSelectRowAt(index: Int, in cell: SectionedTableViewCell) {
        let indexPath = IndexPath(row: index, section: cell.section)
        let currentTableIndexPath = IndexPath(row: 0, section: cell.section)
        selectRow(at: currentTableIndexPath, animated: false, scrollPosition: .none)
        groupedDelegate?.tableView?(cell.tableView, didSelectRowAt: indexPath)
    }

    func trailingSwipeActionsConfigurationForRowAt(index: Int, for cell: SectionedTableViewCell) -> UISwipeActionsConfiguration? {
        let indexPath = IndexPath(row: index, section: cell.section)
        return groupedDelegate?.tableView?(cell.tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        groupedDelegate?.scrollViewDidScroll?(scrollView)
    }

    func willDisplay(index: Int, tableCell: UITableViewCell, forCell: SectionedTableViewCell) {
        let indexPath = IndexPath(row: index, section: forCell.section)
        groupedDelegate?.tableView?(forCell.tableView, willDisplay: tableCell, forRowAt: indexPath)
    }
}
