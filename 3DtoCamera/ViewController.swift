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
    //let pir = Pyramide!
     let camera = Camera()
    var n = 15
    var height: CGFloat = 100.0
    var radius: CGFloat = 100.0
    var light = Vertex(1000,1000,1000)
    var timer: Timer!
    var radiusSlider : UISlider!
    var heightSlider : UISlider!
    @IBOutlet weak var facetsLabel: UILabel!
    var list = [Vertex]()
    var i = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(changeCamera), name: NSNotification.Name(rawValue: "changeCamera"), object: nil)
        recalculate()
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
        print("-------------") ; print("-------------")
        
        sceneView.setNeedsDisplay()
        self.view.setNeedsDisplay()
    }
}

struct Vertex {
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var z: CGFloat = 0.0
    
    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    static func * (v1: Vertex, v2: Vertex) -> CGFloat {
        return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
    }
    
    func getScalar() -> CGFloat {
        return CGFloat(sqrtf(Float(x*x + y*y + z*z)))
    }
    
    static func getVector(fromVertex v1: Vertex, toVertex v2: Vertex) -> Vertex {
        return Vertex(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z)
    }
}

struct Facet {
    var p1: CGPoint
    var p2: CGPoint
    var p3: CGPoint
    var color: UIColor
    var z : CGFloat
    var number: Int
    
    var nx: CGFloat!
    var ny: CGFloat!
    var nz: CGFloat!
    
    public init(_ ver1: Vertex, _ ver2: Vertex, _ ver3: Vertex,z: CGFloat,cameraPos : Vertex, n: Int) {
        self.p1 = CGPoint(x: ver1.x, y: ver1.y)
        self.p2 = CGPoint(x: ver2.x, y: ver2.y)
        self.p3 = CGPoint(x: ver3.x, y: ver3.y)
        self.z = z
        number = n
        
        let a2 = ver2.x - ver1.x
        let b2 = ver2.y - ver1.y
        let c2 = ver2.z - ver1.z
        
        let a3 = ver3.x - ver1.x
        let b3 = ver3.y - ver1.y
        let c3 = ver3.z - ver1.z
        
        nx = b2 * c3 - b3 * c2
        ny = a3 * c2 - a2 * c3
        nz = a2 * b3 - b2 * a3
    
        let helpVertex = Vertex((ver2.x + ver3.x) / 2.0, (ver2.y + ver3.y) / 2.0, (ver2.z + ver3.z) / 2.0)
        let center = Vertex( (helpVertex.x + ver1.x) / 2.0, (helpVertex.y + ver1.y) / 2.0, (helpVertex.z + ver1.z) / 2.0)
        
        let cameraVector = Vertex.getVector(fromVertex: center, toVertex: cameraPos)
        var normal = Vertex(nx,ny,nz)
        if ny < 0.0 {
            normal = Vertex(-nx,-ny,-nz)
        }

        let intensity =  (cameraVector * normal) / (cameraVector.getScalar() *  normal.getScalar())
        print(intensity)
        
        self.color = UIColor(colorLiteralRed: intensity > 0.0 ? Float(intensity) : 0.0,  green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    public init(_ ver1: Vertex, _ ver2: Vertex, _ ver3: Vertex,z: CGFloat, n: Int, color : UIColor) {
        self.p1 = CGPoint(x: ver1.x, y: ver1.y)
        self.p2 = CGPoint(x: ver2.x, y: ver2.y)
        self.p3 = CGPoint(x: ver3.x, y: ver3.y)
        self.z = z
        number = n
        self.color = color
    }

}

