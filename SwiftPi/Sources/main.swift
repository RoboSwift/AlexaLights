import Foundation
import Glibc

var reset = false

func signalHandler(number: Int32) {
	// Do nothing
	if number == SIGINT {
		print("Exiting shortly...")
		reset = true
	}
}

signal(SIGINT, signalHandler)

let gpio = SwiftyGPIO.GPIOs(for:.RaspberryPi2)

var power1 = gpio[.P17]!
power1.direction = .OUT
var power2 = gpio[.P18]!
power2.direction = .OUT

let server = HttpServer()
server.POST["/gpio/on"] = { request in
	power1.value = 1
	power2.value = 1
	return .ok(.html("No problem"))
}

server.POST["/gpio/off"] = { request in
	power1.value = 0
	power2.value = 0
	return .ok(.html("No problem"))
}

do {
	let port: UInt16 = 9090
	print("Starting gpio server on port \(port)")
	try server.start(port)
} catch let error {
	print("Can't start server: Error: \(error)")
}

repeat {
	sleep(5)
} while(!reset)

power1.value = 0
power2.value = 0

