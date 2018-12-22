//
//  LocationDelegate.swift
//
//  Created by Momchil Tomov on 12/22/18.
//  Copyright © 2016 Princeton. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

class LocationDelegate: NSObject /*for @objc*/, CLLocationManagerDelegate {
    
    enum Mode: String {
        case OFF
        case UPDATING // startUpdatingLocation
        //case DEFERRED // allowDeferredBlaBla
        case MONITORING // startMonitoringSignificantChanges i.e. background mode
    }
    
    private var mode = Mode.OFF
    dynamic var modeString = ""
    
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()

    dynamic var location = CLLocation()
    
    private var geo = CLGeocoder()
    dynamic var address = ""
    
    static let sharedInstance = LocationDelegate()

    // TODO dedupe with ConnectionController.swift
    //
    let queues: [String: DispatchQueue] = ["location": DispatchQueue(label: "muse.locationPendingJsons", attributes: .concurrent),
                                           "acceleration": DispatchQueue(label: "muse.accelerationPendingJsons", attributes: .concurrent)]
    var pendingJsons: [String: NSMutableArray] = ["location": NSMutableArray(),
                                                  "acceleration": NSMutableArray()]
    var semaphore = DispatchSemaphore(value: 0) // make POST requests synchronous
    
    func setup () {
        locationManager.delegate = self

        // request permission to use locations
        //
        locationManager.requestWhenInUseAuthorization() // for foreground
        locationManager.requestAlwaysAuthorization() // for background

        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        mode = Mode.OFF

        motionManager.deviceMotionUpdateInterval = 0.1 // TODO const
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] (data, error) in
            if (error != nil) {
                print("motion error: \(error)")
            }

            if (data != nil) {
                self!.postRequestAcceleration(acceleration: data!.userAcceleration, table: "acceleration", subject_id: -1) // TODO subj id
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            self.postRequestLocation(location: location, table: "location", subject_id: -1)
        }
    }
   
    /*
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.error("Location Manager failed " + String(describing: error))
    }
    

    // MARK: Some wrappers for our singleton
    
    func request() {
        // dosn't seem to work if startUpdatingLocation() or monitoring
        //
        locationManager.requestLocation()
    }
    
    func computeAddress() {
        geo.reverseGeocodeLocation(location) { (myPlacements, error) -> Void in
            if error != nil {
                self.address = "ERROR \(error)"
                print("\(error)")
            }
            
            if let myPlacemet = myPlacements?.first
            {
                self.address = "\(myPlacemet.locality!) \(myPlacemet.country!) \(myPlacemet.postalCode!) \(myPlacemet.addressDictionary!)"
                print(self.address)
            }
        }
    }
    
    func startUpdating() {
        if mode == Mode.MONITORING {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
        // foreground only -- receive updates every X meters
        //
        locationManager.distanceFilter = 20 // meters
        locationManager.startUpdatingLocation()
        mode = Mode.UPDATING
        modeString = mode.rawValue
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        mode = Mode.OFF
        modeString = mode.rawValue
    }
    
    func startMonitoring() {
        if mode == Mode.UPDATING {
            locationManager.stopUpdatingLocation()
        }
        // background
        //
        locationManager.startMonitoringSignificantLocationChanges()
        mode = Mode.MONITORING
        modeString = mode.rawValue
    }
    
    func stopMonitoring() {
        locationManager.stopMonitoringSignificantLocationChanges()
        mode = Mode.OFF
        modeString = mode.rawValue
    }
    */


    // TODO dedupe with ConnectionController 
    //
    func postRequestAsync(table: String, json: Dictionary<String, Any>) -> URLSessionDataTask {
        let url = URL(string: "http://flask-env.r3jmjqfi9f.us-east-2.elasticbeanstalk.com/log")!  // TODO const
        //let url = URL(string: "http://127.0.0.1:5000/log")!

        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        var task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            } else {
                // no error -> safe to empty array 
                // TODO this could create a deadly spiral, if server errors out b/c request is too big -> request is bigger next time
                self.queues[table]!.sync {
                    self.pendingJsons[table]!.removeAllObjects()
                }
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            self.semaphore.signal()

        }
        return task
    }

    // TODO dedupe with ConnectionController
    //
    func backgroundDequeueRequests() {
        while true {
            for (table, queue) in self.queues {
                NSLog("background thread: queue = \(table)")
                var task = URLSessionDataTask()
                queue.sync {
                    let count = self.pendingJsons[table]!.count
                    NSLog("          total # of requests: %d, address of array: %p", count, pendingJsons) // make sure pointer is the same (yes for NSMutableArray, NO for Array...)
                    let json: [String: Any] = ["table": table,
                                               "subject_id": 1,   // TODO const
                                               "rows": self.pendingJsons[table]!]
                    task = postRequestAsync(table: table, json: json) // TODO do it async
                }
                // Execute task out here so as not to block Muse request from queueing up
                //
                self.semaphore = DispatchSemaphore(value: 0) // wait for the request to complete
                task.resume()
                print("       ...waiting on semaphore")
                _ = self.semaphore.wait(timeout: .distantFuture)  
                usleep(100000) // 0.1 seconds
            }
        }
    }


    // TODO dedupe with ConnectionController 
    //
    func enqueueRequest(table: String, json: Dictionary<String, Any>) {

        let queue = self.queues[table] as? DispatchQueue ?? DispatchQueue(label: "muse." + table + "PendingJsons", attributes: .concurrent)
        queue.async(flags: .barrier) {
            //print("\(table) -> insert \(json)")
            self.pendingJsons[table]!.add(json)
        }
    }

    func postRequestLocation(location: CLLocation?, table: String, subject_id: Int?) {
        let json: [String: Any] = ["table": table,
                                   "subject_id": subject_id,
                                   "timestamp": location!.timestamp,
                                   "latitude": location!.coordinate.latitude,
                                   "longitude": location!.coordinate.longitude,
                                   "altitude": location!.altitude]
        enqueueRequest(table:table, json: json)
    }

    func postRequestAcceleration(acceleration: CMAcceleration, table: String, subject_id: Int?) {
        let json: [String: Any] = ["table": table,
                                   "subject_id": subject_id,
                                   "x": acceleration.x,
                                   "y": acceleration.y,
                                   "z": acceleration.z]
        enqueueRequest(table:table, json: json)
    }

    
   /* 
    func postToRESTAPI(dataDict: NSDictionary) {
        //let endpoint: String = "http://localhost:5000/add_data" // for local testing
        let endpoint: String = "https://blooming-wave-72684.herokuapp.com/add_data" // for prod
        guard let url = NSURL(string: endpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.HTTPMethod = "POST"
        
        let config = URLSessionConfiguration.defaultSessionConfiguration()
        let session = URLSession(configuration: config)
        
        do {
            let dataJson = try JSONSerialization.dataWithJSONObject(dataDict, options: [])
            urlRequest.HTTPBody = dataJson
        } catch {
            print ("ERROR: cannot create JSON")
        }
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
            print("GOT RESPONSE!!!")
            print("data = \(data)")
            print("response = \(response)")
            print("error = \(error)")
        })
        task.resume()
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // list of latest locations
        //
        print(locations)
        location = locations[0]
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        // Push location to REST API
        //
        dispatch_async(dispatch_get_global_queue(priority, 0)) { // TODO isn't this a bg thread already?
            print("dispatch bitch")
            self.postToRESTAPI(["location": "\(self.location)"])
        }


        // Try to push geo info to REST API too
        //
        geo.reverseGeocodeLocation(location) { (myPlacements, error) -> Void in
            if error != nil {
                print("error posting geo: \(error)")
            }
            if let myPlacemet = myPlacements?.first
            {
                self.postToRESTAPI(["location": "\(myPlacemet.addressDictionary!)"])
            }
        }
    }
    */
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("did fail with error: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        print("did finish deferred updates with error: \(error)")
    }
    
    //
    // TODO make it ask again if location services was disabled

}
