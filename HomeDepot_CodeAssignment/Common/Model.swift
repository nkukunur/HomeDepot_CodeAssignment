//
//  Model.swift
//  HomeDepot_CodeAssignment
//
//  Created by Naga Kukunuru on 7/13/18.
//  Copyright © 2018 Naga Kukunuru. All rights reserved.
//

import Foundation

struct Dict : Decodable {
    var key: String?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
    }
    
    init(from decoder: Decoder) throws {
        let valueArray = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try valueArray.decode(String.self,forKey: CodingKeys.key)
        self.name = try valueArray.decode(String.self, forKey: CodingKeys.name)
    }
    
    init(key: String, name: String){
        self.key = key
        self.name = name
    }
}

struct RepositResponse: Decodable {
    var name: String?
    var license: String?
    var dateCreated: String?
    var description: String?
    
    enum CodingKeys: String, CodingKey{
        case name
        case description
        case dateCreated = "created_at"
        case license
    }
    
    init(from decoder: Decoder) throws {
        let valueArray = try decoder.container(keyedBy: CodingKeys.self)
        self.dateCreated = try valueArray.decode(String.self,forKey: CodingKeys.dateCreated)
        
        do {
            self.description = try valueArray.decode(String.self, forKey: CodingKeys.description)
        } catch {
            self.description = "No description found"
        }
        
        do {
            let licenseValues = try valueArray.decode(Dict.self, forKey: CodingKeys.license)
            self.license = licenseValues.name
        } catch {
            self.license = ""
        }
        
        self.name = try valueArray.decode(String.self, forKey: CodingKeys.name)
    }
}
