//
//  HomeVC.swift
//  crescat
//
//  Created by Madelyn Nelson on 12/22/16.
//  Copyright © 2016 Madelyn Nelson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var askQuestionButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let usersRef = FIRDatabase.database().reference(withPath: "users")
    let questionsRef = FIRDatabase.database().reference(withPath: "questions").queryOrdered(byChild: "date")
    
    var professionalArray: [[String:AnyObject]] = [] // has all the prof data
    var professionalNameArray: [String] = [] // for ask a question
    var professionalUIDArray: [String] = [] // for ask a question
    var questionArray: [[String:AnyObject]] = []
    var answeredQuestionArray: [[String:AnyObject]] = []
    var followeesArray: [String] = []
    
    var selectedCellIndex = 0 // used for sending data via segue to ProfileViewController
    
    /*
    let titles: [String] = ["Bernie Sanders", "Alexandria Viegut", "Barack Obama", "Queen Elizabeth II"]
    let questions: [String] = ["Q: Why did you choose deloitte?", "Q: What is your proudest achievement?", "Q: What is the best advice you've ever received?", "Q: Why Notre Dame?"]
    let answers: [String] = ["A: I really wanted to do consulting, it sounds super fun and awesome and they pay really well and I love being social and food!", "A: I went skydiving once and it was awesome, conquered ALL the fears and it was great bonding!", "A: Go to college, don't do drugs.", "A: Because Notre Dame has the best community ever, duh!"]
    let dates: [String] = ["1/2/17", "12/13/16", "12/1/16", "11/15/16"]
    */
    

    let cellReuseIdentifier = "cell"
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call firebase to get the Q/A of profs that this user is following
        //getListOfFollowees() no called from viewDidAppear
        //getQuestionsAndAnswers() now called from getListOfFollowees
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // set row height
        //tableView.estimatedRowHeight = 100
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        getProfessionalsList() // gets full list of professionals for searching
        makePretty()
    }
    
    
    // need this here in order to reload tableview after switching prof followees
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       print("VIEW APPEARING!")

        getListOfFollowees()
        tableView.reloadData()
        
        
        // nav bar colors
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        
        //self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white

        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        var navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.lightGray  // Back buttons and such
        
    }
    
    func makePretty() {
        self.askQuestionButton.layer.cornerRadius = 5
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController!.view.backgroundColor = oldColor
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: (247.0 / 255.0), green: (247.0 / 255.0), blue: (247.0 / 255.0), alpha: 1)
        //self.navigationController?.navigationBar.backgroundColor = oldColor
        //self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    
    
    
    
    
    
    
    
    func getListOfFollowees() {
        followeesArray = [] // reset list of followees
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        let userPath = "users/" + userID!
        let usersRef = FIRDatabase.database().reference(withPath: userPath)
        
        usersRef.observe(.childAdded, with: { snapshot in
            print(snapshot.value)
            
            if (snapshot.hasChild("listOfFollowees")) {
                
                let json = snapshot.value as! [String:AnyObject]
                let listOfFollowees = json["listOfFollowees"] as! [String]
                print("is following these profs:")
                print(listOfFollowees)
                self.followeesArray = listOfFollowees
            }
            else {
                // is following no one
                print("user is not following anyone")
            }
        })
        
        getQuestionsAndAnswers() // great, now use this list to get the questions and answers
        
        
        usersRef.removeAllObservers()
    }
    
    
    
    
    func getQuestionsAndAnswers() {
        questionArray = [] // reset question array
        answeredQuestionArray = [] // reset question array

        
        // .childAdded
        questionsRef.observe(.childAdded, with: { snapshot in
        //questionsRef.observe(.value, with: { snapshot in
            
            //print(snapshot)
            //print(snapshot.value)
            
            //let blah = snapshot.value as! [AnyObject]
            //for json in blah {
            
            let json = snapshot.value as! [String:AnyObject]
            print("question printed:", json, "\n\n")
            
            
                // check if following this prof, if so then put question in array to be displayed
                if (self.followeesArray.contains(json["uid"] as! String)) {
                
                    var questionData: [String:String] = [:]
                
                    let question = json["question"]
                    let answer = json["answer"]
                    let uid = json["uid"]
                    let profName = json["profName"]
                    let date = json["date"]
            
                    questionData["answer"] = answer as! String?
                    questionData["question"] = question as! String?
                    questionData["uid"] = uid as! String?
                    questionData["profName"] = profName as! String?
                    questionData["date"] = date as! String?
                
                    let ansStr = answer as! String
                
                    //if ( ansStr.characters.count >= 4) {
                        self.answeredQuestionArray.append(questionData as [String : AnyObject])
                    //}

                    self.questionArray.append(questionData as [String : AnyObject])
                
                    //print(self.questionArray)
                }
                else {
                    print("user is NOT following this prof")
                }
            
            
                print("printing question array")
                print(self.questionArray)
                print(self.questionArray.count)
            
                self.tableView.reloadData()
            //}
        })
    }
    
    func getProfessionalsList() {

        usersRef.observe(.childAdded, with: { snapshot in
            
            let json = snapshot.value as! [String:AnyObject]
            
            // storing UID under userInfo also, makes following easier
            print(snapshot.key)
            let userID = snapshot.key
            
            
            let userInfo = json["userInfo"] as! [String:AnyObject]
            
            if (userInfo["isProfessional"] as! Bool) {
                var prof: [String:String] = [:]
                
                let uid = userID
                let name = userInfo["name"] as! String
                let company = userInfo["company"] as! String
                let position = userInfo["position"] as! String
                let industry = userInfo["industry"] as! String
                let location = userInfo["location"] as! String
                let school = userInfo["school"] as! String
                
                prof["uid"] = uid
                prof["name"] = name
                prof["company"] = company
                prof["position"] = position
                prof["industry"] = industry
                prof["location"] = location
                prof["school"] = school

                self.professionalArray.append(prof as [String : AnyObject])
                self.professionalUIDArray.append(uid)
                self.professionalNameArray.append(name)
            }
            
            //print(self.professionalArray)
            
        })
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.questionArray.count
        return answeredQuestionArray.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MyCustomCell
        
        //let thisQuestion = self.questionArray[indexPath.row]
        let thisQuestion = self.answeredQuestionArray[indexPath.row]
        let name = thisQuestion["profName"] as! String?
        let question = thisQuestion["question"] as! String?
        let answer = thisQuestion["answer"] as! String?
        
        cell.myCellQuestion.text = "Q: " + question!
        cell.myCellAnswer.text = "A: " + answer!
        cell.myCellDate.text = thisQuestion["date"] as! String?
        cell.myCellTitle.text = " " + name! + " answered a question"
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        selectedCellIndex = indexPath.row
        
        let cell:MyCustomCell = tableView.cellForRow(at: indexPath) as! MyCustomCell
        cell.myCellTitle.backgroundColor = UIColor.darkGray
        
        // now go to that professional's profile page
        self.performSegue(withIdentifier: "homeToProfessional", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "searchProfessionals") {
            let yourNextViewController = (segue.destination as! SearchViewController)
            yourNextViewController.professionalArray = self.professionalArray
            yourNextViewController.followeesArray = self.followeesArray
        }
        else if(segue.identifier == "toAskQuestion") {
            let yourNextViewController = (segue.destination as! AskQuestionViewController)
            yourNextViewController.professionalNameArray = self.professionalNameArray
            yourNextViewController.professionalUIDArray = self.professionalUIDArray
            yourNextViewController.professionalArray = self.professionalArray
            yourNextViewController.followeesArray = self.followeesArray
        }
        else if(segue.identifier == "homeToProfessional") {
            let yourNextViewController = (segue.destination as! ProfileViewController)
            
            let question = self.answeredQuestionArray[selectedCellIndex]
            let profUID = question["uid"] as! String
            
            var i = 0
            
            for prof in professionalArray {
                let uid = prof["uid"] as! String
                if (uid == profUID) {
                    print("found this prof in prof array")
                    print(i)
                    break
                }
                i += 1
            }
            
            let thisProf = professionalArray[i]
            
            let name = thisProf["name"] as! String
            let position = thisProf["position"] as! String
            let company = thisProf["company"] as! String
            let location = thisProf["location"] as! String
            let industry = thisProf["industry"] as! String
            let school = thisProf["school"] as! String
                
            yourNextViewController.uid = profUID
            yourNextViewController.name = name
            yourNextViewController.location = location
            yourNextViewController.position = position
            yourNextViewController.company = company
            yourNextViewController.industry = industry
            yourNextViewController.school = school
            //yourNextViewController.showBackButton = true

            yourNextViewController.questionArray = self.questionArray
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
        //return UITableViewAutomaticDimension
    }

    
    @IBAction func logout(_ sender: Any) {
        try! FIRAuth.auth()?.signOut()
        
        // clear table views and stuff, just in case different user logs in during this app session
        professionalArray = []
        professionalNameArray = []
        professionalUIDArray = []
        questionArray = []
        answeredQuestionArray = []
        followeesArray = []
        
        self.tableView.clearsContextBeforeDrawing = true
        self.tableView.reloadData() // clear the table
        
        print("removing all FB observers")
        self.usersRef.removeAllObservers()
        self.questionsRef.removeAllObservers()
        
        self.performSegue(withIdentifier: "homeLogoutSegue", sender: self)
    }
    
    /*
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
 */

    @IBAction func searchButton(_ sender: Any) {
        // reset tableview arrays so can adjust to new data after (un)follows new profs
        
        self.performSegue(withIdentifier: "searchProfessionals", sender: self)
    }
    
    @IBAction func leftButtonPress(_ sender: Any) {
        
        print("pressed left button")
        self.performSegue(withIdentifier: "searchProfessionals", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
