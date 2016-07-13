import Foundation
import UIKit
import MobileCoreServices
import TwitterKit

class PreviewViewController: BoothViewController, UITextViewDelegate {
    
    // MARK: members
    private var orientation:UIImageOrientation!
    
    // MARK: UI elements outlets
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var tweetTxt: UITextView!
    
    // MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setupNav(true, enableSettings : false)
        
        // get image from photo
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let destinationPath = (documentsPath as NSString).stringByAppendingPathComponent("photobooth.jpg")
        
        let image = UIImage(contentsOfFile: destinationPath)
        previewImage.image = UIImage(CGImage: image!.CGImage!, scale: 1.0, orientation: orientation)

        let tap = UITapGestureRecognizer(target:self, action:Selector("share"))
        self.view.addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: Selector("reset"))
        self.view.addGestureRecognizer(swipe)
        
        tweetTxt.text = SettingsViewController.Settings.tweetText
        tweetTxt.becomeFirstResponder();
        tweetTxt.alpha = 0.6
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    // MARK: user gestures handlers
    @IBAction func didTouchTweetButton(sender: AnyObject) {
        self.share()
    }
    
    // MARK: selectors
    func share(){
        
        let status = tweetTxt.text
        let uiImage = self.previewImage.image
        
        let composer = TWTRComposer()
        
        composer.setText(status)
        composer.setImage(uiImage)
        composer.showFromViewController(self) { (result) -> Void in
            
            if (result == TWTRComposerResult.Cancelled) {
                
                self.showCamera()
            } else {
                print("Sending tweet!")
                sleep(3)
                self.showTweets()
            }
        }
        
        print("share")
        
    }
    
    func reset(){
        self.showCamera()
        print("reset")
    }
    
    // MARK: accessors
    var imageOrientation: UIImageOrientation {
        
        set(newImageOrientation) {
            
            orientation = newImageOrientation
        }
        
        get{
            
            return orientation
        }
    }
  
    // MARK: internal methods
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
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") 
            self.showViewController(controller, sender: self)
        });
        
    }
    
}
