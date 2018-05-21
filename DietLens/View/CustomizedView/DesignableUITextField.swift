// References: https://stackoverflow.com/questions/27903500/swift-add-icon-image-in-uitextfield

import UIKit

@IBDesignable
class DesignableUITextField: UITextField {

     var addedTouchArea = CGFloat(0)

    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += imagePadding
        return textRect
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        let newBound = CGRect(
            x: self.bounds.origin.x - 20,
            y: self.bounds.origin.y - 20,
            width: self.bounds.width + 2 * 20,
            height: self.bounds.width + 2 * 20
        )
        return newBound.contains(point)
    }

    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }

    @IBInspectable var imagePadding: CGFloat = 0 {
        didSet {
            updateView()
        }
    }

    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }

    func updateView() {
        if let image = leftImage {
            leftViewMode = .always
            let sideLength = frame.height - imagePadding * 2
            let imageView = UIImageView(frame: CGRect(x: imagePadding, y: imagePadding,
                                                      width: sideLength, height: sideLength))
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = .never
            leftView = nil
        }

        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "",
                                                   attributes: [.foregroundColor: color])
    }
}
