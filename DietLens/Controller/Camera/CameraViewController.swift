import UIKit
import AVFoundation
import Photos
import XLPagerTabStrip
import JPSVolumeButtonHandler
import Reachability
import AssetsLibrary
import FirebaseAnalytics

class CameraViewController: BaseViewController, UINavigationControllerDelegate {

    @IBOutlet weak var capturePhotoButton: LoadingButton!

    @IBOutlet weak var previewContainer: UIView!

    @IBOutlet private weak var cameraUnavailableLabel: UILabel!

    // MARK: Scanning barcodes
    @IBOutlet weak var chosenImageView: UIImageView!

    private let sessionManager = CameraSessionManager()

    private let previewView = PreviewView()

    private let barScannerLine = UIView()

    private let imagePicker = UIImagePickerController()

    private var activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var loadingScreen: UIView!

    @IBOutlet weak var uploadPercentageLabel: UILabel!

    @IBOutlet weak var galleryBtn: ExpandedUIButton!

    private var recordType: String = RecognitionInteger.recognition

    var imageId: Int = 0

    var pinchGestureRecognizer = UIPinchGestureRecognizer()
    var tapGestureRecognizer = UITapGestureRecognizer()

    //passing parameter
    var displayList = [DisplayFoodCategory]()
    //mealTime & mealType
    var addFoodDate = Date()
    var mealType: String = StringConstants.MealString.breakfast
    var isSetMealByTimeRequired = true
    @IBOutlet weak var sampleImagCollectionView: UICollectionView!

    let imageArray = [#imageLiteral(resourceName: "CameraExampleHokkienMee"), #imageLiteral(resourceName: "CameraExampleAyamPenyet"), #imageLiteral(resourceName: "CameraExampleRotiPrata"), #imageLiteral(resourceName: "CameraExampleChickenRice"), #imageLiteral(resourceName: "CameraExampleChickenChop"), #imageLiteral(resourceName: "CameraExampleSatay")]
    let imageKeyArray = ["sample/3_Hokkien_Mee.png", "sample/6_Ayam_Penyet.png", "sample/2_Roti_Prata.png", "sample/4_Chicken_Rice.png",
                         "sample/5_Chicken_Chop.png", "sample/1_Satay.png"]
    var currentImageIndex = 0

    var focusIndicator: UIImageView?
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideReview()
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchCameraView(_:)))
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCameraViewTappped(_:)))
        previewView.addGestureRecognizer(pinchGestureRecognizer)
        previewView.addGestureRecognizer(tapGestureRecognizer)
        sessionManager.previewView = previewView
        previewContainer.addGestureRecognizer(pinchGestureRecognizer)
        previewContainer.addGestureRecognizer(tapGestureRecognizer)
        //view gesture recognizer
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
        //setup location manager
        sessionManager.onViewWillAppear()
        sampleImagCollectionView.delegate = self
        sampleImagCollectionView.dataSource = self
        sampleImagCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        //gallery button
        galleryBtn.centerVertically()
        //set up location manager
        if CLLocationManager.locationServicesEnabled() {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.enableLocationServices()
            }
        } else {
            print("Location services are not enabled")
        }
        //analytic screen name
        Analytics.setScreenName("ImagePage", screenClass: "CameraViewController")
        //analytic log the event for the total number that start to record food
        Analytics.logEvent(StringConstants.FireBaseAnalytic.FoodRecrodStartFlag, parameters: nil)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isImageCaptureTriggered = true
        }
    }

    @objc func pinchCameraView(_ sender: UIPinchGestureRecognizer) {
        //TODO camera zoom in & out according to pinch
        sessionManager.pinch(pinch: sender)
    }

    /** cameraView focus part*/

    @objc func onCameraViewTappped(_ gestureRecognizer: UITapGestureRecognizer) {
        let location  = gestureRecognizer.location(in: sessionManager.previewView)
        addfocusIndicatorView(at: location)
        let captureDeviceLocation = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: location)
        sessionManager.focus(at: captureDeviceLocation)
    }

    func addfocusIndicatorView(at point: CGPoint) {
        if focusIndicator == nil {
            focusIndicator = UIImageView(image: UIImage(imageLiteralResourceName: "cameraFocusIndicator"))
            focusIndicator!.frame.size = CGSize(width: 60, height: 60)
            self.previewView.addSubview(focusIndicator!)
        }
        focusIndicator!.center = point
        //schedule timer
        if timer != nil {
             timer?.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(removeCameraIndicator), userInfo: nil, repeats: false)
    }

    @objc func removeCameraIndicator() {
        focusIndicator?.removeFromSuperview()
        focusIndicator = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.videoPreviewLayer.frame.size = previewContainer.frame.size
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        //        volumeHandler?.start(true)
        sessionManager.onViewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Order matters here
        sessionManager.onViewWillDisappear()
        //        volumeHandler?.stop()
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
        super.dismiss(animated: true)
    }

    func takePhoto() {
        sessionManager.capturePhoto()
    }

    @IBAction func capturePhoto (_ sender: UIButton) {
        sessionManager.capturePhoto()
        capturePhotoButton.isEnabled = false
        //#google analytic log part
        Analytics.logEvent(StringConstants.FireBaseAnalytic.ImageClickCaptureButton, parameters: [
            StringConstants.FireBaseAnalytic.Parameter.MealTime: mealType
        ])
    }

    @IBAction func switchToGallery(_ sender: UIButton) {
        present(imagePicker, animated: false, completion: nil)
    }

    func approveImage(image: UIImage) {
        if Reachability()!.connection == .none {
            let storyboard = UIStoryboard(name: "AddFoodScreen", bundle: nil)
            if let confirmationAlert =  storyboard.instantiateViewController(withIdentifier: "confirmationVC") as? ConfirmationDialog {
                confirmationAlert.delegate = self
                confirmationAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                confirmationAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                confirmationAlert.contentText = "Do you want to save image to photo album and recognize it later?"
                confirmationAlert.reminderText = "No Internet connection found"
                present(confirmationAlert, animated: true, completion: nil)
            }
            return
        }

        let size = CGSize(width: previewView.frame.width, height: previewView.frame.height)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        //        var convertedRect = previewView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: rect)
        //        chosenImageView.image!.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imgData = UIImageJPEGRepresentation(newImage!, 1.0)!
        //        let preferences = UserDefaults.standard
        //        let key = "userId"
        //        let userId = preferences.string(forKey: key)
        //upload image to server
        let startTime = Date()
        APIService.instance.qiniuImageUpload(imgData: imgData, completion: {(imageKey) in
            if imageKey != nil {
                let uploadTime = Date().timeIntervalSince(startTime)
                print(uploadTime)
                self.postImageKeyToServer(imageKey: imageKey!, isUsingSample: false, uploadTime: uploadTime)
            } else {//error happen during upload image to Qiniu
                self.hideReview()
                self.capturePhotoButton.isEnabled = true
                //                self.loadingScreen.alpha = 0
                AlertMessageHelper.showMessage(targetController: self, title: "", message: "Image upload failed")
            }
            //upload imageToken to server to get the food recognition results
        }) { (progress) in
            self.uploadPercentageLabel.text = "\(progress)%"
        }
    }

    func postImageKeyToServer(imageKey: String, isUsingSample: Bool, uploadTime: TimeInterval) {
        self.uploadPercentageLabel.text = "Retrieving recognition results..."
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        APIService.instance.postForRecognitionResult(imageKey: imageKey, latitude: appDelegate.latitude, longitude: appDelegate.longitude, uploadSpeed: uploadTime, completion: { (resultList, taskId) in
            self.hideReview()
            self.capturePhotoButton.isEnabled = true
            if resultList == nil || resultList?.count == 0 {
                AlertMessageHelper.showMessage(targetController: self, title: "", message: "Recognized failed")
            } else {
                self.displayList.removeAll()
                self.displayList = resultList!
                if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "recognitionVC") as? RecognitionResultViewController {
                    if isUsingSample {
                        dest.cameraImage = self.imageArray[self.currentImageIndex]
                    } else {
                        dest.cameraImage = self.chosenImageView.image!
                    }
                    dest.imageKey = imageKey
                    dest.taskId = taskId
                    dest.foodCategoryList = self.displayList
                    //pass display value
                    dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
                    dest.recordDate = self.addFoodDate
                    dest.mealType = self.mealType
                    dest.recordType = self.recordType
                    if let navigator = self.navigationController {
                        navigator.pushViewController(dest, animated: true)
                    }
                    //#Google Analytics part
                    Analytics.logEvent(StringConstants.FireBaseAnalytic.ImageCaptureFlag, parameters: nil)
                }
            }
            self.hideReview()
        })
    }

    @IBAction func rejectImage(_ sender: UIButton) {
        hideReview()
    }
}

extension CameraViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchedView = touch.view, let gestureView = gestureRecognizer.view, touchedView.isDescendant(of: gestureView), touchedView !== gestureView {
            return false
        }
        return true
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
        //        var activeButton: UIButton
        switch captureMode {
        case .photo:
            //            activeButton = photoButton
            capturePhotoButton.isHidden = false
            removeBarScannerLine()
        case .barcode:
            //            activeButton = barcodeButton
            capturePhotoButton.isHidden = true
            addBarScannerLine()
        }
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
        //set record type to capture
        self.recordType = RecognitionInteger.recognition
        let croppedImage = cropCameraImage(image, previewLayer: previewView.videoPreviewLayer)!
        let saveToAblumFlag = UserDefaults.standard.bool(forKey: PreferenceKey.saveToAlbumFlag)
//        if saveToAblumFlag && !(Reachability()!.connection == .none) { //with network & save to album flag
//            CustomPhotoAlbum.sharedInstance.saveImage(image: croppedImage)
//        }
        showReview(image: croppedImage)
        approveImage(image: croppedImage)
    }

    func cropCameraImage(_ original: UIImage, previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {

        var image = UIImage()

        let previewImageLayerBounds = previewLayer.bounds

        let originalWidth = original.size.width
        let originalHeight = original.size.height

        let APoint = previewImageLayerBounds.origin
        let BPoint = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.origin.y)
        let DPoint = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.size.height)

        let aPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: APoint)
        let bPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: BPoint)
        let dPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: DPoint)

        let posX = floor(bPoint.x * originalHeight)
        let posY = floor(bPoint.y * originalWidth)

        let width: CGFloat = dPoint.x * originalHeight - bPoint.x * originalHeight
        let height: CGFloat = aPoint.y * originalWidth - bPoint.y * originalWidth

        let cropRect = CGRect(x: posX, y: posY, width: width, height: height)
        if let imageRef = original.cgImage?.cropping(to: cropRect) {
            image = UIImage(cgImage: imageRef, scale: original.scale, orientation: original.imageOrientation)
        }
        return image
    }

    func onDetect(barcode: String) {
        AlertMessageHelper.showMessage(targetController: self, title: "", message: "Work in progress")
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
        if let url = info[UIImagePickerControllerReferenceURL] as? URL {
            //get image meta data from gallery
            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
            let fetchAsset = fetchResult.firstObject
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appDelegate.latitude = fetchAsset?.location?.coordinate.latitude ?? 0.0
            appDelegate.longitude = fetchAsset?.location?.coordinate.longitude ?? 0.0
        }

        self.recordType = RecognitionInteger.gallery
        imagePicker.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            let croppedImage = self.cropCameraImage(image, previewLayer: self.previewView.videoPreviewLayer)!
            self.showReview(image: croppedImage)
            self.approveImage(image: image)
        }
        //#google analytic log part
        Analytics.logEvent(StringConstants.FireBaseAnalytic.ImageClickGalleryButton, parameters: [
            StringConstants.FireBaseAnalytic.Parameter.MealTime: mealType
        ])

    }

    func getGalleryImageInfo() {

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
        capturePhotoButton.showLoading()
        capturePhotoButton.isEnabled = false
        capturePhotoButton.setImage(nil, for: .normal)
    }

    private func hideReview() {
        chosenImageView.isHidden = true
        capturePhotoButton.isHidden = false
        capturePhotoButton.hideLoading()
        capturePhotoButton.isEnabled = true
        capturePhotoButton.setImage(#imageLiteral(resourceName: "capture"), for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest  = segue.destination as? RecognitionResultViewController {
            if recordType == RecognitionInteger.recognition {
                dest.cameraImage = chosenImageView.image!
                dest.foodCategoryList = displayList
            } else if recordType == RecognitionInteger.barcode {
                dest.cameraImage = #imageLiteral(resourceName: "barcode_sample_icon")
            }
        }
    }

}

extension CameraViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sampleImageCell", for: indexPath) as? UICollectionViewCell {
            let displayImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            displayImage.image = imageArray[indexPath.row]
            cell.addSubview(displayImage)
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //show loading progress dialog
        //        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
        //            self.loadingScreen.alpha = 1
        //        }, completion: nil)
        //post recognition imageKey
        currentImageIndex = indexPath.row
        self.postImageKeyToServer(imageKey: imageKeyArray[currentImageIndex], isUsingSample: true, uploadTime: 0)
        showReview(image: imageArray[indexPath.row])
        //# Firebase Analytic log
        Analytics.logEvent(StringConstants.FireBaseAnalytic.ImageSelectSampleItem, parameters: [StringConstants.FireBaseAnalytic.Parameter.MealTime: mealType, "rank": indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(40), height: CGFloat(40))
    }

}

extension CameraViewController: ConfirmationDelegate {

    func onPositiveBtnPressed() {
        let croppedImage = cropCameraImage(chosenImageView.image!, previewLayer: previewView.videoPreviewLayer)!
        CustomPhotoAlbum.sharedInstance.saveImage(image: croppedImage)
        dismiss(animated: true, completion: nil)
        self.hideReview()
    }

    func onNegativeBtnPressed() {
        dismiss(animated: true, completion: nil)
        self.hideReview()
    }

}
