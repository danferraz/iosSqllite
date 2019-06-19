//
//  ViewController.swift



//  SqlLiteDbSample
//
//  Created by Yash on 2019-06-05.
//  Copyright © 2019 YashShah. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var db: OpaquePointer?
    var heroList = [Hero]()
    
    @IBOutlet weak var HeroName: UITextField!
    
    @IBOutlet weak var HeroPower: UITextField!
    
    @IBOutlet weak var tableviewHeros: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //step 1 create a database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.sqlite")
        
        //2 - opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //3 - creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        readValues()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //this method is giving the row count of table view which is
        //total number of heroes in the list
        return heroList.count
    }
    
    
    //this method is binding the hero name with the tableview cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let hero: Hero
        hero = heroList[indexPath.row]
        cell.textLabel?.text = hero.name
        return cell
    }
    

    @IBAction func AddButtonTapped(_ sender: Any) {
        
        // 4 - getting values from textfields
        let name = HeroName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let powerRanking = HeroPower.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        //validating that values are not empty
        if(name?.isEmpty)!{
            HeroName.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(powerRanking?.isEmpty)!{
            HeroName.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO Heroes (name, powerrank) VALUES (?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, (powerRanking! as NSString).intValue) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        //emptying the textfields
        HeroName.text=""
        HeroPower.text=""
        
        
        readValues()
        
        //displaying a success message
        print("Hero saved successfully")
    
    }
    
    func readValues(){
        
        //5 - first empty the list of heroes
        heroList.removeAll()
        
        //this is our select query
        let queryString = "SELECT * FROM Heroes"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let powerrank = sqlite3_column_int(stmt, 2)
            
            //adding values to list
            heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
        }
        
        self.tableviewHeros.reloadData()
        
    }

}

