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

    var light = Vertex(0,600,0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(changeCamera), name: NSNotification.Name(rawValue: "changeCamera"), object: nil)
        let a = Facet(Vertex(0,0,-100), Vertex(0,100,0), Vertex(100,0,0), z: 12.3, cameraPos: light, n: 2)
        recalculate()
        var list = [Vertex]()
        let n  = 500
        let r = CGFloat(1000.0)
        for i in 0..<n {
            let x = CGFloat(r * sin(CGFloat(i) * 2.0 * CGFloat.pi / CGFloat(n) ))
            let z = CGFloat(r * cos(CGFloat(i) * 2.0 * CGFloat.pi / CGFloat(n) ))
            list.append(Vertex(x,0.0,z))
        }
        var i = 0
      /*  Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
            if i == n-1 {
                i = 0
            }
            self.light.x = list[i].x
            self.light.z = list[i].z
            self.recalculate()
            i += 1
        }*/
        
    
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
        let pirHelp = Pyramide(height: 100, numberOfFacets: 10, radius: 50)
        let pir = Pyramide(height: 100, numberOfFacets: 10, radius: 50)
        
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


struct  Line {
    var start: CGPoint
    var end: CGPoint
    
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
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
        
        let b1 = ver2.x - ver1.x
        let b2 = ver2.y - ver1.y
        let b3 = ver2.z - ver1.z
        
        let c1 = ver3.x - ver1.x
        let c2 = ver3.y - ver1.y
        let c3 = ver3.z - ver1.z
        
        nx = b2 * c3 - b3 * c2
        ny = b2 * c1 - b1 * c3
        nz = b1 * c2 - b2 * c1
        
        let helpVertex = Vertex((ver2.x + ver3.x) / 2.0, (ver2.y + ver3.y) / 2.0, (ver2.z + ver3.z) / 2.0)
        let center = Vertex( (helpVertex.x + ver1.x) / 2.0, (helpVertex.y + ver1.y) / 2.0, (helpVertex.z + ver1.z) / 2.0)
        
        let cameraVector = Vertex.getVector(fromVertex: center, toVertex: cameraPos)
        let normal = Vertex( -nx,-ny,-nz)
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

