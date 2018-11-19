//
//  YStepMarkerView.swift
//  DietLens
//
//  Created by linby on 2018/10/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import Charts

open class YStepMarkerView: MarkerImage {
    open var color: UIColor
    open var arrowSize = CGSize(width: 15, height: 11)

    open var font: UIFont
    open var textColor: UIColor
    open var insets: UIEdgeInsets
    open var minimumSize = CGSize()

    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key: AnyObject]()

    let labelHeight = 70 //at the top of the chartView
    var lineHeight = CGFloat(490)

    var dateMode = StringConstants.DateMode.day

    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets

        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }

    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        var offset = self.offset
        var size = self.size

        if size.width == 0.0 && image != nil {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil {
            size.height = image!.size.height
        }

        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        if origin.x + offset.x < -1.0 {
            offset.x = -origin.x + padding
        } else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }

        if origin.y + offset.y < 0 {
            offset.y = height + padding
        } else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }
        return offset
    }

    open override func draw(context: CGContext, point: CGPoint) {
        guard let label = label else { return }

        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size

        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: CGFloat(labelHeight)),
            size: size)
        lineHeight = point.y - rect.origin.y/2
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height

        context.saveGState()

        context.setFillColor(color.cgColor)

        if offset.y > 0 {
            context.beginPath()
            //left bottom rect point
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + CGFloat(lineHeight)))
            //darw rect
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width/2,
                y: rect.origin.y + CGFloat(lineHeight)))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width/2,
                y: 500))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width/2,
                y: rect.origin.y + CGFloat(lineHeight)))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width/2,
                y: rect.origin.y + CGFloat(lineHeight)))
            //the other 3 lines
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y +  CGFloat(lineHeight)))
            context.fillPath()
            //draw line
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x/2,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x/2,
                y: 0))
            context.fillPath()
        } else {
            context.beginPath()
            //darw rect
            context.addRect(CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height/2))
            //draw line
            context.addRect(CGRect(x: rect.origin.x + rect.size.width/2, y: rect.origin.y + rect.size.height/2, width: 1, height: CGFloat(lineHeight)))
            context.fillPath()
        }

//        if offset.y > 0 {
//            rect.origin.y += self.insets.top + arrowSize.height
//        } else {
//            rect.origin.y += self.insets.top
//        }
//        rect.size.height -= self.insets.top + self.insets.bottom

        UIGraphicsPushContext(context)
        label.draw(in: rect, withAttributes: _drawAttributes)
        UIGraphicsPopContext()
        context.restoreGState()
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        switch dateMode {
            case .day:
                setLabel(String(Int(entry.x)) + ":00 | " + String(Int(entry.y)))
            case .week:
                setLabel(StringConstants.DateString.weekString[(Int(entry.x)-1)] + " | " + String(Int(entry.y)))
            case .month:
                setLabel(String(Int(entry.x)) + " | " + String(Int(entry.y)))
            case .year:
                setLabel(StringConstants.DateString.monthString[(Int(entry.x)-1)] + " | " + String(Int(entry.y)))
        }

    }

    open func setLabel(_ newLabel: String) {
        label = newLabel

        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor

        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero

        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }

}
