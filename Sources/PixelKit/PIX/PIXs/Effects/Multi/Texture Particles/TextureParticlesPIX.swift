//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-12-29.
//

import CoreGraphics
import CoreGraphicsExtensions
import RenderKit
import Resolution
import PixelColor

final public class TextureParticlesPIX: PIXMultiEffect, NODEResolution {
    
    public typealias Model = TextureParticlesPixelModel
    
    private var model: Model {
        get { multiEffectModel as! Model }
        set { multiEffectModel = newValue }
    }
    
    public override var shaderName: String { return "textureParticlesPIX" }
    
    /// Defined as `PARTICLE_MAX_COUNT` in shader
    private static let particleMaxCount: Int = 1000
    public override var uniformArrayMaxLimit: Int? { Self.particleMaxCount }
        
    struct Particle {
        let textureIndex: Int
        var position: CGPoint
        var velocity: CGPoint
        var lifeTime: Double = 0.0
    }
    private var particles: [Particle] = []
    private var framesSinceEmit: Int = 0
    
    // MARK: Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    @LiveColor("backgroundColor") public var backgroundColor: PixelColor = .black
    @LiveEnum("blendMode") public var blendMode: BlendMode = .add
    @LiveFloat("lifeTime") public var lifeTime: CGFloat = 1.0
    @LiveInt("emitCount", range: 0...10) public var emitCount: Int = 1
    @LiveInt("emitFrameInterval", range: 0...100) public var emitFrameInterval: Int = 10
    @LivePoint("emitPosition") public var emitPosition: CGPoint = .zero
    @LiveSize("emitSize") public var emitSize: CGSize = .zero
    @LivePoint("direction") public var direction: CGPoint = .zero
    @LiveFloat("randomDirection") public var randomDirection: CGFloat = 1.0
    @LiveFloat("velocity", range: 0.0...0.01, increment: 0.001) public var velocity: CGFloat = 0.005
    @LiveFloat("randomVelocity", range: 0.0...0.01, increment: 0.001) public var randomVelocity: CGFloat = 0.0
    @LiveFloat("particleScale", range: 0.0...0.2, increment: 0.05) public var particleScale: CGFloat = 0.1

    // MARK: Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_resolution, _backgroundColor, _blendMode, _lifeTime, _emitCount, _emitFrameInterval, _emitPosition, _emitSize, _direction, _randomDirection, _velocity, _randomVelocity, _particleScale]
    }
    
    public override var values: [Floatable] {
        [backgroundColor, blendMode, particleScale, resolution.aspect]
    }
    
    public override var uniformArray: [[CGFloat]] {
        particles.map({ [$0.position.x, $0.position.y, CGFloat($0.textureIndex)] })
    }

    public override var uniformArrayLength: Int? { 3 }

    // MARK: - Life Cycle
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        setup()
    }
    
    public init(at resolution: Resolution) {
        let model = Model(resolution: resolution)
        super.init(model: model)
        setup()
    }
    
    // MARK: - Setup
    
    func setup() {
        PixelKit.main.render.listenToFrames(id: id) { [weak self] in
            self?.particleLoop()
        }
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        resolution = model.resolution
        backgroundColor = model.backgroundColor
        blendMode = model.blendMode
        lifeTime = model.lifeTime
        emitCount = model.emitCount
        emitFrameInterval = model.emitFrameInterval
        emitPosition = model.emitPosition
        emitSize = model.emitSize
        direction = model.direction
        randomDirection = model.randomDirection
        velocity = model.velocity
        randomVelocity = model.randomVelocity
        particleScale = model.particleScale

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.resolution = resolution
        model.backgroundColor = backgroundColor
        model.blendMode = blendMode
        model.lifeTime = lifeTime
        model.emitCount = emitCount
        model.emitFrameInterval = emitFrameInterval
        model.emitPosition = emitPosition
        model.emitSize = emitSize
        model.direction = direction
        model.randomDirection = randomDirection
        model.velocity = velocity
        model.randomVelocity = randomVelocity
        model.particleScale = particleScale

        super.liveUpdateModelDone()
    }
    
    // MARK: - Destroy
    
    public override func destroy() {
        super.destroy()
        
        PixelKit.main.render.unlistenToFrames(for: id)
    }
    
    // MARK: - Particle Loop
    
    private func particleLoop() {
        if framesSinceEmit < emitFrameInterval {
            framesSinceEmit += 1
        } else {
            addParticles()
            framesSinceEmit = 0
        }
        moveParticles()
        removeParticles()
        render()
    }
    
    private func addParticles() {
        guard emitCount > 0 else { return }
        for _ in 0..<emitCount {
            guard particles.count < Self.particleMaxCount else { return }
            var position: CGPoint = emitPosition
            position -= emitSize / 2
            position += CGPoint(x: emitSize.width * .random(in: 0.0...1.0),
                                y: emitSize.height * .random(in: 0.0...1.0))
            var velocity: CGPoint = direction * velocity
            if randomDirection > 0.0 {
                velocity += CGPoint(x: .random(in: -1.0...1.0) * randomDirection * self.velocity,
                                    y: .random(in: -1.0...1.0) * randomDirection * self.velocity)
            }
            let lastTextureIndex: Int = particles.last?.textureIndex ?? 0
            let textureIndex: Int = inputs.isEmpty ? 0 : (lastTextureIndex + 1) % inputs.count
            let particle = Particle(textureIndex: textureIndex, position: position, velocity: velocity)
            particles.append(particle)
        }
    }
    
    private func moveParticles() {
        for (index, particle) in particles.enumerated() {
            var velocity = particle.velocity
            if randomVelocity > 0.0 {
                velocity += CGPoint(x: .random(in: -1.0...1.0) * randomVelocity,
                                    y: .random(in: -1.0...1.0) * randomVelocity)
            }
            particles[index].position += velocity
            particles[index].lifeTime += PixelKit.main.render.secondsPerFrame
        }
    }
    
    private func removeParticles() {
        for (index, particle) in particles.enumerated().reversed() {
            if particle.lifeTime >= lifeTime {
                particles.remove(at: index)
            }
        }
    }
    
    public func removeAllParticles() {
        particles = []
        render()
    }
    
    // MARK: - Custom Vertices
    
    public func customVertices() -> RenderKit.Vertices? {
        
        let count = particles.count
        var vertices: [RenderKit.Vertex] = []
        for particle in particles {
            vertices.append(Vertex(x: particle.position.x,
                                   y: particle.position.y))
        }
        
        let vertexBuffer = vertices.flatMap(\.buffer3d)
        let vertexBufferSize = max(vertexBuffer.count, 1) * MemoryLayout<Float>.size
        let vertexBufferBuffer = PixelKit.main.render.metalDevice.makeBuffer(bytes: !vertexBuffer.isEmpty ? vertexBuffer : [0.0], length: vertexBufferSize, options: [])!
        
        return RenderKit.Vertices(buffer: vertexBufferBuffer, vertexCount: count, type: .point, wireframe: false)
    }
    
}
