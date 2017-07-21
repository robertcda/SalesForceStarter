/*
 Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import UIKit
import SalesforceSDKCore
import SmartStore

class RootViewController : UITableViewController, SFRestDelegate
{
    var dataRows = [Account]()
    
    // MARK: - View lifecycle
    override func loadView()
    {
        super.loadView()
        self.title = "Mobile SDK Sample App"
        
        /*
        //Here we use a query that should work on either Force.com or Database.com
        let request = SFRestAPI.sharedInstance().request(forQuery:"SELECT Name,AccountNumber FROM Account LIMIT 10");
        SFRestAPI.sharedInstance().send(request, delegate: self);
         */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get all the accounts data.
        self.initializeAccountsModel()
        self.initializeinspectorBarButton()
        self.initializeRefreshBarButton()
    }
    
    //MARK:- Store Inspector
    func launchStoreInspector(){
        // Start the Inspector.
        if let inspector = SFSmartStoreInspectorViewController(store: ModelInterface.instance.store){
            self.present(inspector, animated: true, completion: {
                // Nothing
            })
        }
    }
    
    func initializeinspectorBarButton(){
        // Configure Inspector Bar Button
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "icon_inspector"), for: .normal)
        button.addTarget(self,
                         action: #selector(launchStoreInspector),
                         for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        let inspectorBarButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItems = [inspectorBarButton]
    }
    //MARK: - Initialize Accounts
    func initializeAccountsModel(){
        ModelInterface.instance.accounts(){ accounts in
            self.dataRows.removeAll()
            if let accounts = accounts{
                self.dataRows.append(contentsOf: accounts)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Refresh
    func initializeRefreshBarButton(){
        // Configure Inspector Bar Button
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "refresh"), for: .normal)
        button.addTarget(self,
                         action: #selector(refresh),
                         for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        let inspectorBarButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItems = [inspectorBarButton]
    }
    func refresh(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ModelInterface.instance.reloadAccountsFromNetwork {
            self.initializeAccountsModel()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    /*
    // MARK: - SFRestDelegate
    func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
    {
        self.dataRows = (jsonResponse as! NSDictionary)["records"] as! [NSDictionary]
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"request:didLoadResponse: #records: \(self.dataRows.count)")
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func request(_ request: SFRestRequest, didFailLoadWithError error: Error)
    {
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"didFailLoadWithError: \(error)")
        // Add your failed error handling here
    }
    
    func requestDidCancelLoad(_ request: SFRestRequest)
    {
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"requestDidCancelLoad: \(request)")
        // Add your failed error handling here
    }
    
    func requestDidTimeout(_ request: SFRestRequest)
    {
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"requestDidTimeout: \(request)")
        // Add your failed error handling here
    }
    */
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "CellIdentifier"
        
        // Dequeue or create a cell of the appropriate type.
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier:cellIdentifier)
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        // If you want to add an image to your cell, here's how.
        let image = UIImage(named: "icon.png")
        cell!.imageView!.image = image
        
        // Configure the cell to show the data.
        let account = dataRows[indexPath.row]
        cell!.textLabel!.text = account.name
        cell?.detailTextLabel?.text = account.accountNumber
        // This adds the arrow to the right hand side.
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //super.tableView(tableView, didSelectRowAt: indexPath)
        
        let storyBoard = UIStoryboard.init(name: "nameDetails", bundle: nil)
        if let detailView = storyBoard.instantiateInitialViewController() as? NameDetailsViewController{
            self.navigationController?.pushViewController(detailView, animated: true)
            let account = dataRows[indexPath.row]
            detailView.accountNumber = account.accountNumber
        }
        
        
    }
}
