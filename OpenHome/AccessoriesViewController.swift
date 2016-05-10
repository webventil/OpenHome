//
//  SecondViewController.swift
//  OpenHome
//
//  Created by Johannes on 16.02.16.
//  Copyright (c) 2016 Johannes Steudle. All rights reserved.
//

import UIKit
import HomeKit

class AccessoriesViewController: UITableViewController, HMHomeManagerDelegate {
    let homeManager = HMHomeManager()
    var activeHome: HMHome?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("viewDidLoad")
        homeManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activeHome != nil {
            let countAccessories = activeHome!.accessories.count
            print("Found \(countAccessories) accessories")
            return countAccessories
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("accessoryId") as UITableViewCell?
        print("Add accessory \(activeHome?.accessories[indexPath.row].name)")
        cell?.textLabel?.text = activeHome?.accessories[indexPath.row].name

        return (cell != nil) ? cell! : UITableViewCell()
    }

    func homeManagerDidUpdateHomes(manager: HMHomeManager) {
        print("homeManagerDidUpdateHomes")
        activeHome = homeManager.primaryHome
        tableView.reloadData()
    }

}
