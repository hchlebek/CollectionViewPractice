//
//  Person.swift
//  collectionViewUpdated
//
//  Created by HChlebek on 11/9/16.
//  Copyright © 2016 HChlebek. All rights reserved.
//

import UIKit
// NSCoding is a protocal that allows you to save data to disk, write and read data.
class Person: NSObject, NSCoding
{

    var name : String
    var image : String
    
    init(name: String, image: String)
    {
        self.name = name
        self.image = image
    }
    
    // initializer used for loading objects of the class.
    required init?(coder aDecoder: NSCoder)
    {
        name = aDecoder.decodeObject(forKey: "name") as! String
        image = aDecoder.decodeObject(forKey: "image") as! String
    }
    
    // used for saving
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(name,forKey: "name")
        aCoder.encode(image,forKey: "image")
    }
}
