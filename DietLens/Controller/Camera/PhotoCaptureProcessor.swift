import AVFoundation
import UIKit
import Photos

protocol PhotoCaptureDelegate: class {
    func onWillCapturePhoto()
    func onDidCapturePhoto(image: UIImage)
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
            delegate.onCaptureError()
            return
        }

        guard let photoData = photoData else {
            print("No photo data resource")
            delegate.onCaptureError()
            return
        }

        guard let image = UIImage(data: photoData) else {
            print("Cannot convert data to UIImage")
            delegate.onCaptureError()
            return
        }

        delegate.onDidCapturePhoto(image: image)
    }
}
