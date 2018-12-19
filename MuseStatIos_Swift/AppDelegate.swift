//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //self.simpleController = SimpleController(nibName: "SimpleController", bundle: nil)
        //self.window!.rootViewController! = simpleController
        self.connectionController = ConnectionController(nibName: "ConnectionController", bundle: nil)
    }
    /*
     * Simple example of getting data from the "*.muse" file
     */
    
    func playMuseFile() {
        print("start play muse")
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("testfile.muse").absoluteString
        let fileReader: IXNMuseFileReader = IXNMuseFileFactory.museFileReader(withPathString: filePath)
        
        while fileReader.gotoNextMessage() != nil {
            let type = fileReader.getMessageType()
            let id_number = fileReader.getMessageId()
            let timestamp: Int64 = fileReader.getMessageTimestamp()
            print("type: \(type), id: \(id_number), timestamp: \(timestamp)")
            switch type {
            case IXNMessageType.eeg, IXNMessageType.quantization, IXNMessageType.accelerometer, IXNMessageType.battery:
                let packet = fileReader.getDataPacket()?.packetType()
                print("data packet = \(packet)")
                
            case IXNMessageType.version:
                let version = fileReader.getVersion()
                print("version = \(version?.getFirmwareVersion)")
                
            case IXNMessageType.configuration:
                let config = fileReader.getConfiguration()
                print("configuration = \(config?.getBluetoothMac)")
                
            case IXNMessageType.annotation:
                let annotation = fileReader.getAnnotation()
                print("annotation = \(annotation.data)")
                
            default:
                break
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        //self.simpleController.applicationWillResignActive()
        //self.connectionController.applicationWillResignActive()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //private(set) var simpleController: SimpleController!
    private(set) var connectionController: ConnectionController!
}
//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//
