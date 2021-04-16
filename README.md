RoundedCornerPolygon

This project demonstrates an easy way to create irregular polygons with a mixture of sharp and rounded corners:

![app screenshot](https://github.com/DuncanMC/RoundedCornerPolygon/blob/main/RoundedCornerPolygon%20app%20screenshot.png)

## The background

If you were to try to create rounded corners between line segments at arbitrary angles yourself, you'd have to deal with a fair amount of pretty complex, fussy math. A guy named David Rönnqvist on Stack Overflow wrote an execellent post explaning how to figure it out. I suggest reading [**his post**](https://stackoverflow.com/questions/20442203/uibezierpath-triangle-with-rounded-edges/20644065#20644065) to understand the problem.


Instead of doing all that hard work, though this project draws the rounded corners of polygon shapes using `CGPath`s. It takes advantage of a very powerful method in the CGMutablePath class, `addArc(tangent1End:tangent2End:radius:transform:)`. This method is not very well explained in the documentation, but it makes creating rounded corners a snap.

In practice, drawing a rounded corner between points A, B, and C is a snap. You set the current point to point A using the CGMutablePath method `move(to:)`. Then you call `addArc(tangent1End:tangent2End:radius:transform:)` with `tangent1End` = point B, and `tangent2End` being point C. You pass in the desired corner radius, and assuming the line segments AB and BC are long enough to make room for the rounded corner, that method takes care of the rest fo you. 

## The project:

The core of the project is in a file called `CustomPolygons.swift`. That file defines a struct PolygonPoint. The PolygonPoint struct looks like this:

```
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
```

To define a polygon, you create an array of `PolygonPoint` objects. and pass them to the function `buildPolygonPathFrom(points:defaultCornerRadius:)`, (described below.) Each `PolygonPoint` contains a CGPoint for the coordinates of the point, plus an `isRounded` Bool and an Optional `customCornerRadius`. If  `isRounded` is true, and you don't provide a value for `customCornerRadius`, the funnction uses the `defaultCornerRadius` value passed to it for that corner.

The function is pretty short:

```
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
```

##The App view controller and UI

The app creates a sample polygon using an array of coordinates, plus random values for isRounded and customCornerRadius. It installs the custom polygon into a simple subclass of `UIView`, `RoundedCornerPolygonView`. That class 

has a class var layerClass:

```
    // This class var causes the view's base layer to be a CAShapeLayer.
    class override var layerClass: AnyClass {
        return CAShapeLayer.self
    }
```

It also has a public var `points`, of type `[PolygonPoint]`. When you install an array of `PolygonPoint` into it's points var, it attempts to build a polygon path (using the  `buildPolygonPathFrom(points:defaultCornerRadius:)` method described above) and install it into the view's layer's path. (The view's layer is a `CAShapeLayer` thanks to the definition of `layerClass` above.)

The app's view controller builds a stack view containing an array of switches, one for each vertex in the polygon. It sets each switch to the (random) value of `isRounded` for that vertex. If the user toggles any of the switches, the app rebuilds the points array and installs it into the `RoundedCornerPolygonView`, causing it to re-draw itself.
