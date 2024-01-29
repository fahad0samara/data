import SwiftUI

struct UserList: View {
    @State private var users: [GitHubUser1] = []
    
    var body: some View {
        VStack {
            List(users) { user in
                VStack {
                    AsyncImage(url: URL(string: user.avatarUrl)!)
                    Text(user.login)
                    
                }
            }
            .onAppear {
                fetchData()
            }
        }
        .padding()
    }

    func fetchData() {
        Task {
            do {
                users = try await getUsers()
            } catch {
                print("Error fetching users: \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GitHubUser1: Codable, Identifiable {
    var id = UUID()
    let login: String
    let avatarUrl: String
    // Adjust the property names to match the JSON keys
    let bio: String?
    let location: String?
}




enum GHError1: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
func getUsers() async throws -> [GitHubUser1] {
    let endpoint = "https://api.github.com/users"
    guard let url = URL(string: endpoint) else {
        throw GHError1.invalidURL
    }

    do {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GHError1.invalidResponse
        }

        let jsonString = String(data: data, encoding: .utf8)
        print("JSON String: \(jsonString ?? "")")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([GitHubUser1].self, from: data)
    } catch {
        throw GHError1.invalidData
    }
}



#Preview {
    UserList()
}
