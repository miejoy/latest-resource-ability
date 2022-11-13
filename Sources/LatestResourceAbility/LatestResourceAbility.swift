//
//  LatestResourceAbility.swift
//  
//
//  Created by 黄磊 on 2022/11/13.
//

import Ability
import Combine

public let latestResourceAbilityName = AbilityName(LatestResourceAbility.self)

public protocol LatestResourceAbility: AbilityProtocol {
    func load<T:Decodable>(_ name: String, as type: T.Type) -> AnyPublisher<T?,Never>
}

extension LatestResourceAbility {
    public static var abilityName: AbilityName { latestResourceAbilityName }
}

extension Ability {
    public static var latestResource : LatestResourceAbility = {
        Ability.getAbility(with: DefaultLatestResourceLoader()) as! LatestResourceAbility
    }()
}
