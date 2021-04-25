//
//  ViewController.swift
//  RoundedCornerPolygon
//
//  Created by Duncan Champney on 4/11/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var polygonView: RoundedCornerPolygonView!

    @IBOutlet weak var stackView: UIStackView!

    /// An array of UISwitches which will control which corners of our poygon are rounded
    var polygonSwitches = [UISwitch]()



    var polygonPoints = [PolygonPoint]()

    override func viewDidLoad() {
        super.viewDidLoad()

        #if false
        polygonPoints = roundedRectCorners( rect: polygonView.bounds.insetBy(dx: 20.0, dy: 20.0),
                                            byRoundingCorners: [.allCorners],
                                            cornerRadius: 30)
        #else
        /// The vertexes of our polgon.
         polygonPoints = [
            PolygonPoint(point: CGPoint(x:  30, y:  20), isRounded: Bool.random(), customCornerRadius: CGFloat.random(in: 10...20)),

            // point 1
            PolygonPoint(point: CGPoint(x:  80, y:  60), isRounded: Bool.random(), customCornerRadius: CGFloat.random(in: 10...15)),

            // point 2
            PolygonPoint(point: CGPoint(x:  30, y:  90), isRounded: Bool.random(), customCornerRadius: CGFloat.random(in: 10...30)),

            // point 3
            PolygonPoint(point: CGPoint(x:  60, y: 170), isRounded: Bool.random(), customCornerRadius: CGFloat.random(in: 10...20)),

            // point 4
            PolygonPoint(point: CGPoint(x: 100, y: 130), isRounded: Bool.random(), customCornerRadius: CGFloat.random(in: 10...20)),

            // point 5
            PolygonPoint(point: CGPoint(x: 130, y: 160), isRounded: Bool.random(), customCornerRadius: CGFloat.random(in: 10...20)),

            // point 6
            PolygonPoint(point: CGPoint(x: 190, y:  90), isRounded: Bool.random(), customCornerRadius: CGFloat.random(in: 10...20)),

            // point 7
            PolygonPoint(point: CGPoint(x: 120, y:  80), isRounded: Bool.random(), customCornerRadius: CGFloat.random(in: 10...20)),

            // point 8
            PolygonPoint(point: CGPoint(x: 140, y:  20), isRounded: Bool.random(), customCornerRadius: CGFloat.random(in: 10...20)),
        ]
        #endif

        // Loop through each of our `PolygonPoint`s
        for (index, point) in polygonPoints.enumerated() {

            //Create a horizontal stack view for this point (to contain a label and switch)
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.spacing = 10

            //Create a label for this point's switch
            let label = UILabel()
            label.text = "Round corner \(index)"
            hStack.addArrangedSubview(label)

            // Add the switch to the horizontal stack view.
            let aSwitch = UISwitch()

            // Add an action which rebuilds the PolygonPoints for our RoundedCornerPolygonView
            let action = UIAction(title: "Refresh") { (_) in
                self.buildPolygonPoints()
            }
            aSwitch.addAction( action, for: .valueChanged)
            aSwitch.isOn = point.isRounded

            // Add the switch to the horizontal stack for this point
            hStack.addArrangedSubview(aSwitch)

            // Add the switch to an array of switches for each point so we can query their states
            polygonSwitches.append(aSwitch)


            //Add this point's label and switch to the vertical stackview for the window.
            stackView.addArrangedSubview(hStack)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        buildPolygonPoints() //Populate our polygonPoints array
    }

    func buildPolygonPoints() {

        let newPolygonPoints = zip(polygonPoints, polygonSwitches)
            .map {
                PolygonPoint(previousPoint: $0, isRounded: $1.isOn )
            }
        polygonPoints = newPolygonPoints
        // Install the array of 'PolygonPoint's into the RoundedCornerPolygonView
        // That causes the RoundedCornerPolygonView to draw itself.
        polygonView.points = polygonPoints
    }

}

