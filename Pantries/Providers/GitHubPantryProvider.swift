//
//  GitHubPantryProvider.swift
//  Pantries
//
//  Created by Swain Molster on 11/24/19.
//  Copyright © 2019 End Hunger Durham. All rights reserved.
//

import Foundation

private let githubURL = URL(string: "https://raw.githubusercontent.com/end-hunger-durham/data-importer/master/pantries.json")!

private struct GitHubJSONResponse: Decodable {
    var pantries: [Pantry]
}

func loadPantriesFromGitHub(completion: @escaping ([Pantry]?) -> Void) {
    URLSession.shared
        .dataTask(with: githubURL) { data, urlResponse, error in
            guard let data = data else {
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(GitHubJSONResponse.self, from: data)
                completion(response.pantries)
            } catch {
                completion(nil)
            }
        }
        .resume()
}
