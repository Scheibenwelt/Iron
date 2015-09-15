//
//  ViewController.swift
//  Iron
//
//  Created by Rox Dorentus on 2015-9-15.
//  Copyright © 2015年 rubyist.today. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {
    lazy var device: MTLDevice = {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("unable to create device") }
        return device
    }()
    lazy var metalLayer: CAMetalLayer = {
        let metalLayer = CAMetalLayer()
        metalLayer.device = self.device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = self.view.layer.frame

        self.view.layer.addSublayer(metalLayer)

        return metalLayer
    }()
    lazy var vertexBuffer: MTLBuffer = {
        let vertexData: [Float] = [
            0.0,   1.0, 0.0,
            -1.0, -1.0, 0.0,
            1.0,  -1.0, 0.0
        ]
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        return self.device.newBufferWithBytes(vertexData, length: dataSize, options: [])
    }()
    lazy var pipelineState: MTLRenderPipelineState = {
        guard let defaultLibrary = self.device.newDefaultLibrary() else { fatalError("failed to new default library") }

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.fragmentFunction = defaultLibrary.newFunctionWithName("basic_fragment")
        pipelineStateDescriptor.vertexFunction = defaultLibrary.newFunctionWithName("basic_vertex")
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm

        do {
            return try self.device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        }
        catch {
            fatalError("Failed to create pipeline state, error \(error)")
        }
    }()
    lazy var commandQueue: MTLCommandQueue = self.device.newCommandQueue()

    override func viewDidLoad() {
        super.viewDidLoad()

        let timer = CADisplayLink(target: self, selector: "render")
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    @objc private func render() {
        guard let drawable = metalLayer.nextDrawable() else { fatalError("invalid drawable") }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)

        let commandBuffer = commandQueue.commandBuffer()
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder.endEncoding()

        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
}

