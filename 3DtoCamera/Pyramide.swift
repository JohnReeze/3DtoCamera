//
//  Pyramide.swift
//  3DtoCamera
//
//  Created by Admin on 22.05.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
class Const: NSObject {
    static var colors = [UIColor]()
}

class Pyramide: NSObject {
    var h : CGFloat = 200.0 //height
    var n : Int = 8 // number of facets
    var r : CGFloat = 100.0 // radius
    
    var vertexList = [Vertex]() // all vertexes
    var colors = [UIColor]() // colors for each vertex
    
    public init(height: CGFloat, numberOfFacets n: Int, radius: CGFloat) {
        super.init()
        h = height
        self.n = n
        r = radius
        vertexList.append(Vertex(0.0, h, 0.0))
        // calculation of each vertex
        for i in 0..<n {
            let x = CGFloat(r * sin(CGFloat(i) * 2.0 * CGFloat.pi / CGFloat(n) ))
            let z = CGFloat(r * cos(CGFloat(i) * 2.0 * CGFloat.pi / CGFloat(n) ))
            vertexList.append(Vertex(x, 0.0, z))
        }
    }
    
    // getting colors for each 
    func getFacetsColors(cameraPos: Vertex) -> [UIColor] {
        var colors = [UIColor]()
        for i in 1..<vertexList.count {
            let f = vertexList[0]
            let s = vertexList[i]
            var t : Vertex
            var max: CGFloat
            if i < vertexList.count - 1 {
                t = vertexList[i+1]
                max = ((vertexList[i].z + vertexList[i+1].z) / 2.0 + vertexList[0].z) / 2.0
            } else {
                t = vertexList[1]
                max = ((vertexList[i].z + vertexList[1].z) / 2.0 + vertexList[0].z) / 2.0
            }
            colors.append(Facet(f,s,t, z: max, cameraPos: cameraPos,n: i).color)
        }
        return colors
    }
    
    func getFacets(withColors colors:[UIColor]) -> [Facet] {
        var tmp = [Facet]()
        
        for i in 1..<vertexList.count {
            let f = vertexList[0]
            let s = vertexList[i]
            var t : Vertex
            var max: CGFloat
            if i < vertexList.count - 1 {
                t = vertexList[i+1]
                max = ((vertexList[i].z + vertexList[i+1].z) / 2.0 + vertexList[0].z) / 2.0
            } else {
                t = vertexList[1]
                max = ((vertexList[i].z + vertexList[1].z) / 2.0 + vertexList[0].z) / 2.0
            }
            tmp.append(Facet(f,s,t, z: max,n: i,color: colors[i-1]))
        }
        tmp.sort { (f1, f2) -> Bool in
            return f1.z < f2.z
        }
        return tmp
    }
    
    func maxOf(_ a : CGFloat, _ b : CGFloat) -> CGFloat {
        return a > b ? a : b
    }
    
}
