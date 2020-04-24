//
//  ViewController.swift
//  ShadowTableViews
//
//  Created by Sumanth on 24/04/2020.
//  Copyright © 2020 sumanth. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SectionedTableViewProtocol {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let text = "This is sample cell for section \(indexPath.section) row \(indexPath.row)"
        cell.textLabel?.text = text
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
    

    @IBOutlet weak var tableView: SectionedTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.groupedDelegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.backgroundColor = UIColor.groupTableViewBackground
    }

}

