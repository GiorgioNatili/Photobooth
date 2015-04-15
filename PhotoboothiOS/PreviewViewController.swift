import UIKit
import MobileCoreServices
import TwitterKit

class PreviewViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var previewImage: UIImageView!
    var logoView: UIImageView!

    @IBOutlet weak var navbar: UINavigationItem!
    
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
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    func share(){
        println("share")
        let status = "Random txt string from Struct"
        let uiImage = self.previewImage.image
        //let imageData = UIImageJPEGRepresentation(uiImage, 0.8)
        // will fix
        if status != ""{
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            // rewrite post request using TwitterKit
            let composer = TWTRComposer()
            composer.setText(status)
            composer.setImage(uiImage)
            composer.showWithCompletion { (result) -> Void in
                if (result == TWTRComposerResult.Cancelled) {
                    //self.beginSession()
                    self.showCamera()
                }
                else {
                    println("Sending tweet!")
                    self.showTweets()
                }
            }
            
        }
        
        println("didTouchUpInsideTweetButton")
        
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
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    
    func showCamera() {
        
        //Twitter.sharedInstance().logOut()
        self.performSegueWithIdentifier("camera", sender: self);
        // ensure that presentViewController happens from the main thread/queue
        //dispatch_async(dispatch_get_main_queue(), {
        //    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CameraViewController") as! UIViewController
            //self.presentViewController(controller, animated: true, completion: nil)
        //});
        
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
