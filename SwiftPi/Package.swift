import PackageDescription

let package = Package(
    name: "LightControl",
    dependencies: [
	    .Package(url: "https://github.com/uraimo/SwiftyGPIO.git", majorVersion: 0),
	    .Package(url: "https://github.com/httpswift/swifter", majorVersion: 1)
    ]
)
