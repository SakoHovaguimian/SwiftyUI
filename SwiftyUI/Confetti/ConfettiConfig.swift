//
//  ConfettiConfig.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/5/25.
//

import SwiftUI

public struct ConfettiConfig: Codable {
    
    // MARK: - Particle Emission
    /// Number of particles emitted in a single burst.
    public var particleCount: Int = 150
    
    /// Maximum total particles allowed on screen simultaneously.
    public var maxTotalParticles: Int = 500
    
    // MARK: - Burst Physics
    /// Minimum initial speed of particles when emitted.
    public var burstSpeedMin: Double = 2000
    
    /// Maximum initial speed of particles when emitted.
    public var burstSpeedMax: Double = 10000
    
    /// Upward bias angle to tilt particle emission (degrees).
    public var upwardBias: Double = 120
    
    /// Initial burst direction angle (degrees from horizontal).
    public var burstDirection: Double = 270
    
    /// Relative X position (0-1 range) from which particles are emitted.
    public var burstX: Double = 0.5
    
    /// Relative Y position (in points) from which particles are emitted.
    public var burstY: Double = 400
    
    // MARK: - Physics
    /// Acceleration due to gravity applied to particles (points/sec²).
    public var gravity: Double = 1000
    
    /// Minimum mass for randomly generated particles.
    public var massMin: Double = 0.5
    
    /// Maximum mass for randomly generated particles.
    public var massMax: Double = 1.5
    
    /// Minimum drag coefficient for particles.
    public var dragMin: Double = 0.8
    
    /// Maximum drag coefficient for particles.
    public var dragMax: Double = 1.2
    
    /// Base duration for particles to fall before fading.
    public var fallDurationBase: Double = 2.0
    
    // MARK: - Wobble Effect
    /// Minimum wobble amplitude for particle side-to-side wobble.
    public var wobbleAmplitudeMin: Double = 5
    
    /// Maximum wobble amplitude for particle side-to-side wobble.
    public var wobbleAmplitudeMax: Double = 15
    
    /// Minimum frequency for wobble oscillation.
    public var wobbleFrequencyMin: Double = 2
    
    /// Maximum frequency for wobble oscillation.
    public var wobbleFrequencyMax: Double = 5
    
    /// Decay rate affecting how quickly wobble diminishes.
    public var wobbleDecay: Double = 1.0
    
    // MARK: - Appearance
    /// Minimum size (points) for randomly sized particles.
    public var sizeMin: CGFloat = 2
    
    /// Maximum size (points) for randomly sized particles.
    public var sizeMax: CGFloat = 20
    
    /// Percentage of particle lifetime when fade begins (0-1).
    public var fadeStartPercent: Double = 0.8
    
    /// Duration (fraction of lifetime) over which the particle fades out.
    public var fadeDuration: Double = 0.2
    
    // MARK: - Metallic Effects
    /// Enable metallic shading effect on particles.
    public var metallicEnabled: Bool = false
    
    /// Intensity of metallic effect (0-1 range).
    public var metallicIntensity: Double = 0.1
    
    /// Intensity of shimmer highlight on particles.
    public var shimmerIntensity: Double = 1.0
    
    // MARK: - Colors (Not Codable)
    /// Color palette used when assigning random particle colors.
    public var colorPalette: [Color] = [
        .white,
        Color(hex: "C0C0C0"),  // Silver
        Color(hex: "B2B0B0"),  // Light gray
        .accentColor
    ]
    
    // MARK: - Shapes
    /// Available shapes for randomly assigned particle shapes.
    public var shapes: [ConfettiParticle.ParticleShape] = [.square]
    
    // Exclude colorPalette from Codable
    private enum CodingKeys: String, CodingKey {
        
        case particleCount
        case maxTotalParticles
        case burstSpeedMin
        case burstSpeedMax
        case upwardBias
        case burstDirection
        case burstX
        case burstY
        case gravity
        case massMin
        case massMax
        case dragMin
        case dragMax
        case fallDurationBase
        case wobbleAmplitudeMin
        case wobbleAmplitudeMax
        case wobbleFrequencyMin
        case wobbleFrequencyMax
        case wobbleDecay
        case sizeMin
        case sizeMax
        case fadeStartPercent
        case fadeDuration
        case metallicEnabled
        case metallicIntensity
        case shimmerIntensity
        
    }
    
    public init() {}
    
}
