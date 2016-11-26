//
//  VideoRecordViewController.swift
//  app
//
//  Created by Jaap Mengers on 25-11-16.
//  Copyright © 2016 Jaap Mengers. All rights reserved.
//

import MobileCoreServices
import UIKit
import AmazonS3RequestManager
import CoreLocation

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

    if checkIfRoundIsFinished() {
      onCompletedHandler()
      self.onCompletedHandler = {}
    }
  }
}

class VideoRecordViewController: UIViewController {

  let gestureRecognizer = UITapGestureRecognizer()

  var cameraController: UIImagePickerController!

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
      let success = cc.startVideoCapture()
      sleep(2)
      self.compassRecorder = CompassRecorder.startRecording {
        cc.stopVideoCapture()
      }

      self.startDate = NSDate()
      print("Start video succeeded \(success)")
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

        uploadVideo(videopath: videoPath)
      }
    }
  }

  func uploadVideo(videopath: NSURL) {
    let amazonS3Manager = AmazonS3RequestManager(bucket: "shinywagavideos",
                                                 region: .EUWest1,
                                                 accessKey: "AKIAIUYBDN7G3LBZZ2SA",
                                                 secret: "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")
    let epoch = Int(NSDate().timeIntervalSince1970)

    amazonS3Manager.upload(from: videopath as URL, to: "\(epoch).mp4").response { res in
      if let err = res.error {
        print(err.localizedDescription)
        let av = UIAlertController(title: "snor", message: "\(err.localizedDescription)", preferredStyle: .alert)
        av.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(av, animated: false)
      } else {
        let av = UIAlertController(title: "snor", message: "Gelukt", preferredStyle: .alert)
        av.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(av, animated: false)
      }
    }
  }
}

extension VideoRecordViewController: UIImagePickerControllerDelegate {

}

extension VideoRecordViewController: UINavigationControllerDelegate {

}
