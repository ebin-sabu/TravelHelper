//
//  popupViewController.swift
//  New Brighton Murals
//
//  Created by Ebin Pereppadan on 13/12/2022.
//

import UIKit

class popupViewController: UIViewController {
    var id = ""
    var fileName = ""
    var info = ""
    var main = ""
    var artist = ""
    
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var ArtistLabel: UILabel!
    
    @IBOutlet weak var favButton: UIButton!
    
    @IBOutlet weak var unFavButton: UIButton!
    
    @IBOutlet weak var favLabel: UILabel!
    
    @IBAction func favButtonClicked(_ sender: Any) {
        favButton.isHidden = true
        favLabel.isHidden = false
        unFavButton.isHidden = false
        unFavButton.tintColor = UIColor.red
        let userDefaults = Foundation.UserDefaults.standard
        userDefaults.set(String(id), forKey: "Favourite")
    }
    
    @IBAction func unFavButtonClicked(_ sender: Any) {
        unFavButton.isHidden = true
        favButton.isHidden = false
        favLabel.isHidden = true
        let userDefaults = Foundation.UserDefaults.standard
        userDefaults.set("empty", forKey: "Favourite")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = Foundation.UserDefaults.standard
        let storedId = userDefaults.string(forKey: "Favourite")
        if storedId == nil{
            userDefaults.set("empty", forKey: "Favourite")
            print("id is empty")
        }
        else{
            if storedId == id {
                favLabel.isHidden = false
                unFavButton.isHidden = false
                unFavButton.tintColor = UIColor.red
                favButton.isHidden = true
                print("id match")
            }
            else {
                unFavButton.isHidden = true
                favLabel.isHidden = true
                favButton.tintColor = UIColor.green
                print("id not match")
            }
        }
        TitleLabel.text = main
        ArtistLabel.text = artist
        infoLabel.text = info
        let url = URL(string:"https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm_images/\(fileName)")!
        downloadImage(from: url)
        image.downloaded(from: url)
        
        //image.loadFrom(URLAddress: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm_images/\(fileName)")
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.image.image = UIImage(data: data)
            }
        }
    }
}
// First i had done the image loading Synchronously this was giving me warnings hence i changed it to Asynchronously.

/*
extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                        self?.image = loadedImage
                }
            }
        }
    }
}
*/

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

