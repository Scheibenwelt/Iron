//
//  Triangle.swift
//  Iron
//
//  Created by Rox Dorentus on 2015-9-19.
//  Copyright © 2015年 rubyist.today. All rights reserved.
//

import Foundation
import Metal

class Triangle: Node {
    init(device: MTLDevice) {
        super.init(name: "Triangle", vertices: [[0, 1, 0, 1, 0, 0, 1], [-1, -1, 0, 0, 1, 0, 1], [1, -1, 0, 0, 0, 1, 1]], device: device)
    }
}
