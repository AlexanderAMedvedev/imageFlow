//
//  ImagesListService.swift
//  imageFlow
//
//  Created by Александр Медведев on 03.10.2023.
//

import Foundation

final class ImagesListService {
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    private var task: URLSessionDataTask?
    
    let imagesPerPage = 10
    
    func fetchPhotosNextPage() {
                // Check, that the function is called within the main queue
        assert(Thread.isMainThread)
                // If the task is active the next task is not started, function returns back
        if let task = task {
            print("The page of photos is downloading")
            return
        }
                // make GET request with parameter 'page'
                  // calculate the number of the page to be downloaded
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
                // get the requested data from server in format [PhotoResult]
        // prepare url
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(imagesPerPage)") else {return}
        // make request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = oauth2TokenStorage.token else { print("The token is not right"); return }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // make task,
          // write the closure for dataTask
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {return}
            if let error = error {
                print("HINT photos error \(error)")
                return
            }
            
            print("HINT photos response \(response)")
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
               return
            }
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let initialPhotosPage = try decoder.decode([PhotoResult].self, from: data)
                print("HINT photos initial\(initialPhotosPage)")
                // convert the new data to format [Photo]
                let nextPagePhotosForTable = self.convert(initialPhotosPage)
                // add new data to array photos within the main Thread to the end of the array photos
                DispatchQueue.main.async {
                    for i in 0..<self.imagesPerPage {
                        self.photos.append(nextPagePhotosForTable[i])
                    }
                    print("HINT photos final \(self.photos)")
                    NotificationCenter.default.post(
                        //post - Creates a notification(уведомление) with a given name, sender, and information and posts it to the notification center.
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["Photos": self.photos])
                    self.task = nil
                }
            } catch {
                print("Failed to parse the downloaded file")
            }
        }
            task!.resume()
    }
}
extension ImagesListService {
    
    private func convert(_ from: [PhotoResult]) -> [Photo] {
        var pagePhotos: [Photo]=[]
        for i in 0..<imagesPerPage {
            pagePhotos.append(Photo(id: from[i].id,
                                  size: CGSize(width: from[i].width, height: from[i].height),
/// convert "2023-09-23T19:19:34Z": String ---> 2016-05-03?: Date
                                  createdAt: Date(),
                                  description: from[i].description ?? "",
                                  thumbImageURL: from[i].urls.thumb,
                                  largeImageURL: from[i].urls.full,
                                  likedByUser: from[i].likedByUser))
        }
        return pagePhotos
    }
    
    func convertDate(from stringInput: String) -> String {
        let dateFormatterInput = DateFormatter()
        // DateFormatter(Форматировщик) - A formatter that converts between dates and their textual representations.
        dateFormatterInput.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        let dateFormatterUI = DateFormatter()
        dateFormatterUI.dateStyle = .long
        dateFormatterUI.timeStyle = .none
        
        guard let date = dateFormatterInput.date(from: stringInput) else {
            print("There was an error decoding the input string date")
            return " "
        }
            //.date - Returns a date representation of a specified string that the system interprets using the receiver’s(приемник) current settings.
        print("\(date)") // 2023-09-23 19:19:34
        return dateFormatterUI.string(from: date)
            // .string - Returns a string representation of a specified date that the system formats using the receiver’s current settings.
    }

    let inputString = "2023-09-23T19:19:34Z"
    print(convertDate(from: inputString)) // 23 сентября 2023 г.


}
/// finish the code
