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

class CameraViewController: UIViewController,
UINavigationControllerDelegate, UIImagePickerControllerDelegate /*, UITextViewDelegate */ {
    
    @IBOutlet weak var imageView: UIButton!
    @IBOutlet weak var statusTextField: UITextView!

    
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var takePhotoButton: UIBarButtonItem!
    @IBOutlet weak var tweetPhotoButton: UIBarButtonItem!
    
    /* We will use this variable to determine if the viewDidAppear:
    method of our view controller is already called or not. If not, we will
    display the camera view */
    var beenHereBefore = false
    var controller: UIImagePickerController?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    func cameraSupportsMedia(mediaType: String,
        sourceType: UIImagePickerControllerSourceType) -> Bool{
            
            let availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(sourceType) as [AnyObject]?
            
            if let types = availableMediaTypes {
                for type in types {
                    if type as! String == mediaType {
                        return true
                    }
                }
            }
            
            return false
    }
    
    func doesCameraSupportTakingPhotos() -> Bool{
        return cameraSupportsMedia(kUTTypeImage as String, sourceType: .Camera)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        self.statusTextField.text = controller.getDefaultText()
        
        if beenHereBefore {
            /* Only display the picker once as the viewDidAppear: method gets
            called whenever the view of our view controller gets displayed */
            return;
        } else {
            beenHereBefore = true
        }
        
        let twitterLogo = UIImage(named: "TwitterLogoSmall")
        let button1 = UIBarButtonItem(image: twitterLogo, style: UIBarButtonItemStyle.Plain, target: self, action: "showSettings")
        self.navbar.setLeftBarButtonItem(button1, animated: false)
        
        let button2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "showPhotoModal")
        self.toolbar.items?[0] = button2
        
        // make tap of image show photo modal
        var tgr = UITapGestureRecognizer(target:self, action:Selector("showPhotoModal"))
        self.imageView.addGestureRecognizer(tgr)
    
//        self.showPhotoModal();
        
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
            
            println("Picker returned successfully")
            
            picker.dismissViewControllerAnimated(true, completion: {
                
                let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
                
                if let type:AnyObject = mediaType {
                    
                    if type is String {
                        let stringType = type as! String
                        
                        //                    if stringType == kUTTypeMovie as String {
                        //                        let urlOfVideo = info[UIImagePickerControllerMediaURL] as NSURL
                        //                        if let url = urlOfVideo {
                        //                            println("Video URL = \(url)")
                        //                        }
                        //                    }
                        
                        if stringType == kUTTypeImage as String {
                            
                            /* Let's get the metadata. This is only for images. Not videos */
                            let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary
                            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
                            
                            if let theImage = image {
                                
                                // UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                                self.imageView.setBackgroundImage(image, forState: UIControlState.Normal)
                                self.imageView.setTitle("", forState: UIControlState.Normal)
                                
                                println("Image = \(theImage)")
                            }
                        }
                        
                    }
                }
                
            })
            
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("Picker was cancelled")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func didTouchUpInsidePhotoButton(sender: AnyObject) {

        let failureHandler: ((NSError) -> Void) = {
            error in
            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        
        println("didTouchUpInsidePhotoButton")
        
        self.showPhotoModal()
        
    }
    
  
    @IBAction func didTouchUpInsideTweetButton(sender: AnyObject) {

        let failureHandler: ((NSError) -> Void) = {
            error in
            self.alertWithTitle("Error", message: error.localizedDescription)
        }

        let status = self.statusTextField.text
        let uiImage = self.imageView.currentBackgroundImage
        let imageData = UIImageJPEGRepresentation(uiImage, 0.8)
        
        if status != nil && imageData != nil {

            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            // rewrite post request using TwitterKit
            let composer = TWTRComposer()
            
            composer.setText(status)
            composer.setImage(uiImage)
            
            composer.showWithCompletion { (result) -> Void in
                if (result == TWTRComposerResult.Cancelled) {
                    println("Tweet composition cancelled")
                }
                else {
                    println("Sending tweet!")
                }
            }
            
        }

        println("didTouchUpInsideTweetButton")

    }
    
    func showPhotoModal() {
        
        controller = UIImagePickerController()
        
        if let theController = controller {
            
            if isCameraAvailable() && doesCameraSupportTakingPhotos(){
                theController.sourceType = .Camera
                theController.cameraDevice = .Front
            } else {
                theController.sourceType = .PhotoLibrary
            }
            
            theController.mediaTypes = [kUTTypeImage as String]
            theController.allowsEditing = true
            theController.delegate = self
            
            presentViewController(theController, animated: true, completion: nil)
        }
        
    }

    @IBAction func showTweets(){
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = TweetViewController()
            self.showViewController(controller, sender: self)

        });
        
    }

    @IBAction func showSettings() {
        
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as! UIViewController
            self.showViewController(controller, sender: self)
        });
        
    }

    func alertWithTitle(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
