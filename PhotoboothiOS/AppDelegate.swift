import UIKit 
import PhotoboothiOS
import Accounts

import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var username: String?
    var swifter: Swifter!
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {

        Swifter.handleOpenURL(url)
        return true
    }

    // initializing Fabric after app loads works better for me
    func applicationDidFinishLaunching(application: UIApplication) {
        Fabric.with([Twitter()]).debug = true
    }

}

