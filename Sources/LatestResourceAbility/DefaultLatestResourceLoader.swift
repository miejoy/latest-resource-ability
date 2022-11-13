//
//  DefaultLatestResourceLoader.swift
//  
//
//  Created by 黄磊 on 2022/11/13.
//

import Ability
import Combine
import Foundation

public final class DefaultLatestResourceLoader: LatestResourceAbility {
    
    var resourceDir : String
    var mapPublisher = [String:CurrentValueSubject<Data?, Never>]()
    var bundle: Bundle
    var jsonDecoder: JSONDecoder
    
    public init(
        bundle: Bundle = .main,
        resourceDir: String = "latest-resource",
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.bundle = bundle
        self.resourceDir = resourceDir
        self.jsonDecoder = jsonDecoder
    }
    
    /// 加载对应名称的最新资源
    ///
    /// - Parameter name: 对应最新资源的名称
    /// - Parameter type: 资源对应解码类型
    /// - Returns: 对应资源数据发布者
    public func load<T: Decodable>(_ name: String, as type: T.Type) -> AnyPublisher<T?, Never> {
        // 只读取项目文件
        self.loadIn(bundle, name, of: T.self).map(transformToModel).eraseToAnyPublisher()
    }
    
    /// 从对应 Bundle 中加载资源，这里返回数据是 Data，因为还有其他地方需要使用，T 传进去只是为了判断是否为数组
    func loadIn<T:Decodable>(_ bundle: Bundle, _ name: String, of type: T.Type) -> CurrentValueSubject<Data?, Never> {
        if let publisher = mapPublisher[name] {
            return publisher
        }
        // 只读取项目文件
        let publisher : CurrentValueSubject<Data?, Never> = .init(nil)
        mapPublisher[name] = publisher
        guard var resourcePath = bundle.resourcePath else {
            return publisher
        }
        let fileManager = FileManager.default
        do {
            if !self.resourceDir.isEmpty {
                resourcePath += "/\(self.resourceDir)/"
            } else {
                resourcePath += "/"
            }
            // 优先查找 json
            let filePath = resourcePath + name + ".json"
            if fileManager.fileExists(atPath: filePath) {
                let data = fileManager.contents(atPath: filePath)
                publisher.send(data)
            } else {
                // 没有 json 再查找 plist
                let plistFilePath = resourcePath + name + ".plist"
                if fileManager.fileExists(atPath: plistFilePath) {
                    var format = PropertyListSerialization.PropertyListFormat.xml
                    if let xmlData = fileManager.contents(atPath: plistFilePath) {
                        let object = try PropertyListSerialization.propertyList(from: xmlData, options: .mutableContainersAndLeaves, format: &format)
                        let data = try JSONSerialization.data(withJSONObject: object, options: .fragmentsAllowed)
                        publisher.send(data)
                    }
                }
            }
            return publisher
        } catch {
            print(error)
            return publisher
        }
    }
    
    public func transformToModel<T:Decodable>(_ data: Data?) -> T? {
        do {
            if let data = data {
                return try jsonDecoder.decode(T.self, from: data)
            }
            return nil
        } catch {
            print(error)
            return nil
        }
    }
}
