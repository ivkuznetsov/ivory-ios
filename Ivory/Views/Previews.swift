//
//  Tests.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 28/03/2023.
//

import Foundation
import Database
import CoreData
import IvoryCore
import SwiftUI
import SwiftUIComponents
import DependencyContainer

func previewWithData<V: View, R>(_ item: @escaping (DataRepository) async ->R, view: @escaping (R)->V) -> some View {
    AsyncPreview<R> {
        await item(DI.Container.resolve(DI.data))
    } view: { view($0) }
}

func previewWithData<V: View>(_ view: @escaping ()->V) -> some View {
    previewWithData({ _ in true }, view: { _ in view() })
}
