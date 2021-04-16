//
//  CustomPolygons.swift
//  TabBarController
//
//  Created by Duncan Champney on 4/14/21.
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
    let midpoint = CGPoint(x: (first.point.x + last.point.x) / 2, y: (first.point.y + last.point.y) / 2)
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
