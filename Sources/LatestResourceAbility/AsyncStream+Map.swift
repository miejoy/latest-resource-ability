//
//  AsyncStream+Map.swift
//
//
//  Created by 黄磊 on 2022/11/13.
//

public extension AsyncStream where Element: Sendable {
    func first() async -> Element? {
        for await element in self {
            return element
        }
        return nil
    }

    func map<T: Sendable>(_ transform: @Sendable @escaping (Element) async -> T) -> AsyncStream<T> {
        let stream = self
        return AsyncStream<T> { continuation in
            Task { @Sendable in
                for await element in stream {
                    let transformed = await transform(element)
                    continuation.yield(transformed)
                }
                continuation.finish()
            }
        }
    }

    func map<T: Sendable>(_ transform: @Sendable @escaping (Element) -> T) -> AsyncStream<T> {
        let stream = self
        return AsyncStream<T> { continuation in
            Task { @Sendable in
                for await element in stream {
                    continuation.yield(transform(element))
                }
                continuation.finish()
            }
        }
    }

    func replaceNil<T>(with value: T) -> AsyncStream<T> where Element == T?, T: Sendable {
        map { $0 ?? value }
    }
}
