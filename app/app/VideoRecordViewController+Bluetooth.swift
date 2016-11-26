//
//  VideoRecordViewController+Bluetooth.swift
//  app
//
//  Created by Jaap Mengers on 25-11-16.
//  Copyright © 2016 Jaap Mengers. All rights reserved.
//

import UIKit
import CoreBluetooth

private let serviceId = CBUUID(string: "00110011-4242-4242-4242-42424242EEFF")
//private let characteristicId = CBUU"0x4242"

extension VideoRecordViewController : CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print("[\(Date())] CentralManager did update state: \(CBManagerState(rawValue: central.state.rawValue))")

    guard central.state == .poweredOn else { return }

    centralManager.scanForPeripherals(withServices: nil, options: nil)
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print("[\(Date())] CentralManager did discover peripheral: \(peripheral)")

    if peripheral.name == "Shiny Waga Cart" {

      centralManager.stopScan()

      self.peripheral = peripheral
      peripheral.delegate = self

      centralManager.connect(peripheral, options: nil)
    }
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("[\(Date())] CentralManager did connect: \(peripheral.name)")
    peripheral.discoverServices(nil)
  }

  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    print("[\(Date())] CentralManager did fail to connect: \(peripheral.name)")
    print("\(error)")
    peripheralID = nil
  }

  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    print("[\(Date())] Centralmanager did disconnect: \(peripheral.name)")
    self.peripheral = nil
  }
}

extension VideoRecordViewController : CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    print("[\(Date())] Peripheral did discover services:")

    for service in peripheral.services ?? [] {
      print(" - \(service)")
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    print("[\(Date())] Peripheral did discover characteristics for peripheral \(peripheral.name):")

    for characteristic in service.characteristics ?? [] {

      print(" - \(characteristic)")

      let data = Data.init(bytes: [0x09])

      let type: CBCharacteristicWriteType = characteristic.properties.contains(.writeWithoutResponse)
        ? .withoutResponse
        : .withResponse


      print("WRITE \(data)")
      peripheral.writeValue(data, for: characteristic, type: type)
//      self.characteristic = characteristic
//      peripheral.setNotifyValue(true, for: characteristic)
    }
  }
//
//  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//    let bytes = characteristic.value!.array
//
//    var comment: String?
//    if let messageId = bytes[safe: 3] {
//      warnings[messageId]?.invalidate()
//      timeouts[messageId]?.invalidate()
//
//      if let c = comments[messageId] {
//        comment = "(\(c))"
//      }
//      else if messageId == 0 {
//        comment = "?in range aid?"
//      }
//    }
//    else if bytes.count == 3 {
//      comment = "?Alive response?"
//    }
//
//    if bytes.count == 10 && bytes[safe: 4] == 8 {
//      if let x = decodeBattery(Array(bytes[6...9])) {
//        comment = "\(comment ?? "") \(x)"
//      }
//    }
//
//    testRun?.log(event: "RECV", bytes: bytes, comment: comment)
//    print("<-- \(bytes) -- [\(bytes.hexString)] -- \(comment ?? "")")
//
//    writeTimer?.invalidate()
//
//    responseLabel.showText("🎉 \(bytes)")
//
//    if bytes[safe: 1] == 1 && bytes[safe: 2] == 3 {
//      tokenGenerated(bytes)
//    }
//  }
//
//  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//    print("[\(Date())] Peripheral did update notification state: \(characteristic.isNotifying)")
//  }
}
