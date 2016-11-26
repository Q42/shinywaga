//
//  UploadViewController.swift
//  app
//
//  Created by Jaap Mengers on 26-11-16.
//  Copyright © 2016 Jaap Mengers. All rights reserved.
//
import UIKit
import AmazonS3RequestManager
import Firebase

class UploadViewController: UIViewController {
  @IBOutlet weak var progressView: UIProgressView!

  var dbRef: FIRDatabaseReference!

  override func viewDidLoad() {
    super.viewDidLoad()
    dbRef = FIRDatabase.database().reference()
    progressView.setProgress(0, animated: false)
  }

  func uploadVideo(videopath: NSURL) {
    let amazonS3Manager = AmazonS3RequestManager(bucket: "shinywagavideos",
                                                 region: .EUWest1,
                                                 accessKey: "AKIAIUYBDN7G3LBZZ2SA",
                                                 secret: "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")
    let epoch = Int(NSDate().timeIntervalSince1970)

    let upload = amazonS3Manager.upload(from: videopath as URL, to: "\(epoch).mp4")

    upload.uploadProgress { [weak self] pr in
      self?.progressView.setProgress(Float(pr.fractionCompleted), animated: true)
    }

    upload.response { res in
      if let err = res.error {
        print(err.localizedDescription)
        let av = UIAlertController(title: "Fout", message: "\(err.localizedDescription)", preferredStyle: .alert)
        av.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(av, animated: false)
      } else {

        self.dbRef.child("commands/lastfile").setValue("https://s3-eu-west-1.amazonaws.com/shinywagavideos/\(epoch).mp4")

        let av = UIAlertController(title: "Gelukt", message: "Gelukt \(res.response?.statusCode)", preferredStyle: .alert)
        av.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(av, animated: false)
      }
    }
  }
}
