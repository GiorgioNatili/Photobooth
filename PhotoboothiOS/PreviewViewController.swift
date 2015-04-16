import Foundation
import UIKit
import MobileCoreServices
import TwitterKit

class PreviewViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var previewImage: UIImageView!
    var logoView: UIImageView!

    @IBOutlet weak var navbar: UINavigationItem!
    
    @IBOutlet weak var tweetTxt: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNav()
        
        // get image from photo
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let destinationPath = documentsPath.stringByAppendingPathComponent("photobooth.jpg")
        let image = UIImage(contentsOfFile: destinationPath )
        previewImage.image = image
        
        var tap = UITapGestureRecognizer(target:self, action:Selector("share"))
        self.view.addGestureRecognizer(tap)
        
        var swipe = UISwipeGestureRecognizer(target: self, action: Selector("reset"))
        self.view.addGestureRecognizer(swipe)
        
        tweetTxt.text = SettingsViewController.Settings.tweetText
        tweetTxt.becomeFirstResponder();
        tweetTxt.alpha = 0.6
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    @IBAction func didTouchTweetButton(sender: AnyObject) {
        self.share()
    }
    
    func share(){
        let status = tweetTxt.text
        let uiImage = self.previewImage.image
        let composer = TWTRComposer()
        composer.setText(status)
        composer.setImage(uiImage)
        composer.showWithCompletion { (result) -> Void in
            if (result == TWTRComposerResult.Cancelled) {
                self.showCamera()
            }
            else {
                println("Sending tweet!")
                sleep(3)
                self.showTweets()
            }
        }
        
        println("share")
        
    }
    
    func reset(){
        self.showCamera()
        println("reset")
    }
  
    func setupNav() {
        
        // Setup Navigation controller / remove uiBorderbottom to blue
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        
        // Change the border to blue
        let navHeight = self.navigationController?.navigationBar.frame.height
        let navWidth = self.navigationController?.navigationBar.frame.width
        var navBorder = UIView(frame: CGRectMake(0, navHeight! - 2, navWidth!, 2))
        navBorder.backgroundColor = UIColor(rgba: "#5EA9DD")
        self.navigationController?.navigationBar.addSubview(navBorder)
        
        // Append image to the navigation bar
        logoView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        logoView.image = UIImage(named: "TwitterLogo")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        logoView.tintColor = UIColor(rgba: "#5EA9DD")
        logoView.contentMode = UIViewContentMode.ScaleAspectFit
        logoView.frame.origin.x = 10
        logoView.frame.origin.y = 8
        self.navbar.titleView = logoView
        
        // Add a tap gesture to the navigation bar image to send the user to settings
        let recognizer = UITapGestureRecognizer(target: self, action: "showSettings")
        self.navbar.titleView!.userInteractionEnabled = true
        self.navbar.titleView!.addGestureRecognizer(recognizer)
//        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    
    func showCamera() {
        
        self.navigationController?.popViewControllerAnimated(true)

        //        self.performSegueWithIdentifier("camera", sender: self);

    }
    
    func showTweets(){
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = TweetViewController()
            self.showViewController(controller, sender: self)
            
        });
        
    }
    
    func showSettings() {
        
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as! UIViewController
            self.showViewController(controller, sender: self)
        });
        
    }
    
}
