//
//  GraphView.swift
//  DietLens
//
//  Created by linby on 18/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

private struct Constants {
    static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
    static let margin: CGFloat = 20.0
    static let topBorder: CGFloat = 60
    static let bottomBorder: CGFloat = 50
    static let colorAlpha: CGFloat = 0.3
    static let circleDiameter: CGFloat = 5.0
}

class GraphView: UIView {

    @IBInspectable var startColor: UIColor = .red
    @IBInspectable var endColor: UIColor = .orange

    var graphPoints = [4, 2, 6, 4, 5, 8, 3]

    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
//        let path = UIBezierPath(roundedRect: rect,
//                                byRoundingCorners: .allCorners,
//                                cornerRadii: Constants.cornerRadiusSize)
//        path.addClip()
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
        //calculate the x point
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
            //Calculate the gap between points
            let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + margin + 2
        }
        // calculate the y point
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = self.graphPoints.max()!
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
            return graphHeight + topBorder - y // Flip the graph
        }
        // draw the line graph
        UIColor.white.setFill()
        UIColor.white.setStroke()
        // set up the points line
        let graphPath = UIBezierPath()
        // go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(self.graphPoints[0])))

        // add points for each item in the graphPoints array
        // at the correct (x, y) for the point
        for i in 1..<self.graphPoints.count {
            let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(self.graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        graphPath.lineWidth = 2.0
        graphPath.stroke()
    }

}
