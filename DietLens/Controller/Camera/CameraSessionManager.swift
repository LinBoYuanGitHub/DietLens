//
//  CameraSessionManager.swift
//  DietLens
//
//  Created by louis on 1/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: class {
    func onConfigureSession(withResult result: CameraSessionManager.SessionSetupResult)
    func onSwitchTo(captureMode: CameraSessionManager.CameraCaptureMode)
    func onCameraInput(isAvailable: Bool)
    func onWillCapturePhoto()
    func onDidFinishCapturePhoto(image: UIImage)
    func onDetect(barcode: String)
}

class CameraSessionManager {

    enum CameraCaptureMode {
        case photo
        case barcode
    }

    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }

    var previewView: PreviewView!
    weak var viewControllerDelegate: CameraViewControllerDelegate!

    // Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let session = AVCaptureSession()
    private var photoProcessor = PhotoCaptureProcessor()
    private let barcodeProcessor = BarcodeScannerProcessor()

    private var captureMode: CameraCaptureMode = .photo
    private var isSessionRunning = false
    private var setupResult: SessionSetupResult = .success
    private var videoInput: AVCaptureDeviceInput!

    private var keyValueObservations: [NSKeyValueObservation] = []

    private var photoOutput = AVCapturePhotoOutput()

    private var metadataOutput = AVCaptureMetadataOutput()

    func setup() {
        previewView.session = session
        authorizeCamera()
        configureProcessors()
        sessionQueue.async { [weak self] in
            guard let wSelf = self else { return }
            wSelf.set(captureMode: .photo)
            wSelf.configureSession()
        }
    }

    func set(captureMode: CameraCaptureMode) {
        var output: AVCaptureOutput
        switch captureMode {
        case .photo:
            output = photoOutput
        case .barcode:
            output = metadataOutput
        }

        session.beginConfiguration()
        session.removeOutput(photoOutput)
        session.removeOutput(metadataOutput)
        if session.canAddOutput(output) {
            session.addOutput(output)
            configureOutputs()
        }
        session.commitConfiguration()
        self.captureMode = captureMode
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.viewControllerDelegate.onSwitchTo(captureMode: captureMode)
        }
    }

    private func authorizeCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                guard let wSelf = self else { return }

                if !granted {
                    wSelf.setupResult = .notAuthorized
                }
                wSelf.sessionQueue.resume()
            })

        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
            viewControllerDelegate.onCameraInput(isAvailable: false)
        }
    }

    private func configureOutputs() {
        photoOutput.isHighResolutionCaptureEnabled = true
        metadataOutput.setMetadataObjectsDelegate(barcodeProcessor, queue: sessionQueue)

        // Set barcode type for which to scan
        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
    }

    // Call this on sessionQueue
    private func configureSession() {
        guard setupResult == .success else {
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        guard configureVideoInput() else {
            print("Could not create video device input")
            setupResult = .configurationFailed
            session.commitConfiguration()
            viewControllerDelegate.onCameraInput(isAvailable: false)
            return
        }

        session.commitConfiguration()
    }

    private func configureProcessors() {
        photoProcessor.delegate = self
        barcodeProcessor.delegate = self
    }

    private func configureVideoInput() -> Bool {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let videoInput = try? AVCaptureDeviceInput(device: device) else {
                return false
        }
        // Set autofocus
        if device.isFocusModeSupported(.continuousAutoFocus),
            (try? device.lockForConfiguration()) != nil {
                device.focusMode = .continuousAutoFocus
            device.unlockForConfiguration()
        }

        guard session.canAddInput(videoInput) else {
            return false
        }

        session.addInput(videoInput)
        self.videoInput = videoInput
        return true
    }

    func pinch(pinch: UIPinchGestureRecognizer) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let videoInput = try? AVCaptureDeviceInput(device: device) else {
                return
        }
        var vZoomFactor = pinch.scale
        var error: NSError!
        let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
        let pinchOutVelocityDividerFactor: CGFloat = 35.0// bigger -> slower
        let pinchInVelocityDividerFactor: CGFloat = 25.0
        do {
            try device.lockForConfiguration()
            defer {device.unlockForConfiguration()}
            var desiredZoomFactor: CGFloat = 1.0
            //set different velocity for pinch-in & pinch-out
            if pinch.velocity > 0 {
                desiredZoomFactor = device.videoZoomFactor + atan2(pinch.velocity, pinchOutVelocityDividerFactor)
            } else {
                desiredZoomFactor = device.videoZoomFactor + atan2(pinch.velocity, pinchInVelocityDividerFactor)
            }
            //pinch velocity
            device.videoZoomFactor = max(1.0, min(desiredZoomFactor, maxZoomFactor))
        } catch error as NSError {
            NSLog("Unable to set videoZoom: %@", error.localizedDescription)
        } catch _ {

        }
    }
}

// MARK: To support view delegate
extension CameraSessionManager {
    func onViewWillAppear() {
        sessionQueue.async { [weak self] in
            guard let wSelf = self else {
                return
            }

            if wSelf.setupResult == .success {
                // Only setup observers and start the session running if setup succeeded.
                wSelf.addObservers()
                wSelf.session.startRunning()
                wSelf.isSessionRunning = wSelf.session.isRunning
            }
        }
    }

    func onViewWillDisappear() {
        sessionQueue.async { [weak self] in
            guard let wSelf = self else {
                return
            }
            if wSelf.setupResult == .success {
                wSelf.session.stopRunning()
                wSelf.isSessionRunning = wSelf.session.isRunning
                wSelf.removeObservers()
            }
        }
    }

    // MARK: KVO and Notifications

    private func addObservers() {

        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }

            DispatchQueue.main.async { [weak self] in
                guard let wSelf = self else {
                    return
                }

                if isSessionRunning && wSelf.captureMode == .photo {
                    DispatchQueue.main.async {
                        if wSelf.viewControllerDelegate != nil {
                            wSelf.viewControllerDelegate.onSwitchTo(captureMode: .photo)
                        }

                    }
                }
                if isSessionRunning && wSelf.captureMode == .barcode {
                    DispatchQueue.main.async {
                        if wSelf.viewControllerDelegate != nil {
                            wSelf.viewControllerDelegate.onSwitchTo(captureMode: .barcode)
                        }
                    }
                }
            }
        }
        keyValueObservations.append(keyValueObservation)

        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded, object: session)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)

        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }

    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios we want to enable the user to resume the session running.
         For example, if music playback is initiated via control center while
         using DietLens, then the user can let DietLens resume
         the session running, which will stop music playback. Note that stopping
         music playback in control center will not automatically resume the session
         running. Also note that it is not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")

            if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                viewControllerDelegate.onCameraInput(isAvailable: true)
            }
        }
    }

    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        viewControllerDelegate.onCameraInput(isAvailable: true)
    }
}

// MARK: Capturing methods
extension CameraSessionManager {
    func capturePhoto() {
        guard captureMode == .photo else {
            return
        }

        guard setupResult == .success else {
            return
        }

        sessionQueue.async { [weak self] in
            guard let wSelf = self else {
                return
            }
            let photoSettings = wSelf.getPhotoSettingsForCapturing()
            wSelf.photoProcessor.capture(photoOutput: wSelf.photoOutput, photoSettings: photoSettings)
        }
    }

    private func getPhotoSettingsForCapturing() -> AVCapturePhotoSettings {
        var photoSettings = AVCapturePhotoSettings()
        // Capture HEIF photo when supported, with flash set to auto and high resolution photo enabled.
        if #available(iOS 11.0, *) {
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
        }

        if videoInput.device.isFlashAvailable {
            photoSettings.flashMode = .auto
        }

        photoSettings.isHighResolutionPhotoEnabled = true

        if let format = photoSettings.__availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: format]
        }

        return photoSettings
    }
}

extension CameraSessionManager: BarcodeScannerDelegate {
    func onDetect(barcode: String) {
        viewControllerDelegate.onDetect(barcode: barcode)
    }
}

extension CameraSessionManager: PhotoCaptureDelegate {
    func onWillCapturePhoto() {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.viewControllerDelegate.onWillCapturePhoto()
        }
    }

    func onDidCapturePhoto(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.viewControllerDelegate.onDidFinishCapturePhoto(image: image)
        }
    }

    func onCaptureError() {

    }
}
