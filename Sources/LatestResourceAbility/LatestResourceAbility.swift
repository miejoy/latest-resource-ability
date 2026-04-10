//
//  LatestResourceAbility.swift
//  
//
//  Created by 黄磊 on 2022/11/13.
//

import Ability

public let latestResourceAbilityName = AbilityName(LatestResourceAbility.self)

public protocol LatestResourceAbility: AbilityProtocol & Sendable {
    func load<T: Decodable & Sendable>(_ name: String, as type: T.Type) -> AsyncStream<T?>
}

extension LatestResourceAbility {
    public static var abilityName: AbilityName { latestResourceAbilityName }
}

extension Ability {
    
    public static let latestResource : LatestResourceAbility = {
        Ability.getAbility(with: DefaultLatestResourceLoader()) as! LatestResourceAbility
    }()
}
