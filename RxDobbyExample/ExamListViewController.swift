//
//  ExamListViewController.swift
//  RxDobby
//
//  Created by ryan on 9/8/16.
//  Copyright © 2016 kimyoungjin. All rights reserved.
//

import UIKit
import RxDobby

class ExamListViewController: UITableViewController {

    @IBAction func lmenu(_ sender: AnyObject) {
        
        DSegue(
            source: self,
            destination: { () -> UIViewController in
                let menuvc = UIViewController.viewControllerFromStoryboard(name: "Main", identifier: "Menu") as! MenuViewController
                return menuvc
            },
            style: {
                DSegueStyle.presentModallyWithDirection(.leftToRight) { (parentSize: CGSize) -> CGSize in
                    return CGSize(width: 300.0, height: parentSize.height)
                }
        }).perform()
    }
    
    @IBAction func rmenu(_ sender: AnyObject) {
        
        DSegue(
            source: self,
            destination: { () -> UIViewController in
                let menuvc = UIViewController.viewControllerFromStoryboard(name: "Main", identifier: "Menu") as! MenuViewController
                return menuvc
            },
            style: {
                DSegueStyle.presentModallyWithDirection(.rightToLeft) { (parentSize: CGSize) -> CGSize in
                    return CGSize(width: 300.0, height: parentSize.height)
                }
        }).perform()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MenuViewController {
            dest.centerViewController = self
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


}
