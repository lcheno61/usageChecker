//
//  Models.swift
//  usageChecker
//
//  Created by lChen on 2023/5/26.
//

import Foundation

struct UnusedModel: Identifiable, Hashable {
    
    var id: String {
        filePath
    }
    let fileImage: String
    let fileName: String
    let filePath: String

}

struct DependsOnModel: Identifiable, Hashable {
    var id: String {
        identifier
    }

    let identifier: String
    let fileName: String
    let dependsOn: String
}

struct cmdOutputModel: Identifiable, Hashable {
    var id: String {
        identifier
    }

    let identifier: String
    let fileName: String!
    let filePath: String!
    let dependsOn: String!
    let count: Int

}
