//
//  Networking.swift
//  Core
//
//  Created by Anton Bal` on 29.09.2022.
//

import Foundation

public protocol Networking {
    func task(for target: RequestConvertible) -> AsyncTask<NetworkResponse>
    func data(for target: RequestConvertible) async throws -> NetworkResponse
}
