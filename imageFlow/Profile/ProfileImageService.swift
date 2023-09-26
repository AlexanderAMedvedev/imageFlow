//
//  ProfileImageService.swift
//  imageFlow
//
//  Created by Александр Медведев on 22.09.2023.
//

import Foundation

final class ProfileImageService {
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private var task: URLSessionDataTask?
    private enum NetworkError: Error {
        case codeError
    }
    private (set) var profileSmallImageURL: String?
    func fetchProfileImageURL(_ username: String,
                              _ token: String,
                              _ completion: @escaping (Result<String, Error>) -> Void) {
        // escape from race condition
        task?.cancel()
        // get url
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {return}
        // prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        //create and do the task
            task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Проверяем, пришла ли ошибка
                if let error = error {
                    completion(Result.failure(error))
                    return
                }
                
                // Проверяем, что нам пришёл успешный код ответа
                //пытаемся превратить  response в объект класса HTTPURLResponse
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    // || - Logical OR
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
                    let UserResult = try JSONDecoder().decode(UserResult.self, from: data)
                    self.profileSmallImageURL = UserResult.profileImageURLs["small"]
                    print("URL \(self.profileSmallImageURL!)")
                    completion(.success(self.profileSmallImageURL!))
                    NotificationCenter.default.post(
                            name: ProfileImageService.DidChangeNotification,       // 3
                            object: self,                                          // 4
                            userInfo: ["URL": self.profileSmallImageURL!])         // 5
                } catch {
                    print("Failed to parse the downloaded file")
                    completion(.failure(error))
                }
            }
            task!.resume() 
    }
}
