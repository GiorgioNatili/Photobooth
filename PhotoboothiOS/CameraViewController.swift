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

class CameraViewController: BoothViewController,
UINavigationControllerDelegate, UIImagePickerControllerDelegate /*, UITextViewDelegate */ {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var canvasImage: UIImageView!
    @IBOutlet weak var countdown: UILabel!
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput : AVCaptureStillImageOutput?
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    var snapTime:Double = 4
    var captureDevice : AVCaptureDevice?
    var imageOrientation: UIImageOrientation?
    var videoConnection : AVCaptureConnection? // find video connection
    var takingPhoto = false

    func startSnap() {

        if self.takingPhoto {
            return
        }
        
        self.takingPhoto = true
        self.countdown.alpha = 0.6

        let aSelector : Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        
    }
    
    func updateTime() {
        
        self.cameraButton.hidden = true
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = currentTime - startTime
        let seconds = snapTime - elapsedTime
        
        if seconds > 0 {
            
            elapsedTime -= NSTimeInterval(seconds)
            self.countdown.hidden = false
            self.countdown.text = "\(Int(seconds+1))"
            
        } else {
            
            self.countdown.hidden = true
            timer.invalidate()
            
            guard (self.stillImageOutput != nil) else {
                
                // TODO: remove self.preview() after testing
                showMessage("Please connect to a device", okaction: { _ in
                    self.preview()}, completion: { _ in })
                return
            }
            
            // wow we are ready to save some photos
            // setup still OutPut to save
            if let stillOutput = self.stillImageOutput {
                
                // we do this on another thread so we don't hang the UI
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    for connection in stillOutput.connections {
                        // find a matching input port
                        for port in connection.inputPorts! {
                            // and matching type
                            if port.mediaType == AVMediaTypeVideo {
                                self.videoConnection = connection as? AVCaptureConnection
                                break
                            }
                        }
                        if self.videoConnection != nil {
                            break // for connection
                        }
                    }
                    
                    if self.videoConnection != nil {
                        
                        // found the video connection, let's get the image
                        let _ = stillOutput.connectionWithMediaType(AVMediaTypeVideo)
                        stillOutput.captureStillImageAsynchronouslyFromConnection(self.videoConnection) {
                            (imageSampleBuffer:CMSampleBuffer!, _) in
                            
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                            self.didTakePhoto(imageData)
                            
                        }
                    }
                }
            }
        }
    }
    
    
    func showMessage(message:String, okaction:(action:UIAlertAction) -> Void,
                                     completion:()->Void) {
        
        let alertController = UIAlertController(title: "Default Style", message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: okaction)
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: completion)
    }
    
    func didTakePhoto(imageData: NSData) {

        print("did take photo:")
        
        if let image = UIImage(data: imageData) {
        
            _ = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: imageOrientation!)
           // TODO: verify this
            self.canvasImage.image = image
            
            //gpj
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let destinationPath = (documentsPath as NSString).stringByAppendingPathComponent("photobooth.jpg")
            
            if let rawData = UIImageJPEGRepresentation(image, 1.0) {
                
                rawData.writeToFile(destinationPath, atomically: true)
            }
            
            self.canvasImage.hidden = false
            self.cameraButton.hidden = false
            self.view.bringSubviewToFront(canvasImage)
            
            // after photo, go directly to preview
            preview()
            
        }
        
        self.takingPhoto = false
        
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
                        print("Capture device found")
                        
                        beginSession()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        super.setupNav(false, enableSettings : true)
        self.setupCam()
        
        // gpj
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setRotation", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    func focusTo(value : Float) {
        if let device = captureDevice, _ = try? device.lockForConfiguration() {
            
            device.unlockForConfiguration()
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    // TODO: clean this
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
            } catch _ {
            }
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
        
        do {
            
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch let error as NSError{
            
            print("error: \(error.localizedDescription)")
        }
        
        // create camera preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let preview = previewLayer  {
            
            self.view.layer.addSublayer(preview)
        }
        
        // prepare for the countdown
        self.view.bringSubviewToFront(countdown)
        
        // add camera button
        self.view.bringSubviewToFront(cameraButton)
        let tap = UITapGestureRecognizer(target:self, action:Selector("startSnap"))
        self.view.addGestureRecognizer(tap)
        
        // set rotation
        self.setRotation()

        captureSession.startRunning()
    }

    // gpj
    func setRotation() {
        
        let device = UIDevice.currentDevice()

        if (device.orientation == UIDeviceOrientation.LandscapeLeft){
            print("landscape left")
            previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            imageOrientation = UIImageOrientation.LeftMirrored
            
        } else if (device.orientation == UIDeviceOrientation.LandscapeRight){
            print("landscape right")
            previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            imageOrientation = UIImageOrientation.LeftMirrored
            
        } else if (device.orientation == UIDeviceOrientation.Portrait){
            print("Portrait")
            previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
            imageOrientation = UIImageOrientation.LeftMirrored
            
        } else if (device.orientation == UIDeviceOrientation.PortraitUpsideDown){
            print("Portrait UD")
            previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let bounds = view.layer.bounds;
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer?.bounds = bounds;
        previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    }
    
    
    @IBAction func touchUpInsideCameraButton(sender: AnyObject) {
        self.startSnap()
    }
    
    func showSettings() {
        
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") 
            self.showViewController(controller, sender: self)
        });
        
    }

    
}
