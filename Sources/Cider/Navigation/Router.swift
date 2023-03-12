//
//  Router.swift
//
//  Created by Mark Malstrom on 3/12/23.
//

import UIKit

public protocol Router<Route> {
    associatedtype Route

    func navigate(to route: Route, from viewController: UIViewController?)
}
