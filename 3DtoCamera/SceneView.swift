//
//  SceneView.swift
//  3DtoCamera
//
//  Created by Admin on 22.05.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class SceneView: UIView {
    
    var facets = [Facet]()
    var helpFacets = [Facet]()
    var lastPoint : CGPoint!
    var vertexs = [Vertex]()
    var dist : CGPoint!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        let g = UIRotationGestureRecognizer(target: self, action: #selector(rotate(recognizer:)))
        self.addGestureRecognizer(g)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(recognizer:)))
        self.addGestureRecognizer(pinch)
    }
    
    func pinch(recognizer: UIPinchGestureRecognizer) {
        var dict = [String : CGFloat]()
        dict["difX"] = 0.0
        dict["difY"] = 0.0
        dict["difZ"] = 0.0
        dict["dist"] = recognizer.scale > 1 ? recognizer.scale : -2.0
        NotificationCenter.default.post(name: NSNotification.Name("changeCamera"), object: nil, userInfo: dict)
        self.setNeedsDisplay()
    }
    
    func rotate(recognizer: UIRotationGestureRecognizer) {
        var dict = [String : CGFloat]()
        dict["difX"] = 0.0
        dict["difY"] = 0.0
        dict["difZ"] = recognizer.rotation
        dict["dist"] = 0.0
        NotificationCenter.default.post(name: NSNotification.Name("changeCamera"), object: nil, userInfo: dict)
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let x = CGFloat(self.frame.width / 2)
        let y = CGFloat(self.frame.height * 0.65)
        var pathes = [UIBezierPath]()
        
        facets.forEach { (facet) in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: facet.p1.x + x, y: y -  facet.p1.y))
            path.addLine(to: CGPoint(x: facet.p2.x + x, y: y -  facet.p2.y))
            path.addLine(to: CGPoint(x: facet.p3.x + x, y: y -  facet.p3.y))
            pathes.append(path)
        }
        let bottom = getBottom()
        var isSeen = false
        UIColor.yellow.setFill()
        for i in 0..<pathes.count {
            if pathes[i].contains(CGPoint(x: x, y: y)) {
                if facets[i].z < 0.0 {
                    isSeen = true
                }
            }
            facets[i].color.setFill()
            pathes[i].close()
            pathes[i].fill()
            pathes[i].stroke()
        }
        
        if isSeen {
            UIColor.black.setFill()
            bottom.close()
            bottom.fill()
            bottom.stroke()
        }
        super.draw(rect)
    }
    
    func getBottom()-> UIBezierPath {
        let x = CGFloat(self.frame.width / 2)
        let y = CGFloat(self.frame.height * 0.65)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: vertexs[1].x + x, y: y - vertexs[1].y))
        for i in 2...vertexs.count-1 {
            path.addLine(to: CGPoint(x: vertexs[i].x + x, y: y - vertexs[i].y))
        }
        return path
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = (touches.first?.location(in: self))!
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newPoint = touches.first?.location(in: self)
        var dict = [String : CGFloat]()
        dict["difX"] = (newPoint?.x)! - lastPoint.x
        dict["difY"] = (newPoint?.y)! - lastPoint.y
        dict["difZ"] = 0.0
        dict["dist"] = 0.0
        NotificationCenter.default.post(name: NSNotification.Name("changeCamera"), object: nil, userInfo: dict)
        self.setNeedsDisplay()
    }
}
