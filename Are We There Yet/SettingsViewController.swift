//
//  SearchViewController.swift
//  Are We There Yet
//
//  Created by Josef Rönn on 2015-07-10.
//  Copyright © 2015 Josef Rönn. All rights reserved.
//

import Foundation
import UIKit


class SettingsViewController:UITableViewController {

    
    @IBOutlet weak var distanceDisplaySwitch: UISwitch!
    @IBOutlet weak var timeDisplaySwitch: UISwitch!
    @IBOutlet weak var distanceAudioSwitch: UISwitch!
    @IBOutlet weak var unitTypeSwitch: UISegmentedControl!
    @IBOutlet weak var volumeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSettingValues()
        
        // Prevent cells from being highlighted
        tableView.allowsSelection = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.whiteColor()
    }
    
    private func loadSettingValues() {
        distanceDisplaySwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("distanceDisplay")
        timeDisplaySwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("timeDisplay")
        distanceAudioSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("distanceAudio")
        volumeSlider.value = NSUserDefaults.standardUserDefaults().floatForKey("volume")
        
        let unitType = NSUserDefaults.standardUserDefaults().stringForKey("unitType")
        
        if unitType == "km" {
            unitTypeSwitch.selectedSegmentIndex = 0
        } else {
            unitTypeSwitch.selectedSegmentIndex = 1
        }
    }
    
    
    @IBAction func distanceDisplayChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "distanceDisplay")
    }
    
    @IBAction func timeDisplayChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "timeDisplay")
    }
    
    @IBAction func distanceAudioChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "distanceAudio")
    }
    
    @IBAction func volumeChange(sender: UISlider) {
        NSUserDefaults.standardUserDefaults().setFloat(sender.value, forKey: "volume")
    }
    
    @IBAction func unitTypeChange(sender: UISegmentedControl) {
        NSUserDefaults.standardUserDefaults().setValue(sender.titleForSegmentAtIndex(sender.selectedSegmentIndex), forKey: "unitType")
    }
}
