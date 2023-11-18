//
//  CreatePinScreen.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 04/04/2023.
//

import Foundation
import SwiftUI
import IvoryCore
import CommonUtils
import DependencyContainer

struct CreatePinScreen: View {

    @Environment(\.dismiss) private var dismiss
    
    @MainActor private final class State: ObservableObject {
        
        @DI.RePublished(DI.pinService) private var pinService
        
        enum CreatingState {
            case inputPin
            case confirm(pin: String)
            
            var title: String {
                switch self {
                case .inputPin: return "Input New Passcode"
                case .confirm(pin: _): return "Confirm Passcode"
                }
            }
        }
        
        let pinViewState = PinView.State()
        @Published var creatingState = CreatingState.inputPin
        var dismiss: DismissAction?
        
        init() {
            pinViewState.completion = { [weak self] in
                self?.submit(pin: $0)
            }
            
            $creatingState.sinkOnMain(retained: self) { [weak self] in
                self?.pinViewState.title = $0.title
            }
        }
        
        private func submit(pin: String) {
            shortAnimation {
                switch creatingState {
                case .inputPin:
                    creatingState = .confirm(pin: pin)
                case .confirm(let previousPin):
                    if pin == previousPin {
                        pinService.pin = pin
                        dismiss?()
                    } else {
                        creatingState = .inputPin
                        pinViewState.subtitle = "Confirmation doesn't match"
                    }
                }
            }
        }
    }
    
    @StateObject private var state = State()
    
    var body: some View {
        PinView(state: state.pinViewState)
            .onFirstAppear {
                state.dismiss = dismiss
        }
    }
}
