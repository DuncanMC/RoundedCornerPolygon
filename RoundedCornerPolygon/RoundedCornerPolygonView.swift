//
//  RoundedCornerPolygonView.swift
//  RoundedCornerPolygon
//
//  Created by Duncan Champney on 4/11/21.
//

import UIKit
/**
 This class draws a closed polygon with either sharp or rounded corners.
 It uses an array of PolygonPoint structs,

 - var `showPoints`: if true it draws the vertexes as small squares.
 - var `cornerRadius`: determines the corner radius for corners that should be rounded.
 - var `points`: determines which points to draw. `points` must contain at least 3 points
*/
class RoundedCornerPolygonView: UIView {

    ///Determines if we draw the corner points for our polygon (defaults to true)
    public var showPoints: Bool = true {
        didSet {
            drawPoints()
        }
    }

    public var animatePathChanges: Bool = true

    func updatePath() {
        guard let layer = self.layer as? CAShapeLayer else { return }
        let newPath = buildPolygonPathFrom(points: points, defaultCornerRadius: cornerRadius)
        if !animatePathChanges || layer.path == nil {
            layer.path = newPath
        } else {
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = 0.3
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.fromValue = layer.path
            animation.toValue = newPath
            layer.add(animation, forKey: nil)
            DispatchQueue.main.async {
                layer.path = newPath
            }
        }
    }
    var cornerRadius: CGFloat = 15 {
        didSet {
            drawPoints() // Draw each vertex into another layer if requested.

            // build and install the polygon path into our (shape) layer
            let layer = self.layer as! CAShapeLayer
            updatePath()
        }
    }

    public var points = [PolygonPoint]() {
        didSet {
            guard points.count >= 3 else {
                print("Polygons must have at least 3 sides.")
                return
            }
            drawPoints() // Draw each vertex into another layer if requested.

            // build and install the polygon path into our (shape) layer
            let layer = self.layer as! CAShapeLayer
            updatePath()
        }
    }

    private var pointsLayer = CAShapeLayer()

    // This class var causes the view's base layer to be a CAShapeLayer.
    class override var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    /// if showPoints == true, draw the vertexes of our polygon into a layer `pointsLayer`. Else clear `pointsLayer`.
    private func drawPoints() {
        guard showPoints, points.count > 3 else {
            pointsLayer.path = nil
            return
        }
        let pointsPath = CGMutablePath()
        for point in points {
            pointsPath.addRect(CGRect(origin: point.point, size: .zero).inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)))
        }
        pointsLayer.path = pointsPath
    }


    // Use didMoveToSuperview to do our inital setup
    override func didMoveToSuperview() {
        let layer = self.layer as! CAShapeLayer

        // Draw the shape in dark blue
        layer.strokeColor = UIColor(red: 0, green: 0, blue: 0.7, alpha: 1).cgColor

        // Fill our path with a nearly transparent cyan
        layer.fillColor = UIColor(red: 0, green: 1, blue: 1, alpha: 0.1).cgColor
        layer.lineWidth = 1

        // Set up the points layer
        pointsLayer.frame = self.layer.bounds

        // Draw the points in partly transparent dark green
        pointsLayer.fillColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 0.5).cgColor

        // Add the points layer to the view's main (shape) layer
        self.layer.addSublayer(pointsLayer)
    }
}
