//
//  AllLeaguesTableViewController.swift
//  SportsApplication
//
//  Created by AbdElrahman Amer on 5/12/22.
//  Copyright © 2022 Shrouk Mamdouh. All rights reserved.
//

import UIKit


class AllLeaguesTableViewController: UITableViewController {
    
    let indicator = UIActivityIndicatorView(style: .large)
    var presenter : AllLeaguesViewPresenter!
    var sportName : String?
    var leagues : [League] = []
    var noLeaguesDataLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = sportName
        refreshTableView()
        noLeaguesDataLabel = showWarning(message : "no Leagues", view: self.view)
        self.view.addSubview(noLeaguesDataLabel)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell =  UITableViewCell()
        
        if let leagueCell = tableView.dequeueReusableCell(withIdentifier:  "LeagueViewCell", for: indexPath) as? LeagueTableViewCell {
            
            leagueCell.configrationCellLeagueLabel(with: leagues[indexPath.row].strLeague ?? "strLeague")
            
            leagueCell.congigrationCellLeagueImage(with: leagues[indexPath.row].strBadge ?? "strBadge" )
            
            leagueCell.congigrationCellLeagueYoutube(with: leagues[indexPath.row].strYoutube ?? "strYoutube" )
            
            cell = leagueCell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select leage \(leagues[indexPath.row].idLeague ?? "idLeague")")
        
        if(ConnectivityMananger.checkNetwork()){
            let LeaguesDetailsScreen = self.storyboard?.instantiateViewController(identifier: "leagueDetails")
                as! LeagueInformationViewController
            
            LeaguesDetailsScreen.league = leagues[indexPath.row]
            LeaguesDetailsScreen.modalPresentationStyle = .fullScreen
            self.present(LeaguesDetailsScreen, animated: true, completion: nil)
        }else{
            showAlert(title: "Connection Failed", message: "You are offline\nPlease connect to newtwork\nthenTry again", view : self)
        }
    }
    
    
}

extension AllLeaguesTableViewController : ResultAPIProtocl{
    func stopAnimating() {
        self.indicator.stopAnimating()
    }
    
    func renderTableView() {
        
        if(presenter.leagues == nil){
            print("leagues null in All leagues table view controller")
        }else{
            leagues = presenter.leagues.map({ (item) -> League in
                return item
            })
            
            if(leagues.count <= 0){
                noLeaguesDataLabel.isHidden = false
            }else{
                noLeaguesDataLabel.isHidden = true
            }
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension AllLeaguesTableViewController{
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(ConnectivityMananger.checkNetwork()){
            startAnimating()
            setupPresenter()
        }else{
            showAlert(title: "Connection Failed", message: "You are offline\nPlease connect to newtwork\nthenTry again", view : self)
        }
    }
    
    private func refreshTableView(){
        self.tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(callPullToRefresh), for: .valueChanged)
    }
    
    @objc private func callPullToRefresh(){
        presenter.getLeaguesFromAPI()
    }
    
    private func startAnimating(){
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    private func setupPresenter(){
        presenter = AllLeaguesViewPresenter()
        presenter.attachView(viewController: self)
        presenter.setSport(sportName: sportName!)
        presenter.getLeaguesFromAPI()
    }
}
