//
//  MTAMovieStorage.swift
//  MovieApp
//
//  Created by Andres Ortiz on 4/17/19.
//  Copyright © 2019 Andres. All rights reserved.
//


import Foundation



class MTAMovieStorage {
    static let shared = MTAMovieStorage()
    
    private(set) var popularMovies: [Movie]
    private(set) var topRatedMovies: [Movie]
    private(set) var upcomingMovies: [Movie]
    private let fileManager: FileManager
    private let documentsURL: URL
    
    func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    
    init() {
        let fileManager = FileManager.default
        self.documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        self.fileManager = fileManager
        var moviesFilesURLs : [URL]
        let jsonDecoder = JSONDecoder()
        
        self.popularMovies = [Movie]()
        self.topRatedMovies = [Movie]()
        self.upcomingMovies = [Movie]()
        
        if directoryExistsAtPath(documentsURL.appendingPathComponent("popular").path){
            moviesFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL.appendingPathComponent("popular"), includingPropertiesForKeys: nil)
            
            
            popularMovies = moviesFilesURLs.compactMap { url -> Movie? in
                guard !url.absoluteString.contains(".DS_Store") else {
                    return nil
                }
                guard let data = try? Data(contentsOf: url) else {
                    return nil
                }
                return try? jsonDecoder.decode(Movie.self, from: data)
                }.sorted(by: { $0.popularity > $1.popularity })
        }
        else{
            try? fileManager.createDirectory(at: documentsURL.appendingPathComponent("popular"), withIntermediateDirectories: false, attributes: nil)
        }
        
        if directoryExistsAtPath(documentsURL.appendingPathComponent("topRated").path){
            moviesFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL.appendingPathComponent("topRated"), includingPropertiesForKeys: nil)
            
            topRatedMovies = moviesFilesURLs.compactMap { url -> Movie? in
                guard !url.absoluteString.contains(".DS_Store") else {
                    return nil
                }
                guard let data = try? Data(contentsOf: url) else {
                    return nil
                }
                return try? jsonDecoder.decode(Movie.self, from: data)
                }.sorted(by: { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) })
        }
        else{
            try? fileManager.createDirectory(at: documentsURL.appendingPathComponent("topRated"), withIntermediateDirectories: false, attributes: nil)
        }
        
        if directoryExistsAtPath(documentsURL.appendingPathComponent("upcoming").path){
            moviesFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL.appendingPathComponent("upcoming"), includingPropertiesForKeys: nil)
            upcomingMovies = moviesFilesURLs.compactMap { url -> Movie? in
                guard !url.absoluteString.contains(".DS_Store") else {
                    return nil
                }
                guard let data = try? Data(contentsOf: url) else {
                    return nil
                }
                return try? jsonDecoder.decode(Movie.self, from: data)
                }.sorted(by: { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") })
        }
        else{
            try? fileManager.createDirectory(at: documentsURL.appendingPathComponent("upcoming"), withIntermediateDirectories: false, attributes: nil)
        }
        
    }
    
    func saveAllOnDisk(movies : [Movie], category: String){
        for movie in movies{
            saveMovieOnDisk(movie, category: category)
        }
    }
    
    func saveMovieOnDisk(_ movie: Movie, category: String) {
        let encoder = JSONEncoder()
        let title = movie.id
        let fileURL = documentsURL.appendingPathComponent(category).appendingPathComponent("\(title).json")
        if !fileManager.fileExists(atPath: fileURL.absoluteString){
            let data = try! encoder.encode(movie)
            try! data.write(to: fileURL)
        }
    }
    
    func resetStorage() {
        var moviesFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL.appendingPathComponent("popular"), includingPropertiesForKeys: nil)
        for path in moviesFilesURLs {
            try? fileManager.removeItem(at: path)
        }
        
        moviesFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL.appendingPathComponent("topRated"), includingPropertiesForKeys: nil)
        for path in moviesFilesURLs {
            try? fileManager.removeItem(at: path)
        }
        
        moviesFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL.appendingPathComponent("upcomingMovies"), includingPropertiesForKeys: nil)
        for path in moviesFilesURLs {
            try? fileManager.removeItem(at: path)
        }
    }
    
    func retrieveArray(category: String) -> [Movie] {
        if (category == "popular"){
           return self.popularMovies
        }
        else if (category == "topRated"){
            return self.topRatedMovies
        }
        else {
            return self.upcomingMovies
        }
    }
}
