import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private let sessionManager = CameraSessionManager()

    @IBOutlet weak var capturePhotoButton: UIButton!

    @IBOutlet weak var previewView: PreviewView!

    @IBOutlet private weak var cameraUnavailableLabel: UILabel!

    @IBOutlet private weak var photoButton: UIButton!

    // MARK: Scanning barcodes

    @IBOutlet weak var barcodeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Disable UI. The UI is enabled if and only if the session starts running.
        photoButton.isEnabled = false
        barcodeButton.isEnabled = false
        capturePhotoButton.isHidden = true
        cameraUnavailableLabel.isHidden = true

        sessionManager.previewView = previewView
        sessionManager.viewControllerDelegate = self
        sessionManager.setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionManager.onViewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Order matters here
        sessionManager.onViewWillDisappear()
        super.viewWillDisappear(animated)
    }

    @IBAction func capturePhoto(_ sender: UIButton) {
        sessionManager.capturePhoto()
    }

    @IBAction func switchToPhoto(_ sender: UIButton) {
        sessionManager.set(captureMode: .photo)
    }

    @IBAction func switchToBarcode(_ sender: UIButton) {
        sessionManager.set(captureMode: .barcode)
    }

    @IBAction func dismissCamera(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension CameraViewController: CameraViewControllerDelegate {
    func onConfigureSession(withResult result: CameraSessionManager.SessionSetupResult) {
        switch result {
        case .notAuthorized:
            DispatchQueue.main.async { [weak self] in
                guard let wSelf = self else {
                    return
                }

                let changePrivacySetting = "DietLens doesn't have permission to use the camera, please change privacy settings"
                let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                let alertController = UIAlertController(title: "DietLens", message: message, preferredStyle: .alert)

                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                        style: .cancel,
                                                        handler: nil))

                alertController.addAction(
                    UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                  style: .`default`,
                                  handler: { _ in
                                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!,
                                                              options: [:], completionHandler: nil)
                    }))

                wSelf.present(alertController, animated: true, completion: nil)
            }

        case .configurationFailed:
            DispatchQueue.main.async { [weak self] in
                guard let wSelf = self else {
                    return
                }

                let alertMsg = "Alert message when something goes wrong during capture session configuration"
                let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                let alertController = UIAlertController(title: "DietLens", message: message, preferredStyle: .alert)

                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                        style: .cancel,
                                                        handler: nil))

                wSelf.present(alertController, animated: true, completion: nil)
            }

        default: break
        }
    }

    func onWillCapturePhoto() {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {
                return
            }

            // Snapping effect
            wSelf.previewView.videoPreviewLayer.opacity = 0
            UIView.animate(withDuration: 0.25) {
                wSelf.previewView.videoPreviewLayer.opacity = 1
            }
        }
    }

    func onSwitchTo(captureMode: CameraSessionManager.CameraCaptureMode) {
        photoButton.isEnabled = false
        barcodeButton.isEnabled = false
        capturePhotoButton.isHidden = true

        switch captureMode {
        case .photo:
            barcodeButton.isEnabled = true
            capturePhotoButton.isHidden = false
        case .barcode:
            photoButton.isEnabled = true
        }
    }

    func onCameraInput(isAvailable: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {
                return
            }

            wSelf.cameraUnavailableLabel.isHidden = !isAvailable
        }
    }

    func onDidFinishCapturePhoto() {
    }

    func onDetect(barcode: String) {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {
                return
            }

            let alertMsg = "Barcode detected!"
            let message = NSLocalizedString("Barcode: \(barcode)", comment: alertMsg)
            let alertController = UIAlertController(title: "DietLens", message: message, preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                    style: .cancel,
                                                    handler: nil))

            wSelf.present(alertController, animated: true, completion: nil)
        }
    }
}
