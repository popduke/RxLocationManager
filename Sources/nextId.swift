//
//  nextId.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/6.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import Foundation

private var id = -1
func nextId() -> Int{
    id += 1
    return id
}