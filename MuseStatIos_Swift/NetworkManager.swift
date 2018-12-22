//
//  NetworkManager.swift
//  MuseStatIos_Swift
//
//  Created by Momchil Tomov on 12/22/18.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import Foundation

// Singleton class for managing streaming data to the 
//
class NetworkManager: NSObject /*for @objc*/ {

    static let sharedInstance = NetworkManager()

    // queue for batch sending POST requests
    // one queue for each table (for batch insert on the backend)
    //
    let queues: [String: DispatchQueue] = ["alpha": DispatchQueue(label: "muse.alphaPendingJsons", attributes: .concurrent),
                                           "beta": DispatchQueue(label: "muse.betaPendingJsons", attributes: .concurrent),
                                           "delta": DispatchQueue(label: "muse.deltaPendingJsons", attributes: .concurrent),
                                           "theta": DispatchQueue(label: "muse.thetaPendingJsons", attributes: .concurrent),
                                           "gamma": DispatchQueue(label: "muse.gammaPendingJsons", attributes: .concurrent),
                                           "good": DispatchQueue(label: "muse.goodPendingJsons", attributes: .concurrent),
                                           "hsi": DispatchQueue(label: "muse.hsiPendingJsons", attributes: .concurrent),
                                           "accelerometer": DispatchQueue(label: "muse.accelerometerPendingJsons", attributes: .concurrent),
                                           "gyro": DispatchQueue(label: "muse.gyroPendingJsons", attributes: .concurrent),
                                           "artifact": DispatchQueue(label: "muse.artifactPendingJsons", attributes: .concurrent),
                                           "location": DispatchQueue(label: "muse.locationPendingJsons", attributes: .concurrent),
                                           "acceleration": DispatchQueue(label: "muse.accelerationPendingJsons", attributes: .concurrent)]
    var pendingJsons: [String: NSMutableArray] = ["alpha": NSMutableArray(),
                                                   "beta": NSMutableArray(),
                                                   "delta": NSMutableArray(),
                                                   "theta": NSMutableArray(),
                                                   "gamma": NSMutableArray(),
                                                   "good": NSMutableArray(),
                                                   "hsi": NSMutableArray(),
                                                   "accelerometer": NSMutableArray(),
                                                   "gyro": NSMutableArray(),
                                                   "artifact": NSMutableArray(),
                                                   "location": NSMutableArray(),
                                                   "acceleration": NSMutableArray()]
    var semaphore = DispatchSemaphore(value: 0) // make POST requests synchronous


    func setup() {

        // from https://medium.com/@ashok.nfn/run-tasks-on-background-thread-swift-5d3aec272140
        let dispatchQueue = DispatchQueue(label: "muse.backgroundDequeueRequests", qos: .background)
        dispatchQueue.async{
            self.backgroundDequeueRequests()
        }
    }


    func postRequestSync(json: Dictionary<String, Any>) {
		// see https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
		// also https://stackoverflow.com/questions/31937686/how-to-make-http-post-request-with-json-body-in-swift

        let url = URL(string: "http://flask-env.r3jmjqfi9f.us-east-2.elasticbeanstalk.com/log")!  // TODO const
        //let url = URL(string: "http://127.0.0.1:5000/log")!

        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }

    // Post request to remote server and on successful completion, empty array with requests
    // note that async is a bit of a misnomer -- it is async w.r.t. the queue, but it is actually sync w.r.t. the POST request (i.e. we wait for it to complete)
    // TODO tight coupling with backgroundDequeueRequest()...
    //
    func postRequestAsync(table: String, json: Dictionary<String, Any>) -> URLSessionDataTask {
		// see https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
		// also https://stackoverflow.com/questions/31937686/how-to-make-http-post-request-with-json-body-in-swift
        // also https://developer.apple.com/documentation/foundation/urlsession/1407613-datatask

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


    func enqueueRequest(table: String, json: Dictionary<String, Any>) {
        // from http://basememara.com/creating-thread-safe-arrays-in-swift/
        //  and https://stackoverflow.com/questions/41518492/append-to-array-in-string-any-dictionary-structure/41518630
        //  and https://medium.com/capital-one-tech/reference-and-value-types-in-swift-de792db330b2
        //
        let queue = self.queues[table] as? DispatchQueue ?? DispatchQueue(label: "muse." + table + "PendingJsons", attributes: .concurrent)
        queue.async(flags: .barrier) {
            //print("\(table) -> insert \(json)")
            self.pendingJsons[table]!.add(json)
        }
    }
}
