//
//  PinView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 19/01/2023.
//

import Foundation
import SwiftUI
import IvoryCore
import CommonUtils
import DependencyContainer

fileprivate struct CodeDashView: View {
    
    let maxCount: Int
    let count: Int
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<maxCount, id: \.self) { index in
                ZStack {
                    Circle().stroke(Color.tint).frame(height: 10)
                    Circle()
                        .foregroundColor(count > index ? .tint : .clear)
                        .frame(height: 10)
                }
            }
        }.frame(width: CGFloat(maxCount) * 30)
    }
}

fileprivate struct PinButton: View {
    
    let title: String
    @Binding var pin: String
    @State private var highlight: Bool = false
    
    var body: some View {
        Button(title) { pin.append(title) }
            .font(.system(size: 35, weight: .thin))
            .foregroundColor(highlight ? Color(UIColor.systemBackground) : .primary)
            .onLongPressGesture(minimumDuration: 0,
                                perform: {},
                                onPressingChanged: { value in
                shortAnimation {
                    highlight = value
                }
        }).frame(maxWidth: 75, maxHeight: 75)
            .aspectRatio(1, contentMode: .fit)
            .background {
                Circle().foregroundColor(.primary)
                    .opacity(highlight ? 1 : 0)
            }
    }
}

struct PinKeyboardView: View {
    
    @DI.Static(DI.pinService) private var pinService
    @Environment(\.verticalSizeClass) private var sizeClass
    
    @ObservedObject var state: PinView.State
    
    private var spacing: CGFloat { sizeClass == .regular ? 40 : 15 }
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<3) { i in
                HStack(spacing: spacing) {
                    ForEach(0..<3) { j in
                        PinButton(title: "\(i * 3 + j + 1)", pin: $state.text)
                    }
                }
            }
            HStack(spacing: spacing) {
                let biomtryType = pinService.allowedBiometry
                
                if let biometryCheck = state.biometryCheck, biomtryType != .none {
                    Button { biometryCheck() } label: {
                        Image(systemName: biomtryType == .face ? "faceid" : "touchid").resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: 35)
                            .tint(.tint)
                    }.frame(maxWidth: 75, maxHeight: 75)
                } else {
                    Spacer().frame(maxWidth: 75, maxHeight: 75)
                }
                
                PinButton(title: "0", pin: $state.text)
                
                DismissButton {
                    Text(state.text.count > 0 ? "Delete" : "Cancel")
                } shouldDismiss: {
                    if state.text.count > 0 {
                        state.text.removeLast()
                        return false
                    }
                    return true
                }.frame(maxWidth: 75, maxHeight: 75)
                    .tint(.tint)
            }
        }
    }
}

struct PinView: View {
    
    static let pinLendth = 4
    
    @MainActor final class State: ObservableObject {
        @Published var title: String = ""
        @Published var text: String = ""
        @Published var disabled: Bool = false
        @Published var subtitle: String? = nil
        
        var biometryCheck: (()->())? = nil
        var completion: ((String)->())?
        
        init(title: String = "") {
            self.title = title
            
            $text.sinkOnMain(retained: self) { [weak self] pin in
                if pin.count > 0 {
                    shortAnimation {
                        self?.subtitle = ""
                    }
                }
                
                if pin.count == PinView.pinLendth {
                    self?.disabled = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self?.completion?(pin)
                        self?.text = ""
                        self?.disabled = false
                    }
                }
            }
        }
    }
    
    @ObservedObject var state: State
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Text("Kids Space Passcode")
                    .font(.system(size: 25))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 0)
                    .frame(maxHeight: 50)
                
                Text(state.title).styled(alignment: .center)
                    .padding(.bottom, 10)
                    .frame(maxHeight: 50)
                
                CodeDashView(maxCount: Self.pinLendth, count: state.text.count)
                    .shaked(state.subtitle?.isValid == true)
                    .padding(.bottom, 10)
                    .frame(maxHeight: 50)
                
                Text(state.subtitle ?? "").styled(alignment: .center, size: .small)
                    .padding(.bottom, 10)
                    .frame(minHeight: 15, maxHeight: 40)
                
            }.frame(maxHeight: .infinity)
            
            PinKeyboardView(state: state)
                .layoutPriority(1)
            
        }.disabled(state.disabled)
            .padding(15)
    }
}
