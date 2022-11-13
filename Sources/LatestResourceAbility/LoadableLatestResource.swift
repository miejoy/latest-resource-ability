//
//  LoadableLatestResource.swift
//  
//
//  Created by 黄磊 on 2022/11/13.
//

import Ability
import Combine

/// 可加载最新资源协议
public protocol LoadableLatestResource {
    associatedtype Response: Decodable
    var name : String { get }
}

extension LoadableLatestResource {
    // 定义资源打开方法
    public func open() -> AnyPublisher<Response?, Never> {
        Ability.latestResource.load(name, as: Response.self)
    }
}

/// 任意最新资源
public struct AnyLatestResource<Response:Decodable> : LoadableLatestResource {
    public var name : String
    
    public init(name: String) {
        self.name = name
    }
}
