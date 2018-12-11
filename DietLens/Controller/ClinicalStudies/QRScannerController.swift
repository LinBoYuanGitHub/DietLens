//
//  QRScannerController.swift
//  DietLens
//
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: BaseViewController {

    @IBOutlet weak var scanerView: UIView!

    var captureSession = AVCaptureSession()
    var scannedFlag = false //make sure only perform scanTask once in process

    var videoPreviewLayer: AVCaptureVideoPreviewLayer? //the UI layer to display the camera video
    var qrCodeFrameView: UIView? //frame view for showing barcodeObject bounds

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

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.frame = scanerView.layer.bounds
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        scanerView.layer.addSublayer(videoPreviewLayer!)

        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            scanerView.addSubview(qrCodeFrameView)
            qrCodeFrameView.isHidden = true //show frameView only when scanning QR Code
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = scanerView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "Scan QR code"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Album", style: .plain, target: self, action: #selector(onAlbum))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        //running or resume session
        captureSession.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        qrCodeFrameView?.isHidden = true
        scannedFlag = false
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func onAlbum() {

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

        guard let scanresultVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScannedResultViewController") as? ScannedResultViewController else {
            return
        }
        self.navigationController?.pushViewController(scanresultVC, animated: true)
        //delted part
        captureSession.stopRunning()
    }

}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //  messageLabel.text = "No QR code is detected"
            return
        }

        // Get the metadata object.
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            return
        }
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            if metadataObj.stringValue != nil && scanerView.bounds.contains((barCodeObject?.bounds)!) && !scannedFlag {
                qrCodeFrameView?.frame = barCodeObject!.bounds
                qrCodeFrameView?.isHidden = false
                scannedFlag = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //delay for showing bounding box for user to confirm the scanned QR code
                    self.launchApp(decodedURL: metadataObj.stringValue!)
                }
            }
        }
    }

}
