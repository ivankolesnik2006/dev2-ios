import UIKit

class PostListViewController: UITableViewController {
    var posts: [RedditPost] = []
    var after: String?
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "/r/iOS"
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "bookmark.fill"),
            style: .plain,
            target: self,
            action: #selector(showSavedPosts)
        )
        
        fetchPosts()
    }
    
    @objc func showSavedPosts() {
        let savedVC = SavedPostsViewController()
        navigationController?.pushViewController(savedVC, animated: true)
    }
    
    func fetchPosts() {
        guard !isLoading else { return }
        isLoading = true
        
        RedditAPIClient.shared.fetchTopPosts(after: after) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.posts.append(contentsOf: data.posts)
                    self?.after = data.after
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error:", error)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = PostDetailsViewController(post: posts[indexPath.row])
        navigationController?.pushViewController(detailsVC, animated: true)
    }
        
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - scrollView.frame.size.height
        
        if position > contentHeight - 100 {
            fetchPosts()
        }
    }
}
