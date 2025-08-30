//
//  ConfettiParticle.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/5/25.
//

import SwiftUI

public struct ConfettiParticle: Identifiable {
    
    /// Unique identifier for this particle instance.
    public let id: UUID
    
    /// Current X-coordinate position of the particle.
    public let x: CGFloat
    
    /// Current Y-coordinate position of the particle.
    public let y: CGFloat
    
    /// Particle's velocity along the X-axis (points per second).
    public let vx: Double
    
    /// Particle's velocity along the Y-axis (points per second).
    public let vy: Double
    
    /// Color of the particle.
    public let color: Color
    
    /// Size (diameter or side length) of the particle.
    public let size: CGFloat
    
    /// Shape of the particle (circle, square, star, heart, or custom path).
    public let shape: ParticleShape
    
    /// Mass of the particle, influencing its acceleration under forces.
    public let mass: Double
    
    /// Drag coefficient applied to slow the particle over time.
    public let dragCoefficient: Double
    
    /// Maximum horizontal wobble amplitude for the particle’s movement.
    public let wobbleAmplitude: Double
    
    /// Frequency of the wobble oscillation (cycles per second).
    public let wobbleFrequency: Double
    
    /// Exponential decay rate applied to the wobble effect.
    public let wobbleDecay: Double
    
    /// Rotation speed around the X-axis (radians per second).
    public let rotationSpeedX: Double
    
    /// Rotation speed around the Y-axis (radians per second).
    public let rotationSpeedY: Double
    
    /// Rotation speed around the Z-axis (radians per second).
    public let rotationSpeedZ: Double
    
    /// Reference to global SwiftettiSettings controlling overall behavior.
    public let settings: ConfettiConfig
    
    public enum ParticleShape {
        
        case circle
        case square
        case star
        case heart
        case custom(Path)
        
    }
    
    public init(id: UUID = UUID(),
                x: CGFloat,
                y: CGFloat,
                vx: Double,
                vy: Double,
                color: Color,
                size: CGFloat,
                shape: ParticleShape = .square,
                mass: Double,
                dragCoefficient: Double,
                wobbleAmplitude: Double,
                wobbleFrequency: Double,
                wobbleDecay: Double,
                rotationSpeedX: Double,
                rotationSpeedY: Double,
                rotationSpeedZ: Double,
                settings: ConfettiConfig) {
        
        self.id = id
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.color = color
        self.size = size
        self.shape = shape
        self.mass = mass
        self.dragCoefficient = dragCoefficient
        self.wobbleAmplitude = wobbleAmplitude
        self.wobbleFrequency = wobbleFrequency
        self.wobbleDecay = wobbleDecay
        self.rotationSpeedX = rotationSpeedX
        self.rotationSpeedY = rotationSpeedY
        self.rotationSpeedZ = rotationSpeedZ
        self.settings = settings
        
    }
    
}
