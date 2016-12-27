import Foundation
import AlexaSkillsKit


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
    public init() {
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
        
        let completion: LightControlResponse = { ok in
            guard ok else  {
                next(.failure(MessageError(message: "There was an error with the lights")))
                return
            }
            
            let response = self.generateResponse(message: intent.response)
            next(.success(standardResponse: response, sessionAttributes: session.attributes))
        }
        
        let client = LightControlClient()
        
        switch intent {
        case .turnOn:
            client.requestOn(completion: completion)
        case .turnOff:
            client.requestOff(completion: completion)
        }
    }
    
    public func handleSessionEnded(request: SessionEndedRequest, session: Session, next: @escaping (VoidResult) -> ()) {
        next(.success())
    }
    
    func generateResponse(message: String) -> StandardResponse {
        let outputSpeech = OutputSpeech.plain(text: message)
        return StandardResponse(outputSpeech: outputSpeech)
    }
}
