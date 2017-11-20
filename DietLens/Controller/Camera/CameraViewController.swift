import UIKit
import AVFoundation
import Photos
import XLPagerTabStrip

class CameraViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var capturePhotoButton: UIButton!

    @IBOutlet weak var previewContainer: UIView!

    @IBOutlet private weak var cameraUnavailableLabel: UILabel!

    @IBOutlet private weak var photoButton: UIButton!

    // MARK: Scanning barcodes

    @IBOutlet weak var barcodeButton: UIButton!

    @IBOutlet weak var reviewImagePalette: UIView!

    @IBOutlet weak var chosenImageView: UIImageView!

    private let sessionManager = CameraSessionManager()

    private let previewView = PreviewView()

    private let barScannerLine = UIView()

    private let imagePicker = UIImagePickerController()

    private var foodResults: [FoodInfomation]?

    private var activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var loadingScreen: UIView!

    private var recordType: String = "recogniton"

    override func viewDidLoad() {
        super.viewDidLoad()

        hideReview()

        sessionManager.previewView = previewView
        sessionManager.viewControllerDelegate = self
        sessionManager.setup()

        let previewLayer = previewView.videoPreviewLayer
        previewLayer.videoGravity = .resizeAspectFill
        previewContainer.layer.addSublayer(previewLayer)

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.navigationBar.isTranslucent = false
        loadingScreen.alpha = 0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.videoPreviewLayer.frame.size = previewContainer.frame.size
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

    private func addBarScannerLine() {
        let previewContainerFrame = previewContainer.frame
        barScannerLine.frame = CGRect(x: 0, y: 0, width: previewContainerFrame.width, height: 2)
        barScannerLine.backgroundColor = UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0)
        previewContainer.addSubview(barScannerLine)
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.barScannerLine.frame = CGRect(x: 0, y: previewContainerFrame.height - 2, width: previewContainerFrame.width, height: 2)
        }, completion: nil)
    }

    private func removeBarScannerLine() {
        barScannerLine.removeFromSuperview()
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

    @IBAction func approveImage(_ sender: UIButton) {
        hideReview()

        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.loadingScreen.alpha = 1
        }, completion: nil)

        let imgData = UIImageJPEGRepresentation(chosenImageView.image!, 0.2)!
        APIService.instance.uploadRecognitionImage(imgData: imgData, userId: "1") {(results) in
            // upload result and callback
            self.loadingScreen.alpha = 0
            self.foodResults = results
            self.recordType = "recognition"
            self.performSegue(withIdentifier: "test", sender: self)
            print(results!)

        }
    }

    @IBAction func rejectImage(_ sender: UIButton) {
        hideReview()
    }
}

// MARK: CameraViewControllerDelegate methods

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
        var activeButton: UIButton
        switch captureMode {
        case .photo:
            activeButton = photoButton
            capturePhotoButton.isHidden = false
            removeBarScannerLine()
        case .barcode:
            activeButton = barcodeButton
            capturePhotoButton.isHidden = true
            addBarScannerLine()
        }

        let allButtons = [photoButton, barcodeButton]
        let inactiveButtons = allButtons.filter { $0 != activeButton }

        for button in inactiveButtons {
            button?.isEnabled = true
            button?.backgroundColor = .clear
        }

        activeButton.isEnabled = false
        activeButton.backgroundColor = UIColor(red: 1.00, green: 0.31, blue: 0.31, alpha: 0.7)
        activeButton.layer.cornerRadius = 5
    }

    func onCameraInput(isAvailable: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {
                return
            }

            wSelf.cameraUnavailableLabel.isHidden = isAvailable
        }
    }

    func onDidFinishCapturePhoto(image: UIImage) {
        let croppedImage = cropCameraImage(image, previewLayer: previewView.videoPreviewLayer)!
        showReview(image: croppedImage)
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
        APIService.instance.getBarcodeScanResult(barcode: barcode) { (foodInfomation) in
            if foodInfomation == nil {
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {
                        return
                    }
                    let alertMsg = "Result not found!"
                    let message = NSLocalizedString("Barcode result not found in database", comment: alertMsg)
                    let alertController = UIAlertController(title: "DietLens", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    wSelf.present(alertController, animated: true, completion: nil)
                }
            } else {
                self.loadingScreen.alpha = 0
                self.foodResults = [foodInfomation!]
                self.recordType = "barcode"
                self.performSegue(withIdentifier: "test", sender: self)
            }

        }
//        DispatchQueue.main.async { [weak self] in
//            guard let wSelf = self else {
//                return
//            }
//
//            let alertMsg = "Barcode detected!"
//            let message = NSLocalizedString("Barcode: \(barcode)", comment: alertMsg)
//            let alertController = UIAlertController(title: "DietLens", message: message, preferredStyle: .alert)
//
//            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
//                                                    style: .cancel,
//                                                    handler: nil))
//
//            wSelf.present(alertController, animated: true, completion: nil)
//        }
        sessionManager.set(captureMode: .photo)
    }
}

// MARK: UIImagePickerControllerDelegate methods

extension CameraViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Cannot get image from gallery")
            return
        }
        showReview(image: image)
//        let imgData = UIImagePNGRepresentation(image)!
//        APIService.instance.uploadRecognitionImage(imgData: imgData, userId: "1") {(_) in
//            // upload result and callback
//        }
//        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: IndicatorInfoProvider methods
extension CameraViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "BY IMAGE")
    }
}

// MARK: review image flow
extension CameraViewController {

    private func showReview(image: UIImage) {
        chosenImageView.image = image
        chosenImageView.contentMode = .scaleAspectFit
        chosenImageView.isHidden = false
        reviewImagePalette.isHidden = false
    }

    private func hideReview() {
        chosenImageView.isHidden = true
        reviewImagePalette.isHidden = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RecognitionResultsViewController {
            dest.results = foodResults
            if recordType == "recognition" {
                dest.userFoodImage = chosenImageView.image!
            } else if recordType == "barcode" {
                dest.userFoodImage = #imageLiteral(resourceName: "barcode_sample_icon")
            }
        }
    }

}
