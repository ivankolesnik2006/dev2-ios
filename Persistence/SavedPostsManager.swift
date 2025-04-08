import Foundation

class SavedPostsManager {
    static let shared = SavedPostsManager()
    private let fileName = "savedPosts.json"
    private var savedPosts: [RedditPost] = []
    
    private init() {
        loadPosts()
    }
    
    private func getFileURL() -> URL? {
        let fm = FileManager.default
        guard let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsURL.appendingPathComponent(fileName)
    }
    
    func loadPosts() {
        guard let url = getFileURL() else { return }
        do {
            let data = try Data(contentsOf: url)
            let posts = try JSONDecoder().decode([RedditPost].self, from: data)
            self.savedPosts = posts
        } catch {
            print("Error: \(error)")
        }
    }
    
    func savePosts() {
        guard let url = getFileURL() else { return }
        do {
            let data = try JSONEncoder().encode(savedPosts)
            try data.write(to: url)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func isPostSaved(_ post: RedditPost) -> Bool {
        return savedPosts.contains(where: { $0.id == post.id })
    }
    
    func toggleSaved(for post: RedditPost) {
        if let index = savedPosts.firstIndex(where: { $0.id == post.id }) {
            savedPosts.remove(at: index)
        } else {
            savedPosts.append(post)
        }
        savePosts()
    }
    
    func getAllSavedPosts() -> [RedditPost] {
        return savedPosts
    }
}
