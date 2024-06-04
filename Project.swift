import ProjectDescription

let project = Project(
    name: "ProtocolDrivenCellBuilder",
    targets: [
        .target(
            name: "ProtocolDrivenCellBuilder",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.ProtocolDrivenCellBuilder",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["ProtocolDrivenCellBuilder/Sources/**"],
            resources: ["ProtocolDrivenCellBuilder/Resources/**"],
            dependencies: [
                .external(name: "Alamofire"),
                .external(name: "Then"),
                .external(name: "SnapKit"),
                .external(name: "CombineExt"),
                .external(name: "CombineCocoa")
            ]
        ),
        .target(
            name: "ProtocolDrivenCellBuilderTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.ProtocolDrivenCellBuilderTests",
            infoPlist: .default,
            sources: ["ProtocolDrivenCellBuilder/Tests/**"],
            resources: [],
            dependencies: [.target(name: "ProtocolDrivenCellBuilder")]
        ),
    ]
)
