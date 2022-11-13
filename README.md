# LatestResourceAbility

LatestResourceAbility 提供最新资源获取能力，可持续监听资源状态，获取最新数据。

[![Swift](https://github.com/miejoy/latest-resource-ability/actions/workflows/test.yml/badge.svg)](https://github.com/miejoy/latest-resource-ability/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/miejoy/latest-resource-ability/branch/main/graph/badge.svg)](https://codecov.io/gh/miejoy/latest-resource-ability)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/swift-5.4-brightgreen.svg)](https://swift.org)

## 依赖

- iOS 13.0+ / macOS 10.15+
- Xcode 14.0+
- Swift 5.7+

## 简介

该模块提供如下内容：
- LatestResourceAbility : 最新资源能力协议，继承改协议，需要实现对应加载最新资源的方法
- DefaultLatestResourceLoader : 默认最新资源加载器，继承 LatestResourceAbility 协议
- Ability.latestResource : 读取当前最新资源加载器，这个加载器可以通过 Ability 提供的方式注册，默认使用 DefaultLatestResourceLoader
- LoadableLatestResource : 可加载的最新资源协议，继承改协议的是一个资源，可通过 open 方法打开并获取内容
- AnyLatestResource : 任意最新的资源，可以用这个包装任何需要加载的最新资源

## 安装

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

在项目中的 Package.swift 文件添加如下依赖:

```swift
dependencies: [
    .package(url: "https://github.com/miejoy/latest-resource-ability.git", from: "0.1.0"),
]
```

## 使用

### 使用资源定义获取数据

```swift
import LatestResourceAbility

let cancellable = AnyLatestResource<ConfigInfo>(name: "json_configs").open().sink { configInfo in
    // 使用对应 最新资源 configInfo，
    // 这里在调用 open 方法时会调用一次
    // 在当前资源更新是还会调用一次
}

// 如果需要持续监听，对应 cancellable 自行存储
cancellable.cancel()
```

### 使用最新资源加载器获取数据

```swift
import LatestResourceAbility

let cancellable = Ability.latestResource.load("json_configs", as: ConfigInfo.self).sink { configInfo in
    // 使用对应 最新资源 configInfo，
    // 这里在调用 load 方法时会调用一次
    // 在当前资源更新是还会调用一次
}

// 如果需要持续监听，对应 cancellable 自行存储
cancellable.cancel()
```

## 作者

Raymond.huang: raymond0huang@gmail.com

## License

LatestResourceAbility is available under the MIT license. See the LICENSE file for more info.


