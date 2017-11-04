import AVFoundation
import Photos

class PhotoCaptureProcessor: NSObject {

	private var willCapturePhotoAnimation: (() -> Void)!
	private var completionHandler: (() -> Void)!
    private var requestedPhotoSettings: AVCapturePhotoSettings!
	private var photoData: Data?
    private let photoOutput: AVCapturePhotoOutput

    init(photoOutput: AVCapturePhotoOutput) {
        self.photoOutput = photoOutput
        super.init()
    }

	private func didFinish() {
		completionHandler()
	}

    func capture(photoSettings: AVCapturePhotoSettings, willCapturePhotoAnimation: @escaping () -> Void,
                 completionHandler: @escaping () -> Void) {
        self.requestedPhotoSettings = photoSettings
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.completionHandler = completionHandler
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    /*
     This extension includes all the delegate callbacks for AVCapturePhotoCaptureDelegate protocol
    */

    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        willCapturePhotoAnimation()
    }

    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
        }
    }

    // iOS 10
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        if let error = error {
            print("Error capturing photo: \(error)")
        }

        guard let sampleBuffer = photoSampleBuffer else {
            print("Cannot retrieve sample buffer")
            return
        }

        photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer,
                                                                     previewPhotoSampleBuffer: previewPhotoSampleBuffer)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            didFinish()
            return
        }

        guard let photoData = photoData else {
            print("No photo data resource")
            didFinish()
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    if #available(iOS 11.0, *) {
                        options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
                    }
                    creationRequest.addResource(with: .photo, data: photoData, options: options)

                    }, completionHandler: { _, error in
                        if let error = error {
                            print("Error occurered while saving photo to photo library: \(error)")
                        }

                        self.didFinish()
                    }
                )
            } else {
                self.didFinish()
            }
        }
    }
}
