//
//  SectionedTableViewCell.swift
//  Sumanth
//
//  Created by Sumanth on 19/03/2020.
//

import UIKit

protocol SectionedTableViewCellProtocol: SectionedTableViewProtocol {
    func cellForRowAt(index: Int, for cell: SectionedTableViewCell) -> UITableViewCell
    func numberOfRows(in cell: SectionedTableViewCell) -> Int
    func didSelectRowAt(index: Int, in cell: SectionedTableViewCell)
    func heightForRowAt(index: Int, for cell: SectionedTableViewCell) -> CGFloat
    func trailingSwipeActionsConfigurationForRowAt(index: Int, for cell: SectionedTableViewCell) -> UISwipeActionsConfiguration?
    func willDisplay(index: Int, tableCell: UITableViewCell, forCell: SectionedTableViewCell)
}

class SectionedTableViewCell: UITableViewCell {
    var section = 0

    public var margin:CGFloat = 16.0
    
    weak var delegate: SectionedTableViewCellProtocol? {
        didSet {
            if let values = delegate?.cellIdentifiersToRegister() {
                for (key, value) in values {
                    tableView.register(value, forCellReuseIdentifier: key)
                }
            }
        }
    }

    weak var dataSource: UITableViewDataSource?

    lazy var containerView: ShadowView = {
        ShadowView()
    }()

    lazy var tableView: ChildTableView = {
        let tableView = ChildTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    deinit {}

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupLayout()
    }

    init(contentHeight onView: UIView & SectionedTableViewCellProtocol) {
        super.init(style: .default, reuseIdentifier: "SectionedTableViewCell1")
        delegate = onView
        onView.addSubview(tableView)
        tableView.isHidden = false
        setHeight()
    }

    func setHeight(height: CGFloat = 0) {
        let tableViewHeight = height > 0 ? height : tableView.superview?.frame.height
        let width = (tableView.superview?.frame.width ?? 100) - CGFloat(margin * 2)
        tableView.frame = CGRect(x: 0, y: 0,
                                 width: width,
                                 height: tableViewHeight ?? 0)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupViews()
        setupLayout()
    }

    func setupViews() {
        containerView.addSubview(tableView)
        addSubview(containerView)
        clipsToBounds = false
        backgroundColor = .clear
        selectionStyle = .none
    }

    func setupLayout() {
        
        containerView.bindFrameToSuperviewBounds(with: UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin))
        tableView.bindFrameToSuperviewBounds()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension SectionedTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        delegate?.numberOfRows(in: self) ?? 0
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        delegate?.cellForRowAt(index: indexPath.row, for: self) ?? UITableViewCell()
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectRowAt(index: indexPath.row, in: self)
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        delegate?.heightForRowAt(index: indexPath.row, for: self) ?? UITableView.automaticDimension
    }

    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        delegate?.trailingSwipeActionsConfigurationForRowAt(index: indexPath.row, for: self)
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.willDisplay(index: indexPath.row, tableCell: cell, forCell: self)
    }
}

extension SectionedTableViewCell {
    func calculateHeight(at indexPath: IndexPath) -> CGFloat {
        section = indexPath.section
        let numberOfRows = tableView(tableView, numberOfRowsInSection: indexPath.section)
        var estimatedHeight = tableView.estimatedRowHeight
        estimatedHeight = estimatedHeight > 0 ? estimatedHeight : 200
        setHeight(height: CGFloat(numberOfRows) * estimatedHeight)
        tableView.reloadData()
        tableView.layoutIfNeeded()

        var height = tableView.contentSize.height
        height += tableView.contentInset.top
        height += tableView.contentInset.bottom
        height += (CGFloat(tableView.numberOfSections) * tableView.sectionHeaderHeight)
        return height
    }
}

class ChildTableView: UITableView {}
