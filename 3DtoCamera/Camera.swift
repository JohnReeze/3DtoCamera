//
//  Camera.swift
//  3DtoCamera
//
//  Created by Admin on 23.05.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class Camera: NSObject {
    var x : CGFloat = 0.0
    var y : CGFloat = 0.0
    var z : CGFloat = 0.0
    
    var cameraPos = Vertex(100,100,100)
    
    var turnX : CGFloat {
        get {
            return self.x
        }
        set (newValue) {
            if newValue < 1.0  && newValue > 0.0 {
                self.x = newValue
            } else {
                self.x = 0
            }
        }
    }
    
    var turnY : CGFloat {
        get {
            return self.y
        }
        set (newValue) {
            if newValue < 1.0  && newValue > 0.0 {
                self.y = newValue
            } else {
                self.y = 0
            }
        }
    }
    
    var turnZ : CGFloat {
        get {
            return self.z
        }
        set (newValue) {
            if newValue < 1.0  && newValue > 0.0 {
                self.z = newValue
            } else {
                self.z = 0
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    
    var d : CGFloat = 1.0
    var dist: CGFloat {
    get {
        return self.d
    }
    set (newValue) {
        if newValue < 5.0  && newValue > 0.0 {
            self.d = newValue
        } else {
            self.d = 0.0
            }
        }
    }
    
    func turnOverXMatrix() -> Matrix {
        var tmp = Matrix()
        let first : [CGFloat] = [ 1.0 ,0.0, 0.0]
        let second : [CGFloat] = [ 0.0 , cos(turnX * 2 * CGFloat.pi ), -1 *  (sin(turnX * 2 * CGFloat.pi))]
        let thrid : [CGFloat] = [ 0.0, sin(turnX * 2 * CGFloat.pi) , cos(turnX * 2 * CGFloat.pi )]
        tmp.matrix.append(first)
        tmp.matrix.append(second)
        tmp.matrix.append(thrid)
        return tmp
    }
    
    func turnOverYMatrix() -> Matrix {
        var tmp = Matrix()
        let first : [CGFloat] = [ cos(turnY * 2 * CGFloat.pi ) ,0.0, sin(turnY * 2 * CGFloat.pi)]
        let second : [CGFloat] = [ 0.0 , 1.0, 0.0 ]
        let thrid : [CGFloat] = [ -1 *  (sin(turnY * 2 * CGFloat.pi)), 0.0 , cos(turnY * 2 * CGFloat.pi )]
        tmp.matrix.append(first)
        tmp.matrix.append(second)
        tmp.matrix.append(thrid)
        return tmp
    }
    
    func turnOverZMatrix() -> Matrix {
        var tmp = Matrix()
        let first : [CGFloat] = [ cos(turnZ * 2 * CGFloat.pi ) ,-1 * sin(turnZ * 2 * CGFloat.pi), 0.0]
        let second : [CGFloat] = [ sin(turnZ * 2 * CGFloat.pi) , cos(turnZ * 2 * CGFloat.pi ),  0.0]
        let thrid : [CGFloat] = [ 0.0, 0.0, 1.0 ]
        tmp.matrix.append(first)
        tmp.matrix.append(second)
        tmp.matrix.append(thrid)
        return tmp
    }
}

struct Matrix {
    var matrix = [[CGFloat]]()
    
    static func * (left: Matrix, right: Matrix) -> Matrix {
        var tmp = Matrix()
        var help = [CGFloat]()
        for _ in 0..<right.matrix[0].count {
            help.append(0.0)
        }
        tmp.matrix.append(help)
        tmp.matrix.append(help)
        tmp.matrix.append(help)
        for i in 0..<left.matrix.count {
            for j in 0..<right.matrix[0].count {
                for k in 0..<right.matrix.count {
                    tmp.matrix[i][j] += left.matrix[i][k] * right.matrix[k][j]
                }
            }
        }
        return tmp
    }
}