//
//  FloatingPlayerModifier.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 21/01/2023.
//

import SwiftUI
import IvoryCore
import CommonUtils
import SwiftUIComponents
import DependencyContainer

extension View {
    
    @MainActor func withFloatingPlayer(coordinator: TabsCoordinator) -> some View  {
        modifier(FloatingPlayerModifier(coordinator: coordinator))
    }
}

fileprivate struct PlayerDraggingModifer: ViewModifier {
    
    @Binding var alignment: Alignment
    @State private var offset: CGSize = .zero
    @State private var dragging: Bool = false
    
    func body(content: Content) -> some View {
        content.simultaneousGesture(DragGesture(minimumDistance: 10, coordinateSpace: .global).onChanged {
            dragging = true
            offset = $0.translation
        }.onEnded {
            let location = $0.predictedEndLocation
            let size = UIScreen.main.bounds.size
            
            if location.x > size.width / 2 {
                alignment = location.y < size.height / 2 ? .topTrailing : .bottomTrailing
            } else {
                alignment = location.y < size.height / 2 ? .topLeading : .bottomLeading
            }
            dragging = false
            offset = .zero
        }).offset(offset)
            .animation(dragging ? .none : .shortEaseOut, value: offset)
    }
}

struct CircleButton: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .foregroundColor(.black.opacity(0.8))
                .frame(width: 30, height: 30)
            configuration.label.foregroundStyle(.white)
        }.frame(width: 50, height: 50)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .contentShape(Rectangle())
    }
}

struct FloatingPlayerModifier: ViewModifier {
    
    @DI.Observed(DI.player) private var player
    let coordinator: TabsCoordinator
    
    @State private var alignment: Alignment = .bottomTrailing
    @State private var visible: Bool = false
    
    private func openVideoDetails() {
        if let video = player.video {
            coordinator.present(video: video)
        }
    }
    
    private func visibilityOffset(_ playerWidth: CGFloat) -> CGSize {
        if visible {
            return .zero
        } else {
            if alignment == .topTrailing || alignment == .bottomTrailing {
                return .init(width: playerWidth + 150, height: 0)
            } else {
                return .init(width: -playerWidth - 150, height: 0)
            }
        }
    }
    
    private func close() {
        player.set(video: nil)
    }
    
    private func reloadVisibility() {
        let visible = player.owner == .floating && player.video != nil
        
        if self.visible != visible {
            withAnimation(.shortEaseOut) {
                self.visible = visible
            }
        }
    }
    
    func body(content: Content) -> some View {
        content.overlay {
            ZStack(alignment: alignment) {
                Spacer().ignoresSafeArea()
                
                OrientationContainer { attr in
                    HStack {
                        PlayerView(owner: .floating)
                            .frame(width: attr.isiPad ? 400 : 280)
                            .bordered(10)
                            .background(content: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.black)
                                    .shadow(radius: 10, y: 3)
                            })
                        
                        VStack {
                            Button {
                                openVideoDetails()
                            } label: {
                                Image(systemName: "ellipsis")
                            }.buttonStyle(CircleButton())
                                .padding(.top, 5).padding(.leading, -5)
                            
                            Button {
                                close()
                            } label: {
                                Image(systemName: "xmark")
                            }.buttonStyle(CircleButton())
                                .padding(.leading, -5)
                            
                            Spacer()
                        }.padding(.bottom, 5)
                    }.frame(height: attr.isiPad ? 225 : 157)
                        .padding(.horizontal, 10)
                        .padding(.top, 44 + 15)
                        .padding(.bottom, 50 + 15)
                        .modifier(PlayerDraggingModifer(alignment: $alignment))
                        .offset(visibilityOffset(attr.isiPad ? 400 : 280))
                        .opacity(player.presentingInPIP ? 0 : 1)
                        .animation(.shortEaseOut, value: visible)
                        .onChange(of: player.video) { _ in reloadVisibility() }
                        .onChange(of: player.owner) { _ in reloadVisibility() }
                }
            }
        }
    }
}
