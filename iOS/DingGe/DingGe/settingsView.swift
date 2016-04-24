//
//  settingsView.swift
//  PCE相机
//
//  Created by Kevin_Feng on 16/4/16.
//  Copyright © 2016年 王浩强. All rights reserved.
//

import UIKit

class settingsView: UIViewController,UITableViewDataSource,UITableViewDelegate {

//    let tag:Int = 1
    
    var settingDataDictionary:NSDictionary! = nil
    var hideSettingSwitch:NSDictionary! = nil
    @IBOutlet var settingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.dataSource = self
        // Do any additional setup after loading the view.
        settingDataDictionary = NSDictionary(contentsOfURL: NSBundle.mainBundle().URLForResource("SupportingFiles/settingData", withExtension: "plist")!)
        hideSettingSwitch = NSDictionary(contentsOfURL: NSBundle.mainBundle().URLForResource("SupportingFiles/hideSettingSwitch", withExtension: "plist")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ((settingDataDictionary?.count)!)
    }
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return (settingDataDictionary?.allValues[section] as! NSArray).count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
//        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        let settingTableCell = tableView.dequeueReusableCellWithIdentifier("settingTableViewCell", forIndexPath: indexPath) as UITableViewCell
        let settingLabel = settingTableCell.viewWithTag(1) as! UILabel
        settingLabel.text = (settingDataDictionary?.allValues[indexPath.section] as! NSArray).objectAtIndex(indexPath.row) as! String
        let settingSwitch = settingTableCell.viewWithTag(2) as! UISwitch
        settingSwitch.hidden = (hideSettingSwitch.allValues[indexPath.section] as! NSArray).objectAtIndex(indexPath.row) as! Bool
//        settingSwitch.hidden =
        //        settingSwitch
//        print("1\(settingLabel.text)")
//        cell.textLabel.text="row#\(indexPath.row)"
//        cell.detailTextLabel.text="subtitle#\(indexPath.row)"
        
        return settingTableCell
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return settingDataDictionary?.allKeys[section] as! String
        return "\n"
    }
    
    @IBAction func settingSwitchValueChange(sender: AnyObject) {
//        print(sender.indexPath.row)
        if(NSUserDefaults.standardUserDefaults().boolForKey("AutoHidden")as Bool! == false){
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "AutoHidden")
        }
        else{
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "AutoHidden")
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
