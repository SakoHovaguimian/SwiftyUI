//
//  HomeViewModel.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import SwiftUI
import Combine

final
class DemoViewModel: ObservableObject, ViewModel {
    
    private let apiService: APIServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    @Published var title: String = ""
    @Published private(set) var bakgroundColor: Color = .red
    @Published private(set) var size: CGSize = .zero

    /// You need to make this published and subscribe to updates
//    var testObserve: String {
//        return self.title == "Sako" ? "HI" : "BYE"
//    }
    
    private var cancelBag: CancelBag!
    
    // TODO: THIS DOES NOT WORK
    /// Nor does `environmentService.environment.value` as a `String`

    // TODO: What to use for computed properties instead
    /// What I would like GuaranteeValueSubject<String>
//    var title: GuaranteePublisher<String> {
//        
//        return self.environmentService
//            .environment
//            .map { $0.rawValue }
//            .eraseToAnyPublisher()
//        
//    }
    
    // TODO: - CombineLatest Example
    /// Disable touches and lower opacity of button unless two toggles are on
    
    // TODO: - Handle Loading State
    /// Do someone redacted view until content is loaded
    
    init(apiService: APIServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.apiService = apiService
        self.environmentService = environmentService
        
    }
    
    @discardableResult
    func setup() -> Self {
        
        bindSubscribers()
        return self
        
    }
    
    func set(environment: AppEnvironment) {
        self.environmentService.setEnvironment(environment)
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.environmentService
            .environment
            .map { $0.rawValue }
            .receiveOnMain()
//            .assign(to: \.title, on: self)
        
        // Dif way to do it
            .sink(receiveValue: { [weak self] envString in
                self?.title = envString
                self?.size = self?.sizeForEnv() ?? .zero
                self?.bakgroundColor = self?.colorForEnv() ?? .pink
            })
            .store(in: &self.cancelBag)
        
        Publishers
            .CombineLatest($title, $size)
            .sink(receiveValue: { [weak self] s, c in
                print(s)
                print(c)
            })
            .store(in: &self.cancelBag)
        
//        self.$title
//            .throttle(for: .seconds(100), scheduler: , latest: true)
//            .sink { [weak self] a in
//                // SEARCH METHOD
//            }
        
    }
    
    private func sizeForEnv() -> CGSize {
        
        return switch self.environmentService.environment.value {
        case .dev: .init(width: 100, height: 300)
        case .stg: .init(width: 300, height: 80)
        case .prod: .init(width: 270, height: 500)
        }
        
    }
    
    private func colorForEnv() -> Color {
        
        return switch self.environmentService.environment.value {
        case .dev: Color.red
        case .stg: Color.blue
        case .prod: Color.green
        }
        
    }
    
}

extension DemoViewModel {
    
    func track() {
        print("📸📸📸📸📸📸 TRACKING DEMO VIEW MODEL")
    }
    
}
