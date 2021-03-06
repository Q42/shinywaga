//
//  VideoRecordViewController.swift
//  app
//
//  Created by Jaap Mengers on 25-11-16.
//  Copyright © 2016 Jaap Mengers. All rights reserved.
//

import MobileCoreServices
import UIKit
import CoreLocation
import CoreBluetooth
import Firebase

typealias Timestamp = Double
typealias Degree = Double

class CompassRecorder: NSObject, CLLocationManagerDelegate {

  let lm = CLLocationManager()
  var recordings: [(Timestamp, Degree)] = []
  let startTime: Date

  override init() {
    startTime = Date()
    super.init()

    lm.delegate = self
    lm.startUpdatingHeading()
  }

  var onCompletedHandler: () -> Void = { }
  var hasFirstValue: () -> Void = { }

  static func startRecording(onRoundCompletedHandler: @escaping () -> Void) -> CompassRecorder {
    let recorder = CompassRecorder()

    recorder.onCompletedHandler = onRoundCompletedHandler

    return recorder
  }

  private func checkIfRoundIsFinished() -> Bool {
    let afterTwoSeconds = recordings.first { $0.0 > 2 }?.1
    let afterFourSeconds = recordings.first { $0.0 > 4 }?.1

    if let twoSec = afterTwoSeconds, let fourSec = afterFourSeconds {
      let last = recordings.reversed().first!.1
      return last > twoSec && last < fourSec
    }

    return false
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    recordings.append(NSDate().timeIntervalSince(startTime), newHeading.trueHeading)

    if(recordings.count == 1){
      hasFirstValue()
    }

    if checkIfRoundIsFinished() {
      onCompletedHandler()
      self.onCompletedHandler = {}
    }
  }
}

class VideoRecordViewController: UIViewController {

  let gestureRecognizer = UITapGestureRecognizer()

  var cameraController: UIImagePickerController!

  var isRemote: Bool { return UIDevice.current.name == "Tom's iPhone 7" }

  // Bluetooths
  var centralManager: CBCentralManager!
  var peripheral: CBPeripheral?
  var peripheralID: UUID?

  // Firebases
  var dbRef: FIRDatabaseReference!

  override func viewDidLoad() {
    super.viewDidLoad()

    if isRemote {
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(32), execute: {

        self.performSegue(withIdentifier: "remoteControl", sender: self)
      })
    }
    else {
      centralManager = CBCentralManager(delegate: self, queue: nil)
      startFirebase()
    }
  }

  @IBAction func recordTouched(_ sender: Any) {
    startCameraFromViewController(viewController: self, withDelegate: self)
  }

  var startDate: NSDate!
  var compassRecorder: CompassRecorder?

  func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> Void {
    if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
      // TODO
    }

    gestureRecognizer.numberOfTouchesRequired = 2
    gestureRecognizer.addTarget(self, action: #selector(tapped))

    let cc = UIImagePickerController()

    cc.sourceType = .camera
    cc.mediaTypes = [kUTTypeMovie as NSString as String]
    cc.allowsEditing = false
    cc.delegate = delegate
    cc.videoQuality = .typeHigh
    cc.showsCameraControls = false
    cc.view.addGestureRecognizer(gestureRecognizer)
    cc.view.frame.origin.y = cc.view.frame.height / 2

    self.cameraController = cc

    present(cc, animated: true, completion: {
      print("Initialized")
      sleep(2)
      print("Start getting compass")
      self.compassRecorder = CompassRecorder.startRecording {
        cc.stopVideoCapture()
      }

      self.compassRecorder?.hasFirstValue = {
        print("We have compass, start recording")
        let success = cc.startVideoCapture()
      }

      self.startDate = NSDate()
    })
  }

  @objc func tapped() {
    if let cc = self.cameraController {
      cc.stopVideoCapture()
    }
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let cc = self.cameraController {
      cc.dismiss(animated: false, completion: nil)

      let mediaType = info[UIImagePickerControllerMediaType] as! String

      if mediaType == kUTTypeMovie as NSString as String
      {
        let videoPath = info[UIImagePickerControllerMediaURL] as! NSURL

        UISaveVideoAtPathToSavedPhotosAlbum(videoPath.path!, nil, nil, nil)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let uploadViewController = storyboard.instantiateViewController(withIdentifier: "uploadViewController") as? UploadViewController

        if let vc = uploadViewController {
          present(vc, animated: true, completion: {
            vc.uploadVideo(videopath: videoPath)
          })
        }
      }
    }
  }
}

extension VideoRecordViewController: UIImagePickerControllerDelegate {

}

extension VideoRecordViewController: UINavigationControllerDelegate {

}
