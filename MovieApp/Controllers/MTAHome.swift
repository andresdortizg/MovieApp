//
//  RPIHome.swift
//  RpiMovieApp
//
//  Created by Andres Ortiz on 4/17/19.
//  Copyright © 2019 Andres. All rights reserved.
//


import UIKit

class RPIHome: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let cellId = "CustomMovieTableViewCell"
    
    var isSearching: Bool?
    var isLoading: Bool?
    var page: Int?
    var movies = [Movie]()
    var category : Int?
    var animationStyle : UITableView.RowAnimation?
    let tableView: UITableView = UITableView()
    
    
    lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .whiteLarge)
        loader.color = .black
        loader.translatesAutoresizingMaskIntoConstraints = false
        return loader
    }()
    
    let svCategory : UISegmentedControl = {
        let items = ["Popular", "Top Rated", "Upcoming"]
        let customSC = UISegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        customSC.layer.cornerRadius = 5.0
        customSC.backgroundColor = .white
        customSC.tintColor = .darkGray
        return customSC
    }()
    
    let vSeachPanel : UIView = {
        let vPanel = UIView()
        vPanel.backgroundColor = UIColor.groupTableViewBackground
        return vPanel
    }()
    
    let txtSearch : UITextField = {
       let text = UITextField()
       text.autocorrectionType = UITextAutocorrectionType.no
       text.borderStyle = UITextField.BorderStyle.roundedRect
       text.backgroundColor = .white
       text.placeholder = "Write something and tab Search..."
       return text
    }()
    
    let btnSearch : UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isSearching = false
        self.isLoading = true
        self.page = 1
        self.category = 1
        self.animationStyle = UITableView.RowAnimation.none
        self.navigationController?.navigationBar.topItem?.title = "Movie App"
        
        setupViews()
        setupActions()
        
        fetchData(text: txtSearch.text!)
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.tableView.reloadData()
    }
    
    func setupViews(){
        
        var margins = view.layoutMarginsGuide

        if #available(iOS 11.0, *) {
            margins = view.safeAreaLayoutGuide
        }
        
        self.view.backgroundColor = .white
        

        self.view.addSubview(svCategory)
        
        svCategory.translatesAutoresizingMaskIntoConstraints = false
        svCategory.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10).isActive = true
        svCategory.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 10).isActive = true
        svCategory.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -10).isActive = true
        svCategory.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.view.addSubview(vSeachPanel)
        
        vSeachPanel.translatesAutoresizingMaskIntoConstraints = false
        vSeachPanel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 70).isActive = true
        vSeachPanel.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 0).isActive = true
        vSeachPanel.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: 0).isActive = true
        vSeachPanel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        self.vSeachPanel.addSubview(txtSearch)
        
        txtSearch.translatesAutoresizingMaskIntoConstraints = false
        txtSearch.topAnchor.constraint(equalTo: vSeachPanel.layoutMarginsGuide.topAnchor, constant: 2).isActive = true
        txtSearch.leftAnchor.constraint(equalTo: vSeachPanel.layoutMarginsGuide.leftAnchor, constant: 5).isActive = true
        txtSearch.rightAnchor.constraint(equalTo: vSeachPanel.layoutMarginsGuide.rightAnchor, constant: -80).isActive = true
        txtSearch.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.vSeachPanel.addSubview(btnSearch)
        
        btnSearch.translatesAutoresizingMaskIntoConstraints = false
        btnSearch.topAnchor.constraint(equalTo: vSeachPanel.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
        btnSearch.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnSearch.rightAnchor.constraint(equalTo: vSeachPanel.layoutMarginsGuide.rightAnchor, constant: -5).isActive = true
        btnSearch.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 120).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: 0).isActive = true
 
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(RpiCustomMovieTableCell.self, forCellReuseIdentifier: cellId)
 
        self.view.addSubview(loader)
        
        loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loader.widthAnchor.constraint(equalToConstant: 50).isActive = true
        loader.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        loader.isHidden = true
        
    }
    
    func setupActions(){
        svCategory.addTarget(self, action: #selector(self.changeCategory(sender:)), for: .valueChanged)
        btnSearch.addTarget(self, action: #selector(self.searchWithText(sender:)), for: .touchUpInside)
    }
    
    func fetchData(text: String){
        self.loader.isHidden = false
        self.loader.startAnimating()
        RPIMovieLoader.shared.fetchMovies(kind: category!, page: page!, text: text){
            (result: [Movie], success) in
            if (success){
                if (self.movies.count > 0){
                    if self.isSearching! {
                        self.movies = result
                        self.tableView.reloadData()
                    }
                    else if self.isLoading! {
                        self.movies.append(contentsOf: result)
                        self.tableView.reloadData()
                    }
                    else{
                        if (self.movies.count == 20){
                            self.movies = result
                            self.tableView.reloadSections(IndexSet(integer: 0), with: self.animationStyle!)
                        }
                        else{
                            self.movies = result
                            self.tableView.reloadData()
                        }
                    }
                }
                else{
                    self.movies = result
                    self.tableView.reloadData()
                }
            }
            self.loader.stopAnimating()
            self.loader.isHidden = true
            self.isLoading = false
            self.isSearching = false
        }
    }
    
    

    
    @objc func changeCategory(sender: UISegmentedControl) {
        let isConnected = RPIReachability.shared.isConnected()
        if isConnected{
            self.txtSearch.text = ""
        }

        
        if (sender.selectedSegmentIndex + 1 > self.category!)
        {
            self.animationStyle = UITableView.RowAnimation.left
        }
        else
        {
            self.animationStyle = UITableView.RowAnimation.right
        }
        txtSearch.resignFirstResponder()
        switch sender.selectedSegmentIndex {
            case 0:
                self.category = 1;
            case 1:
                self.category = 2;
            case 2:
                self.category = 3;
            default:
                self.category = 1;
        }
        page = 1
        fetchData(text:txtSearch.text!)
    }
    
    @objc func searchWithText(sender: UIButton){
        let isConnected = RPIReachability.shared.isConnected()
        if isConnected{
            svCategory.selectedSegmentIndex = UISegmentedControl.noSegment
        }
        txtSearch.resignFirstResponder()
        self.isSearching = true
        fetchData(text: txtSearch.text!)
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if self.movies.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = isLoading! ? "" : "No Matching Results"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.movies.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMovieTableViewCell", for: indexPath) as! RpiCustomMovieTableCell

        let movie = movies[indexPath.row]
        
        
        if  ((movie.posterPath) != nil){
            let url = URL(string: baseURL + movie.posterPath!)
            let placeholderImage = UIImage(named: "movieplaceholder")!
            
            cell.imgMoviePoster.sd_imageTransition = .fade
            cell.imgMoviePoster.sd_internalSetImage(with: url, placeholderImage: placeholderImage, operationKey: nil, setImageBlock: nil, progress: nil)
        }
        else{
            cell.imgMoviePoster.image = UIImage.init(named: "movieplaceholder")
        }

        cell.lblMovieTitle.text = movie.title
        cell.lblMovieOverview.text = movie.overview
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let targetController =  RPIMovieDetailedViewController()
        targetController.movie = movie
        self.navigationController?.pushViewController(targetController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let lastElement = movies.count - 1
            let isConnected = RPIReachability.shared.isConnected()
            if !(isLoading!) && (indexPath.row == lastElement) && movies.count > 19 && isConnected  {
                isLoading = true
                page = page! + 1
                
                fetchData(text: txtSearch.text!)
            }

    }


}

