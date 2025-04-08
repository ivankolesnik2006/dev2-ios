import UIKit

class SavedPostsViewController: UITableViewController, UISearchBarDelegate {
    var allSavedPosts: [RedditPost] = []
    var filteredPosts: [RedditPost] = []
    
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Posts"
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        
        allSavedPosts = SavedPostsManager.shared.getAllSavedPosts()
        filteredPosts = allSavedPosts
        
        searchBar.delegate = self
        searchBar.placeholder = "Search by title"
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: filteredPosts[indexPath.row])
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = PostDetailsViewController(post: filteredPosts[indexPath.row])
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredPosts = allSavedPosts
        } else {
            filteredPosts = allSavedPosts.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allSavedPosts = SavedPostsManager.shared.getAllSavedPosts()
        filteredPosts = allSavedPosts
        tableView.reloadData()
    }
}
