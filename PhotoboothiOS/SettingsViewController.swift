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
    