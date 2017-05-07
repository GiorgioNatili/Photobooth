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
import MobileCoreServices
import TwitterKit

class SettingsViewController: BoothViewController, UITextViewDelegate {

    struct Settings {
        static var tweetText = ""
    }
    
    @IBOutlet weak var defaultTextField: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setupNav(true, enableSettings: false, enableLogout: true)
        navigationBarTitle = "Settings"
        
        self.defaultTextField.delegate = self
        
        let sessionStore = Twitter.sharedInstance().sessionStore
        
        if let session = sessionStore.session() as? TWTRSession {
            
            var tweet = defaultTextField.text
            tweet = tweet.stringByReplacingOccurrencesOfString("YOUR_HANDLE", withString:session.userName)
            
            defaultTextField.text = tweet
        }
        
        Settings.tweetText = defaultTextField.text
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        print(textView.text, terminator: ""); //the textView parameter is the textView where text was changed
        
        SettingsViewController.Settings.tweetText = textView.text
    }
    
    func logOut() {
        
        let sessionStore = Twitter.sharedInstance().sessionStore
        if let userId = sessionStore.session()?.userID {
            
            sessionStore.logOutUserID(userId)
        }
        
        // ensure that presentViewController happens from the main thread/queue
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AuthViewController") 
            self.presentViewController(controller, animated: true, completion: nil)
        });
        
    }
    
}
    