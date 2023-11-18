//
//  CommentView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 15/01/2023.
//

import SwiftUI
import Loader
import IvoryCore
import DependencyContainer
import GridView

@MainActor final class CommentsLoader: ObservableObject {
    
    @DI.Static(DI.data, \.comments) private var comments
    
    let loader: Loader
    var video: Video? {
        didSet {
            if oldValue != video {
                expanded.removeAll()
                loading.removeAll()
            }
        }
    }
    
    @Published var expanded = Set<UUID>()
    @Published var loading = Set<UUID>()
    
    private func loadMore(comment: Comment) {
        loading.insert(comment.id)
        loader.run(.none()) { [weak self] _ in
            guard let wSelf = self, let video = wSelf.video else { return }
            
            try await wSelf.comments.moreReplies(video, comment: comment)
            wSelf.loading.remove(comment.id)
        }
    }
    
    func expand(comment: Comment) {
        if expanded.contains(comment.id) {
            expanded.remove(comment.id)
        } else {
            if let rootComment = comment.rootComment {
                loadMore(comment: rootComment)
            } else {
                expanded.insert(comment.id)
                
                if comment.replies.isEmpty && !loading.contains(comment.id) {
                    loadMore(comment: comment)
                }
            }
        }
    }
    
    init(loader: Loader) {
        self.loader = loader
    }
}

extension CollectionSnapshot {
    
    @MainActor
    func addSection(_ comments: [Comment], commentsLoader: CommentsLoader) {
        
        var result: [Comment] = []
        
        func add(_ comments: [Comment]) {
            addSection(comments,
                       fill: { CommentCell(comment: $0,
                                           loader: commentsLoader) },
                       itemSize: { CommentCell.cellSize(comment: $0, width: $1) })
        }
        
        comments.forEach {
            result.append($0)
            
            if $0.repliesCount > 0 {
                add(result)
                result = []
                
                let expanded = commentsLoader.expanded.contains($0.id)
                
                add(expanded ? $0.replies : [])
                    
                if expanded {
                    if commentsLoader.loading.contains($0.id) {
                        self.add(LoadingCell(), id: $0.id.uuidString, staticSize: { .init(width: $0, height: 30) })
                    } else {
                        self.add(Color.clear, id: "spacing" + $0.id.uuidString, staticSize: { CGSize(width: $0, height: 15) })
                    }
                }
            }
        }
        add(result)
    }
}

private extension Comment {
    
    var hasLoadMore: Bool {
        (rootComment?.replies.last == self && rootComment?.nextReplies != nil) || self.repliesCount > 0
    }
}

struct CommentCell: View {
    
    let comment: Comment
    @ObservedObject var loader: CommentsLoader
    
    static func cellSize(comment: Comment, width: CGFloat) -> CGSize {
        let height = CellHeightCache.size(id: comment, width: width) {
            var height = comment.authorName.heightWithConstrainedWidth(.greatestFiniteMagnitude, font: .styleFont(size: .small))
            height += 5
            
            height += comment.content.heightWithConstrainedWidth(width - (comment.rootComment != nil ? 15 : 0), font: .styleFont(size: .small))
            
            if comment.hasLoadMore {
                height += 36
            }
            return height + 5
        }
        return CGSize(width: width, height: height)
    }
    
    private var moreTitle: String {
        let title: String
        if loader.expanded.contains(comment.id) {
            title = "Hide Replies"
        } else if comment.rootComment != nil {
            title = "Load More Replies"
        } else {
            title = "Show Replies"
        }
        return title
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Text(comment.authorName)
                    .styled(size: .small)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text(comment.date.dateAgo)
                    .styled(alignment: .center, size: .small)
                    .foregroundStyle(Color.secondaryText)
            }.padding(.bottom, 5)
            
            Text(comment.content)
                .styled(size: .small)
            
            if comment.hasLoadMore {
                Button(moreTitle) {
                    loader.expand(comment: comment)
                }.styled(size: .small)
                    .padding(.top, 5)
            }
            Spacer(minLength: 0)
        }.padding(.leading, comment.rootComment == nil ? 0 : 15)
    }
}

#Preview {
    CommentCell(comment: .example(), loader: CommentsLoader(loader: .init())).padding(15)
}
