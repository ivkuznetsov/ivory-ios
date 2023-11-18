//
//  PlayBackVideoView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/01/2023.
//

import SwiftUI
import Kingfisher
import IvoryCore
import DependencyContainer
import Loader
import LoaderUI

struct PlayerViewAdapter: UIViewRepresentable {
    
    @DI.Observed(DI.player) private var player
    
    let owner: PlayerOwner
    
    func makeUIView(context: Context) -> UIView { UIView() }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if owner == player.owner && player.controller.view.superview != uiView {
            player.controller.removeFromParent()
            uiView.attach(player.controller.view)
            DispatchQueue.main.async {
                if player.controller.view.superview == uiView {
                    var controller = uiView.next
                    
                    while controller as? UIViewController == nil && controller != nil {
                        controller = controller?.next
                    }
                    if let controller = controller as? UIViewController {
                        controller.addChild(player.controller)
                    }
                }
            }
        }
    }
}

@MainActor
struct PlayerView: View {
    
    static func cellHeight(width: CGFloat) -> CGFloat { width * 9 / 16 }
    
    @DI.Observed(DI.player) private var player
    @State var owner: PlayerOwner = .inline(UUID().hashValue)
    var didAppear: (()->())? = nil
    
    private func didBecomeVisible(_ visible: Bool) {
        if visible {
            player.owner = owner
            didAppear?()
        } else {
            if player.owner == owner, !player.controller.isFullScreen {
                player.owner = .floating
            }
        }
    }
    
    var body: some View {
        LoadingContainer(player.loader, customization: .init(loadingView: { _ in
            InCellProgressView(tintColor: UIColor(white: 1, alpha: 0.5), style: .big).asAny
        }, failView: { fail in
            ZStack {
                Text(fail.error.localizedDescription)
                    .styled()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.all, 30)
                    .frame(maxWidth: 400)
            }.asAny
        }), content: {
            ZStack {
                KFImage(player.video?.thumbnailURL)
                    .prepared()
                    .opacity(0.1)
                    .background { Color.black }
                PlayerViewAdapter(owner: owner)
            }
        }).aspectRatio(16 / 9, contentMode: .fit)
            .onBecomingVisible { didBecomeVisible($0) }
            .background { Color.black }
    }
}
