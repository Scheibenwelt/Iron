//
//  ViewController.swift
//  Iron
//
//  Created by Rox Dorentus on 2015-9-15.
//  Copyright © 2015年 rubyist.today. All rights reserved.
//

import UIKit
import Metal
import QuartzCore.CAMetalLayer
import GLKit

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
    lazy var objectToDraw: Node = {
        var node = Cube(device: self.device)
        node.position.x = 0
        node.position.y = 0
        node.position.z = -2
        node.rotation.z = Float(45 * M_PI / 180)
        node.scale.x = 0.5
        node.scale.y = 0.5
        node.scale.z = 0.5
        return node
    }()
    lazy var projectionMatrix: GLKMatrix4 = {
        return GLKMatrix4MakePerspective(Float(85 * M_PI / 180) , Float(self.view.bounds.width / self.view.bounds.height), 0.01, 100.0)
    }()
    let worldModelMatrix = GLKMatrix4MakeTranslation(0, 0, -4)

    override func viewDidLoad() {
        super.viewDidLoad()

        let timer = CADisplayLink(target: self, selector: "render:")
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    @objc private func render(displayLink: CADisplayLink) {
        guard let drawable = metalLayer.nextDrawable() else {
            debugPrint("invalid drawable")
            return
        }

        objectToDraw.time = displayLink.timestamp

        objectToDraw.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix)
    }
}

