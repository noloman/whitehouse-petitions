//
//  Petition.swift
//  Whitehouse Petitions
//
//  Created by Manu on 20/04/2021.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
