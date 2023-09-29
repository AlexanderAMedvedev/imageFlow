//
//  OAuth2Service.swift
//  imageFlow
//
//  Created by Александр Медведев on 12.08.2023.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    // Ожидаю ответ
    private let urlSession = URLSession.shared
    // URLSession: An object that coordinates a group of related, network (вычислительная сеть) data transfer tasks.
    // shared: The shared singleton(одиночный элемент) session object.
    private (set) var authToken: String? {
    // private (set):  the getter for authToken is public, but the setter is private
        get {
                return OAuth2TokenStorage().token
            }
        set {
                OAuth2TokenStorage().token = newValue
    } }
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(
                        _ code: String,
                        completion: @escaping (Result<String, Error>) -> Void ){
        assert(Thread.isMainThread)
        //Thread: A thread of execution.
        //assert(утверждать): Performs a traditional C-style assert with an optional message.
                if task != nil {                                    // 5
                    if lastCode != code {                           // 6
                        task?.cancel()                              // 7
                    } else {
                        return                                      // 8
                    }
                } else {
                    if lastCode == code {                           // 9
                        return
                    }
                }
                lastCode = code
            let request = authTokenRequest(code: code)
        //Authorization: Авторизация;     Request: просьба
            let task = object(for: request) { [weak self] result in
            // private func object(
            //  for request: URLRequest,
            //  completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
            //  ) -> URLSessionTask {
                guard let self = self else { return }
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                            //  struct OAuthTokenResponseBody: Decodable {
                            //     let accessToken: String
                    self.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
    } }
            task.resume()
        }
}
    extension OAuth2Service {
        private func object(
            for request: URLRequest,
            completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
        ) -> URLSessionTask {
     // URLSessionTask: A task, like downloading a specific resource, performed in a URL session.
            let decoder = JSONDecoder()
            return urlSession.data(for: request) { (result: Result<Data, Error>) in
                let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                    Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
    }
                completion(response)
            }
    }
        private func authTokenRequest(code: String) -> URLRequest {
            URLRequest.makeHTTPRequest(
                //URLRequest: A URL load request that is independent of protocol or URL scheme.
                path: "/oauth/token"
                + "?client_id=\(AccessKey)"
                + "&&client_secret=\(SecretKey)"
                + "&&redirect_uri=\(RedirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                httpMethod: "POST",
                baseURL: URL(string: "https://unsplash.com")!
    ) }
         struct OAuthTokenResponseBody: Decodable {
            let accessToken: String
            let tokenType: String
            let scope: String
            let createdAt: Int
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case tokenType = "token_type"
                case scope
                case createdAt = "created_at"
            }
    }
    }
    // MARK: - HTTP Request
    // Если в вашем в проекте уже объявлена переменная `DefaultBaseURL` (с тем же значением),
    // то строчку ниже можно удалить.
   // fileprivate let DefaultBaseURL = URL(string: "https://api.unsplash.com")!

    extension URLRequest {
        static func makeHTTPRequest(
            path: String,
            httpMethod: String,
            baseURL: URL = DefaultBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
               request.httpMethod = httpMethod
               return request
       } }
       // MARK: - Network Connection
       enum NetworkError: Error {
           case httpStatusCode(Int)
           case urlRequestError(Error)
           case urlSessionError
       }
       extension URLSession {
           func data(
               for request: URLRequest,
               completion: @escaping (Result<Data, Error>) -> Void
           ) -> URLSessionTask {
               let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
                   DispatchQueue.main.async {
                       completion(result)
                   }
       }
               let task = dataTask(with: request, completionHandler: { data, response, error in
                   if let data = data,
                       let response = response,
                       let statusCode = (response as? HTTPURLResponse)?.statusCode
                   {
                       if 200 ..< 300 ~= statusCode {
                           fulfillCompletion(.success(data))
                       } else {
                           fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                       }
                   } else if let error = error {
                       fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
                   } else {
                       fulfillCompletion(.failure(NetworkError.urlSessionError))
                   }
               })
               task.resume()
               return task
       }
    }
