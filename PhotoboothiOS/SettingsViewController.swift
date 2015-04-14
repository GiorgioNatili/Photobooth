import UIKit
import MobileCoreServices
import PhotoboothiOS

import TwitterKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var defaultTextField: UITextView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func logOut(sender: AnyObject) {
        
        Twitter.sharedInstance().logOut()
        
        // ensure that presentViewController happens from the main thread/queue
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AuthViewController") as UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        });
        
    }
    
}
    