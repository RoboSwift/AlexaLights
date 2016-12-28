import Foundation

class LightController {

	private let power1: GPIO
	private let power2: GPIO

	init() {
		let gpio = SwiftyGPIO.GPIOs(for:.RaspberryPi2)
		self.power1 = gpio[.P17]!
		self.power2 = gpio[.P18]!
		self.power1.direction = .OUT
		self.power2.direction = .OUT
	}

	func turnOn() {
		power1.value = 1
		power2.value = 1
	}
	func turnOff() {
		power1.value = 0
		power2.value = 0
	}
}
