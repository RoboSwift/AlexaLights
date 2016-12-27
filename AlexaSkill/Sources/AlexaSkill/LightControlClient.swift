//
//  LightControlClient.swift
//  AlexaSkill
//
//  Created by Miguel on 27/12/2016.
//
//

import Foundation

fileprivate let lightControlHost = "miqu-swiftpi.ydns.eu"
fileprivate let lightControlPort = 9090

typealias LightControlResponse = (Bool) -> Void

class LightControlClient {
    func requestOn(completion: @escaping LightControlResponse) {
        var request = URLRequest(url: baseURL.appendingPathComponent("gpio/on"))
        request.httpMethod = "POST"
        let task = buildTask(with: request, completion: completion)
        task.resume()
    }
    
    func requestOff(completion: @escaping LightControlResponse) {
        var request = URLRequest(url: baseURL.appendingPathComponent("gpio/off"))
        request.httpMethod = "POST"
        let task = buildTask(with: request, completion: completion)
        task.resume()
    }
    
    let session: URLSession = URLSession(configuration: .default)
    
    var baseURL: URL {
        return URL(string: "http://\(lightControlHost):\(lightControlPort)")!
    }
    
    private func buildTask(with request: URLRequest, completion: @escaping LightControlResponse) -> URLSessionDataTask {
        return session.dataTask(with: request) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            switch (statusCode, error) {
            case (200, nil):
                completion(true)
            default:
                completion(false)
            }
        }
    }
}
