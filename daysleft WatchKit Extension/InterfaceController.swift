//
//  InterfaceController.swift
//  daysleft WatchKit Extension
//
//  Created by John Pollard on 22/03/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var labelTitle: WKInterfaceLabel!
    @IBOutlet weak var labelPercentDone: WKInterfaceLabel!
    @IBOutlet weak var imageProgress: WKInterfaceImage!
    
    var currentDaysLeft: Int = -1;
    var currentWeekdaysOnly = false;
    var currentTitle = ""
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InterfaceController.userSettingsUpdated(_:)), name: BLUserSettings.UpdateSettingsNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.updateViewData()
    }
    
    override func willActivate() {
        super.willActivate()
        self.updateViewData()
    }
    
    private func updateViewData() {
        NSLog("Updating view data...")
        
        let now: NSDate = NSDate()
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        let model = appDelegate.model
        
        // Do we need to update the view?
        let daysLeft = model.DaysLeft(now);
        let weekdaysOnly = model.weekdaysOnly
        let title = model.title
        
        if (daysLeft == self.currentDaysLeft && currentWeekdaysOnly == weekdaysOnly && currentTitle.compare(title) == NSComparisonResult.OrderedSame) {
            NSLog("View unchanged")
            return;
        }
        
        self.currentDaysLeft = daysLeft
        self.currentWeekdaysOnly = weekdaysOnly
        self.currentTitle = title
        
        self.labelTitle.setText(model.FullDescription(now))
        
        let percentageDone: Float = (Float(model.DaysGone(now)) * 100.0) / Float(model.DaysLength)
        self.labelPercentDone.setText(String(format:"%3.0f%% done", percentageDone))
        
        // Set the progress image set
        let intPercentageDone: Int = Int(percentageDone)
        self.imageProgress.setImageNamed("progress")
        self.imageProgress.startAnimatingWithImagesInRange(NSRange(location:0, length: intPercentageDone), duration: 0.5, repeatCount: 1)
        NSLog("View updated")
        
        // Let's also update the complications if the data has changed
        model.updateComplications()
        
        // Let's update the snapshot if the view changed
        print("Scheduling snapshot")
        let soon = NSDate().addTimeInterval(5.0)
        WKExtension.sharedExtension().scheduleSnapshotRefreshWithPreferredDate(soon as! NSDate, userInfo: nil, scheduledCompletion: { (error: NSError?) in
            if let error = error {
                print("Error occurred while scheduling snapshot: \(error.localizedDescription)")
            }})
    }
    
    @objc
    private func userSettingsUpdated(notification: NSNotification) {
        NSLog("Received BLUserSettingsUpdated notification")
        
        // Update view data on main thread
        dispatch_async(dispatch_get_main_queue()) {
            self.updateViewData()
        }
    }
}
