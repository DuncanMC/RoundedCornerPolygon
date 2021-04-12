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

    /// The vertexes of our polgon.
    var cgPoints = [CGPoint(x:  30, y:  20), //point 0
                    CGPoint(x:  80, y:  60), //point 1
                    CGPoint(x:  10, y: 100), //point 2
                    CGPoint(x:  60, y: 170), //point 3
                    CGPoint(x: 100, y: 120), //point 4
                    CGPoint(x: 150, y: 160), //point 5
                    CGPoint(x: 190, y:  90), //point 6
                    CGPoint(x: 120, y:  80), //point 7
                    CGPoint(x: 140, y:  20), //point 8
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        var polygonPoints = [PolygonPoint]()

        // Loop through each of our cgPoints
        for (index, point) in cgPoints.enumerated() {

            //Create a horizontal stack view for this point (to contain a label and switch
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
            aSwitch.isOn = true

            // Add the switch to the horizontal stack for this point
            hStack.addArrangedSubview(aSwitch)

            // Add the switch to an array of switches for each point so we can query their states
            polygonSwitches.append(aSwitch)

            // Create a PolygonPoint struct for this point and add it to our array
            polygonPoints.append(PolygonPoint(point: point, isRounded: false))

            //Add this point's label and switch to the vertical stackview for the window.
            stackView.addArrangedSubview(hStack)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        buildPolygonPoints() //Populate our polygonPoints array
    }

    func buildPolygonPoints() {
        let polygonPoints = zip(cgPoints, polygonSwitches)
            .map {
                PolygonPoint(point: $0, isRounded: $1.isOn )
            }
        // Install the array of 'PolygonPoint's into the RoundedCornerPolygonView
        // That causes the RoundedCornerPolygonView to draw itself.
        polygonView.points = polygonPoints
    }

}

