//
//  ContentView.swift
//  data
//
//  Created by fahad samara on 1/29/24.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    var body: some View {
        VStack {
            
            AsyncImage(url: URL (string: user?.avatarUrl ?? ""))
            
            
            
            Text(user?.login ?? "login")
            
            Text(user?.bio ?? "")
            Text(user?.location ?? "")
        }
        .padding().task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invalodUrl")
                
            } catch  GHError.invalidResponse{
                print("invalidResponse")
                
            } catch  GHError.invalidData{
                print("invalidData")
            }catch {
                print("uneexpected")
            }
        }
        
        
        
        
        
    }
}

func getUser() async throws -> GitHubUser {
    let endpoint = "https://api.github.com/users/fahad"
    guard let url = URL(string: endpoint) else {
        throw GHError.invalidURL
    }
    
    let (data,response) = try await URLSession.shared.data(from: url)
    
    guard let  response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw GHError.invalidResponse
    }
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GitHubUser.self, from: data)
        
    } catch {
        throw GHError.invalidData
        
        
    }
    
}

struct GitHubUser:Codable{
    let login:String
    let avatarUrl:String
    let bio:String
    let location: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    
    
}




