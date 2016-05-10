//
//  MainViewController.swift
//  OpenHome
//
//  Created by Johannes on 16.02.16.
//  Copyright (c) 2016 Johannes Steudle. All rights reserved.
//

import UIKit
import HomeKit

class MainViewController: UITableViewController, HMHomeManagerDelegate {

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

    // MARK: - Table Delegate

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let homes = homeManager.homes
        print("Found \(homes.count) homes")
        return homes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("homeId") as UITableViewCell?
        let home = homeManager.homes[indexPath.row] as HMHome
        cell?.textLabel?.text = home.name

        // ignore the information service
        cell?.detailTextLabel?.text = "\(home.accessories.count) " + { () -> String in
            if home.accessories.count <= 1 { return "accessory" } else { return "accessories" }
        }()
        return (cell != nil) ? cell! : UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // lastSelectedIndexRow = indexPath.row
    }

    // MARK: - HomeManager Delegate

    func homeManagerDidUpdateHomes(manager: HMHomeManager) {
        print("homeManagerDidUpdateHomes")
        checkHomeSetup()
    }

    // MARK: HomeKit Helper Functions

    func checkHomeSetup() {
        if homeManager.primaryHome != nil {
            self.activeHome = homeManager.primaryHome
            print("Found primary home: \(activeHome)")
            title = activeHome!.name
            self.tableView.reloadData()
        } else if homeManager.homes.first != nil {
            self.activeHome = homeManager.homes.first
            print("Found first home: \(activeHome), set it to primary")
            self.homeManager.updatePrimaryHome(activeHome!, completionHandler: { (error) in
                if error != nil {
                    print("Something went wrong when attempting to make this home our primary home. \(error?.localizedDescription)")
                }
            })
            self.tableView.reloadData()
        } else {
            print("Found no home")

            var alertViewTextField = UITextField()
            var text = "Default"
            let alertView = UIAlertController(title: "No home found!", message: "Didn't find any home, please create a new one:", preferredStyle: UIAlertControllerStyle.Alert)

            alertView.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                alertViewTextField = textField
            })

            alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                // update the text
                text = alertViewTextField.text!

                self.homeManager.addHomeWithName(text, completionHandler: { (home, error) in
                    // what to do here?
                    if error != nil {
                        print("Something went wrong when attempting to create our home. \(error?.localizedDescription)")
                    } else {
                        print("Successfully added home \(home)")
                        self.activeHome = home
                        self.homeManager.updatePrimaryHome(home!, completionHandler: { (error) in
                            if error != nil {
                                print("Something went wrong when attempting to make this home our primary home. \(error?.localizedDescription)")
                            }
                        })
                        self.tableView.reloadData()
                    }
                })
                }))

            alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))

            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alertView, animated: true, completion: nil)
            })
        }
    }
}
