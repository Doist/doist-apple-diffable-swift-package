//
//  Array+DiffableSection.swift
//  
//
//  Created by Jaime Azevedo on 24/03/2021.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen = Set<Iterator.Element>()
        return filter { seen.insert($0).inserted }
    }
}
