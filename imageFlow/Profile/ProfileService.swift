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
        task?.cancel()
        guard let url = URL(string: "https://api.unsplash.com/me") else {return}
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                    completion(.failure(error))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            //пытаемся превратить  response в объект класса HTTPURLResponse
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                //statusCode - The response’s HTTP status code.
                
                    completion(.failure(NetworkError.codeError))
                return
            }
            
            //Обрабатываем успешный ответ (Обычно ответ от сервера — это набор единиц информации в какой-либо кодировке)
            // Возвращаем данные
            guard let data = data else { return }
            do {
                //JSONDecoder() - An object that decodes instances of a data type from JSON objects.
                //decode - Returns a value of the type you specify, decoded from a JSON object.
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                self.profile = Profile(username: profileResult.username,
                                       name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")",
                                       loginName: "@\(profileResult.username)",
                                       bio: "\(profileResult.bio ?? "")")
                print("PROFILE \(self.profile)")
                ProfileImageService.shared.fetchProfileImageURL(self.profile!.username, token) { _ in }
                
                    completion(.success(self.profile!))
            } catch {
                print("Failed to parse the downloaded profile")
                
                    completion(.failure(error)) 
            }
        }
            task!.resume()
    }
}
