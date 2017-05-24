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

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pir = Pyramide(height: 100, numberOfFacets: 5, radius: 50, cameraPos: Vertex(100,100,100))
        let help = camera.turnOverXMatrix() * camera.turnOverYMatrix() * camera.turnOverZMatrix()
        NotificationCenter.default.addObserver(self, selector: #selector(changeCamera), name: NSNotification.Name(rawValue: "changeCamera"), object: nil)
        for i in 0..<pir.vertexList.count {
            var cord = Matrix()
            cord.matrix.append([pir.vertexList[i].x])
            cord.matrix.append([pir.vertexList[i].y])
            cord.matrix.append([pir.vertexList[i].z])
            let res = help * cord
            pir.vertexList[i].x = res.matrix[0][0]
            pir.vertexList[i].y = res.matrix[1][0]
            pir.vertexList[i].z = res.matrix[2][0]
        }
        
        var helpM = Matrix()
        helpM.matrix.append([camera.cameraPos.x])
        helpM.matrix.append([camera.cameraPos.y])
        helpM.matrix.append([camera.cameraPos.z])
        let res = help * helpM
        camera.cameraPos.x = res.matrix[0][0]
        camera.cameraPos.y = res.matrix[1][0]
        camera.cameraPos.z = res.matrix[2][0]
        
       sceneView.vertexs = pir.vertexList
       sceneView.facets = pir.getFacets(cameraPos: camera.cameraPos)
       sceneView.setNeedsDisplay()
        self.view.setNeedsDisplay()
    }
    
    func changeCamera( notif: Notification) {
        let pir = Pyramide(height: 100, numberOfFacets: 5, radius: 50, cameraPos: Vertex(100,100,100))
        let dict = notif.userInfo as! [String : CGFloat]
        camera.turnY += dict["difX"]! / 10000.0
        camera.turnX += dict["difY"]! / 10000.0
        camera.turnZ -= dict["difZ"]! / 75.0
        camera.dist += dict["dist"]! / 150.0
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
        
        var helpM = Matrix()
        helpM.matrix.append([camera.cameraPos.x])
        helpM.matrix.append([camera.cameraPos.y])
        helpM.matrix.append([camera.cameraPos.z])
        let res = help * helpM
        camera.cameraPos.x = res.matrix[0][0]
        camera.cameraPos.y = res.matrix[1][0]
        camera.cameraPos.z = res.matrix[2][0]
        
        sceneView.vertexs = pir.vertexList
        sceneView.facets = pir.getFacets(cameraPos: camera.cameraPos)
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
        return v1.x * v2.x + v1.y * v2.y + v1.z * v1.z
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
    
    var nx: CGFloat!
    var ny: CGFloat!
    var nz: CGFloat!
    
    public init(_ ver1: Vertex, _ ver2: Vertex, _ ver3: Vertex,z: CGFloat,cameraPos : Vertex) {
        self.p1 = CGPoint(x: ver1.x, y: ver1.y)
        self.p2 = CGPoint(x: ver2.x, y: ver2.y)
        self.p3 = CGPoint(x: ver3.x, y: ver3.y)
        self.z = z
        
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
        
        let cameraVector = Vertex.getVector(fromVertex: cameraPos, toVertex: center)
        let normal = Vertex(nx,ny,nz)
        let intensity = abs((cameraVector * normal ) / (cameraVector.getScalar() *  normal.getScalar()))
        
        self.color = UIColor(colorLiteralRed: Float(255 * intensity), green: 0.0, blue: 0.0, alpha: 1.0)
    }
}

