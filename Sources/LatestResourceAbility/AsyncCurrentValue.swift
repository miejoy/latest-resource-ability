//
//  AsyncCurrentValue.swift
//
//
//  Created by 黄磊 on 2022/11/13.
//

/// 类似 CurrentValueSubject 的 async/await 封装：
/// - 内部缓存最新值（未设置时为 .noValue）
/// - 添加 continuation 时若已有缓存值则立即 yield 一次
/// - 更新值时通知所有已注册的 continuation
/// - onTermination 时自动从内部移除，完全闭环
public final class AsyncCurrentValue<T: Sendable>: @unchecked Sendable {
    
    public enum State {
        case noValue
        case hasValue(T)
    }
    
    var state: State = .noValue
    private var nextId: Int = 0
    private var continuations: [(id: Int, continuation: AsyncStream<T>.Continuation)] = []
    
    /// 添加 continuation，若已有缓存值则立即 yield 一次，onTermination 时自动移除
    public func add(_ continuation: AsyncStream<T>.Continuation) {
        let id = nextId
        nextId += 1
        continuations.append((id: id, continuation: continuation))
        if case .hasValue(let current) = state {
            continuation.yield(current)
        }
        continuation.onTermination = { [weak self] _ in
            self?.continuations.removeAll { $0.id == id }
        }
    }
    
    /// 更新值并通知所有 continuation
    public func send(_ value: T) {
        state = .hasValue(value)
        for entry in continuations {
            entry.continuation.yield(value)
        }
    }
}
