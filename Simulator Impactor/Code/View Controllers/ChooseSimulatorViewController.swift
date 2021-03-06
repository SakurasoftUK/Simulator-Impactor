//
//  ChooseSimulatorViewController.swift
//  Simulator Impactor
//
//  Created by Jacob King on 03/02/2017.
//  Copyright © 2017 Militia Softworks Ltd. All rights reserved.
//

import Cocoa

class ChooseSimulatorViewController: NSViewController {
    
    @IBOutlet var simulatorListDropDown: NSPopUpButton!
    @IBOutlet var runButton: NSButton!
    @IBOutlet var selectAppButton: NSButton!
    @IBOutlet var helpButton: NSButton!
    @IBOutlet var appLabel: NSTextField!
    @IBOutlet var versionLabel: NSTextField!
    
    var simulators = [Simulator]()
    
    var selectedSimulator: Simulator?
    var selectedApp: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveSimulators()
        versionLabel.stringValue = "v" + Utilities.getBundleVersionString()
    }
    
    func retrieveSimulators() {
        simulators = SimulatorRepository.fetchSimulators()
        simulatorListDropDown.removeAllItems()
        simulatorListDropDown.addItem(withTitle: "- Please Select -")
        for sim in simulators {
            simulatorListDropDown.addItem(withTitle: sim.displayString)
        }
    }
    
    func openSimulatorWithApp() {
        if let bundleId = Utilities.extractBundleIdentifierFromApp(app: self.selectedApp!) {
            SimulatorRepository.launchSimulator(sim: self.selectedSimulator!, onSuccessfulCompletion: { (process) in
                SimulatorRepository.installApp(atPath: self.selectedApp!, onSuccessfulCompletion: { (process) in
                    SimulatorRepository.runApp(withBundleId: bundleId)
                })
            })
        }
    }
    
    @IBAction func userDidSelectSimulator(_ sender: Any) {
        let selectedItemTitle = simulatorListDropDown.selectedItem!.title
        simulatorListDropDown.setTitle(selectedItemTitle)
        guard selectedItemTitle != "- Please Select -" else {
            return
        }
        
        selectedSimulator = simulators.filter { $0.displayString == selectedItemTitle }.first
    }
    
    @IBAction func run(_ sender: Any) {
        guard selectedSimulator != nil && selectedApp != nil else {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "Please select a simulator and .app file before clicking run."
                alert.addButton(withTitle: "Okay")
                alert.runModal()
            }
            return
        }
        SimulatorRepository.killRunningSimulators { (process) in
            self.openSimulatorWithApp()
        }
    }
    
    @IBAction func openAppSelection(_ sender: Any) {
        Utilities.openPanelForAppFileType { (url) in
            if let selectedFileURL = url {
                let fileName = selectedFileURL.pathComponents.last!
                self.appLabel.stringValue = fileName
                self.selectedApp = selectedFileURL
            }
        }
    }
}
