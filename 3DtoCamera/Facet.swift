//
//  Facet.swift
//  3DtoCamera
//
//  Created by Admin on 09.08.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import UIKit

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
    //normale coordinates
    var nx: CGFloat!
    var ny: CGFloat!
    var nz: CGFloat!
    
    public init(_ ver1: Vertex, _ ver2: Vertex, _ ver3: Vertex,z: CGFloat,cameraPos : Vertex, n: Int) {
        self.p1 = CGPoint(x: ver1.x, y: ver1.y)
        self.p2 = CGPoint(x: ver2.x, y: ver2.y)
        self.p3 = CGPoint(x: ver3.x, y: ver3.y)
        self.z = z
        number = n
        //calculte normales in order to find out the intensity of light for each facet
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
        
        let intensity =  (cameraVector * normal) / (cameraVector.getScalar() * normal.getScalar())
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
