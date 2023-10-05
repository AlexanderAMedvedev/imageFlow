//
//  ImagesListService.swift
//  imageFlow
//
//  Created by Александр Медведев on 03.10.2023.
//

import Foundation

final class ImagesListService {
    
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
        // make task,
          // write the closure for dataTask
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {return}
            if let error = error {
                print(error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print(response)
                return
            }
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let initialPhotosPage = try decoder.decode([PhotoResult].self, from: data)
                // convert the new data to format [Photo]
                let nextPagePhotosForTable = self.convert(initialPhotosPage)
                // add new data to array photos within the main Thread to the end of the array photos
                DispatchQueue.main.async {
                    for i in 0..<self.imagesPerPage {
                        self.photos.append(nextPagePhotosForTable[i])
                    }
                    NotificationCenter.default.post(
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
    private func convert(_ from: [PhotoResult]) -> [Photo] {
        var pagePhotos: [Photo]=[]
        for i in 0..<imagesPerPage {
            pagePhotos.append(Photo(id: from[i].id,
                                  size: CGSize(width: from[i].width, height: from[i].height),
/// convert "2016-05-03T11:00:28-04:00" to 2016-05-03: Date
                                  createdAt: Date(),
                                  description: from[i].description ?? "",
                                  thumbImageURL: from[i].urls.thumb,
                                  largeImageURL: from[i].urls.full,
                                  likedByUser: from[i].likedByUser))
        }
        return pagePhotos
    }
}
// finish the code
