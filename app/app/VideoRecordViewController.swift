//
//  VideoRecordViewController.swift
//  app
//
//  Created by Jaap Mengers on 25-11-16.
//  Copyright © 2016 Jaap Mengers. All rights reserved.
//

import MobileCoreServices
import UIKit

class VideoRecordViewController: UIViewController {

  let gestureRecognizer = UITapGestureRecognizer()

  var cameraController: UIImagePickerController?

  @IBAction func recordTouched(_ sender: Any) {
    startCameraFromViewController(viewController: self, withDelegate: self)
  }

  func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Void {
    if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
      // TODO
    }

    gestureRecognizer.numberOfTouchesRequired = 2
    gestureRecognizer.addTarget(self, action: #selector(tapped))

    self.cameraController = UIImagePickerController()
    if let cc = self.cameraController {
      cc.sourceType = .camera
      cc.mediaTypes = [kUTTypeMovie as NSString as String]
      cc.allowsEditing = false
      cc.delegate = delegate
      cc.showsCameraControls = false
      cc.cameraOverlayView = UIView(frame: self.view.frame)
      cc.view.addGestureRecognizer(gestureRecognizer)

      present(cc, animated: true, completion: {
        let success = cc.startVideoCapture()
        print("Start video succeeded \(success)")
      })
    }
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
      }
    }
  }
}

extension VideoRecordViewController: UIImagePickerControllerDelegate {

}

extension VideoRecordViewController: UINavigationControllerDelegate {

}
