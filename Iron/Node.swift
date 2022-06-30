//
//  Node.swift
//  Iron
//
//  Created by Rox Dorentus on 2015-9-19.
//  Copyright © 2015年 rubyist.today. All rights reserved.
//

import Metal
import QuartzCore.CAMetalLayer
import GLKit

extension GLKMatrix4 {
    var raw: [Float] {
        return [
            m00, m01, m02, m03,
            m10, m11, m12, m13,
            m20, m21, m22, m23,
            m30, m31, m32, m33,
        ]
    }
}

class Node {
    let name: String
    let vertexCount: Int
    let vertexBuffer: MTLBuffer
    let device: MTLDevice

    var position: (x: Float, y: Float, z: Float) = (0, 0, 0)
    var rotation: (x: Float, y: Float, z: Float) = (0, 0, 0)
    var scale: (x: Float, y: Float, z: Float) = (1, 1, 1)

    var time: CFTimeInterval = 0

    class func timeModifier(_ time: CFTimeInterval, _ matrix: GLKMatrix4) -> GLKMatrix4 {
        return matrix
    }

    var modelMatrix: GLKMatrix4 {
        var matrix = GLKMatrix4Identity
        matrix = GLKMatrix4Translate(matrix, position.x, position.y, position.z)
        matrix = GLKMatrix4RotateX(matrix, rotation.x)
        matrix = GLKMatrix4RotateY(matrix, rotation.y)
        matrix = GLKMatrix4RotateZ(matrix, rotation.z)
        matrix = GLKMatrix4Scale(matrix, scale.x, scale.y, scale.z)

        return matrix
    }

    var modelMatrixNow: GLKMatrix4 {
        return Self.timeModifier(time, modelMatrix)
    }

    init(name: String, vertices: Array<Vertex>, device: MTLDevice) {
        var vertexData = vertices.map { $0.floatBuffer }.reduce([], +)

        self.name = name
        self.vertexCount = vertices.count
        self.device = device
        self.vertexBuffer = device.makeBuffer(bytes: &vertexData, length: vertexData.count * MemoryLayout.size(ofValue: vertexData[0]), options: [])!
    }

    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: GLKMatrix4, projectionMatrix: GLKMatrix4, clearColor: MTLClearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setCullMode(.front)

        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        let modelMatrix = GLKMatrix4Multiply(parentModelViewMatrix, modelMatrixNow)
        var modalMatrixRaw = modelMatrix.raw + projectionMatrix.raw
        let uniformBuffer = device.makeBuffer(bytes: &modalMatrixRaw, length: modalMatrixRaw.count * MemoryLayout.size(ofValue: modalMatrixRaw[0]), options: [])
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount / 3)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
