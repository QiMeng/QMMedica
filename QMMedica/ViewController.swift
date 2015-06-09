//
//  ViewController.swift
//  QMMedica
//
//  Created by QiMENG on 15/6/8.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    var dataArray:Array<Model> = []
    var pageInt:Int = 1
    var searchArray:Array<Model> = []
    
    @IBOutlet weak var mainSearch: UISearchBar!
    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mainTableView.tableFooterView = UIView()
        
        self.dataArray = Service.readDB() as! Array<Model>
        
        mainSearch.placeholder = "请输入要搜索的内容(\(self.dataArray.count))"
        
//        SVProgressHUD.showWithStatus("努力加载...", maskType: SVProgressHUDMaskType.Black)
//        Service.medicaPage(1, withBlock: { (list, error) -> Void in
//            self.dataArray += list as! Array<Model>
//            
//            self.mainTableView.reloadData()
//            SVProgressHUD.dismiss()
//            ++self.pageInt
//        })
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.mainSearch.text.isEmpty {
            return self.dataArray.count
        }else {
            return self.searchArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == self.dataArray.count
        {
            var cell = tableView.dequeueReusableCellWithIdentifier("MoreCell", forIndexPath: indexPath) as! UITableViewCell
            
            return cell
        }
        else
        {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
            
            if self.mainSearch.text.isEmpty {
                var m = self.dataArray[indexPath.row]
                cell.textLabel?.text = m.title
            }else {
                var m = self.searchArray[indexPath.row]
                cell.textLabel?.text = m.title
            }
            
            
            
            return cell
        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.mainTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == dataArray.count {
            
            SVProgressHUD.showWithStatus("加载更多...", maskType: SVProgressHUDMaskType.Black)
            
            Service.medicaPage(Int32(self.pageInt)) { (array, error) -> Void in
                
                if self.dataArray.count > 0 && array.count > 0 {
                    
                    let model1 = self.dataArray.last as Model!
                    let model2 = array.last as! Model
                    
                    if model1.href == model2.href {
                        
                        SVProgressHUD.showErrorWithStatus("没有更多了")
                        return
                    }
                }
                
                self.dataArray += array as! Array<Model>
                self.mainTableView.reloadData()
                SVProgressHUD.dismiss()
                ++self.pageInt
                
            }
            
        }
        else {
            
            var model:Model?
            if self.mainSearch.text.isEmpty {
                model = self.dataArray[indexPath.row]

            }else {
                model = self.searchArray[indexPath.row]
            }
            
            self.performSegueWithIdentifier("DetaileViewController", sender: model)
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "DetaileViewController" {
            
            var ctrl = segue.destinationViewController as! DetaileViewController
            ctrl.infoModel = sender as? Model
        }
        
    }

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        self.mainSearch.setShowsCancelButton(true, animated: true)
        
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        self.mainSearch.text = ""
        self.mainTableView.reloadData()
        self.mainSearch.setShowsCancelButton(false, animated: true)
        
        self.mainSearch.resignFirstResponder()
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.searchArray = Service.searchDB(searchBar.text) as!Array<Model>
        
        self.mainTableView.reloadData()
        
        self.mainSearch.setShowsCancelButton(false, animated: true)
        self.mainSearch.resignFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

