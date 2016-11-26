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

public extension Sequence {
  func categorise<U : Hashable>(_ key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
    var dict: [U:[Iterator.Element]] = [:]
    for el in self {
      let key = key(el)
      if case nil = dict[key]?.append(el) { dict[key] = [el] }
    }
    return dict
  }
}

typealias Timestamp = Double
typealias Degree = Double

class CompassRecorder: NSObject, CLLocationManagerDelegate {

  let lm = CLLocationManager()
  var recordings: [Timestamp:Degree] = [:]
  let startTime: Date

  override init(){
    startTime = Date()
    super.init()

    lm.delegate = self
    startRecording()
  }

  private func startRecording() {
    lm.startUpdatingHeading()
  }

  func stopRecording() -> [Timestamp:Degree] {
    lm.stopUpdatingHeading()
    return recordings
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    recordings[NSDate().timeIntervalSince(startTime)] = newHeading.trueHeading
  }
}

private func toByteArray<T>(_ value: T) -> [UInt8] {
  var value = value
  return withUnsafeBytes(of: &value) { Array($0) }
}

func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
  return value.withUnsafeBytes {
    $0.baseAddress!.load(as: T.self)
  }
}

struct Video {
  init(videoPath: NSURL, compassReadings: [Timestamp: Degree]) {
    self.videoPath = videoPath


//    var intervals: [Double] = Array.init(repeating: -1, count: 360)

    let res = Array(compassReadings)
      .categorise { Int($0.value) }
      .map { group in (group.key, group.value.min { $0.value < $1.value }!.key ) }
      .map { String(format: "%d:%0.2f", $0.0, $0.1) }
      .joined(separator: "\n")

    self.metadata = res
  }

  let videoPath: NSURL
  let metadata: String
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
      sleep(2)
      self.compassRecorder = CompassRecorder()
      let success = cc.startVideoCapture()
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

        let compassReadings = self.compassRecorder!.stopRecording()
        let video = Video(videoPath: videoPath, compassReadings: compassReadings)

        UISaveVideoAtPathToSavedPhotosAlbum(videoPath.path!, nil, nil, nil)

        uploadVideo(video: video)
      }
    }
  }

  func uploadVideo(video: Video) {
    let amazonS3Manager = AmazonS3RequestManager(bucket: "shinywagavideos",
                                                 region: .EUWest1,
                                                 accessKey: "AKIAIUYBDN7G3LBZZ2SA",
                                                 secret: "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")
    let epoch = Int(NSDate().timeIntervalSince1970)

    amazonS3Manager.upload(video.metadata.data(using: .utf8)!, to: "\(epoch).txt")

    amazonS3Manager.upload(from: video.videoPath as URL, to: "\(epoch).mp4").response { res in
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

      print("Upload succeeded")
    }
  }
}

extension VideoRecordViewController: UIImagePickerControllerDelegate {

}

extension VideoRecordViewController: UINavigationControllerDelegate {

}
