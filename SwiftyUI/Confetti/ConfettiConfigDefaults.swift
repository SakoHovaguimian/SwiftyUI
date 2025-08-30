//
//  ConfettiConfigDefaults.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 8/5/25.
//

import SwiftUI

extension ConfettiConfig {
    
    /// Default settings for standard confetti
    public static func `default`() -> ConfettiConfig {
        ConfettiConfig()
    }
    
}

extension ConfettiConfig {
    
    /// Celebration preset with lots of particles
    public static func celebration() -> ConfettiConfig {
        
        var settings = ConfettiConfig()
        
        settings.particleCount = 200
        settings.maxTotalParticles = 500
        
        settings.burstX = 0.5
        settings.burstY = -100
        
        settings.burstSpeedMin = 300
        settings.burstSpeedMax = 600
        settings.upwardBias = 270
        settings.burstDirection = 90
        
        settings.sizeMin = 12
        settings.sizeMax = 20
        
        settings.fallDurationBase = 4.0
        settings.gravity = 150
        
        settings.massMin = 0.8
        settings.massMax = 1.5
        settings.dragMin = 0.5
        settings.dragMax = 1.5
        
        settings.wobbleAmplitudeMin = 15
        settings.wobbleAmplitudeMax = 35
        settings.wobbleFrequencyMin = 2
        settings.wobbleFrequencyMax = 5
        settings.wobbleDecay = 0.7
        
        settings.fadeStartPercent = 0.8
        settings.fadeDuration = 0.2
        
        settings.metallicEnabled = false
        settings.metallicIntensity = 0.8
        settings.shimmerIntensity = 0.4
        
        settings.colorPalette = [
            Color(hex: "FFD700"),  // Gold
            Color(hex: "FF1493"),  // Deep Pink
            Color(hex: "00CED1"),  // Dark Turquoise
            Color(hex: "FF6347"),  // Tomato
            Color(hex: "9370DB"),  // Medium Purple
            .white
        ]
        
        return settings
        
    }
    
}

extension ConfettiConfig {
    
    /// Subtle preset with fewer particles
    public static func subtle() -> ConfettiConfig {
        
        var settings = ConfettiConfig()
        
        settings.particleCount = 50
        settings.maxTotalParticles = 100
        
        settings.burstSpeedMin = 1000
        settings.burstSpeedMax = 3000
        settings.upwardBias = 60
        
        settings.sizeMin = 4
        settings.sizeMax = 10
        
        settings.gravity = 800
        settings.fallDurationBase = 1.5
        
        settings.wobbleAmplitudeMin = 2
        settings.wobbleAmplitudeMax = 8
        
        settings.colorPalette = [
            .white.opacity(0.9),
            Color(hex: "E0E0E0"),
            Color(hex: "D0D0D0")
        ]
        
        return settings
        
    }
    
}

extension ConfettiConfig {
    
    /// Gold theme preset
    public static func gold() -> ConfettiConfig {
        
        var settings = ConfettiConfig()
        
        settings.particleCount = 100
        
        settings.metallicEnabled = true
        settings.metallicIntensity = 0.9
        settings.shimmerIntensity = 0.8
        
        settings.colorPalette = [
            Color(hex: "FFD700"),  // Gold
            Color(hex: "FFA500"),  // Orange
            Color(hex: "FFE5B4"),  // Peach
            Color(hex: "FFDF00"),  // Golden yellow
        ]
        
        return settings
        
    }
    
}

extension ConfettiConfig {

/// Rainbow preset with many colors
    public static func rainbow() -> ConfettiConfig {
        
        var settings = ConfettiConfig()
        
        settings.particleCount = 120
        
        settings.colorPalette = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple,
            .pink
        ]
        
        return settings
        
    }
    
}


extension ConfettiConfig {
    
    public static func custom() -> ConfettiConfig {
        var settings = ConfettiConfig()
        
        settings.particleCount = 32
        settings.maxTotalParticles = 100
        
        settings.burstSpeedMin = 1000
        settings.burstSpeedMax = 2000
        settings.upwardBias = 10
        
        settings.sizeMin = 8
        settings.sizeMax = 16
        
        settings.gravity = 800
        settings.fallDurationBase = 1.5
        
        settings.wobbleAmplitudeMin = 1
        settings.wobbleAmplitudeMax = 50
        
        settings.burstX = 0.5
        settings.burstY = 200
        
        settings.shapes = [
            .circle
        ]
        
        settings.colorPalette = [
            .brandGreen,
            .brandPink,
            .darkBlue,
            .darkGreen
        ]
        
        return settings
    }
    
}
