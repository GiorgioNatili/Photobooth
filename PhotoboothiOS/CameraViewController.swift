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
import AVFoundation

class CameraViewController: UIViewController,
UINavigationControllerDelegate, UIImagePickerControllerDelegate /*, UITextViewDelegate */ {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var canvasImage: UIImageView!
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var countdown: UILabel!
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput : AVCaptureStillImageOutput?
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    var snapTime:Double = 4
    var logoView: UIImageView!
    var captureDevice : AVCaptureDevice?

    func startSnap() {

        self.countdown.alpha = 0.6

        let aSelector : Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        
    }
    
    func updateTime() {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = currentTime - startTime
        var seconds = snapTime - elapsedTime
        if seconds > 0 {
            elapsedTime -= NSTimeInterval(seconds)
            self.countdown.hidden = false
            self.countdown.text = "\(Int(seconds+1))"
            
        } else {
            self.countdown.hidden = true
            timer.invalidate()
            
            // wow we are ready to save some photos
            // setup still OutPut to save
            if let stillOutput = self.stillImageOutput {
                
                // we do this on another thread so we don't hang the UI
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    // find video connection
                    var videoConnection : AVCaptureConnection?
                    for connection in stillOutput.connections {
                        // find a matching input port
                        for port in connection.inputPorts! {
                            // and matching type
                            if port.mediaType == AVMediaTypeVideo {
                                videoConnection = connection as? AVCaptureConnection
                                break
                            }
                        }
                        if videoConnection != nil {
                            break // for connection
                        }
                    }
                    
                    if videoConnection != nil {
                        // found the video connection, let's get the image
                        stillOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                            (imageSampleBuffer:CMSampleBuffer!, _) in
                            
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                            self.didTakePhoto(imageData)
                            
                        }
                    }
                }
            }
        }
    }
    
    func didTakePhoto(imageData: NSData) {

        println("did take photo")
        let image = UIImage(data: imageData)
        let flippedImage = UIImage(CGImage: image!.CGImage, scale: 1.0, orientation: .LeftMirrored)
        self.canvasImage.image = flippedImage
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let destinationPath = documentsPath.stringByAppendingPathComponent("photobooth.jpg")
        UIImageJPEGRepresentation(flippedImage,1.0).writeToFile(destinationPath, atomically: true)
        self.canvasImage.hidden = false
        //captureSession.stopRunning()
        self.view.bringSubviewToFront(canvasImage)
        
        //store photo
        
//        if let recognizers = self.view.gestureRecognizers {
//            for recognizer in recognizers {
//                self.view.removeGestureRecognizer(recognizer as! UIGestureRecognizer)
//            }
//        }

        // after photo, go directly to preview
        preview()
        
//        var tap = UITapGestureRecognizer(target:self, action:Selector("preview"))
//        self.view.addGestureRecognizer(tap)
        
        
    }
    
    func preview() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //self.captureSession.stopRunning()
            self.canvasImage.hidden = true
        }
        self.performSegueWithIdentifier("preview", sender: self);
    }
    

    

    func setupCam() {
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Front) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCam()
        
        // Setup Navigation controller / remove uiBorderbottom to blue
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        
        // Change the border to blue
        var navHeight = self.navigationController?.navigationBar.frame.height
        var navWidth = self.navigationController?.navigationBar.frame.width
        if navWidth == nil {
            navWidth = 600
        }
        if navHeight == nil {
            navHeight = 30
        }
        
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
        navbar.titleView = logoView
        
        // Add a tap gesture to the navigation bar image to send the user to settings
        let recognizer = UITapGestureRecognizer(target: self, action: "showSettings")
        navbar.titleView!.userInteractionEnabled = true
        navbar.titleView!.addGestureRecognizer(recognizer)
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    func focusTo(value : Float) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.unlockForConfiguration()
            }
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            //device.focusMode = .Locked
            device.unlockForConfiguration()
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        stillImageOutput = AVCaptureStillImageOutput()
        let outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG ]
        stillImageOutput!.outputSettings = outputSettings
        
        // add output to session
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        var err : NSError? = nil
        if captureSession.running == false {
            captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        }
        
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        let bounds = self.canvasImage.layer.contentsRect
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.bounds = bounds
        previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        self.view.layer.addSublayer(previewLayer)
        self.view.bringSubviewToFront(countdown)
        var tap = UITapGestureRecognizer(target:self, action:Selector("startSnap"))
        self.view.addGestureRecognizer(tap)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }

    func showSettings() {
        
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as! UIViewController
            self.showViewController(controller, sender: self)
        });
        
    }

    
}
