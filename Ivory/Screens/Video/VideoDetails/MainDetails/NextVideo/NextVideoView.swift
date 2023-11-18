//
//  NextVideoView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 20/01/2023.
//

import SwiftUI
import SwiftUIComponents
import IvoryCore
import DependencyContainer
import GridView
import Loader
import LoaderUI

struct NextVideoView: View {
    
    let content: VideoDetails.Content
    let didSelect: (VideoDetails.Content)->()
    
    @State var playlistPresented: Bool = false
    
    var body: some View {
        OrientationContainer { attr in
            HStack {
                Button { didSelect(content) } label: {
                    Text("Next:").fontWeight(.medium) +
                    Text(" \(content.video.title ?? "")")
                }.lineLimit(1)
                    .styled()
                    .foregroundStyle(Color.label)
                
                Spacer()
                
                if attr.orientation == .portrait {
                    ZStack {
                        if case .playlist(_, let paging) = content {
                            Button {
                                playlistPresented.toggle()
                            } label: {
                                Image(systemName: "list.triangle")
                            }.sheet(isPresented: $playlistPresented) {
                                PlaylistPickerView(paging: paging, didSelect: didSelect)
                            }
                        } else if case .watchLater(_) = content {
                            Button {
                                playlistPresented.toggle()
                            } label: {
                                Image(systemName: "list.triangle")
                            }.sheet(isPresented: $playlistPresented) {
                                WatchLaterPickerView(didSelect: didSelect)
                            }
                        }
                    }
                }
            }.frame(maxHeight: .infinity)
        }.padding(.horizontal, 15)
            .background { RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.control) }
            .padding(.bottom, 15)
    }
}

#Preview {
    previewWithData {
        Video.example(ctx: $0.previewContext)
    } view: { video in
        NextVideoView(content: .video(video), didSelect: { _ in }).frame(height: 80).padding(15)
    }
}
