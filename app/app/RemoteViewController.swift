//
//  RemoteViewController.swift
//  app
//
//  Created by Tom Lokhorst on 2016-11-26.
//  Copyright © 2016 Jaap Mengers. All rights reserved.
//

import UIKit
import Firebase

class RemoteViewController : UIViewController {

  var dbRef: FIRDatabaseReference!

  override func viewDidLoad() {
    super.viewDidLoad()

    dbRef = FIRDatabase.database().reference()
  }

  @IBAction func setRed(_ sender: Any) {
    self.dbRef.child("commands/color").setValue("red")
  }

  @IBAction func setGreen(_ sender: Any) {
    self.dbRef.child("commands/color").setValue("green")
  }

  @IBAction func setWhite(_ sender: Any) {
    self.dbRef.child("commands/color").setValue("white")
  }
}
