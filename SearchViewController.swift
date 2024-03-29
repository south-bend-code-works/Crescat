//
//  SearchViewController.swift
//  crescat
//
//  Created by Madelyn Nelson on 12/29/16.
//  Copyright © 2016 Madelyn Nelson. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating  {

    var professionalArray:[[String:AnyObject]]! // from view controller
    var followeesArray: [String] = [] // also from home view controller
    
    @IBOutlet weak var searchTableView: UITableView!

    let cellReuseIdentifier = "profCell"
    
    var uids:[String] = []
    var names:[String] = []
    var positions:[String] = []
    var companies:[String] = []
    var positionsAndCompanies:[String] = []
    var industries:[String] = []
    var locations:[String] = []
    var schools:[String] = []
    var details:[String] = []
    var toggles:[Int] = []
    
    
    //var titles = ["Bernie Sanders", "Alexandria Viegut", "Barack Obama", "Queen Elizabeth II"]
    //var companies = ["Deloitte", "UW Madison", "United States of America", "England Monarchy"]
    //var concatenatedData = [String]()
    
    //var nameAndCompany: [(name:String , company: String)] = []
    
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
           searchTableView.tableHeaderView = controller.searchBar
            return controller
        })()
        searchTableView.reloadData()
        
        updateProfessionalsArrays()
        
        //concatenatedData = names + companies
        //print("concatenated array:")
        //print(concatenatedData)

        
        // for searching through all fields
       /*
        for (i, element) in names.enumerated() {
            nameAndCompany += [(name:names[i] , company:companies[i])]
        }
         */
    }
    
    // need this here in order to reload tableview after switching prof followees
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // nav bar colors
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        
        //self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.black
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.black]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController!.view.backgroundColor = oldColor
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: (247.0 / 255.0), green: (247.0 / 255.0), blue: (247.0 / 255.0), alpha: 1)
        //self.navigationController?.navigationBar.backgroundColor = oldColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateProfessionalsArrays() {
        print("printing profs now!")
        for prof in professionalArray {
            uids.append(prof["uid"] as! String)
            names.append(prof["name"] as! String)
            positions.append(prof["position"] as! String)
            companies.append(prof["company"] as! String)
            positionsAndCompanies.append((prof["position"] as! String) + " at " +  (prof["company"] as! String))
            industries.append(prof["industry"] as! String)
            locations.append(prof["location"] as! String)
            schools.append(prof["school"] as! String)
            details.append((prof["industry"] as! String) + " • " +  (prof["location"] as! String) + " • " +  (prof["school"] as! String))
            
            // check for inital toggle value
            if (followeesArray.contains(prof["uid"] as! String)) {
                toggles.append(1)
            }
            else {
                toggles.append(0)
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)

        let array = (names as NSArray).filtered(using: searchPredicate)
        
        filteredTableData = array as! [String]
        
        searchTableView.reloadData()
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.isActive {
            return self.filteredTableData.count
        }
        else {
            return self.names.count
        }
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = searchTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ProfSearchCell
        
        if self.resultSearchController.isActive {
            let i = indexPath.row
            let j = names.index(of: filteredTableData[i])
    
            cell.nameLabel.text = filteredTableData[i]
            cell.companyLabel.text = positionsAndCompanies[j!]
            cell.detailsLabel.text = details[j!]
            cell.uid.text = uids[j!]
            
            // check toggle state
            if (self.toggles[j!] == 1) {
                cell.followToggle.setOn(true, animated: false)
            }
            else {
                cell.followToggle.setOn(false, animated: false)
            }
            
        } else {
           cell.nameLabel.text = self.names[indexPath.row]
           cell.companyLabel.text = self.positionsAndCompanies[indexPath.row]
           cell.detailsLabel.text = self.details[indexPath.row]
           cell.uid.text = uids[indexPath.row]
            
            
            // check toggle state
            if (self.toggles[indexPath.row] == 1) {
                cell.followToggle.setOn(true, animated: false)
            }
            else {
                cell.followToggle.setOn(false, animated: false)
            }
 
        }
        return cell
        
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        //return UITableViewAutomaticDimension
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
