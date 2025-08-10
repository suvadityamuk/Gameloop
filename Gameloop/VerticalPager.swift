//
//  VerticalPager.swift
//  Gameloop
//
//  Created by Suvaditya Mukherjee on 8/9/25.
//


import SwiftUI
import UIKit

struct VerticalPager<Page: View>: UIViewControllerRepresentable {
    var pages: [Page]
    @Binding var index: Int
    var onIndexNearEnd: (() -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pvc = UIPageViewController(transitionStyle: .scroll,
                                       navigationOrientation: .vertical,
                                       options: nil)
        pvc.dataSource = context.coordinator
        pvc.delegate = context.coordinator
        if !context.coordinator.controllers.isEmpty {
            pvc.setViewControllers([context.coordinator.controllers[index]], direction: .forward, animated: false)
        }
        pvc.view.backgroundColor = .clear
        return pvc
    }

    func updateUIViewController(_ pvc: UIPageViewController, context: Context) {
        context.coordinator.update(pages: pages)
        if index < context.coordinator.controllers.count {
            pvc.setViewControllers([context.coordinator.controllers[index]], direction: .forward, animated: false)
        }
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: VerticalPager
        var controllers: [UIHostingController<Page>] = []

        init(_ parent: VerticalPager) {
            self.parent = parent
            super.init()
            update(pages: parent.pages)
        }

        func update(pages: [Page]) {
            controllers = pages.map { UIHostingController(rootView: $0) }
            controllers.forEach { $0.view.backgroundColor = .clear }
        }

        func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
            guard let idx = controllers.firstIndex(where: { $0 === vc }) else { return nil }
            let prev = idx - 1
            return prev >= 0 ? controllers[prev] : nil
        }

        func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
            guard let idx = controllers.firstIndex(where: { $0 === vc }) else { return nil }
            let next = idx + 1
            if next >= controllers.count - 2 {
                DispatchQueue.main.async { self.parent.onIndexNearEnd?() }
            }
            return next < controllers.count ? controllers[next] : nil
        }

        func pageViewController(_ pvc: UIPageViewController,
                                didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController],
                                transitionCompleted completed: Bool) {
            guard completed,
                  let vc = pvc.viewControllers?.first,
                  let idx = controllers.firstIndex(where: { $0 === vc }) else { return }
            parent.index = idx
        }
    }
}
