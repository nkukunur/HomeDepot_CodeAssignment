//
//  WebService.swift
//  HomeDepot_CodeAssignment
//
//  Created by Naga Kukunuru on 7/13/18.
//  Copyright © 2018 Naga Kukunuru. All rights reserved.
//

import Foundation

class WebService {
    static let webService = WebService()
    
    var repositResponses:[RepositResponse]? = [RepositResponse]()
    
    let defaults = UserDefaults.standard
    let base_url = "https://api.github.com/users/"
    
    func getData(org_name: String, page: Int, completion: @escaping (_ success: Bool)-> ()){
        let txt = "\(base_url)" + (org_name) + "/repos?page=" + String(page) + "&per_page=10"
        let url = URL(string: txt)!
        print(url)
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else {
                print("No data received")
                return
            }
            DispatchQueue.main.async {
                print(data)
            }
            do {
                let jsonData = try JSONDecoder().decode([RepositResponse]?.self, from: data)
                
                DispatchQueue.main.async {
                    if let json = jsonData {
                        self.repositResponses?.append(contentsOf: json)
                    }
                    completion(true)
                }
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
}
