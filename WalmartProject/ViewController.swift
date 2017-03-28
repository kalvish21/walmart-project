//
//  ViewController.swift
//  WalmartProject
//
//  Created by Kalyan Vishnubhatla on 3/27/17.
//  Copyright © 2017 Kalyan Vishnubhatla. All rights reserved.
//

import UIKit
import MBProgressHUD

class ViewController: UITableViewController {

    var results: Array<AnyObject> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchForNewTerm))
    }
    
    func searchForNewTerm() {
        NSLog("Searching for new term")
        
        let alert = UIAlertController(title: "Search term", message: "Enter a search term", preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Search term ..."
        }
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            
            // Show HUD
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            
            let textField = alert.textFields![0]
            let text = textField.text
            if text != nil && text != "" {
                guard let url = URL(string: "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=" + text!) else {
                    print("Error: cannot create URL")
                    return
                }
                
                let req = URLRequest(url: url)
                let session = URLSession(configuration: URLSessionConfiguration.default)
                let task = session.dataTask(with: req, completionHandler: { (data, res, err) in
                    
                    if let data = data {
                        do {
                            guard let dataJson = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [AnyObject] else {
                                print("error trying to convert data to JSON")
                                MBProgressHUD.hide(for: self.view, animated: true)
                                return
                            }
                            
                            self.results = dataJson[0]["lfs"]! as! Array<AnyObject>
                            print (self.results)
                            
                            DispatchQueue.main.async {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                self.title = text!
                                self.tableView.reloadData()
                            }
                        } catch let error as NSError {
                            print(error.localizedDescription)
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                    } else if let error = err {
                        print(error.localizedDescription)
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }

                })
                task.resume()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let data = self.results[indexPath.row]
        
        cell?.textLabel?.text = data["lf"] as! String
        
        return cell!
    }
}

