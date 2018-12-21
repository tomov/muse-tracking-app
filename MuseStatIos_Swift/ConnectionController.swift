//
//  ConnectionController.swift
//  MuseStatIos_Swift
//
//  Created by Ivan Rzhanoi on 24/11/2016.
//  Copyright © 2016 Ivan Rzhanoi. All rights reserved.
//

import UIKit

class ConnectionController: UIViewController, IXNMuseConnectionListener, IXNMuseDataListener, IXNMuseListener, IXNLogListener, UITableViewDelegate, UITableViewDataSource {
    /**
     * Handler method for Muse data packets
     *
     * \warning It is important that you do not perform any computation
     * intensive tasks in this callback. This would result in significant
     * delays in all the listener callbacks from being called. You should
     * delegate any intensive tasks to another thread or schedule it to run
     * with a delay through handler/scheduler for the platform.
     *
     * However, you can register/unregister listeners in this callback.
     * All previously registered listeners would still receive callbacks
     * for this current event. On subsequent events, the newly registered
     * listeners will be called. For example, if you had 2 listeners 'A' and 'B'
     * for this event. If, on the callback for listener A, listener A unregisters
     * all listeners and registers a new listener 'C' and then in the callback for
     * listener 'B', you unregister all listeners again and register a new listener
     * 'D'. Then on the subsequent event callback, only listener D's callback
     * will be invoked.
     *
     * \param packet The data packet
     * \param muse   The
     * \if ANDROID_ONLY
     * Muse
     * \elseif IOS_ONLY
     * IXNMuse
     * \endif
     * that sent the data packet.
     */
    
    var muse = IXNMuse()
    var manager = IXNMuseManagerIos()
    var logLines = [Any]()
    var isLastBlink = false
    
    // Declaring an object that will call the functions in SimpleController()
    var connectionController = SimpleController()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var logView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView.delegate = SimpleController()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        
        //if self.manager != nil {
        
        self.manager = IXNMuseManagerIos.sharedManager()
        
        //}
    }
    
        override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
            //if (self == super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)) {
    
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
            self.manager = IXNMuseManagerIos.sharedManager()
            self.manager.museListener = self
            self.tableView = UITableView()
            self.logView = UITextView()
            self.logLines = [Any]()
            self.logView.text = ""
            IXNLogManager.instance()?.setLogListener(self)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            //var dateStr = dateFormatter.string(fromDate: Date()).appending(".log")
            let dateStr = dateFormatter.string(from: Date()).appending(".log")
            print("\(dateStr)")
        }
    
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    
    
    
    
    
    
    func log(fmt: String) {
        
        //log(fmt: fmt)
        //self.log(fmt: fmt)
        
        
        
//        var args: CVaListPointer
//        
//        va_start(args, fmt)
//        
//        var line = String(format: fmt, arguments: [args])
//        
//        va_end(args)
//        
//        print("\(line)")
//        self.logLines.insert(line, at: 0)
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.logView.text = (self.logLines as NSArray).componentsJoined(by: "\n")
        })
        //print("\(line)")
    }
    
    func receiveLog(_ log: IXNLogPacket) {
        connectionController.receiveLog(log)
        //print("\(log.tag): \(log.timestamp) raw: \(log.raw) \(log.message)")
    }
    
    
    // TODO: Investigate the line below. Something wrong with tableView or it's update. It requires the manual table refresh.
    func museListChanged() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = connectionController.tableView(tableView, numberOfRowsInSection: section)
        return rows
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = connectionController.tableView(tableView, cellForRowAt: indexPath)
        
        
        // The code below works fine. It is simplier to use only one line above, but in case someone would like to completely port it to swift, I kept it.
        
//        let simpleTableIdentifier: String = "nil"
//        let muses = self.manager.getMuses()
//        
//        // Checking for the value. If cell doesn't receive any data (finding nil, while unwraping), we give empty.
//        if let cell = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier) {
//            
//            if indexPath.row < muses.count {
//                let muse: IXNMuse = self.manager.getMuses()[indexPath.row] as! IXNMuse
//                cell.textLabel!.text = muse.getName()
//                if !muse.isLowEnergy() {
//                    cell.textLabel!.text = cell.textLabel!.text?.appending(muse.getMacAddress())
//                }
//            }
//            return cell
//            
//        } else {
//            let cell = UITableViewCell(style: .default, reuseIdentifier: simpleTableIdentifier)
//
//            if indexPath.row < muses.count {
//                let muse: IXNMuse = self.manager.getMuses()[indexPath.row] as! IXNMuse
//                
//                // TODO: Check the code below in the future
//                cell.textLabel?.text = muse.getName()
//                if !muse.isLowEnergy() {
//                    cell.textLabel?.text = cell.textLabel?.text?.appending(muse.getMacAddress())
//                }
//            }
//            return cell
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //connectionController.tableView(tableView, didSelectRowAt: indexPath)
        print("If this is not called, then it does not do jackshit!")
        var muses = self.manager.getMuses()
        
        if indexPath.row < muses.count {
            print("Everything is fine!")
            // TODO: Add error safety.
            let muse: IXNMuse = muses[indexPath.row] as! IXNMuse
            print("Everything is fine!")
            print("Everything is fine!")
            //var synchronius = DispatchQueue
            //DispatchQueue.main.sync {
            
            print("Everything is fine!")
            
            
            // TODO: Add the proper checking, so it wouldn't be initialized each time
            //if self.muse.getConfiguration() == nil {
            
            
//            if self.muse == nil {
//                print("Everything is fine!")
//                self.muse = muse
//                print("Everything is  STILL fine!")
//
//            } else if self.muse != muse {
//                // TODO: Add the proper support for disconnecting
//                //self.muse.disconnect(false)
//                self.muse = muse
//            }
            //}
            
            // T
            self.muse = muse
            
            print("It should call!\n")
            self.connect()
            print("======Choose device to connect: \(self.muse.getName()) \(self.muse.getMacAddress())======\n")
        }
        //self.connect()
    }
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {       // TODO: Find and error over here!
        var state: String
        switch packet.currentConnectionState {
        case IXNConnectionState.disconnected:
            state = "disconnected"
        case IXNConnectionState.connected:
            state = "connected"
        case IXNConnectionState.connecting:
            state = "connecting"
        case IXNConnectionState.needsUpdate:
            state = "needs update"
        case IXNConnectionState.unknown:
            state = "unknown"
        }
        print("connect: \(state)")
    }
    
    
    func connect() {
        print("It does call indeed!\n")
        //self.muse.register(self)
        self.muse.register(self)
        self.muse.register(self, type: IXNMuseDataPacketType.artifacts)
        self.muse.register(self, type: IXNMuseDataPacketType.alphaAbsolute)
        self.muse.register(self, type: IXNMuseDataPacketType.betaAbsolute)
        self.muse.register(self, type: IXNMuseDataPacketType.deltaAbsolute)
        self.muse.register(self, type: IXNMuseDataPacketType.thetaAbsolute)
        self.muse.register(self, type: IXNMuseDataPacketType.gammaAbsolute)
        self.muse.register(self, type: IXNMuseDataPacketType.isGood)
        self.muse.register(self, type: IXNMuseDataPacketType.hsiPrecision)
        self.muse.register(self, type: IXNMuseDataPacketType.accelerometer)
        self.muse.register(self, type: IXNMuseDataPacketType.gyro)
        
        
        //self.muse.register(self, type: IXNMuseDataPacketType.eeg) <-- RAW eeg data DO NOT USE -- too much
        
        self.muse.runAsynchronously()
    }

    func testPostRequest() {
        let url = URL(string: "http://flask-env.r3jmjqfi9f.us-east-2.elasticbeanstalk.com/log")!
        //let url = URL(string: "http://127.0.0.1:5000/log")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
 
		// https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method

        //let postString = "{\"key1\":\"shit\", \"key2\":\"fuck\"}"
        // request.httpBody = postString.data(using: .utf8)

		// https://stackoverflow.com/questions/31937686/how-to-make-http-post-request-with-json-body-in-swift
		//let json: [String: Any] = ["title": "ABC",
	    //							   "dict": ["1":"First", "2":"Second"]]	
        let json: [String: Any] = ["table": "alpha",
                                   "subject_id": 34,
                                   "timestamp": 234234,
                                   "eeg1": 123,
                                   "eeg2": 234,
                                   "eeg3": 345,
                                   "eeg4": 456,
                                   "aux1": 1000,
                                   "aux2": 2000]
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

    func postRequest(json: Dictionary<String, Any>) {
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

    // Post a EEG request, with one value for each channel, e.g. alpha band or isGood values
    //
    func postRequestEeg(packet: IXNMuseDataPacket?, table: String?, subject_id: Int?) {

        let json: [String: Any] = ["table": table,
                                   "subject_id": subject_id,
                                   "timestamp": (packet?.timestamp() ?? 0) / 1000000,
                                   "eeg1": packet?.getEegChannelValue(IXNEeg.EEG1),
                                   "eeg2": packet?.getEegChannelValue(IXNEeg.EEG2),
                                   "eeg3": packet?.getEegChannelValue(IXNEeg.EEG3),
                                   "eeg4": packet?.getEegChannelValue(IXNEeg.EEG4),
                                   "aux1": packet?.getEegChannelValue(IXNEeg.AUXLEFT),
                                   "aux2": packet?.getEegChannelValue(IXNEeg.AUXRIGHT)]
        postRequest(json: json)
    }

    func postRequestAccelerometer(packet: IXNMuseDataPacket?, table: String?, subject_id: Int?) {
        let json: [String: Any] = ["table": table,
                                   "subject_id": subject_id,
                                   "timestamp": (packet?.timestamp() ?? 0) / 1000000,
                                   "x": packet?.getAccelerometerValue(IXNAccelerometer.X),
                                   "y": packet?.getAccelerometerValue(IXNAccelerometer.Y),
                                   "z": packet?.getAccelerometerValue(IXNAccelerometer.Z),
                                   "fb": packet?.getAccelerometerValue(IXNAccelerometer.forwardBackward),
                                   "ud": packet?.getAccelerometerValue(IXNAccelerometer.upDown),
                                   "lr": packet?.getAccelerometerValue(IXNAccelerometer.leftRight)]
        postRequest(json: json)
    }

    func postRequestGyro(packet: IXNMuseDataPacket?, table: String?, subject_id: Int?) {
        let json: [String: Any] = ["table": table,
                                   "subject_id": subject_id,
                                   "timestamp": (packet?.timestamp() ?? 0) / 1000000,
                                   "x": packet?.getGyroValue(IXNGyro.X),
                                   "y": packet?.getGyroValue(IXNGyro.Y),
                                   "z": packet?.getGyroValue(IXNGyro.Z),
                                   "fb": packet?.getGyroValue(IXNGyro.forwardBackward),
                                   "ud": packet?.getGyroValue(IXNGyro.upDown),
                                   "lr": packet?.getGyroValue(IXNGyro.leftRight)]
        postRequest(json: json)
    }

    func postRequestArtifact(packet: IXNMuseArtifactPacket?, table: String?, subject_id: Int?) {
        let json: [String: Any] = ["table": table,
                                   "subject_id": subject_id,
                                   //"timestamp": packet?.timestamp / 1000000, <-- wtf docs are lying; no such thing: http://ios.choosemuse.com/interface_i_x_n_muse_artifact_packet.html
                                   "timestamp": NSDate().timeIntervalSince1970,
                                   "headband": packet?.headbandOn,
                                   "blink": packet?.blink,
                                   "jaw": packet?.jawClench]
        postRequest(json: json)
    }

    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {

        if packet?.packetType() == IXNMuseDataPacketType.alphaAbsolute {
            postRequestEeg(packet: packet, table: "alpha", subject_id: -1)

        } else if packet?.packetType() == IXNMuseDataPacketType.betaAbsolute {
            postRequestEeg(packet: packet, table: "beta", subject_id: -1)

        } else if packet?.packetType() == IXNMuseDataPacketType.deltaAbsolute {
            postRequestEeg(packet: packet, table: "delta", subject_id: -1)

        } else if packet?.packetType() == IXNMuseDataPacketType.thetaAbsolute {
            postRequestEeg(packet: packet, table: "theta", subject_id: -1)

        } else if packet?.packetType() == IXNMuseDataPacketType.gammaAbsolute {
            postRequestEeg(packet: packet, table: "gamma", subject_id: -1)

        } else if packet?.packetType() == IXNMuseDataPacketType.isGood {
            postRequestEeg(packet: packet, table: "good", subject_id: -1)

        } else if packet?.packetType() == IXNMuseDataPacketType.hsiPrecision {
            postRequestEeg(packet: packet, table: "hsi", subject_id: -1)

        } else if packet?.packetType() == IXNMuseDataPacketType.accelerometer {
            postRequestAccelerometer(packet: packet, table: "accelerometer", subject_id: -1)

        } else if packet?.packetType() == IXNMuseDataPacketType.gyro {
            postRequestGyro(packet: packet, table: "gyro", subject_id: -1)
        }

       // if packet?.packetType() == IXNMuseDataPacketType.alphaAbsolute || packet?.packetType() == IXNMuseDataPacketType.eeg {
       //     
       //     if let info = packet?.values() {
       //         //print("Alpha: \(info[0]) Beta: \(IXNEeg.EEG2.rawValue) Gamma: \(IXNEeg.EEG3.rawValue) Theta: \(IXNEeg.EEG4.rawValue)")
       //         print("Alpha: \(info[0]) \(info[1]) \(info[2]) \(info[3]) \(info[4]) \(info[5])")
       //     }
       //     
       //     //  Lines below are not exactly correct
       //     //print("Alpha: \(packet?.values()[0]) Beta: \(IXNEeg.EEG2.rawValue) Gamma: \(IXNEeg.EEG3.rawValue) Theta: \(IXNEeg.EEG4.rawValue)")
       //     //print("%5.2f %5.2f %5.2f %5.2f", packet?.values() ?? 0)

       //     //self.postRequest()
       // }
       // 
       // // TODO: Add info for other brainwaves
       // if packet?.packetType() == IXNMuseDataPacketType.betaAbsolute || packet?.packetType() == IXNMuseDataPacketType.eeg {
       //     
       //     if let info = packet?.values() {
       //         //print("Alpha: \(info[0]) Beta: \(IXNEeg.EEG2.rawValue) Gamma: \(IXNEeg.EEG3.rawValue) Theta: \(IXNEeg.EEG4.rawValue)")
       //         print("Beta: \(info[0]) \(info[1]) \(info[2]) \(info[3]) \(info[4]) \(info[5])")
       //     }
       // }
    }
    
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        //if packet.blink && packet.blink != self.isLastBlink {
        //    self.log(fmt: "blink detected")
        //}
        //self.isLastBlink = packet.blink

        postRequestArtifact(packet: packet, table: "artifact", subject_id: -1)
    }
    
    
//    TODO: Maybe I will delete this function, because it is stupid to just disconnect.
//    func applicationWillResignActive() {
//        print("disconnecting before going into background")
//        //self.muse.disconnect(true)
//    }
    
    
    @IBAction func disconnect(_ sender: Any) {
        
        // TODO: Make a proper disconnect. 
        
//        if self.muse.getConnectionState() == IXNConnectionState.connected {

//        if self.muse != NSObject{
//            self.muse.disconnect(true)
//        }
        
        
        //self.muse.disconnect(true)
    }
    
    @IBAction func scan(_ sender: AnyObject) {
        //self.testPostRequest()

        //SimpleController().scan(AnyObject)
        self.manager.startListening()
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    @IBAction func stopScan(_ sender: AnyObject) {
        self.manager.stopListening()
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
