//
//  ViewController.swift
//  3DtoCamera
//
//  Created by Admin on 16.05.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import GLKit

extension Notification.Name {
    static let changeCamera = Notification.Name(rawValue: "changeCamera")
}

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: SceneView!
    @IBOutlet weak var facetsLabel: UILabel!
    
    let camera = Camera()
    var n = 15
    var height: CGFloat = 100.0
    var radius: CGFloat = 100.0
    var light = Vertex(1000,1000,1000)
    var timer: Timer!
    var radiusSlider : UISlider!
    var heightSlider : UISlider!

    var list = [Vertex]() // trajectory for light's moving
    var i = 0 // light's moving iterator variable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(changeCamera), name: NSNotification.Name(rawValue: "changeCamera"), object: nil)
        recalculate()
        initialSetup()
        setLight()
    }
    
    func initialSetup() {
        radiusSlider = UISlider(frame: CGRect(x: 15.0, y: view.frame.height - 40.0, width: self.view.frame.width - 20.0, height: 20.0))
        radiusSlider.minimumValue = 10
        radiusSlider.tintColor = UIColor.red
        radiusSlider.maximumValue = 200
        radiusSlider.value = Float(radius)
        radiusSlider.addTarget(self, action: #selector(radOrHeightChanged), for: .valueChanged)
        radiusSlider.tag = 1
        let tmpW = view.frame.width * 1.3
        heightSlider = UISlider(frame: CGRect(x: 20.0 - tmpW / 2.0, y: view.frame.height - 40.0 - tmpW / 2.0 , width: tmpW, height: 20.0))
        heightSlider.minimumValue = 10
        heightSlider.tintColor = UIColor.red
        heightSlider.maximumValue = 250
        heightSlider.value = Float(height)
        heightSlider.tag = 2
        heightSlider.transform = heightSlider.transform.rotated(by: ( CGFloat(-1 * Double.pi / 2.0) ))
        heightSlider.addTarget(self, action: #selector(radOrHeightChanged), for: .valueChanged)
        view.addSubview(radiusSlider)
        view.addSubview(heightSlider)
    }
    
    func setLight() {
        let n  = 500
        let r = CGFloat(1000.0)
        for i in 0..<n {
            let x = CGFloat(r * sin(CGFloat(i) * 2.0 * CGFloat.pi / CGFloat(n) ))
            let z = CGFloat(r * cos(CGFloat(i) * 2.0 * CGFloat.pi / CGFloat(n) ))
            list.append(Vertex(x,0.0,z))
        }
    }
    
    @IBAction func numberOfFacetsChanged(_ sender: UIStepper) {
        self.n = Int(sender.value)
        facetsLabel.text = "Number of facets (curr =" + String(n) + ")"
        recalculate()
    }
    
    @IBAction func lightStopsOrStarts(_ sender: UISwitch) {
        if sender.isOn {
            startTimer()
        } else {
            timer.invalidate()
        }
    }
    
    func radOrHeightChanged(_ sender: UISlider) {
        if sender.tag == 1 {
            self.radius = CGFloat(sender.value)
        } else {
            self.height = CGFloat(sender.value)
        }
        recalculate()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
    }
    
    func runTimer() {
        if i == 499 {
            i = 0
        }
        self.light.x = list[i].x
        self.light.z = list[i].z
        self.recalculate()
        i += 1
    }
    
    func changeCamera( notif: Notification) {
        let dict = notif.userInfo as! [String : CGFloat]
        camera.turnY += dict["difX"]! / 10000.0
        camera.turnX += dict["difY"]! / 10000.0
        camera.turnZ -= dict["difZ"]! / 75.0
        camera.dist += dict["dist"]! / 150.0
        recalculate()
    }
    
    func recalculate() {
        let pirHelp = Pyramide(height: self.height, numberOfFacets: self.n, radius: self.radius)
        let pir = Pyramide(height: self.height, numberOfFacets: self.n, radius: self.radius)
        let help = camera.turnOverXMatrix() * camera.turnOverYMatrix() * camera.turnOverZMatrix()
        for i in 0..<pir.vertexList.count {
            var cord = Matrix()
            cord.matrix.append([pir.vertexList[i].x])
            cord.matrix.append([pir.vertexList[i].y])
            cord.matrix.append([pir.vertexList[i].z])
            let res = help * cord
            pir.vertexList[i].x = res.matrix[0][0] * camera.dist
            pir.vertexList[i].y = res.matrix[1][0] * camera.dist
            pir.vertexList[i].z = res.matrix[2][0] * camera.dist
        }
        sceneView.vertexs = pir.vertexList
        sceneView.facets = pir.getFacets(withColors: pirHelp.getFacetsColors(cameraPos: light))
        sceneView.setNeedsDisplay()
        self.view.setNeedsDisplay()
    }
}


