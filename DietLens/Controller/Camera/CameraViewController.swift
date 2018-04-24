import UIKit
import AVFoundation
import Photos
import XLPagerTabStrip
import RealmSwift

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

    private var foodDiary = FoodDiaryModel()

    private var activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var loadingScreen: UIView!

    @IBOutlet weak var uploadPercentageLabel: UILabel!

    private var recordType: String = RecordType.RecordByImage

//    @IBOutlet weak var focusViewImg: UIImageView!

    let locationManager = CLLocationManager()
    var latitude = 0.0
    var longitude = 0.0
    var imageId: Int = 0

    var pinchGestureRecognizer = UIPinchGestureRecognizer()

    //passing parameter
    var displayList = [DisplayFoodCategory]()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideReview()
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(CameraViewController.pinchCameraView(_:)))
        sessionManager.previewView = previewView
        sessionManager.previewView.addGestureRecognizer(pinchGestureRecognizer)
        sessionManager.viewControllerDelegate = self
        sessionManager.setup()
        let previewLayer = previewView.videoPreviewLayer
        previewLayer.videoGravity = .resizeAspectFill

        previewContainer.layer.addSublayer(previewLayer)
        //previewContainer.bringSubview(toFront: focusViewImg)
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.navigationBar.isTranslucent = false
        loadingScreen.alpha = 0
        //setup location manager
        if CLLocationManager.locationServicesEnabled() {
            enableLocationServices()
        } else {
            print("Location services are not enabled")
        }
    }

    @objc func pinchCameraView(_ sender: UIPinchGestureRecognizer) {
        //TODO camera zoom in & out according to pinch
        sessionManager.pinch(pinch: sender)
    }

    func enableLocationServices() {
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            break
            // Disable location features or quit
//            disableMyLocationBasedFeatures()
        case .authorizedWhenInUse:
            // Enable basic location features
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
            break
            // Enable any of your app's location features
//            enableMyAlwaysFeatures()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.videoPreviewLayer.frame.size = previewContainer.frame.size
//        previewContainer.bringSubview(toFront: focusViewImg)
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

    @IBAction func dismissCamera(_ sender: UIButton) {
        if reviewImagePalette.isHidden {
            super.dismiss(animated: true)
        } else {
            hideReview()
        }
    }

    @IBAction func capturePhoto(_ sender: UIButton) {
        capturePhotoButton.isEnabled = false
        sessionManager.capturePhoto()
    }

    @IBAction func switchToPhoto(_ sender: UIButton) {
        capturePhotoButton.isEnabled = true
        capturePhotoButton.tintColor = UIColor.red
        sessionManager.set(captureMode: .photo)
    }

    @IBAction func switchToBarcode(_ sender: UIButton) {
        sessionManager.set(captureMode: .barcode)
        barcodeButton.tintColor = UIColor.red
    }

    @IBAction func switchToGallery(_ sender: UIButton) {
        present(imagePicker, animated: false, completion: nil)
    }

    @IBAction func approveImage(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.loadingScreen.alpha = 1
        }, completion: nil)
        //resize&compress image process
        let size = CGSize(width: previewView.frame.width, height: previewView.frame.height)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        chosenImageView.image!.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imgData = UIImageJPEGRepresentation(newImage!, 0.6)!
//        let preferences = UserDefaults.standard
//        let key = "userId"
//        let userId = preferences.string(forKey: key)
        //upload image to server
        APIService.instance.qiniuImageUpload(imgData: imgData, completion: {(imageKey) in
            if imageKey == nil {
                //error happen during upload image to Qiniu
                return
            }
            self.uploadPercentageLabel.text = "retrieving recognition result..."
            APIService.instance.postForRecognitionResult(imageKey: imageKey!, latitude: self.latitude, longitude: self.longitude, completion: { (resultList) in
                    self.hideReview()
                    self.capturePhotoButton.isEnabled = true
                    self.loadingScreen.alpha = 0
                    if resultList == nil || resultList?.count == 0 {
                        AlertMessageHelper.showMessage(targetController: self, title: "", message: "Recognized failed")
                    } else {
                        self.displayList.removeAll()
                        self.displayList = resultList!
                        self.recordType = RecordType.RecordByImage
                        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "recognitionVC") as? RecognitionResultViewController {
                            if self.recordType == RecordType.RecordByImage {
                                dest.cameraImage = self.chosenImageView.image!
                                dest.imageKey = imageKey
                                dest.foodCategoryList = self.displayList
                            } else if self.recordType == RecordType.RecordByBarcode {
                                dest.cameraImage = #imageLiteral(resourceName: "barcode_sample_icon")
                            }
                            if let navigator = self.navigationController {
                                navigator.pushViewController(dest, animated: true)
                            }
                        }
                    }
                    self.hideReview()
            })
            //upload imageToken to server to get the food recognition results
        }) { (progress) in
            self.uploadPercentageLabel.text = "\(progress)%"
        }
//        APIService.instance.uploadImageForMatrix(imgData: imgData, userId: userId!, latitude: latitude, longitude: longitude, completion: { (results) in
//            // upload result and callback
//            self.capturePhotoButton.isEnabled = true
//            self.loadingScreen.alpha = 0
//            if results == nil || results?.count == 0 {
//                AlertMessageHelper.showMessage(targetController: self, title: "", message: "Recognized failed")
//            } else {
//                self.displayList.removeAll()
//                self.displayList = results!
//                self.recordType = RecordType.RecordByImage
//                //                self.performSegue(withIdentifier: "test", sender: self)
//                self.performSegue(withIdentifier: "showResultPage", sender: self)
//            }
//            self.hideReview()
//        }) { (progress) in
//            self.uploadPercentageLabel.text = "\(progress)%"
//        }
//        APIService.instance.uploadRecognitionImage(imgData: imgData, userId: userId!, latitude: latitude, longitude: longitude, completion: { (imageId, results) in
//            // upload result and callback
//            self.imageId = imageId
//            self.capturePhotoButton.isEnabled = true
//            self.loadingScreen.alpha = 0
//            if results == nil || results?.count == 0 {
//                AlertMessageHelper.showMessage(targetController: self, title: "", message: "Recognized failed")
//            } else {
//                self.foodDiary.foodInfoList.removeAll()
//                for result in results! {
//                    self.foodDiary.foodInfoList.append(result)
//                }
//                self.recordType = RecordType.RecordByImage
////                self.performSegue(withIdentifier: "test", sender: self)
//                self.performSegue(withIdentifier: "showResultPage", sender: self)
//            }
//            self.hideReview()
//        }) { (progress) in
//            self.uploadPercentageLabel.text = "\(progress)%"
//        }
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
//            focusViewImg.isHidden = false
            removeBarScannerLine()
        case .barcode:
            activeButton = barcodeButton
            capturePhotoButton.isHidden = true
//            focusViewImg.isHidden = true
            addBarScannerLine()
        }

        let allButtons = [photoButton, barcodeButton]
        let inactiveButtons = allButtons.filter { $0 != activeButton }

        for button in inactiveButtons {
            button?.isEnabled = true
            button?.backgroundColor = .clear
        }
//        activeButton.setTitleColor(UIColor(red: 242, green: 64, blue: 93, alpha: 1), for: .disabled)
        activeButton.isEnabled = false
//        activeButton.backgroundColor = UIColor(red: 1.00, green: 0.31, blue: 0.31, alpha: 0.7)
//        activeButton.layer.cornerRadius = 5
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
        APIService.instance.getBarcodeScanResult(barcode: barcode) { (foodInformation) in
            if foodInformation == nil {
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
                do {
                    try Realm().write {
                        self.foodDiary.foodInfoList.append(foodInformation!)
                    }
                } catch let error as NSError {
                    //handel error
                }
                self.recordType = RecordType.RecordByBarcode
                self.performSegue(withIdentifier: "test", sender: self)
            }
        }
//        APIService.instance.getBarcodeScanResult(barcode: barcode){ (foodInformation?) in
//            if foodInformation == nil {
//                DispatchQueue.main.async { [weak self] in foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos]
//                    guard let wSelf = self else {
//                        returna
//                    }
//                    let alertMsg = "Result not found!"
//                    let message = NSLocalizedString("Barcode result not found in database", comment: alertMsg)
//                    let alertController = UIAlertController(title: "DietLens", message: message, preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
//                                                            style: .cancel,
//                                                            handler: nil))
//                    wSelf.present(alertController, animated: true, completion: nil)
//                }
//            } else {
//                self.loadingScreen.alpha = 0
//                try Realm().write {
//                    self.foodDiary.foodInfoList.append(foodInformation)
//                }
//                self.recordType = RecordType.RecordByBarcode
//                self.performSegue(withIdentifier: "test", sender: self)
//            }
//
//        }
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
            imagePicker.dismiss(animated: true, completion: nil)
            return
        }
        showReview(image: image)
//        let imgData = UIImagePNGRepresentation(image)!
//        APIService.instance.uploadRecognitionImage(imgData: imgData, userId: "1") {(_) in
//            // upload result and callback
//        }
        imagePicker.dismiss(animated: true, completion: nil)
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
        chosenImageView.contentMode = .scaleToFill
        chosenImageView.isHidden = false
        reviewImagePalette.isHidden = false
    }

    private func hideReview() {
        chosenImageView.isHidden = true
        reviewImagePalette.isHidden = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let parentVC = self.parent as! AddFoodViewController
//        if let dest = segue.destination as? RecognitionResultsViewController {
//            dest.foodDiary = foodDiary
//            dest.imageId = imageId
//            dest.dateTime = parentVC.addFoodDate
//            dest.isSetMealByTimeRequired = parentVC.isSetMealByTimeRequired
//            dest.whichMeal = parentVC.mealType
//            dest.foodDiary.recordType = self.recordType
//            if recordType == RecordType.RecordByImage {
//                dest.userFoodImage = chosenImageView.image!
//            } else if recordType == RecordType.RecordByBarcode {
//                dest.userFoodImage = #imageLiteral(resourceName: "barcode_sample_icon")
//            }
//        }
        if let dest  = segue.destination as? RecognitionResultViewController {
            if recordType == RecordType.RecordByImage {
                dest.cameraImage = chosenImageView.image!
                dest.foodCategoryList = displayList
            } else if recordType == RecordType.RecordByBarcode {
                dest.cameraImage = #imageLiteral(resourceName: "barcode_sample_icon")
            }
        }
    }

}

extension CameraViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude = (locations.last?.coordinate.latitude)!
        self.longitude = (locations.last?.coordinate.longitude)!
        print("latitude:\(locations.last?.coordinate.latitude)")
        print("longitude\(locations.last?.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
    }
}
