//
//  ViewController.swift
//  Pursuit-Core-iOS-Episodes-from-Online
//
//  Created by Benjamin Stone on 9/5/19.
//  Copyright © 2019 Benjamin Stone. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var showsTableView: UITableView!
    
    var shows = [Show]() {
        didSet {
            DispatchQueue.main.async {
                self.showsTableView.reloadData()
            }
        }
    }
    
    var searchString: String? //Our filter is going to filter based on this variable, searchString
    
    var filteredShow: [Show] {
        get {
            guard let searchString = searchString else {return shows} //When search bar is empty, just keep showing me the array of all the shows.
            guard searchString != "" else {return shows}
            
            return Show.getFilteredShowsByName(arr: shows, searchString: searchString)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueIdentifer = segue.identifier else {fatalError("No indentifier in segue")}
        
        switch segueIdentifer {
            
        case "segToTableView":
            guard let destVC = segue.destination as? EpisodeViewController else {
                fatalError("Unexpected segue VC")
            }
            guard let selectedIndexPath = showsTableView.indexPathForSelectedRow else {fatalError("No row selected")
                
            }
            
            let currentShow = shows[selectedIndexPath.row]
            destVC.show = currentShow
            
        default:
            fatalError("unexpected segue identifier")
            
        }
    }
    
    
    private func loadData() {
        Show.getShowData { (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let showsFromOnline):
                    self.shows = showsFromOnline
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showsTableView.dataSource = self
        showsTableView.delegate = self
        loadData()
        
    }
}

extension ViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = showsTableView.dequeueReusableCell(withIdentifier: "showCell", for: indexPath)  as! showsTableViewCell
        let currentShow = shows[indexPath.row]
        
        cell.TitleLabel.text = currentShow.name
        cell.rating.text = "\(currentShow.rating?.average ?? 0.0)"
        
        ImageHelper.shared.fetchImage(urlString: currentShow.image.original) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let imageFromOnline):
                    cell.showsImage.image = imageFromOnline
                }
            }
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 164
    }
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText //I am setting the global variable equal to whatever was typed in the search bar. This is so I can use that global variable for other stuff like filtering shows.
    }
}



