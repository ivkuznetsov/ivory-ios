//
//  TabsView.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 11/01/2023.
//

import SwiftUI

protocol TabsItem: Hashable {
    
    var title: String { get }
}

extension TabsItem where Self: RawRepresentable<String> {
    
    var title: String { rawValue.capitalized }
}

struct ViewItem: TabsItem {
    
    let title: String
    let view: () -> any View
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: ViewItem, rhs: ViewItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class TabsState<Item: TabsItem>: ObservableObject {
    
    @Published var items: [Item]
    @Published var selected: Item
    
    init(items: [Item], initialSelected: Item? = nil) {
        self.items = items
        self.selected = initialSelected ?? items[0]
        
        $items.sink { [weak self] tabs in
            if let wSelf = self, !tabs.contains(wSelf.selected) {
                wSelf.selected = tabs[0]
            }
        }.retained(by: self)
    }
}

struct TabsView<Item: TabsItem>: View {
    
    var height: CGFloat = 32
    @ObservedObject var state: TabsState<Item>
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Capsule()
                    .foregroundColor(.tint)
                    .offset(x: proxy.size.width / CGFloat(state.items.count) * CGFloat(max(0, min(state.items.count - 1, state.items.firstIndex(of: state.selected)!))) + 5)
                    .frame(width: proxy.size.width / CGFloat(state.items.count > 0 ? state.items.count : 1) - 10)
            }.frame(height: height)
            
            HStack(spacing: 0) {
                ForEach(state.items, id: \.self) { item in
                    Button {
                        withAnimation(.shortEaseOut) {
                            state.selected = item
                        }
                    } label: {
                        Text(item.title).styled(alignment: .center, size: .small).frame(maxWidth: .infinity)
                            .foregroundColor(item == state.selected ? Color.white : .secondaryText)
                    }.frame(maxWidth: .infinity)
                }
            }.frame(height: height)
        }
    }
}

#Preview {
    let state = TabsState(items: [ViewItem(title: "Test 1", view: { Color.clear }),
                                  ViewItem(title: "Test 2", view: { Color.clear }),
                                  ViewItem(title: "Test 3", view: { Color.clear })])
    
    return TabsView(state: state)
}
