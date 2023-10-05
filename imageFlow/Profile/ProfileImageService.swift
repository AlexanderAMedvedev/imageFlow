//
//  ProfileImageService.swift
//  imageFlow
//
//  Created by Александр Медведев on 22.09.2023.
//

import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private var task: URLSessionDataTask?
    private enum NetworkError: Error {
        case codeError
    }
    private (set) var profileSmallImageURL: String?
    func fetchProfileImageURL(_ username: String,
                              _ token: String,
                              _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {return}

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    DispatchQueue.main.async { completion(Result.failure(error)) }
                    return
                }
                
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    DispatchQueue.main.async { completion(.failure(NetworkError.codeError)) }
                    return
                }
                
                guard let data = data else { return }
                do {
                    let UserResult = try JSONDecoder().decode(UserResult.self, from: data)
                    guard let self = self else { return }
                    self.profileSmallImageURL = UserResult.profileImageURLs["small"]
                    
                    print("URL \(self.profileSmallImageURL!)")
                    
                    DispatchQueue.main.async { completion(.success(self.profileSmallImageURL!))
                        self.task = nil
                    }
                    NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,       // 3
                            object: self,                                          // 4
                            userInfo: ["URL": self.profileSmallImageURL!])         // 5
                } catch {
                    print("Failed to parse the downloaded file")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
            task!.resume() 
    }
}
