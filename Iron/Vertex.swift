//
//  Vertex.swift
//  Iron
//
//  Created by Rox Dorentus on 2015-9-19.
//  Copyright © 2015年 rubyist.today. All rights reserved.
//

import Foundation

struct Vertex {
    let x, y, z: Float
    let r, g, b, a: Float

    var floatBuffer: [Float] {
        return [x, y, z, r, g, b, a]
    }
}

extension Vertex: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Float...) {
        guard elements.count == 7 else { fatalError("invalid Vertex data") }

        self.init(x: elements[0], y: elements[1], z: elements[2], r: elements[3], g: elements[4], b: elements[5], a: elements[6])
    }
}
