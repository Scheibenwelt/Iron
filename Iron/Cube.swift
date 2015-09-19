//
//  Cube.swift
//  Iron
//
//  Created by Rox Dorentus on 2015-9-19.
//  Copyright © 2015年 rubyist.today. All rights reserved.
//

import Foundation
import Metal
import GLKit

class Cube: Node {
    init(device: MTLDevice) {
        let a: Vertex = [-1, 1, 1, 1, 0, 0, 1]
        let b: Vertex = [-1, -1, 0, 0, 1, 0, 1]
        let c: Vertex = [1, -1, 0, 0, 0, 1, 1]
        let d: Vertex = [1, 1, 1, 0.1, 0.6, 0.4, 1]

        let q: Vertex = [-1, 1, -1, 1, 0, 0, 1]
        let r: Vertex = [1, 1, -1, 0, 1, 0, 1]
        let s: Vertex = [-1, -1, -1, 0, 0, 1, 1]
        let t: Vertex = [1, -1, -1, 0.1, 0.6, 0.4, 1]

        super.init(name: "Cube", vertices: [
            a, b, c, a, c, d,   // front
            r, t, s, q, r, s,   // back
            q, s, b, q, b, a,   // left
            d, c, t, d, t, r,   // right
            q, a, d, q, d, r,   // top
            b, s, t, b, t, c,   // bottom
        ], device: device)
    }

    override class func timeModifier(time: CFTimeInterval)(_ matrix: GLKMatrix4) -> GLKMatrix4 {
        var matrix = matrix

        let secsPerMove: Float = 6
        matrix = GLKMatrix4RotateX(matrix, sin(Float(time) * 2.0 * Float(M_PI) / secsPerMove))
        matrix = GLKMatrix4RotateY(matrix, sin(Float(time) * 2.0 * Float(M_PI) / secsPerMove))

        return matrix
    }
}
