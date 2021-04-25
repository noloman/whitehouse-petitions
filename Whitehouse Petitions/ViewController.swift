//
//  ViewController.swift
//  Whitehouse Petitions
//
//  Created by Manu on 20/04/2021.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var filters = [String]()
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFilter))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeFilters))
        performSelector(inBackground: #selector(fetchJson), with: nil)
    }
    
    @objc func removeFilters() {
        self.filteredPetitions = self.petitions
        self.tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    @objc func addFilter() {
        let vc = UIAlertController(title: "Filters", message: nil, preferredStyle: .alert)
        vc.addTextField { textField in
            textField.placeholder = "Enter filter"
        }
        vc.addAction(.init(title: "Save filter", style: .default, handler: { (a: UIAlertAction) in
            let textField = vc.textFields![0] as UITextField
            self.filters.append(textField.text!)
            if !self.filters.isEmpty {
                let newArray = self.filteredPetitions.filter { petition in
                    petition.title.lowercased().contains(textField.text!.lowercased()) || petition.body.lowercased().contains(textField.text!.lowercased())
                }
                self.filteredPetitions = newArray
            }
            self.tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        }))
        self.present(vc, animated: true)
    }
    
    @objc func fetchJson() {
        if let url = URL(string: urlString ?? "") {
            if let data = try? Data(contentsOf: url) {
                // OK to parse
                parse(json: data)
                return
            }
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    @objc func showError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading error", message: "Please check your connection", preferredStyle: .alert)
            ac.addAction(.init(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let jsonDecoder = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonDecoder.results
            filteredPetitions = petitions
            DispatchQueue.main.async {
                self.tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            }
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = filteredPetitions[indexPath.row].title
        cell.detailTextLabel?.text = filteredPetitions[indexPath.row].body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

