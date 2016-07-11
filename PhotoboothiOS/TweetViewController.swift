//
// Copyright (C) 2015 Twitter, Inc. and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import TwitterKit

class TweetViewController : TWTRTimelineViewController {
    
    private var screenName:String?
    private var client:TWTRAPIClient?
    
    convenience init() {
                
        if let session = Twitter.sharedInstance().sessionStore.session() {
            
            let client = TWTRAPIClient()
            client.loadUserWithID(session.userID) { (user, error) -> Void in
                
                if let user = user {
                    
                    self.dataSource = TWTRUserTimelineDataSource(screenName: user.screenName, APIClient: client)
                    self.screenName = user.screenName
                    self.client = client
                    
                    self.init(dataSource: self.dataSource)
                }
            }
        }
    }
    
    override required init(dataSource: TWTRTimelineDataSource?) {
        super.init(dataSource: dataSource)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {

      //  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
     //   let screenName = Twitter.sharedInstance().session().userName
     //   let client = Twitter.sharedInstance().APIClient
        
       // TODO clean this forced unwrap
        
        self.dataSource = TWTRUserTimelineDataSource(screenName: screenName!, APIClient: client!)
        
        // kick off actual rendering
        super.viewWillAppear(animated)
        
        print("TweetViewController.viewWillAppear: \(self.dataSource)")
    }
    
}
