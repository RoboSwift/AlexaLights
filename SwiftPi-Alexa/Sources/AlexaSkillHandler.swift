import Foundation


enum LightIntent : String {
    case turnOn = "TurnOn"
    case turnOff = "TurnOff"
}

extension LightIntent {
    var response: String {
        switch self {
        case .turnOn:
            return "OK, turning on"
        case .turnOff:
            return "OK, turning off"
        }
    }
}

public class AlexaSkillHandler : RequestHandler {
	private let controller: LightController

    init(controller: LightController) {
	    self.controller = controller
    }
    
    public func handleLaunch(request: LaunchRequest, session: Session, next: @escaping (StandardResult) -> ()) {
        let response = generateResponse(message: "This skill can't be launched")
        next(.success(standardResponse: response, sessionAttributes: session.attributes))
    }
    
    public func handleIntent(request: IntentRequest, session: Session, next: @escaping (StandardResult) -> ()) {
        guard let intent = LightIntent(rawValue: request.intent.name) else {
            next(.failure(MessageError(message: "Intent not supported")))
            return
        }
        
        switch intent {
        case .turnOn:
		controller.turnOn()
        case .turnOff:
		controller.turnOff()
        }

        let response = self.generateResponse(message: intent.response)
        next(.success(standardResponse: response, sessionAttributes: session.attributes))
    }
    
    public func handleSessionEnded(request: SessionEndedRequest, session: Session, next: @escaping (VoidResult) -> ()) {
        next(.success())
    }
    
    func generateResponse(message: String) -> StandardResponse {
        let outputSpeech = OutputSpeech.plain(text: message)
        return StandardResponse(outputSpeech: outputSpeech)
    }
}
