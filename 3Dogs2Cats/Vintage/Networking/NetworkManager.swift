import Foundation

class NetworkManager {
    
    let baseURL = "https://api.pexels.com/v1"
    let apiKey = "563492ad6f91700001000001f2688721afe342fd9d84f6e8522091d6"
    
    static let shared = NetworkManager()
    
    func getAnimals(searchString: String, page: Int, completed: @escaping (Result<[Animal], NetworkError>) -> Void) {
        
        let endpoint = baseURL + "/search?query=\(searchString)&page=\(page)&per_page=60".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! // Change white space to %20 for url
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidUsername))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let vintages = try decoder.decode(JSONPayload.self, from: data)
                completed(.success(vintages.photos))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
}
