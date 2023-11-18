//
//  PinService.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 23/01/2023.
//

import Foundation
import LocalAuthentication

public enum BiometryType {
    case none
    case face
    case touch
}

public protocol PinService: ObservableObject {
    
    var pinSet: Bool { get }
    
    var pin: String? { get set }
    
    var allowedBiometry: BiometryType { get }
    
    func performBiometryCheck() async -> Bool
}

public final class PinServiceImp: PinService {
    
    private let key: String
    
    public init(key: String = "pin") {
        self.key = key
        pin = UserDefaults.standard.string(forKey: key)
    }
    
    @Published public var pin: String? {
        didSet { UserDefaults.standard.set(pin, forKey: key) }
    }
    
    public var pinSet: Bool { pin != nil }
    
    public func performBiometryCheck() async -> Bool {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            return (try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                      localizedReason:  "Kids Space Passcode")) ?? false
        }
        return false
    }
    
    public var allowedBiometry: BiometryType {
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            return .none
        } else {
            return LAContext().biometryType == .faceID ? .face : .touch
        }
    }
}

public class PinServiceMock: PinService {
    
    public var pinSet: Bool = false
    public var pin: String?
    public var allowedBiometry: BiometryType = .face
    
    public func performBiometryCheck() async -> Bool {
        try? await Task.sleep(nanoseconds: 1000000)
        return true
    }
    
    public init() {}
}
