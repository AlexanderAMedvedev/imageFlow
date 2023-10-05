//
//  ProfileService.swift
//  imageFlow
//
//  Created by Александр Медведев on 18.09.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private (set) var profile: Profile?
    private enum NetworkError: Error {
        case codeError
    }
    private var task: URLSessionDataTask?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let url = URL(string: "https://api.unsplash.com/me") else {return}
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                
                DispatchQueue.main.async { completion(.failure(NetworkError.codeError))
                }
                return
            }
            
            guard let data = data else { return }
            do {
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                guard let self = self else { return }
                DispatchQueue.main.async { self.profile = Profile(username: profileResult.username,
                                                                  name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")",
                                                                  loginName: "@\(profileResult.username)",
                                                                  bio: "\(profileResult.bio ?? "")")
                    print("HINT profile data \(self.profile)")
                }
                DispatchQueue.main.async { ProfileImageService.shared.fetchProfileImageURL(self.profile!.username, token) { _ in } }
                
                DispatchQueue.main.async { completion(.success(self.profile!))
                    self.task = nil
                }
            } catch {
                print("Failed to parse the downloaded profile")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
            task!.resume()
    }
}
