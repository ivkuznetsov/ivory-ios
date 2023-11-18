//
//  MenuPicker.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 18/11/2023.
//

import Foundation
import SwiftUI

struct MenuPicker<Value: CustomStringConvertible & Hashable, Label: View>: View {
    
    @Binding var selection: Value
    let items: [Value]
    let label: (Value)->Label
    
    var body: some View {
        Menu { // we need to use this technique for correct work in mac catalyst, at the moment it doesn't support labels with images in menu
            Picker("", selection: $selection) {
                ForEach(items, id: \.self) {
                    Text($0.description)
                }
            }.pickerStyle(InlinePickerStyle())
        } label: {
            label(selection)
        }
    }
}
