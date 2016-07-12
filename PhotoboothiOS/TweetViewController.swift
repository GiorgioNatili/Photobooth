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
    
    // MARK: overrides
    convenience init() {
        
        self.init(dataSource: nil)
        
        if let session = Twitter.sharedInstance().sessionStore.session() {
            
            let client = TWTRAPIClient()
            client.loadUserWithID(session.userID) { (user, error) in
                
                if let user = user {
                    
                    self.dataSource = TWTRUserTimelineDataSource(screenName: user.screenName, APIClient: client)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    override init (dataSource: TWTRTimelineDataSource?) {
        super.init(dataSource: dataSource)
    }
    
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // kick off actual rendering
        super.viewWillAppear(animated)
    }
    
}
