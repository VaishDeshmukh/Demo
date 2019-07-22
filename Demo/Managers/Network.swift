//
//  Network.swift
//  Demo
//
//  Created by Vaishu on 17/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift
import JWTDecode
import Auth0

class Network {
    static let shared = Network()
    
    private static let session: SessionManager = {
        return SessionManager(configuration: URLSessionConfiguration.default)
    }()
    enum Endpoints {
        
        case login([String : Any])
        case getMovies([String : Any])
        case getMovieDetail([String: Any])
        case getSimilarMovies([String : Any])
        
        internal var method: HTTPMethod {
            switch self {
            case .login: return HTTPMethod.get
            case .getMovies: return HTTPMethod.get
            case .getMovieDetail: return HTTPMethod.get
            case .getSimilarMovies: return HTTPMethod.get
            }}
        
        internal var urlString: URLConvertible {
            switch self {
            case .login:
                return ""
            case .getMovies:
                return Constants.moviesURL + "now_playing?api_key=2759736974789ab8e9bac43e20ce3ffd"
            case .getMovieDetail(let data):
                let mediaId = data.valueForKeyPath(keyPath: "movie_id")!
                return Constants.moviesURL + "\(mediaId)/" + Constants.api
            case .getSimilarMovies(let data):
                let mediaId = data.valueForKeyPath(keyPath: "id")!
                return Constants.moviesURL + "\(mediaId)/similar" + Constants.api
            }
        }
        
        internal var parameters: Parameters? {
            var params: Parameters?
            
            switch self {
                
            case .login:
                return nil

            case .getMovies(let data):
                params = data
                break
                
            case .getMovieDetail(let data):
                params = data
                break
                
            case .getSimilarMovies(let data):
                params = data
                break
            }
            return params as Parameters?
        }
            
        internal var encoding: ParameterEncoding? {
            var encodingType: ParameterEncoding?
            
            switch self {
                
            case .login:
                return URLEncoding.default
                
            case .getMovies:
                encodingType = URLEncoding.default
                break
                
            case .getMovieDetail:
                encodingType = URLEncoding.default
                break
                
            case .getSimilarMovies:
                encodingType = URLEncoding.default
                break
            }
            return encodingType as ParameterEncoding?
        }
        
    }
    
    // MARK: - Request Broker
    
    func request(endpoint: Network.Endpoints, completion: @escaping (DataResponse<Any>) -> Void) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        print("Cooking a reqest to server... 🍳🍭☕🍲")
        print("Endpoint: \(endpoint)")
        print("HttpMethod: \(endpoint.method)")
        print("UrlString: \(endpoint.urlString)")
        print("Parameters: \(String(describing: endpoint.parameters))")
        
        let keychain = KeychainSwift()
        //let path = Bundle.main.path(forResource: "Auth0", ofType: "plist")
        //let values = NSDictionary(contentsOfFile: path!) as? [String: Any]
        let clientId = "HooQDemo"
        let domain = "themoviedb"
        
        let interceptor = Interceptor(
            clientId: clientId,
            domain: domain,
            baseURL: Constants.baseURL,
            jwToken: keychain.get("id_token"),
            refreshToken: keychain.get("refresh_token")
        )
    
        Network.session.adapter = interceptor
        Network.session.retrier = interceptor
        
        let request = Network.session.request(
            endpoint.urlString,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.encoding!
            ).validate().responseJSON { response in
                completion(response)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        print("request: \(request)")
        
//        print("request headers: \(String(describing: request.request?.allHTTPHeaderFields))")
    }
    // MARK: - Upload Request Broker
    
    func cancel() {
        Network.session.session.getAllTasks { tasks in
            tasks.forEach({
                $0.cancel()
            })
        }
    }
    
    func suspend() {
        Network.session.session.getAllTasks { (tasks) in
            tasks.forEach({
                $0.suspend()
            })
        }
    }
    
    func resume() {
        Network.session.session.getAllTasks { (tasks) in
            tasks.forEach({
                $0.resume()
            })
        }
    }
    
    func isReachable() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    func listen(completion: @escaping (Bool) -> Void) {
        let reachabilityManager = NetworkReachabilityManager()
        reachabilityManager?.startListening()
        
        reachabilityManager?.listener = {status in
            if reachabilityManager?.isReachable ?? false {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
}
