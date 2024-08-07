//
//  Ext+Combine.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import Combine
import Dispatch

/// A subject that outputs an initial value, and all future values to downstream subscribers, and cannot fail.
public typealias GuaranteeValueSubject<Output> = CurrentValueSubject<Output, Never>

/// A publisher that can never fail.
public typealias GuaranteePublisher<Output> = AnyPublisher<Output, Never>

/// A subject that outputs elements to downstream subscribers, and can never fail.
public typealias GuaranteePassthroughSubject<Output> = PassthroughSubject<Output, Never>

public extension Publisher where Failure == Never /* Value */ {
    
    /// Latest value of the publisher's output sequence.
    ///
    /// **Note**: This assumes the publisher has values
    /// in it's stream. If it doesn't, calling this
    /// will throw an exception.
    var value: Self.Output {
        
        var value: Self.Output!
        var bag = Set<AnyCancellable>()
        
        sink { value = $0 }
            .store(in: &bag)
        
        return value
        
    }
        
    /// Latest value of the publisher's output sequence
    /// _or_ a fallback value if the publisher has no
    /// values in it's stream.
    func value(or fallback: Self.Output) -> Self.Output {
        
        var value: Self.Output?
        var bag = Set<AnyCancellable>()
        
        sink { value = $0 }
            .store(in: &bag)
        
        return value ?? fallback
        
    }
    
}

public extension Publisher /* Scheduling */ {
    
    /// Specifies `DispatchQueue.main` as the publisher's
    /// subscribe, cancel, & request operation scheduler.
    func subscribeOnMain(options: DispatchQueue.SchedulerOptions? = nil) -> Publishers.SubscribeOn<Self, DispatchQueue> {
        
        return subscribe(
            on: .main,
            options: options
        )
        
    }
    
    /// Specifies `DispatchQueue.main` as the receiving
    /// scheduler for published elements.
    func receiveOnMain(options: DispatchQueue.SchedulerOptions? = nil) -> Publishers.ReceiveOn<Self, DispatchQueue> {
                
        return receive(
            on: .main,
            options: options
        )
        
    }
    
}

public extension Publisher where Failure == Never /* Weak */ {
    
    /// Attaches a weak subscriber with closure-based
    /// behavior to a publisher that never fails.
    func weakSink<T: AnyObject>(capturing object: T,
                                receiveValue: @escaping (T?, Output)->Void) -> AnyCancellable {
        
        return sink { [weak object] value in
            receiveValue(object, value)
        }
        
    }
    
    /// Republishes elements received from a publisher,
    /// by weakly assigning them to a property marked as a publisher.
    func weakAssign<T: AnyObject>(to keyPath: ReferenceWritableKeyPath<T, Output>,
                                  on object: T) -> AnyCancellable {
        
        return weakSink(capturing: object) { wObject, value in
            wObject?[keyPath: keyPath] = value
        }
        
    }
    
}

public extension Publisher where Output == Bool /* Bool */ {
    
    /// Filters `false` outputs out of a publisher sequence.
    func isTrue() -> AnyPublisher<Output, Failure> {
        
        return filter { $0 }
            .eraseToAnyPublisher()
        
    }

    /// Filters `true` outputs out of a publisher sequence.
    func isFalse() -> AnyPublisher<Output, Failure> {
        
        return filter { !$0 }
            .eraseToAnyPublisher()
        
    }

}
