import UIKit
import TwitterKit

class TweetViewController : TWTRTimelineViewController {
    
    convenience init() {
        
        let client = Twitter.sharedInstance().APIClient
        let screenName = Twitter.sharedInstance().session().userName
        let dataSource = TWTRUserTimelineDataSource(screenName: screenName, APIClient: client)
        
        self.init(dataSource: dataSource)
    }
    
    override required init(dataSource: TWTRTimelineDataSource) {
        super.init(dataSource: dataSource)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let screenName = Twitter.sharedInstance().session().userName
        let client = Twitter.sharedInstance().APIClient
        self.dataSource = TWTRUserTimelineDataSource(screenName: screenName, APIClient: client)
        
        // kick off actual rendering
        super.viewWillAppear(animated)
        
        println("TweetViewController.viewWillAppear: \(self.dataSource)")
    }
    
}
