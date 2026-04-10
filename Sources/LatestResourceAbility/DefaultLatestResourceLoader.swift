//
//  DefaultLatestResourceLoader.swift
//  
//
//  Created by 黄磊 on 2022/11/13.
//

import Ability
import Foundation
import Logger

public final class DefaultLatestResourceLoader: LatestResourceAbility {
    
    let resourceDir : String
    nonisolated(unsafe) var mapPublisher = [String: AsyncCurrentValue<Data?>]()
    let bundle: Bundle
    let jsonDecoder: JSONDecoder
    
    public init(
        bundle: Bundle = .main,
        resourceDir: String = "latest-resource",
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.bundle = bundle
        self.resourceDir = resourceDir
        self.jsonDecoder = jsonDecoder
    }
    
    public func load<T: Decodable & Sendable>(_ name: String, as type: T.Type) -> AsyncStream<T?> {
        loadData(name).map(transformToModel)
    }
    
    /// 加载原始 Data 流，内部通过 AsyncCurrentValue 管理
    func loadData(_ name: String) -> AsyncStream<Data?> {
        AsyncStream<Data?> { continuation in
            let isNew = DispatchQueue.syncOnAbilityQueue { () -> Bool in
                if let existing = mapPublisher[name] {
                    existing.add(continuation)
                    return false
                }
                let subject = AsyncCurrentValue<Data?>()
                subject.add(continuation)
                mapPublisher[name] = subject
                return true
            }
            // 首次创建时加载文件
            if isNew {
                let data = loadFromBundle(name: name)
                DispatchQueue.syncOnAbilityQueue { mapPublisher[name]?.send(data) }
            }
        }
    }
    
    /// 更新指定名称的数据并通知所有订阅者
    public func update(_ name: String, with data: Data?) {
        DispatchQueue.syncOnAbilityQueue {
            mapPublisher[name]?.send(data)
        }
    }
    
    /// 从 Bundle 中同步读取文件数据
    private func loadFromBundle(name: String) -> Data? {
        guard var resourcePath = bundle.resourcePath else {
            return nil
        }
        let fileManager = FileManager.default
        if !self.resourceDir.isEmpty {
            resourcePath += "/\(self.resourceDir)/"
        } else {
            resourcePath += "/"
        }
        // 优先查找 json
        let filePath = resourcePath + name + ".json"
        if fileManager.fileExists(atPath: filePath) {
            return fileManager.contents(atPath: filePath)
        }
        // 没有 json 再查找 plist
        let plistFilePath = resourcePath + name + ".plist"
        if fileManager.fileExists(atPath: plistFilePath) {
            do {
                var format = PropertyListSerialization.PropertyListFormat.xml
                if let xmlData = fileManager.contents(atPath: plistFilePath) {
                    let object = try PropertyListSerialization.propertyList(from: xmlData, options: .mutableContainersAndLeaves, format: &format)
                    return try JSONSerialization.data(withJSONObject: object, options: .fragmentsAllowed)
                }
            } catch {
                LogError("Load latest resource '\(name)' failed: \(error)")
            }
        }
        return nil
    }
    
    public func transformToModel<T:Decodable>(_ data: Data?) -> T? {
        do {
            if let data = data {
                return try jsonDecoder.decode(T.self, from: data)
            }
            return nil
        } catch {
            LogError("Transform to model[\(T.self)] failed: \(error)")
            return nil
        }
    }
}
