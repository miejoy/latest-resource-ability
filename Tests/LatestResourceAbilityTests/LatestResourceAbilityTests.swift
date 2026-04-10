//
//  LatestResourceAbilityTests.swift
//  
//
//  Created by 黄磊 on 2022/11/13.
//

@testable import Ability
import XCTest
@testable import LatestResourceAbility

final class LatestResourceAbilityTests: XCTestCase {
    
    func resetAll() {
        let resourceBundle = Bundle.module
        AbilityCenter.shared.registerAbilities([.init(DefaultLatestResourceLoader(bundle: resourceBundle))])
    }
    
    func testLoadJsonConfigs() async {
        resetAll()
        var iterator = AnyLatestResource<ConfigInfo>(name: "json_configs").open().makeAsyncIterator()
        let configInfo = await iterator.next()!
        
        XCTAssertNotNil(configInfo)
        XCTAssertEqual(configInfo?.string_key, "json")
        XCTAssertEqual(configInfo?.int_key, 1)
        XCTAssertEqual(configInfo?.double_key, 1.1)
        XCTAssertEqual(configInfo?.bool_key, true)
        XCTAssertEqual(configInfo?.map_key, ["second_string_key":"second_test"])
        XCTAssertEqual(configInfo?.array_key, ["test1", "test2"])
    }
    
    func testLoadPlistConfigs() async {
        resetAll()
        var iterator = AnyLatestResource<ConfigInfo>(name: "plist_configs").open().makeAsyncIterator()
        let configInfo = await iterator.next()!
        
        XCTAssertNotNil(configInfo)
        XCTAssertEqual(configInfo?.string_key, "plist")
        XCTAssertEqual(configInfo?.int_key, 1)
        XCTAssertEqual(configInfo?.double_key, 1.1)
        XCTAssertEqual(configInfo?.bool_key, true)
        XCTAssertEqual(configInfo?.map_key, ["second_string_key":"second_test"])
        XCTAssertEqual(configInfo?.array_key, ["test1", "test2"])
    }
    
    func testLoadConfigsUpdate() async {
        resetAll()
        var iterator = AnyLatestResource<ConfigInfo>(name: "json_configs").open().makeAsyncIterator()
        
        // 收到初始值
        let first = await iterator.next()!
        XCTAssertNotNil(first)
        XCTAssertEqual(first?.string_key, "json")
        XCTAssertEqual(first?.int_key, 1)
        XCTAssertEqual(first?.double_key, 1.1)
        XCTAssertEqual(first?.bool_key, true)
        XCTAssertEqual(first?.map_key, ["second_string_key":"second_test"])
        XCTAssertEqual(first?.array_key, ["test1", "test2"])
        
        let defaultLoader = AbilityCenter.shared.storage[latestResourceAbilityName.identifier] as! DefaultLatestResourceLoader
        
        // 触发更新
        defaultLoader.update("json_configs", with: nil)
        
        let second = await iterator.next()!
        XCTAssertNil(second)
        
        defaultLoader.mapPublisher.removeValue(forKey: "json_configs")
    }
    
    func testLoadNoData() async {
        resetAll()
        var iterator = AnyLatestResource<ConfigInfo>(name: "json_no_data").open().makeAsyncIterator()
        let configInfo = await iterator.next()!
        XCTAssertNil(configInfo)
    }
    
    func testLoadWrongData() async {
        resetAll()
        var iterator = AnyLatestResource<ConfigInfo>(name: "plist_wrong_data").open().makeAsyncIterator()
        let configInfo = await iterator.next()!
        XCTAssertNil(configInfo)
    }
    
    func testLoadWrongFormat() async {
        resetAll()
        var iterator = AnyLatestResource<ConfigInfo>(name: "json_wrong_format").open().makeAsyncIterator()
        let configInfo = await iterator.next()!
        XCTAssertNil(configInfo)
    }
    
    func testLoadWrongStruct() async {
        resetAll()
        var iterator = AnyLatestResource<ConfigInfo>(name: "json_wrong_struct").open().makeAsyncIterator()
        let configInfo = await iterator.next()!
        XCTAssertNil(configInfo)
    }
    
    func testLoadWithAbility() async {
        resetAll()
        
        var iterator = Ability.latestResource.load("json_configs", as: ConfigInfo.self).makeAsyncIterator()
        let configInfo = await iterator.next()!
        
        XCTAssertNotNil(configInfo)
        XCTAssertEqual(configInfo?.string_key, "json")
        XCTAssertEqual(configInfo?.int_key, 1)
        XCTAssertEqual(configInfo?.double_key, 1.1)
        XCTAssertEqual(configInfo?.bool_key, true)
        XCTAssertEqual(configInfo?.map_key, ["second_string_key":"second_test"])
        XCTAssertEqual(configInfo?.array_key, ["test1", "test2"])
    }
    
    // 这个只能单独测试
    func _testUserDefaultAbility() throws {
        AbilityCenter._shared = .init()
        
        let loader = Ability.latestResource as! DefaultLatestResourceLoader
        XCTAssertEqual(loader.bundle, Bundle.main)
    }
}

final class AsyncStreamMapTests: XCTestCase {

    func testMapSync() async {
        let stream = AsyncStream<Int> { continuation in
            continuation.yield(1)
            continuation.yield(2)
            continuation.yield(3)
            continuation.finish()
        }
        var iterator = stream.map { $0 * 2 }.makeAsyncIterator()
        let results = await [iterator.next(), iterator.next(), iterator.next(), iterator.next()]
        XCTAssertEqual(results, [2, 4, 6, nil])
    }

    func testMapAsync() async {
        let stream = AsyncStream<Int> { continuation in
            continuation.yield(10)
            continuation.yield(20)
            continuation.finish()
        }
        var iterator = stream.map { value async -> Int in
            // 模拟异步操作
            try? await Task.sleep(nanoseconds: 1_000)
            return value + 1
        }.makeAsyncIterator()
        let results = await [iterator.next(), iterator.next(), iterator.next()]
        XCTAssertEqual(results, [11, 21, nil])
    }

    func testMapTransformsType() async {
        let stream = AsyncStream<Int> { continuation in
            continuation.yield(42)
            continuation.finish()
        }
        var iterator = stream.map { "\($0)" }.makeAsyncIterator()
        let value = await iterator.next()
        XCTAssertEqual(value, "42")
    }
}

struct ConfigInfo: Decodable, Sendable {
    let string_key: String
    let int_key: Int
    let double_key: Double
    let bool_key: Bool
    let map_key: [String: String]
    let array_key: [String]
}
