//
//  NetworkAPI.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 08/04/2023.
//

import Foundation
import DependencyContainer

struct NetworkAPI {
    
    @DI.Static(DI.network) var network
}
