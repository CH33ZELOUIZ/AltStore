//
//  DuoLayoutCoordinator.swift
//  AltStore Duo
//
//  Keeps AltStore's UIKit navigation clear of the active iPhone Duo fold.
//  The APIs are available beginning with iOS 27.1; older OS versions are a no-op.
//

import UIKit

final class DuoLayoutCoordinator
{
    private weak var viewController: UIViewController?
    private let divisionGuide = UIView()

    init(viewController: UIViewController)
    {
        self.viewController = viewController
    }

    func start()
    {
        guard #available(iOS 27.1, *), let view = self.viewController?.view else { return }

        self.divisionGuide.isUserInteractionEnabled = false
        self.divisionGuide.backgroundColor = .separator
        self.divisionGuide.alpha = 0.0
        self.divisionGuide.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(self.divisionGuide)

        let hingeInteraction = UIHingeInteraction { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.updateLayout()
            }
        }
        view.addInteraction(hingeInteraction)

        self.updateLayout()
    }

    func updateLayout()
    {
        guard #available(iOS 27.1, *), let view = self.viewController?.view else { return }

        // UIKit already adapts the tab/navigation controllers to the view's current
        // geometry. Reserve the physical division visibly and never treat it as content.
        let divisionRegions = view.reservedRegions(kind: .division)
        guard let division = divisionRegions.first(where: { $0.active && !$0.frame.isEmpty }) else
        {
            self.divisionGuide.alpha = 0.0
            return
        }

        self.divisionGuide.frame = division.frame.integral
        self.divisionGuide.alpha = 1.0
        view.bringSubviewToFront(self.divisionGuide)
    }
}
