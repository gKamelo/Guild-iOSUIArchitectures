//
//  DetailTaskViewController.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import UIKit

final class DetailTaskViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var dueDateLabel: UILabel!

    var viewModel: DetailTaskViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.viewModel?.title
        self.descriptionLabel.text = self.viewModel?.description
        self.dueDateLabel.text = self.viewModel?.dueDate
    }
}
