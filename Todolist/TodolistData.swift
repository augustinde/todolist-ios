//
//  TodolistData.swift
//  Todolist
//
//  Created by Augustin Desaintfucien on 12/12/2023.
//

import Foundation

enum Priority: String, CaseIterable{
    case major = "MAJOR"
    case minor = "MINOR"
}

struct ItemData {
    var task: String
    var priority: String
}
