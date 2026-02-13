
//
//  DynamicIslandView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 2/10/26.
//

import SwiftUI

public let DYNAMIC_ISLAND_HEIGHT: CGFloat = 36
public let DYNAMIC_ISLAND_PADDING: CGFloat = 11

@available(iOS 26.0, *)
public struct DynamicIslandView<Content: View>: View {
        
    @Binding private var isPresented: Bool
    @ViewBuilder private var content: Content
    
    @State private var contentHeight: CGFloat = 0
    
    private let forceDynamicIsland: Bool?
    private let containerColor: Color
    private let animation: Animation
        
    public init(
        isPresented: Binding<Bool>,
        forceDynamicIsland: Bool? = nil,
        containerColor: Color = .black,
        animation: Animation = .interactiveSpring(
            duration: 0.30,
            extraBounce: 0.35,
            blendDuration: 0.0
        ),
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.forceDynamicIsland = forceDynamicIsland
        self.containerColor = containerColor
        self.animation = animation
        self.content = content()
    }
    
    // MARK: Body
    
    public var body: some View {
        
        GeometryReader { proxy in
            
            let safeTop = proxy.safeAreaInsets.top
            let hasDynamicIsland = self.forceDynamicIsland ?? (safeTop >= 59)
            
            let topOffset: CGFloat = DYNAMIC_ISLAND_PADDING + max((safeTop - 59), 0)
            
            let collapsedWidth: CGFloat = 120
            let collapsedHeight: CGFloat = 37
            
            let expandedWidth: CGFloat = proxy.size.width - (DYNAMIC_ISLAND_PADDING * 2)
            let expandedHeight: CGFloat = max(self.contentHeight, collapsedHeight)
            
            let activeWidth = self.isPresented ? expandedWidth : collapsedWidth
            let activeHeight = self.isPresented ? expandedHeight : collapsedHeight
            
            let scaleX: CGFloat = self.isPresented ? 1 : (collapsedWidth / max(expandedWidth, 1))
            let scaleY: CGFloat = self.isPresented ? 1 : (collapsedHeight / max(expandedHeight, 1))
            
            let isPresentedOffset = self.isPresented ? safeTop + 10 : -activeHeight
            let offset = hasDynamicIsland ? topOffset : isPresentedOffset
            
            let opacity: CGFloat = hasDynamicIsland ? 1 : (self.isPresented ? 1 : 0)
            
            ZStack(alignment: .top) {
                
                ConcentricRectangle(corners: .concentric(minimum: 30), isUniform: true)
                    .fill(self.containerColor)
                    .overlay {
                        
                        embeddedContent(
                            expandedWidth: expandedWidth,
                            scaleX: scaleX,
                            scaleY: scaleY
                        )
                        
                    }
                    .frame(
                        width: activeWidth,
                        height: activeHeight
                    )
                    .clipped()
                    .offset(y: offset)
                    .opacity(opacity)
                    .gesture(
                        DragGesture().onEnded { value in
                            
                            if value.translation.height < -20 {
                                self.isPresented = false
                            }
                            
                        }
                    )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .ignoresSafeArea()
            .animation(self.animation, value: self.isPresented)
            .animation(self.animation, value: self.contentHeight)
            
        }
        
    }
    
    private func embeddedContent(expandedWidth: CGFloat,
                                 scaleX: CGFloat,
                                 scaleY: CGFloat) -> some View {
        
        self.content
            .onGeometryChange(for: CGFloat.self) { geo in
                geo.size.height
            } action: { newValue in
                self.contentHeight = newValue
            }
            .frame(width: expandedWidth)
            .opacity(self.isPresented ? 1 : 0)
            .blur(radius: self.isPresented ? 0 : 10)
            .scaleEffect(
                x: scaleX,
                y: scaleY,
                anchor: .top
            )
            .drawingGroup()
        
    }
    
}

//
//  DynamicIslandPreview.swift
//  Rune
//
//  Created by Sako Hovaguimian on 2/10/26.
//

import SwiftUI
import Combine

@available(iOS 26.0, *)
struct DynamicIslandAlwaysOnTop: View {
        
    enum IslandScenario: String,
                         CaseIterable,
                         Identifiable {
        
        var id: String { self.rawValue }
        
        case timer = "Timer"
        case music = "Music"
        case call = "Call"
        
        case ride = "Ride Share"
        case sports = "Sports"
        case airdrop = "AirDrop"
        case voice = "Siri/AI"
        case flight = "Flight"
        case focus = "Focus"
        case wallet = "Wallet"
        case stopwatch = "Stopwatch"
        case home = "Camera"
        case shortcut = "Shortcut"
                
    }
        
    @State private var isPresented: Bool = false
    @State private var selectedScenario: IslandScenario = .ride
    
    @State private var progress: CGFloat = 0.0
    @State private var waveformPhase: CGFloat = 0.0
    @State private var secondaryPhase: CGFloat = 0.0
    @State private var tickCount: Int = 0
    
    private let timer = Timer
        .publish(every: 0.05, on: .main, in: .common)
        .autoconnect()
        
    var body: some View {
        
        AppBaseView(alignment: .top) {
            
            self.content
            
        }
        .onReceive(self.timer) { _ in
            self.handleTimerTick()
        }
        .onChange(of: self.selectedScenario) { oldValue, newValue in
            
            DynamicIslandManager.shared.dismissAll()
            DynamicIslandManager.shared.present(
                
                islandInjectedContent(for: newValue)
                    .asAnyView()
                
            )
            
        }
        .withWindowDynamicIslandService()
        
    }
    
    // MARK: - Content
    
    private var content: some View {
        
        ScrollView {
            
            VStack(spacing: 24) {
                
                self.topSpacer
                self.scenarioPickerSection
                self.presentButton
                self.feedPlaceholders
                
            }
            
        }
        
    }
    
    private var topSpacer: some View {
        
        Spacer(minLength: 120)
        
    }
    
    // MARK: - Scenario Picker
    
    private var scenarioPickerSection: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            self.scenarioPickerTitle
            self.scenarioPickerScroll
            
        }
        
    }
    
    private var scenarioPickerTitle: some View {
        
        Text("Select Scenario")
            .font(.caption)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal, 24)
        
    }
    
    private var scenarioPickerScroll: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 12) {
                
                ForEach(IslandScenario.allCases) { scenario in
                    self.scenarioChip(for: scenario)
                }
                
            }
            .padding(.horizontal, 24)
            
        }
        
    }
    
    private func scenarioChip(for scenario: IslandScenario) -> some View {
        
        Button {
            
            withAnimation(.snappy) {
                
                self.selectedScenario = scenario
                self.resetScenarioState()
                
            }
            
        } label: {
            
            Text(scenario.rawValue)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(self.isScenarioSelected(scenario) ? Color.primary : Color.gray.opacity(0.1))
                .foregroundStyle(self.isScenarioSelected(scenario) ? Color(uiColor: .systemBackground) : Color.primary)
                .clipShape(Capsule())
            
        }
        
    }
    
    private func isScenarioSelected(_ scenario: IslandScenario) -> Bool {
        return self.selectedScenario == scenario
    }
    
    // MARK: - Present
    
    private var presentButton: some View {
        
        Button {
            
            self.handlePresentTap()
            
        } label: {
            
            Text("Present \(self.selectedScenario.rawValue)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
        }
        .padding(.horizontal, 20)
        
    }
    
    // MARK: - Feed
    
    private var feedPlaceholders: some View {
        
        VStack(spacing: 16) {
            
            ForEach(0..<6, id: \.self) { _ in
                
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 80)
                
            }
            
        }
        .padding(.horizontal, 20)
        
    }
    
    // MARK: - Always On Top
    
    private func updateAlwaysOnTopIsland() {
        
//        AlwaysOnTopWindowManager.shared.hide(.custom("dynamic-island"))
//        AlwaysOnTopWindowManager.shared.show(.custom("dynamic-island")) {
//
//            DynamicIslandView(
//                isPresented: self.$isPresented,
//                forceDynamicIsland: true
//            ) {
//
//                self.islandInjectedContent
//                    .foregroundStyle(.white)
//
//            }
//
//        }
        
    }
    
    @ViewBuilder
    private func islandInjectedContent(for content: IslandScenario) -> some View {
        
        switch content {
        case .timer: self.timerView
        case .music: self.musicView
        case .call: self.callView
        case .ride: self.rideShareView
        case .sports: self.sportsView
        case .airdrop: self.airdropView
        case .voice: self.voiceAIView
        case .flight: self.flightView
        case .focus: self.focusView
        case .wallet: self.walletView
        case .stopwatch: self.stopwatchView
        case .home: self.homeCameraView
        case .shortcut: self.shortcutView
        }
        
    }
    
    // MARK: - Actions
    
    private func handlePresentTap() {
        
        self.resetScenarioState()
        self.isPresented = true
        
    }
    
    // MARK: - Logic
    
    private func resetScenarioState() {
        self.progress = 0.0
        self.waveformPhase = 0.0
        self.secondaryPhase = 0.0
        self.tickCount = 0
    }
    
    private func handleTimerTick() {
        
        self.waveformPhase += 0.2
        self.secondaryPhase += 0.1
        self.tickCount += 1
        
        guard self.isPresented else { return }
        
        if self.progress < 1.0 {
            self.progress += 0.005
        }
        
        if self.shouldAutoDismissSelectedScenario,
           self.progress > 0.8 {
            
            withAnimation {
                self.isPresented = false
            }
            
        }
        
    }
    
    private var shouldAutoDismissSelectedScenario: Bool {
        
        return [
            IslandScenario.focus,
            IslandScenario.wallet,
            IslandScenario.shortcut,
            IslandScenario.airdrop
        ]
            .contains(self.selectedScenario)
        
    }
    
    // MARK: - Views (Ride Share)
    
    private var rideShareView: some View {
        
        HStack(alignment: .top, spacing: 12) {
            
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundStyle(.gray)
                .frame(width: 44, height: 44)
                .background(.white)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    
                    Text("Picking up in 4m")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Spacer()
                    
                    Text("UBER")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                }
                
                Text("Toyota Camry • 5XG-992")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: 100 * self.progress)
                    }
                    .padding(.top, 4)
                
            }
            
            Spacer()
            
            Image(systemName: "car.side.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .foregroundStyle(.white)
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, 20)
        
    }
    
    // MARK: - Views (Sports)
    
    private var sportsView: some View {
        
        HStack(alignment: .center, spacing: 0) {
            
            HStack {
                
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("L")
                            .font(.caption2)
                            .foregroundStyle(.black)
                    )
                
                Text("LAL")
                    .font(.system(size: 14, weight: .bold))
                
                Text("102")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                
                Text("Q4")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.gray)
                
                Text("2:04")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
                
            }
            
            Spacer()
            
            HStack {
                
                Text("99")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
                
                Text("BOS")
                    .font(.system(size: 14, weight: .bold))
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("B")
                            .font(.caption2)
                            .foregroundStyle(.white)
                    )
                
            }
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, .medium)
        
    }
    
    // MARK: - Views (AirDrop)
    
    private var airdropView: some View {
        
        HStack {
            
            Image(systemName: "person.crop.circle")
                .font(.title)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text("AirDrop")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.gray)
                
                Text(self.airdropStatusText)
                    .font(.subheadline.weight(.semibold))
                
            }
            
            Spacer()
            
            ZStack {
                
                Circle()
                    .strokeBorder(Color.blue.opacity(0.3 - (self.progress * 0.3)), lineWidth: 2)
                    .frame(width: 34, height: 34)
                    .scaleEffect(1 + self.progress)
                
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(45))
                    .offset(x: self.progress * 50, y: self.progress * -20)
                    .scaleEffect(1.0 - self.progress)
                    .opacity(1.0 - self.progress)
                
            }
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, 20)
        
    }
    
    private var airdropStatusText: String {
        return self.progress > 0.5 ? "Sent" : "Sending..."
    }
    
    // MARK: - Views (Voice AI)
    
    private var voiceAIView: some View {
        
        HStack {
            
            ZStack {
                
                ForEach(0..<3) { i in
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .blur(radius: 10)
                        .scaleEffect(1 + (sin(self.waveformPhase + Double(i)) * 0.3))
                        .opacity(0.5)
                        .blendMode(.screen)
                    
                }
            }
            .frame(width: 50, height: 50)
            
            Text("Go ahead, I'm listening...")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
            
            Spacer()
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, 20)
        
    }
    
    // MARK: - Views (Flight)
    
    private var flightView: some View {
        
        HStack(spacing: 16) {
            
            Rectangle()
                .fill(.white)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    Image(systemName: "airplane")
                        .foregroundStyle(.black)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack {
                    
                    Text("SFO")
                        .fontWeight(.bold)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    
                    Text("JFK")
                        .fontWeight(.bold)
                    
                }
                
                Text("Boarding in 15m")
                    .font(.caption)
                    .foregroundStyle(.green)
                
            }
            
            Spacer()
            
            self.flightDetailColumn(title: "GATE", value: "A4", valueColor: .yellow)
            self.flightDetailColumn(title: "SEAT", value: "12B", valueColor: nil)
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, 20)
        
    }
    
    private func flightDetailColumn(title: String,
                                    value: String,
                                    valueColor: Color?) -> some View {
        
        VStack(alignment: .trailing, spacing: 2) {
            
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.gray)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(valueColor ?? .white)
            
        }
        
    }
    
    // MARK: - Views (Focus)
    
    private var focusView: some View {
        
        HStack(spacing: 12) {
            
            Spacer()
            
            Image(systemName: "moon.fill")
                .foregroundStyle(.indigo)
            
            Text("Do Not Disturb")
                .font(.subheadline.weight(.semibold))
            
            Text("On")
                .font(.subheadline)
                .foregroundStyle(.gray)
            
            Spacer()
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        
    }
    
    // MARK: - Views (Wallet)
    
    private var walletView: some View {
        
        HStack(spacing: 16) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white)
                    .frame(width: 46, height: 30)
                    .offset(y: self.progress < 0.2 ? 20 : 0)
                    .rotation3DEffect(
                        .degrees(self.progress < 0.2 ? 40 : 0),
                        axis: (x: 1, y: 0, z: 0)
                    )
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .background(Circle().fill(.white))
                    .offset(x: 16, y: 10)
                    .scaleEffect(self.progress > 0.3 ? 1 : 0)
                
            }
            .animation(.bouncy, value: self.progress)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text("Apple Store")
                    .font(.subheadline.weight(.bold))
                
                Text("$1,299.00")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
            }
            
            Spacer()
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, .large)
        
    }
    
    // MARK: - Views (Stopwatch)
    
    private var stopwatchView: some View {
        HStack {
            Image(systemName: "stopwatch.fill")
                .foregroundStyle(.orange)
            
            Spacer()
            
            self.stopwatchTime
            
            Spacer()
            
            self.stopwatchLapButton
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, 20)
    }
    
    private var stopwatchTime: some View {
        
        HStack(spacing: 0) {
            
            Text("00:04")
                .font(.system(size: 24, weight: .regular, design: .monospaced))
            
            Text(".82")
                .font(.system(size: 24, weight: .regular, design: .monospaced))
                .foregroundStyle(.orange)
            
        }
        
    }
    
    private var stopwatchLapButton: some View {
        
        Button {} label: {
            
            Text("Lap")
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
            
        }
        
    }
    
    // MARK: - Views (Home Camera)
    
    private var homeCameraView: some View {
        
        VStack(spacing: 0) {
            
            self.homeCameraHeader
            self.homeCameraFeed
            
        }
        
    }
    
    private var homeCameraHeader: some View {
        
        HStack {
            
            Label("Front Door", systemImage: "door.left.hand.closed")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text("LIVE")
                .font(.system(size: 8, weight: .bold))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 2))
            
        }
        .padding(.horizontal, 20)
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        
    }
    
    private var homeCameraFeed: some View {
        
        ZStack {
            
            Rectangle()
                .fill(Color(white: 0.2))
            
            Image(systemName: "figure.walk")
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .offset(x: sin(self.secondaryPhase) * 40)
            
            self.homeCameraTimestamp
            
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 12)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        
    }
    
    private var homeCameraTimestamp: some View {
        
        VStack {
            
            Spacer()
            
            HStack {
                
                Text("12:04:33 PM")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                
            }
            .padding(8)
            
        }
        
    }
    
    // MARK: - Views (Shortcut)
    
    private var shortcutView: some View {
        
        HStack(spacing: 14) {
            
            self.shortcutIcon
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text("Gym Mode")
                    .font(.subheadline.weight(.semibold))
                
                Text("Running automation...")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                
            }
            
            Spacer()
            
            self.shortcutProgressRing
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, 20)
        
    }
    
    private var shortcutIcon: some View {
        
        ZStack {
            
            Circle()
                .fill(Color.white)
                .frame(width: 36, height: 36)
            
            Image(systemName: "shortcuts")
                .foregroundStyle(.blue)
                .font(.headline)
            
        }
        
    }
    
    private var shortcutProgressRing: some View {
        
        Circle()
            .trim(from: 0, to: self.progress)
            .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: 20, height: 20)
            .rotationEffect(.degrees(-90))
        
    }
    
    // MARK: - Legacy Views
    
    private var timerView: some View {
        
        HStack(alignment: .center, spacing: 0) {
            
            ZStack {
                
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Image(systemName: "timer")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                
            }
            
            Spacer()
            
            Text(Date().addingTimeInterval(60 * (1.0 - Double(self.progress))), style: .timer)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.orange)
            
            Spacer()
            
            Capsule()
                .fill(Color.orange)
                .frame(width: 4, height: 16)
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, 20)
        
    }
    
    private var musicView: some View {
        
        HStack(spacing: 12) {
            
            Rectangle()
                .fill(Color.purple.gradient)
                .frame(width: 48, height: 48)
                .cornerRadius(.small2)
            
            VStack(alignment: .leading) {
                
                Text("Music")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Text("Playing")
                    .font(.subheadline.weight(.bold))
                
            }
            
            Spacer()
            
            Image(systemName: "waveform")
                .foregroundStyle(.pink)
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, .medium)
        
    }
    
    private var callView: some View {
        
        HStack {
            
            Image(systemName: "phone.fill")
                .foregroundStyle(.green)
            
            Spacer()
            
            Text("Mom")
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "phone.down.fill")
                .foregroundStyle(.red)
            
        }
        .padding(.top, DYNAMIC_ISLAND_HEIGHT)
        .padding(.bottom, DYNAMIC_ISLAND_HEIGHT / 1.25)
        .padding(.horizontal, 20)
        
    }
    
}

@available(iOS 26.0, *)
#Preview {
    DynamicIslandAlwaysOnTop()
}

//
//  DynamicIslandManager.swift
//  Rune
//
//  Created by Sako Hovaguimian on 2/10/26.
//

import SwiftUI

@MainActor
@Observable
public class DynamicIslandManager {
    
    public static let shared = DynamicIslandManager()
    public var views: [AnyView] = []
    
    private init() {
        // Single Instance
    }
    
    public func present(_ view: AnyView) {
        
        withAnimation(.snappy) {
            self.views.append(view)
        }
        
    }
    
    public func present(_ views: [AnyView]) {
        
        withAnimation(.snappy) {
            self.views.append(contentsOf: views)
        }
        
    }
    
    public func dismiss() {
        
        guard !self.views.isEmpty else { return }
        
        withAnimation(.snappy) {
            _ = self.views.removeLast()
        }
        
    }
    
    public func dismissAll() {
        
        withAnimation(.snappy) {
            self.views.removeAll()
        }
        
    }
    
}

fileprivate struct DynamicIslandBridgeView: View {

    private var manager = DynamicIslandManager.shared
    
    var body: some View {
        
        let isPresentedBinding = Binding<Bool>(
            get: { !manager.views.isEmpty },
            set: { isPresented in
                if !isPresented {
                    manager.dismiss()
                }
            }
        )
        
        DynamicIslandView(
            isPresented: isPresentedBinding,
            containerColor: .black
        ) {
            if let currentView = manager.views.last {
                currentView
            }
        }
    }
}

//
//  DynamicIslandViewModifier.swift
//  Rune
//
//  Created by Sako Hovaguimian on 2/10/26.
//

import SwiftUI

@available(iOS 26.0, *)
public extension View {
    
    func withWindowDynamicIslandService() -> some View {
        
        @State var currentDynamicIslandView = DynamicIslandManager.shared
        
        return self
            .onSceneActiveInstall {
                
                AlwaysOnTopWindowManager.shared.show(.custom("island")) {
                    
                    DynamicIslandBridgeView()
                    
                }
                
            }
        
    }
    
}

public struct ScenePhaseInstallModifier: ViewModifier {
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var didInstall: Bool = false
    
    let install: @MainActor () -> Void
    
    public func body(content: Content) -> some View {
        
        content
            .onChange(of: self.scenePhase) { _, newValue in
                
                guard newValue == .active else { return }
                self.installIfNeeded()
                
            }
            .task {
                
                if self.scenePhase == .active {
                    self.installIfNeeded()
                }
                
            }
        
    }
    
    private func installIfNeeded() {
        
        guard !self.didInstall else { return }
        
        self.didInstall = true
        self.install()
        
    }
    
}

public extension View {
    
    func onSceneActiveInstall(_ install: @escaping @MainActor () -> Void) -> some View {
        
        self
            .modifier(ScenePhaseInstallModifier(install: install))
        
    }
    
}
