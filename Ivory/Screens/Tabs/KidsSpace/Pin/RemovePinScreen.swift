//
//  RemovePinScreen.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 04/04/2023.
//

import Foundation
import SwiftUI
import IvoryCore
import CommonUtils
import DependencyContainer

struct RemovePinScreen: View {
    
    @DI.Observed(DI.pinService) private var pinService
    @Environment(\.dismiss) private var dismiss
    @StateObject private var state = PinView.State(title: "Input Passcode")
    
    private func submitBiometry() {
        Task {
            if await pinService.performBiometryCheck() {
                pinService.pin = nil
                dismiss()
            }
        }
    }
    
    private func submit(pin: String) {
        shortAnimation {
            if pin == pinService.pin {
                pinService.pin = nil
                dismiss()
            } else {
                state.subtitle = "Incorrect Passcode"
            }
        }
    }
    
    var body: some View {
        PinView(state: state).onFirstAppear {
            state.completion = { submit(pin: $0) }
            state.biometryCheck = { submitBiometry() }
        }
    }
}

#Preview {
    let pin = PinServiceMock()
    pin.allowedBiometry = .face
    DI.Container.register(DI.pinService, pin)
    
    return RemovePinScreen()
}

