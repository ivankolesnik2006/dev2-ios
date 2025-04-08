import UIKit

class PostDetailsViewController: UIViewController {
    let post: RedditPost
    
    let postImageView = UIImageView()
    let titleLabel = UILabel()
    let authorLabel = UILabel()
    let contentLabel = UILabel()
    
    lazy var shareButton: UIBarButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(sharePost)
        )
    }()
    
    lazy var saveButton: UIBarButtonItem = {
        return UIBarButtonItem(
            title: SavedPostsManager.shared.isPostSaved(post) ? "Unsave" : "Save",
            style: .plain,
            target: self,
            action: #selector(toggleSave)
        )
    }()
    
    init(post: RedditPost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implement")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Details"
        setupUI()
        
        navigationItem.rightBarButtonItems = [shareButton, saveButton]
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(imageDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(doubleTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSaveButtonTitle()
    }
    
    private func updateSaveButtonTitle() {
        saveButton.title = SavedPostsManager.shared.isPostSaved(post) ? "Unsave" : "Save"
    }
    
    func setupUI() {
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        if let urlString = post.url, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self.postImageView.image = image
                    } else {
                        self.postImageView.image = UIImage(systemName: "photo")
                    }
                }
            }.resume()
        } else {
            postImageView.image = UIImage(systemName: "photo")
        }
        
        titleLabel.text = post.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 0
        
        authorLabel.text = "by \(post.author)"
        authorLabel.textColor = .gray
        
        contentLabel.text = post.selftext?.isEmpty == false ? post.selftext : ""
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, contentLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 12
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(postImageView)
        view.addSubview(infoStack)
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            postImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 250),
            
            infoStack.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 20),
            infoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func sharePost() {
        let itemToShare: Any
        if let urlString = post.url, let url = URL(string: urlString) {
            itemToShare = url
        } else {
            itemToShare = post.title
        }
        let activityVC = UIActivityViewController(activityItems: [itemToShare], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc func toggleSave() {
        SavedPostsManager.shared.toggleSaved(for: post)
        updateSaveButtonTitle()
    }
    
    @objc func imageDoubleTapped() {
        toggleSave()
        animateBookmarkIcon()
    }
    
    func animateBookmarkIcon() {
        let bookmarkPath = UIBezierPath()
        let width: CGFloat = 40
        let height: CGFloat = 50
        bookmarkPath.move(to: CGPoint(x: 0, y: 0))
        bookmarkPath.addLine(to: CGPoint(x: width, y: 0))
        bookmarkPath.addLine(to: CGPoint(x: width, y: height - 15))
        bookmarkPath.addLine(to: CGPoint(x: width/2, y: height))
        bookmarkPath.addLine(to: CGPoint(x: 0, y: height - 15))
        bookmarkPath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bookmarkPath.cgPath
        shapeLayer.fillColor = UIColor.systemYellow.cgColor
        shapeLayer.opacity = 0
        
        shapeLayer.frame = CGRect(x: (postImageView.bounds.width - width)/2,
                                  y: (postImageView.bounds.height - height)/2,
                                  width: width,
                                  height: height)
        postImageView.layer.addSublayer(shapeLayer)
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = 0
        opacityAnim.duration = 1.0
        opacityAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        shapeLayer.opacity = 0
        shapeLayer.add(opacityAnim, forKey: "fade")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            shapeLayer.removeFromSuperlayer()
        }
    }
}
