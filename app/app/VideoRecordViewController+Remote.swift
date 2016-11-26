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
    self.dbRef.child("commands/color").observe(.value, with: { snapshot in
      let str = snapshot.value as? String

      if str == "red" {
        self.view.backgroundColor = .red
      }
      else if str == "green" {
        self.view.backgroundColor = .green
      }
      else {
        self.view.backgroundColor = .white
      }

//      strongSelf.messages.append(snapshot)
//      strongSelf.clientTable.insertRows(at: [IndexPath(row: strongSelf.messages.count-1, section: 0)], with: .automatic)
    })
  }

}

