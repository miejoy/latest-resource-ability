//
//  LatestResourceAbilityTests.swift
//  
//
//  Created by 黄磊 on 2022/11/13.
//

import Combine
@testable import Ability
import XCTest
@testable import LatestResourceAbility

final class LatestResourceAbilityTests: XCTestCase {
    
    func resetAll() {
        let resourceBundle = Bundle.module
        AbilityCenter.shared.registeAbilities([DefaultLatestResourceLoader(bundle: resourceBundle)])
    }
    
    func testLoadJsonConfigs() {
        resetAll()
        var getValueCall = 0
        let cancellable = AnyLatestResource<ConfigInfo>(name: "json_configs").open().sink { configInfo in
            
            XCTAssertNotNil(configInfo)
            XCTAssertEqual(configInfo?.string_key, "json")
            XCTAssertEqual(configInfo?.int_key, 1)
            XCTAssertEqual(configInfo?.double_key, 1.1)
            XCTAssertEqual(configInfo?.bool_key, true)
            XCTAssertEqual(configInfo?.map_key, ["second_string_key":"second_test"])
            XCTAssertEqual(configInfo?.array_key, ["test1", "test2"])
            
            getValueCall += 1
        }
        
        XCTAssertEqual(getValueCall, 1)
        cancellable.cancel()
    }
    
    func testLoadPlistConfigs() {
        resetAll()
        var getValueCall = 0
        let cancellable = AnyLatestResource<ConfigInfo>(name: "plist_configs").open().sink { configInfo in
            
            XCTAssertNotNil(configInfo)
            XCTAssertEqual(configInfo?.string_key, "plist")
            XCTAssertEqual(configInfo?.int_key, 1)
            XCTAssertEqual(configInfo?.double_key, 1.1)
            XCTAssertEqual(configInfo?.bool_key, true)
            XCTAssertEqual(configInfo?.map_key, ["second_string_key":"second_test"])
            XCTAssertEqual(configInfo?.array_key, ["test1", "test2"])
            
            getValueCall += 1
        }
        
        XCTAssertEqual(getValueCall, 1)
        cancellable.cancel()
    }
    
    func testLoadConfigsUpdate() {
        resetAll()
        var getValueCall = 0
        let cancellable = AnyLatestResource<ConfigInfo>(name: "json_configs").open().sink { configInfo in
            
            if getValueCall == 0 {
                XCTAssertNotNil(configInfo)
                XCTAssertEqual(configInfo?.string_key, "json")
                XCTAssertEqual(configInfo?.int_key, 1)
                XCTAssertEqual(configInfo?.double_key, 1.1)
                XCTAssertEqual(configInfo?.bool_key, true)
                XCTAssertEqual(configInfo?.map_key, ["second_string_key":"second_test"])
                XCTAssertEqual(configInfo?.array_key, ["test1", "test2"])
            } else if getValueCall == 1 {
                XCTAssertNil(configInfo)
            }
            
            getValueCall += 1
        }
        
        XCTAssertEqual(getValueCall, 1)
        
        let defaultLoader = AbilityCenter.shared.storage[latestResourceAbilityName.identifier] as! DefaultLatestResourceLoader
        
        defaultLoader.mapPublisher["json_configs"]?.send(nil)
        
        XCTAssertEqual(getValueCall, 2)
        cancellable.cancel()
        defaultLoader.mapPublisher.removeValue(forKey: "json_configs")
    }
    
    func testLoadNoData() {
        resetAll()
        var getValueCall = 0
        let cancellable = AnyLatestResource<ConfigInfo>(name: "json_no_data").open().sink { configInfo in
            XCTAssertNil(configInfo)
            getValueCall += 1
        }
        
        XCTAssertEqual(getValueCall, 1)
        cancellable.cancel()
    }
    
    func testLoadWrongData() {
        resetAll()
        var getValueCall = 0
        let cancellable = AnyLatestResource<ConfigInfo>(name: "plist_wrong_data").open().sink { configInfo in
            XCTAssertNil(configInfo)
            getValueCall += 1
        }
        
        XCTAssertEqual(getValueCall, 1)
        cancellable.cancel()
    }
    
    func testLoadWrongFormat() {
        resetAll()
        var getValueCall = 0
        let cancellable = AnyLatestResource<ConfigInfo>(name: "json_wrong_format").open().sink { configInfo in
            XCTAssertNil(configInfo)
            getValueCall += 1
        }
        
        XCTAssertEqual(getValueCall, 1)
        cancellable.cancel()
    }
    
    func testLoadWrongStruct() {
        resetAll()
        var getValueCall = 0
        let cancellable = AnyLatestResource<ConfigInfo>(name: "json_wrong_struct").open().sink { configInfo in
            XCTAssertNil(configInfo)
            getValueCall += 1
        }
        
        XCTAssertEqual(getValueCall, 1)
        cancellable.cancel()
    }
    
    func testLoadWithAbility() {
        resetAll()
        
        var getValueCall = 0
        let cancellable = Ability.latestResource.load("json_configs", as: ConfigInfo.self).sink { configInfo in
            XCTAssertNotNil(configInfo)
            XCTAssertEqual(configInfo?.string_key, "json")
            XCTAssertEqual(configInfo?.int_key, 1)
            XCTAssertEqual(configInfo?.double_key, 1.1)
            XCTAssertEqual(configInfo?.bool_key, true)
            XCTAssertEqual(configInfo?.map_key, ["second_string_key":"second_test"])
            XCTAssertEqual(configInfo?.array_key, ["test1", "test2"])
            
            getValueCall += 1
        }
        
        XCTAssertEqual(getValueCall, 1)
        
        cancellable.cancel()
    }
    
    // 这个只能单独测试
    func _testUserDefaultAbility() throws {
        AbilityCenter._shared = .init()
        
        let loader = Ability.latestResource as! DefaultLatestResourceLoader
        XCTAssertEqual(loader.bundle, Bundle.main)
    }
}

struct ConfigInfo: Decodable {
    let string_key: String
    let int_key: Int
    let double_key: Double
    let bool_key: Bool
    let map_key: [String: String]
    let array_key: [String]
}
