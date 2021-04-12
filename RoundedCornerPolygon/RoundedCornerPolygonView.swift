//
//  RoundedCornerPolygonView.swift
//  RoundedCornerPolygon
//
//  Created by Duncan Champney on 4/11/21.
//

import UIKit

struct PolygonPoint {
    let point: CGPoint
    let isRounded: Bool
}
/**
 This class draws a closed polygon with either sharp or rounded corners.
 It uses an array of PolygonPoint structs,

 - Parameter `showPoints`: if true it draws the vertexes as small squares.
 - Parameter `points` determines which points to draw. `points` must contain at least 3 points
 - Parameter `cornerRadius`: determines the corner radius for corners that should be rounded.
*/
class RoundedCornerPolygonView: UIView {


    ///Determines if we draw the corner points for our polygon (defaults to true)
    public var showPoints: Bool = true {
        didSet {
            drawPoints()
        }
    }
    var cornerRadius: CGFloat = 15 {
        didSet {
            buildPolygon()
        }
    }

    public var points = [PolygonPoint]() {
        didSet {
            guard points.count >= 3 else {
                print("Polygons must have at least 3 sides.")
                return
            }
            buildPolygon()
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

    /// Rebuild our polygon's path and install it into our shape layer.
    private func buildPolygon() {
        guard points.count >= 3 else { return }
        drawPoints() // Draw each vertex into another layer if requested.
        let first = points.first!
        let last = points.last!

        let path = CGMutablePath()

        // Start at the midpoint between the first and last vertex in our polygon
        // (Since that will always be in the middle of a straight line segment.)
        let midpoint = CGPoint(x: (first.point.x + last.point.x) / 2, y: (first.point.y + last.point.y) / 2 )
        path.move(to: midpoint)

        //Loop through the points in our polygon.
        for (index, point) in points.enumerated() {
            // If this vertex is not rounded, just draw a line to it.
            if !point.isRounded {
                path.addLine(to: point.point)
            } else {
                //Draw an arc from the previous vertex (the current point), around this vertex, and pointing to the next
                let nextIndex = (index+1) % points.count
                let nextPoint = points[nextIndex]
                path.addArc(tangent1End: point.point, tangent2End: nextPoint.point, radius: cornerRadius)
            }
        }

        // Close the path by drawing a line from the last vertex/corner to the midpoint between the last and first point
        path.addLine(to: midpoint)

        // install the path into our (shape) layer
        let layer = self.layer as! CAShapeLayer
        layer.path = path
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
