//
//  BarcodeScannerProcessor.swift
//  DietLens
//
//  Created by louis on 4/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import AVFoundation

protocol BarcodeScannerDelegate: class {
    func onDetect(barcode: String)
}

class BarcodeScannerProcessor: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    weak var delegate: BarcodeScannerDelegate!

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // Get the first object from the metadataObjects array.
        guard let barcodeData = metadataObjects.first else {
            return
        }

        guard let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject else {
            return
        }

        guard var barcode = barcodeReadable.stringValue else {
            return
        }

        // UPC-A is an EAN-13 barcode with a zero prefix.
        // See: https://stackoverflow.com/questions/22767584/ios7-barcode-scanner-api-adds-a-zero-to-upca-barcode-format
        if barcodeData.type == .ean13 && barcode.hasPrefix("0") {
            barcode = String(barcode.dropFirst())
        }

        barcode = barcode.trimmingCharacters(in: .whitespaces)

        delegate.onDetect(barcode: barcode)
    }
}
