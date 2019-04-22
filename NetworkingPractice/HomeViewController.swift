//
//  HomeViewController.swift
//  ATSPractice
//
//  Created by Miguel D Rojas Cortés on 4/20/19.
//  Copyright © 2019 MRC. All rights reserved.
//

import UIKit
import SafariServices

extension String {
    
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
    }
    
}

final class HomeViewController: UIViewController {
    
    let clientID = "654899588599-abq0ls0mrol1v7fli6f80daap6bit2dp.apps.googleusercontent.com"
    let redirectURI: String = "\(Bundle.main.bundleIdentifier!):redirect_uri_path"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = "https://applecoding.com/wp-json/wp/v2/posts"
        
        request(type: .get, urlPath: urlString) { data, error in
            if let data = data {
                print(data)
            }
        }
        
        let download = DataDownload()
        download.download(url: URL(string: "https://speed.hetzner.de/40MB.bin")!, fileName: "FortyMBTest.bin")
        NotificationCenter.default.addObserver(self, selector: #selector(obtainOAuthToken), name: NSNotification.Name("OAuthAuthorizationCode"), object: nil)
    }
    
    //MARK: - Auth Token Service
    
    @objc private func obtainOAuthToken() {
        let parameters = ["code": authCode!, "client_id": clientID, "redirect_uri": redirectURI, "grant_type": "authorization_code"]
        
        request(type: .post, params: parameters, urlPath: "https://www.googleapis.com/oauth2/v4/token") { [weak self] data, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let tokenData = try decoder.decode(JSONOAuth2.self, from: data)
                    
                    if let refreshToken = tokenData.refresh_token {
                        oAuthRefreshToken = refreshToken
                        self?.uploadFileToGDrive(url: Bundle.main.url(forResource: "iPhoneXBg", withExtension: "jpeg")!)
                    }
                } catch let error {
                    print("We are fucked up: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func uploadFileToGDrive(url: URL) {
        guard let refresh = oAuthRefreshToken else { return }
        let parameters = ["refresh_token": refresh, "client_id": clientID, "grant_type": "refresh_token"]
        
        request(type: .post, params: parameters, urlPath: "https://www.googleapis.com/oauth2/v4/token") { [weak self] data, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let tokenData = try decoder.decode(JSONOAuth2.self, from: data)
                    self?.upload(file: url, token: tokenData.access_token)
                } catch let error {
                    print("We are fucked up: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func upload(file: URL, token: String) {
        let urlString = "https://www.googleapis.com/upload/drive/v2/files"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.uploadTask(with: request, fromFile: file) { data, response, error in
            guard let data = data, error == nil, let response = response as? HTTPURLResponse else {
                print("GET request trouble")
                return
            }
            
            if response.statusCode == 200 {
                print("Encoded data as utf8: \(String(data: data, encoding: .utf8) ?? "No Data :-O")")
            }
            }.resume()
    }
    
    @IBAction private func loginButtonWasTapped(_ sender: Any) {
        let scope = "https://www.googleapis.com/auth/drive"
        let url = "https://accounts.google.com/o/oauth2/v2/auth?client_id=\(clientID)&redirect_uri=\(redirectURI.urlEncoded)&response_type=code&scope=\(scope.urlEncoded)"
        let safariVC = SFSafariViewController(url: URL(string: url)!)
        present(safariVC, animated: true, completion: nil)
    }
    
}
