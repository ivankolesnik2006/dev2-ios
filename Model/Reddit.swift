import Foundation

struct RedditListing: Codable {
    let data: ListingData
}

struct ListingData: Codable {
    let children: [RedditChild]
    let after: String?
}

struct RedditChild: Codable {
    let data: RedditPost
}

struct RedditResponse: Codable {
    let data: RedditData
}

struct RedditData: Codable {
    let children: [RedditPostWrapper]
    let after: String?
}

struct RedditPostWrapper: Codable {
    let data: RedditPost
}

struct RedditPost: Codable, Equatable {
    let id: String
    let title: String
    let author: String
    let thumbnail: String?
    let url: String?
    let selftext: String?
    
    var isSaved: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, title, author, thumbnail, url, selftext
    }
}
