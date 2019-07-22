//
//  Interceptor.swift
//  Demo
//
//  Created by Vaishu on 17/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

class Interceptor: RequestAdapter, RequestRetrier {
    
    private typealias RefreshCompletion = (_ succeeded: Bool, _ jwToken: String?, _ refreshToken: String?) -> Void
    
    private let Manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    private var clientId: String
    private var domain: String
    private var baseURL: String
    private var jwToken: String?
    private var refreshToken: String?
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    
    public init(clientId: String, domain: String, baseURL: String, jwToken: String?, refreshToken: String?) {
        self.clientId = clientId
        self.baseURL = baseURL
        self.jwToken = jwToken
        self.refreshToken = refreshToken
        self.domain = domain
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        guard let token = jwToken else {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            return urlRequest
        }
        
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, jwToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let jwToken = jwToken, let refreshToken = refreshToken {
                        strongSelf.jwToken = jwToken
                        strongSelf.refreshToken = refreshToken
                        
                        // clear previous jwt from keychain and set brand new token
                        let keychain = KeychainSwift()
                        keychain.delete("id_token")
                        keychain.set(jwToken, forKey: "id_token")
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        
        debugPrint("Intercepted a failed request ->>>>>")
        debugPrint("Interceptor will keep retrying ->>>>>")
        
        guard !isRefreshing else {
            return
        }
        
        isRefreshing = true
        
        let parameters: [String: Any] = [
            "refresh_token": refreshToken!,
            "client_id": clientId
           // "grant_type": Constants.Authentication.grantType
        ]
        print(self.domain + "/delegation")
        Manager.request("https://" + self.domain + "/delegation", method: .post, parameters: parameters).responseJSON { [weak self] response in
            guard let strongSelf = self else {
                return
            }
            
            switch response.result {
            case .success:
                let result = response.result.value as! NSDictionary
                let jwToken = result.object(forKey: "id_token")! as! String
                completion(true, jwToken, strongSelf.refreshToken)
            case .failure: break
            }
            
            strongSelf.isRefreshing = false
        }
        
    }
}
