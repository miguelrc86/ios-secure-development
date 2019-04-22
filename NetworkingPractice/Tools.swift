//
//  Tools.swift
//  ATSPractice
//
//  Created by Miguel D Rojas Cortés on 4/20/19.
//  Copyright © 2019 MRC. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get
    case post
    case put
}

var authCode: String?
var oAuthRefreshToken: String?

func request(type: HTTPMethod, params: [String: String]? = nil, urlPath: String, completion: @escaping (Data?, Error?) -> Void) {
    var queryItems = [URLQueryItem]()
    
    if let parameters = params {
        for key in parameters.keys {
            queryItems.append(URLQueryItem(name: key, value: parameters[key]))
        }
    }
    
    var urlComponents = URLComponents(string: urlPath)
    urlComponents?.queryItems = queryItems
    
    if let url = urlComponents?.url {
        var request = URLRequest(url: url)
        
        request.httpMethod = type.rawValue
        request.setValue("application/x-www-form-urlencoded; charset=utf8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "cache-control")
        //    request.setValue("LeToken", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil, let response = response as? HTTPURLResponse else {
                print("GET request trouble")
                return
            }
            
            if response.statusCode == 200 {
                completion(data, nil)
            } else {
                completion(nil, error)
                print("Network request trouble with error: \(response.statusCode) \(error?.localizedDescription ?? "DAMN!")")
            }
            }.resume()
    }
    
}

final class DataDownload: NSObject, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    var fileLocation: URL?
    var isDownloaded = false
    
    func download(url: URL, fileName: String) {
        let configuration = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        guard var documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        documentsPathURL.appendPathComponent(fileName)
        fileLocation = documentsPathURL
        
        session.downloadTask(with: url).resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("File downloaded at: \(location)")
        
        if let fileLocation = fileLocation {
            do {
                try FileManager.default.moveItem(at: location, to: fileLocation)
                print("File moved to \(fileLocation)")
                isDownloaded = true
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            print("Downloaded \(totalBytesWritten) of \(totalBytesExpectedToWrite)")
        }
    }
    
}

struct JSONOAuth2: Codable {
    var access_token: String
    var expires_in: Int
    var token_type: String
    var refresh_token: String?
}
