import Foundation

public class RequestParserV1: RequestParser {
    public var json: Any
    
    public init(json: Any = [:]) {
        self.json = json
    }
    
    public func parseSession() -> Session? {
        guard let jsonEnvelope = json as? [String: Any],
            let jsonSession = jsonEnvelope["session"] as? [String: Any],
            let isNew = jsonSession["new"] as? Bool,
            let sessionId = jsonSession["sessionId"] as? String,
            let application = RequestParserV1.parseApplication(jsonSession),
            let user = RequestParserV1.parseUser(jsonSession) else {
                return nil
        }
        
        let attributes = RequestParserV1.parseAttributes(jsonSession)
        return Session(isNew: isNew, sessionId: sessionId, application: application, attributes: attributes, user: user)
    }
    
    public func parseRequestType() -> RequestType? {
        guard let jsonEnvelope = json as? [String: Any],
            let jsonRequest = jsonEnvelope["request"] as? [String: Any],
            let type = jsonRequest["type"] as? String else {
                return nil
        }
        
        switch type {
        case "LaunchRequest": return .launch
        case "IntentRequest": return .intent
        case "SessionEndedRequest": return .sessionEnded
        default: return nil
        }
    }
    
    public func parseLaunchRequest() -> LaunchRequest? {
        guard let jsonEnvelope = json as? [String: Any],
            let jsonRequest = jsonEnvelope["request"] as? [String: Any],
            let request = RequestParserV1.parseRequest(jsonRequest) else {
                return nil
        }
        
        return LaunchRequest(request: request)
    }
    
    public func parseIntentRequest() -> IntentRequest? {
        guard let jsonEnvelope = json as? [String: Any],
            let jsonRequest = jsonEnvelope["request"] as? [String: Any],
            let request = RequestParserV1.parseRequest(jsonRequest),
            let intent = RequestParserV1.parseIntent(jsonRequest) else {
                return nil
        }
        
        return IntentRequest(request: request, intent: intent)
    }
    
    public func parseSessionEndedRequest() -> SessionEndedRequest? {
        guard let jsonEnvelope = json as? [String: Any],
            let jsonRequest = jsonEnvelope["request"] as? [String: Any],
            let request = RequestParserV1.parseRequest(jsonRequest),
            let reason = RequestParserV1.parseReason(jsonRequest) else {
                return nil
        }
        
        return SessionEndedRequest(request: request, reason: reason)
    }
}

extension RequestParserV1 {
    class func parseDate(_ string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormatter.date(from: string)
    }
    
    class func parseApplication(_ jsonSession: [String: Any]) -> Application? {
        guard let jsonApplication = jsonSession["application"] as? [String: Any],
            let applicationId = jsonApplication["applicationId"] as? String else {
                return nil
        }
        
        return Application(applicationId: applicationId)
    }
    
    class func parseAttributes(_ jsonSession: [String: Any]) -> [String: Any] {
        let attributes = jsonSession["attributes"] as? [String: Any]
        return attributes ?? [String: Any]()
    }
    
    class func parseUser(_ jsonSession: [String: Any]) -> User? {
        guard let jsonUser = jsonSession["user"] as? [String: Any],
            let userId = jsonUser["userId"] as? String else {
                return nil
        }
        
        let accessToken = jsonUser["accessToken"] as? String
        return User(userId: userId, accessToken: accessToken)
    }
    
    class func parseRequest(_ jsonRequest: [String: Any]) -> Request? {
        guard let requestId = jsonRequest["requestId"] as? String,
            let timestampString = jsonRequest["timestamp"] as? String,
            let timestamp = RequestParserV1.parseDate(timestampString),
            let localeString = jsonRequest["locale"] as? String else {
                return nil
        }
        
        return Request(requestId: requestId, timestamp: timestamp, locale: Locale(identifier: localeString))
    }
    
    class func parseSlots(_ jsonIntent: [String: Any]) -> [String: Slot] {
        var slots = [String: Slot]()
        
        if let jsonSlots = jsonIntent["slots"] as? [String: Any] {
            for (key, json) in jsonSlots {
                guard let jsonSlot = json as? [String: Any],
                    let name = jsonSlot["name"] as? String else {
                        continue
                }
                
                let value = jsonSlot["value"] as? String
                slots[key] = Slot(name: name, value: value)
            }
        }
        
        return slots
    }
    
    class func parseIntent(_ jsonRequest: [String: Any]) -> Intent? {
        guard let jsonIntent = jsonRequest["intent"] as? [String: Any],
            let name = jsonIntent["name"] as? String else {
                return nil
        }
        
        let slots = RequestParserV1.parseSlots(jsonIntent)
        return Intent(name: name, slots: slots)
    }
    
    class func parseReason(_ jsonRequest: [String: Any]) -> Reason? {
        guard let reason = jsonRequest["reason"] as? String else {
            return nil
        }
        
        switch reason {
        case "USER_INITIATED": return .userInitiated
        case "ERROR": return RequestParserV1.parseError(jsonRequest).map{ .error($0) }
        case "EXCEEDED_MAX_REPROMPTS": return .exceededMaxReprompts
        default: return .unknown
        }
    }
    
    class func parseError(_ jsonRequest: [String: Any]) -> RequestError? {
        guard let jsonError = jsonRequest["error"] as? [String: Any],
            let type = RequestParserV1.parseErrorType(jsonError),
            let message = jsonError["message"] as? String else {
                return nil
        }
        
        return RequestError(type: type, message: message)
    }
    
    class func parseErrorType(_ jsonError: [String: Any]) -> ErrorType? {
        guard let type = jsonError["type"] as? String else {
            return nil
        }
        
        switch type {
        case "INVALID_RESPONSE": return .invalidResponse
        case "DEVICE_COMMUNICATION_ERROR": return .deviceCommunicationError
        case "INTERNAL_ERROR": return .internalError
        default: return .unknown
        }
    }
}
