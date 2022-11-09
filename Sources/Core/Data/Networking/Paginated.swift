//
//  Paginated.swift
//  Core
//
//  Created by Anton Bal` on 02.10.2022.
//

import Foundation

public protocol Paginated {
    var size: Int { get }
    var total: Int { get }
}

public extension Paginated {
    var hasMore: Bool { size < total }

    func hasMore(for page: Int, pageSize: Int) -> Bool {
        (pageSize * page) < total
    }
}
