import UIKit
import PhotoboothiOS

import TwitterKit

class TweetViewController : TWTRTimelineViewController {

    convenience init() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let client = Twitter.sharedInstance().APIClient
        let dataSource = TWTRUserTimelineDataSource(screenName: appDelegate.username, APIClient: client)
        
        self.init(dataSource: dataSource)
    }
    
    override required init(dataSource: TWTRTimelineDataSource) {
        super.init(dataSource: dataSource)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let client = Twitter.sharedInstance().APIClient
        self.dataSource = TWTRUserTimelineDataSource(screenName: appDelegate.username, APIClient: client)
        
        // kick off actual rendering
        super.viewWillAppear(animated)
        
        println("TweetViewController.viewWillAppear: \(self.dataSource)")
    }
    
}
