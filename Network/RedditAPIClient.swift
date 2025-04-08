import Foundation

class RedditAPIClient {
    static let shared = RedditAPIClient()
    
    private init() {}

    func fetchTopPosts(after: String?, limit: Int = 20, completion: @escaping (Result<(posts: [RedditPost], after: String?), Error>) -> Void) {
        var urlString = "https://www.reddit.com/r/ios/top.json?limit=\(limit)"
        if let after = after {
            urlString += "&after=\(after)"
        }
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("MyRedditApp/1.0 (by /u/ivankolesnyk)", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(RedditResponse.self, from: data)
                var posts = decoded.data.children.map { $0.data }
                
                for i in 0..<posts.count {
                    if SavedPostsManager.shared.isPostSaved(posts[i]) {
                        posts[i].isSaved = true
                    }
                }
                
                completion(.success((posts, decoded.data.after)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
