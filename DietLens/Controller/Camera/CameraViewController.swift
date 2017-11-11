import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, UINavigationControllerDelegate {

    private let sessionManager = CameraSessionManager()

    @IBOutlet weak var capturePhotoButton: UIButton!

    @IBOutlet weak var previewContainer: UIView!

    @IBOutlet private weak var cameraUnavailableLabel: UILabel!

    @IBOutlet private weak var photoButton: UIButton!

    private let previewView = PreviewView()

    // MARK: Scanning barcodes

    @IBOutlet weak var barcodeButton: UIButton!

    private let imagePicker = UIImagePickerController()

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

        let previewLayer = previewView.videoPreviewLayer
        previewLayer.frame.size = previewContainer.frame.size
        previewLayer.videoGravity = .resizeAspectFill
        previewContainer.layer.addSublayer(previewLayer)

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.navigationBar.isTranslucent = false
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

    @IBAction func switchToGallery(_ sender: UIButton) {
        present(imagePicker, animated: false, completion: nil)
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

    func onDidFinishCapturePhoto(image: UIImage) {
        let croppedImage = cropCameraImage(image, previewLayer: previewView.videoPreviewLayer)
        print("Cropped image")
    }

    func cropCameraImage(_ original: UIImage, previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {

        var image = UIImage()

        let previewImageLayerBounds = previewLayer.bounds

        let originalWidth = original.size.width
        let originalHeight = original.size.height

        let A = previewImageLayerBounds.origin
        let B = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.origin.y)
        let D = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.size.height)

        let a = previewLayer.captureDevicePointConverted(fromLayerPoint: A)
        let b = previewLayer.captureDevicePointConverted(fromLayerPoint: B)
        let d = previewLayer.captureDevicePointConverted(fromLayerPoint: D)

        let posX = floor(b.x * originalHeight)
        let posY = floor(b.y * originalWidth)

        let width: CGFloat = d.x * originalHeight - b.x * originalHeight
        let height: CGFloat = a.y * originalWidth - b.y * originalWidth

        let cropRect = CGRect(x: posX, y: posY, width: width, height: height)

        if let imageRef = original.cgImage?.cropping(to: cropRect) {
            image = UIImage(cgImage: imageRef, scale: original.scale, orientation: original.imageOrientation)
        }

        return image
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
        sessionManager.set(captureMode: .photo)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Cannot get image from gallery")
            return
        }
        print("got image")
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
