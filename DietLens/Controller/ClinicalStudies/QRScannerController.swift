//
//  QRScannerController.swift
//  DietLens
//
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: BaseViewController {

    // @IBOutlet var messageLabel:UILabel!
    @IBOutlet weak var scanerView: UIView!

    var captureSession = AVCaptureSession()
    var scannedFlag = false

    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]

    //TODO: count testing
    var scanCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the back-facing camera for capturing videos
        var deviceDiscoverySession: AVCaptureDevice.DiscoverySession?
        if #available(iOS 10.2, *) {
            deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        }

        guard let captureDevice = deviceDiscoverySession?.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session.
            captureSession.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = scanerView.layer.bounds
        scanerView.layer.addSublayer(videoPreviewLayer!)

        // Start video capture.
//        captureSession.startRunning()

        // Move the message label and top bar to the front
        //view.bringSubview(toFront: messageLabel)
        //view.bringSubview(toFront: topbar)

        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            scanerView.addSubview(qrCodeFrameView)
            //  view.bringSubview(toFront: qrCodeFrameView)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "Scan QR code"
        //running or resume session
        captureSession.startRunning()

    }
    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Helper methods

    func launchApp(decodedURL: String) {
        if presentedViewController != nil {
            return

        }
        //test

        guard let scanresultVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScanResultViewController") as? ScanResultViewController else {
            return
        }
        self.navigationController?.pushViewController(scanresultVC, animated: true)
        //delted part
        captureSession.stopRunning()
//        present(scanresultVC, animated: true, completion: nil)
//        scannedFlag = true

//                if presentedViewController != nil {
//                    return
//                }
//
//                let alertPrompt = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
//                let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in
//
//                    if let url = URL(string: decodedURL) {
//                        if UIApplication.shared.canOpenURL(url) {
//                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                        }
//                    }
//                })
//
//                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
//
//                alertPrompt.addAction(confirmAction)
//                alertPrompt.addAction(cancelAction)
//
//                present(alertPrompt, animated: true, completion: nil)
    }

}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        scanCount += 1
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //  messageLabel.text = "No QR code is detected"
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                launchApp(decodedURL: metadataObj.stringValue!)
                //    messageLabel.text = metadataObj.stringValue
            }
        }
    }

}
