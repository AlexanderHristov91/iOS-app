import UIKit
import SDWebImage 
import SafariServices 

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var newsData: [[String: Any]] = [] 
    var apiKey = "f2ab4e7e67fe44c8a1ea28d32be2f9c5"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchNewsData()
    }
    
    func fetchNewsData() {
        let urlString = "https://newsapi.org/s/uk-news-api"
        
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "Authorization") 
        
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let articles = json?["articles"] as? [[String: Any]] {
                        
                        self.newsData = articles 
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    print("Error: Failed to parse JSON data")
                }
            }
        }
        
       
        dataTask.resume()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData.count
    }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        let newsItem = newsData[indexPath.row]
        if let title = newsItem["title"] as? String,
           let author = newsItem["author"] as? String,
           let source = newsItem["source"] as? [String: Any],
           let sourceName = source["name"] as? String,
           let publishedAt = newsItem["publishedAt"] as? String,
           let imageUrlString = newsItem["urlToImage"] as? String {
            cell.titleLabel.text = title
            cell.authorLabel.text = "Author: \(author)"
            cell.sourceLabel.text = "Source: \(sourceName)"
            cell.publishedAtLabel.text = "Published At: \(publishedAt)"
            
           
            cell.newsImageView.sd_setImage(with: URL(string: imageUrlString), placeholderImage: UIImage(named: "placeholder"))
        } else {
           
            cell.newsImageView.image = UIImage(named: "placeholder")
            cell.titleLabel.text = "Title not available"
            cell.authorLabel.text = "Author not available"
            cell.sourceLabel.text = "Source not available"
            cell.publishedAtLabel.text = "Published At not available"
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let newsItem = newsData[indexPath.row]
        if let title = newsItem["title"] as? String,
           let urlString = newsItem["url"] as? String {
            let newsDetailViewController = NewsDetailViewController()
            newsDetailViewController.titleString = title
            newsDetailViewController.imageUrlString = newsItem["urlToImage"] as? String
            newsDetailViewController.urlString = urlString
            navigationController?.pushViewController(newsDetailViewController, animated: true)
        }
    }
    
}

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var publishedAtLabel: UILabel!
    
}

class NewsDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var openButton: UIButton!
    
    var titleString: String?
    var imageUrlString: String?
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        titleLabel.text = titleString
        newsImageView.sd_setImage(with: URL(string: imageUrlString ?? ""), placeholderImage: UIImage(named: "placeholder"))
        openButton.addTarget(self, action: #selector(openButtonTapped), for: .touchUpInside)
    }
    
    @objc func openButtonTapped() {
        if let urlString = urlString, let url = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
}
