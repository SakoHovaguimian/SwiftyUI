//
//  Shake.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 5/2/24.
//

import SwiftUI
import Foundation

extension UIDevice {
    static let deviceDidShakeNotification = Foundation.Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype,
                                   with event: UIEvent?) {
        
        if motion == .motionShake {
            
            NotificationCenter
                .default
                .post(
                    name: UIDevice.deviceDidShakeNotification,
                    object: nil
                )
            
        }
        
    }
    
}

// Important Note
/// Always put this after `onAppear`
/// View needs to be shown before this works. We can always call `onAppear()` like this even though it does nothing

struct DeviceShakeViewModifier: ViewModifier {
    
    let action: () -> ()
    
    func body(content: Content) -> some View {
        
        content
            .onReceive(
                NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification),
                perform: { _ in
                    self.action()
                }
            )
        
    }
    
}

extension View {
    
    func onShake(perform action: @escaping () -> ()) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
    
}

struct ShakeTestView: View {
    
    var body: some View {
        
        Rectangle()
            .fill(.blue.gradient)
            .ignoresSafeArea()
            .onAppear()
            .onShake {
                print("Shookith")
            }
        
    }
    
}

#Preview {
    ShakeTestView()
}
