//
//  VideoRecordViewController+Remote.swift
//  app
//
//  Created by Tom Lokhorst on 2016-11-26.
//  Copyright © 2016 Jaap Mengers. All rights reserved.
//

import Foundation
import Firebase

extension VideoRecordViewController {

  func startFirebase() {

    dbRef = FIRDatabase.database().reference()


    // Listen for new messages in the Firebase database
    let _refHandle = self.dbRef.child("commands").observe(.childAdded, with: { snapshot in
      print(snapshot)
//      strongSelf.messages.append(snapshot)
//      strongSelf.clientTable.insertRows(at: [IndexPath(row: strongSelf.messages.count-1, section: 0)], with: .automatic)
    })
  }

}

