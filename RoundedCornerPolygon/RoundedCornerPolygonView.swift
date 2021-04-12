//
//  RoundedCornerPolygonView.swift
//  RoundedCornerPolygon
//
//  Created by Duncan Champney on 4/11/21.
//

import UIKit
/// A struct describing a single vertex in a polygon. Used in building polygon paths with a mixture of rounded an sharp-edged vertexes.
public struct PolygonPoint {
    let point: CGPoint
    let isRounded: Bool
    let customCornerRadius: CGFloat?
    init(point: CGPoint, isRounded: Bool, customCornerRadius: CGFloat? = nil) {
        self.point = point
        self.isRounded = isRounded
        self.customCornerRadius = customCornerRadius
    }

    init(previousPoint: PolygonPoint, isRounded: Bool) {
        self.init(point: previousPoint.point, isRounded: isRounded, customCornerRadius: previousPoint.customCornerRadius)
    }
}

/**
 A function to create and return a`CGPath` of a polygon from an array of `PolygonPoint`s. For each `PolygonPoint`, if its `isRounded` property is true, that point's vertex is rounded in the resulsting path.
 - Parameter points: The array of `PolygonPoint`s to use in buliding the polygon.
 - Parameter  defaultCornerRadius: a default corner radius to use for curved corners that do not specify a custom corner radius.
 */
public func buildPolygonPathFrom(points: [PolygonPoint], defaultCornerRadius: CGFloat) -> CGPath {
    guard points.count >= 3 else { return CGPath(rect: CGRect.zero, transform: nil) }
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
            path.addArc(tangent1End: point.point, tangent2End: nextPoint.point, radius: point.customCornerRadius ?? defaultCornerRadius)
        }
    }

    // Close the path by drawing a line from the last vertex/corner to the midpoint between the last and first point
    path.addLine(to: midpoint)

    return path
}
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

    var cornerRadius: CGFloat = 15 {
        didSet {
            drawPoints() // Draw each vertex into another layer if requested.

            // build and install the polygon path into our (shape) layer
            let layer = self.layer as! CAShapeLayer
            layer.path = buildPolygonPathFrom(points: points, defaultCornerRadius: cornerRadius)
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
            layer.path = buildPolygonPathFrom(points: points, defaultCornerRadius: cornerRadius)
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
