import UIKit
import Accounts
import Social
import PhotoboothiOS
import TwitterKit

class AuthViewController: UIViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let logInButton = TWTRLogInButton(logInCompletion: {
            (session: TWTRSession!, error: NSError!) in

            let twitter = Twitter.sharedInstance()
            
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.username = session.userName
            appDelegate.swifter = Swifter(consumerKey: twitter.authConfig.consumerKey!, consumerSecret: twitter.authConfig.consumerSecret!, oauthToken: session.authToken!, oauthTokenSecret: session.authTokenSecret!)
            
            self.showPhotoView()
            
        })
        
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
    func showPhotoView() {
        
        let failureHandler: ((NSError) -> Void) = {
            error in
            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        
        // ensure that presentViewController happens from the main thread/queue
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") as UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        });
        
    }

    func alertWithTitle(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}