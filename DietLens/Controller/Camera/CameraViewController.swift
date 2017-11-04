import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private let sessionManager = CameraSessionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Disable UI. The UI is enabled if and only if the session starts running.
        photoButton.isEnabled = false
        barcodeButton.isEnabled = false

        sessionManager.previewView = previewView
        sessionManager.viewControllerDelegate = self
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

    @IBOutlet weak var previewView: PreviewView!

    @IBOutlet private weak var cameraUnavailableLabel: UILabel!

    @IBOutlet private weak var photoButton: UIButton!

    // MARK: Scanning barcodes

    @IBOutlet weak var barcodeButton: UIButton!


    @IBAction func capturePhoto(_ sender: UIButton) {
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

    func onEnableSwitchTo(captureModel: CameraSessionManager.CameraCaptureMode) {

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
}
