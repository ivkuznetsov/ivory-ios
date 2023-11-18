//
//  SearchBar.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 30/03/2023.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText: String
    
    @FocusState private var isFocused: Bool
    @State private var text = ""
    
    let cancel: ()->()
    
    private func submit() {
        searchText = text
    }
    
    private func clearAction() {
        text = ""
        searchText = ""
    }
    
    private func cancelAction() {
        isFocused = false
        cancel()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search...", text: $text).foregroundColor(.primary)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .onSubmit { submit() }
                Button(action: { clearAction() },
                       label: { Image(systemName: "xmark.circle.fill").opacity(text == "" ? 0 : 1) })
            }.padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                .foregroundColor(Color(.tertiaryLabel))
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10.0)
            Button("Cancel") { cancelAction() }
                .foregroundColor(.tint)
        }.padding(.horizontal, 15)
            .padding(.vertical, 5)
            .onFirstAppear { isFocused = true }
            .frame(maxWidth: 600)
    }
}

#Preview {
    SearchBar(searchText: .constant("Test"), cancel: { })
}
