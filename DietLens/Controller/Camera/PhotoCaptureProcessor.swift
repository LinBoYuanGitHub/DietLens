import AVFoundation
import Photos

protocol PhotoCaptureDelegate: class {
    func onWillCapturePhoto()
    func onDidCapturePhoto()
    func onCaptureError()
}

class PhotoCaptureProcessor: NSObject {

    weak var delegate: PhotoCaptureDelegate!
    private var requestedPhotoSettings: AVCapturePhotoSettings!
	private var photoData: Data?

    func capture(photoOutput: AVCapturePhotoOutput, photoSettings: AVCapturePhotoSettings) {
        self.requestedPhotoSettings = photoSettings
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    /*
     This extension includes all the delegate callbacks for AVCapturePhotoCaptureDelegate protocol
    */

    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        delegate.onWillCapturePhoto()
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
            delegate.onDidCapturePhoto()
            return
        }

        guard let photoData = photoData else {
            print("No photo data resource")
            delegate.onCaptureError()
            return
        }

        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let wSelf = self else {
                return
            }

            guard status == .authorized else {
                wSelf.delegate.onCaptureError()
                return
            }

            PHPhotoLibrary.shared().performChanges({
                let options = PHAssetResourceCreationOptions()
                let creationRequest = PHAssetCreationRequest.forAsset()
                if #available(iOS 11.0, *) {
                    options.uniformTypeIdentifier = wSelf.requestedPhotoSettings.processedFileType.map { $0.rawValue }
                }
                creationRequest.addResource(with: .photo, data: photoData, options: options)

                }, completionHandler: { _, error in

                    guard error == nil else {
                        print("Error occurered while saving photo to photo library: \(error.debugDescription)")
                        wSelf.delegate.onCaptureError()
                        return
                    }

                    wSelf.delegate.onDidCapturePhoto()
                }
            )
        }
    }
}
