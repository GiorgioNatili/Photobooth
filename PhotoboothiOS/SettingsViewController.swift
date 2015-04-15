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

class SettingsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var defaultTextField: UITextView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultTextField.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func getDefaultText() -> String {
        if self.defaultTextField == nil {
            self.defaultTextField = UITextView()
        }
        
        if self.defaultTextField.text == nil || self.defaultTextField.text == "" {
            self.defaultTextField.text = "Hanging out at the @TwitterDev booth during #bitcamp!"
        }
        
        return self.defaultTextField.text
    }
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        print(textView.text); //the textView parameter is the textView where text was changed
    }
    
    @IBAction func logOut(sender: AnyObject) {
        
        Twitter.sharedInstance().logOut()
        
        // ensure that presentViewController happens from the main thread/queue
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AuthViewController") as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        });
        
    }
    
}
    