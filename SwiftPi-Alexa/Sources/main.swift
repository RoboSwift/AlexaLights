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

let controller = LightController()

let server = HttpServer()
server["/"] = { request in
	let data = Data(bytes: request.body)
	let requestDispatcher = RequestDispatcher(requestHandler: AlexaSkillHandler(controller: controller))

	var response: HttpResponse = .internalServerError
	// Assuming synchronous execution here...
	requestDispatcher.dispatch(data: data) { result in
		if case .success(let data) = result {
			let encoded = String(data: data, encoding: .utf8) ?? ""
			response = .ok(.text(encoded))
		}
	}

	return response
}

server.POST["/gpio/on"] = { request in
	controller.turnOn()
	return .ok(.html("No problem"))
}

server.POST["/gpio/off"] = { request in
	controller.turnOff()
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

controller.turnOff()
