# LatestResourceAbility

LatestResourceAbility 提供最新资源获取能力，可持续监听资源状态，获取最新数据。

[![Swift](https://github.com/miejoy/latest-resource-ability/actions/workflows/test.yml/badge.svg)](https://github.com/miejoy/latest-resource-ability/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/miejoy/latest-resource-ability/branch/main/graph/badge.svg)](https://codecov.io/gh/miejoy/latest-resource-ability)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/swift-6.2-brightgreen.svg)](https://swift.org)

## 依赖

- iOS 14.0+ / macOS 11.0+
- Xcode 26.0+
- Swift 6.2+

## 简介

该模块提供如下内容：
- LatestResourceAbility : 最新资源能力协议，继承该协议，需要实现对应加载最新资源的方法
- DefaultLatestResourceLoader : 默认最新资源加载器，继承 LatestResourceAbility 协议
- Ability.latestResource : 读取当前最新资源加载器，这个加载器可以通过 Ability 提供的方式注册，默认使用 DefaultLatestResourceLoader
- LoadableLatestResource : 可加载的最新资源协议，继承该协议的是一个资源，可通过 open 方法打开并获取内容
- AnyLatestResource : 任意最新的资源，可以用这个包装任何需要加载的最新资源
- AsyncCurrentValue : 类似 CurrentValueSubject 的 async/await 封装，内部缓存最新值，支持多订阅者持续推送更新

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

// 获取初始值
var iterator = AnyLatestResource<ConfigInfo>(name: "json_configs").open().makeAsyncIterator()
let configInfo = await iterator.next()

// 持续监听资源更新
Task {
    for await configInfo in AnyLatestResource<ConfigInfo>(name: "json_configs").open() {
        // 使用对应的最新资源 configInfo
        // open() 调用时会立即收到一次当前值
        // 资源更新时还会继续收到新值
    }
}
```

### 使用最新资源加载器获取数据

```swift
import LatestResourceAbility

// 获取初始值
var iterator = Ability.latestResource.load("json_configs", as: ConfigInfo.self).makeAsyncIterator()
let configInfo = await iterator.next()

// 持续监听资源更新
Task {
    for await configInfo in Ability.latestResource.load("json_configs", as: ConfigInfo.self) {
        // 使用对应的最新资源 configInfo
        // load() 调用时会立即收到一次当前值
        // 资源更新时还会继续收到新值
    }
}
```

### 使用 AsyncCurrentValue 自定义持续推送

```swift
import LatestResourceAbility

// 创建一个持有当前值的 subject
let subject = AsyncCurrentValue<Int>()

// 订阅：立即收到当前值（若已有），后续更新时继续收到
let stream = AsyncStream<Int> { continuation in
    subject.add(continuation)
}
Task {
    for await value in stream {
        print("收到值：\(value)")
    }
}

// 推送新值，所有订阅者都会收到
subject.send(42)
subject.send(100)
```

## 作者

Raymond.huang: raymond0huang@gmail.com

## License

LatestResourceAbility is available under the MIT license. See the LICENSE file for more info.

