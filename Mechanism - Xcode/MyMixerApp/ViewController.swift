//
//  ViewController.swift
//  MyMixerApp
//
//  Created by Lachlan Forbes on 10/1/2023.
//

import UIKit
import CoreBluetooth
import SwiftUI


class ViewController: UIViewController {
    
    private var speedSlider:UISlider = UISlider()
    private var angleSlider:UISlider = UISlider()
    private var circlePowerStatus:UILabel = UILabel()
    private var label:UILabel = UILabel()
    private var centralManager:CBCentralManager!
    private var bluefruitPeripheral: CBPeripheral!
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    private let sizeS:CGRect = UIScreen.main.bounds
    private var imageView:UIImageView = UIImageView()
    public var speedValue:Int = 0 // 0 to 10
    public var angleValue: Int = 90 //0 to -180
    
     
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        setupHomeScreen()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        writeOutgoingValue(data: "0|90\n")
        
    }
    
    func setupHomeScreen(){
    
        
        //Title H-Stack begin
        let containerHorStack = UIView()
        self.view.addSubview(containerHorStack)
        containerHorStack.translatesAutoresizingMaskIntoConstraints = false
        containerHorStack.backgroundColor = .blue
        containerHorStack.heightAnchor.constraint(equalToConstant: sizeS.height*0.1).isActive = true
        containerHorStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        containerHorStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        containerHorStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        
        let titleHorStack = UIStackView()
        containerHorStack.addSubview(titleHorStack)
        titleHorStack.axis = .horizontal
        titleHorStack.alignment = .center
        titleHorStack.translatesAutoresizingMaskIntoConstraints = false
        titleHorStack.spacing = 0
        titleHorStack.distribution = .fill
        titleHorStack.topAnchor.constraint(equalTo: containerHorStack.topAnchor).isActive = true
        titleHorStack.bottomAnchor.constraint(equalTo: containerHorStack.bottomAnchor).isActive = true
        titleHorStack.leftAnchor.constraint(equalTo: containerHorStack.leftAnchor).isActive = true
        titleHorStack.rightAnchor.constraint(equalTo: containerHorStack.rightAnchor).isActive = true
        
        print(containerHorStack.bounds.size.width)
        let titleView = UIView()
        titleHorStack.addArrangedSubview(titleView)
        titleView.backgroundColor = .black
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.widthAnchor.constraint(equalTo: containerHorStack.widthAnchor, multiplier: 0.7).isActive = true
        titleView.heightAnchor.constraint(equalTo: containerHorStack.heightAnchor, multiplier: 1).isActive = true
        
        let bold = "MY"
        let style = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)]
        let styleBold = NSMutableAttributedString(string: bold, attributes: style)
        let normal = "Mixer"
        let styleN = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)]
        let styleNormal = NSMutableAttributedString(string: normal, attributes: styleN)
        styleBold.append(styleNormal)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.textColor = .white
            titleLabel.textAlignment = .center
            titleLabel.attributedText = styleBold
        
        titleView.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        
        let bluetoothActiveView = UIView()
        titleHorStack.addArrangedSubview(bluetoothActiveView)
        bluetoothActiveView.backgroundColor = .black
        bluetoothActiveView.translatesAutoresizingMaskIntoConstraints = false
        bluetoothActiveView.widthAnchor.constraint(equalTo: containerHorStack.widthAnchor, multiplier: 0.3).isActive = true
        bluetoothActiveView.heightAnchor.constraint(equalTo: containerHorStack.heightAnchor, multiplier: 1).isActive = true
        
        circlePowerStatus = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: sizeS.width*0.025, height: sizeS.width*0.025)))
        circlePowerStatus.translatesAutoresizingMaskIntoConstraints = false
        circlePowerStatus.layer.cornerRadius = circlePowerStatus.frame.width/2
        circlePowerStatus.layer.masksToBounds = true
        circlePowerStatus.backgroundColor = .red

        bluetoothActiveView.addSubview(circlePowerStatus)
        circlePowerStatus.widthAnchor.constraint(equalToConstant: sizeS.width*0.025).isActive = true
        circlePowerStatus.heightAnchor.constraint(equalToConstant: sizeS.width*0.025).isActive = true
        circlePowerStatus.centerYAnchor.constraint(equalTo: bluetoothActiveView.centerYAnchor).isActive = true
        circlePowerStatus.centerXAnchor.constraint(equalTo: bluetoothActiveView.centerXAnchor).isActive = true
        //Title H-Stack end
        
        //connecting label begin
        label = UILabel()
        view.addSubview(label)
        label.backgroundColor = .gray
        label.text = "Connecting..."
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: sizeS.height*0.03).isActive = true
        label.topAnchor.constraint(equalTo: containerHorStack.bottomAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        //connecting label end
        
        let whiteView = UIView()
        view.addSubview(whiteView)
        whiteView.backgroundColor = .white
        whiteView.layer.cornerRadius = 10
        whiteView.layer.masksToBounds = true
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        whiteView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        whiteView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        whiteView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        whiteView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        

        
      


        
     
        
        let buttonsContainer = UIView()
        whiteView.addSubview(buttonsContainer)
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.widthAnchor.constraint(equalTo: whiteView.widthAnchor, multiplier: 0.8).isActive = true
        buttonsContainer.heightAnchor.constraint(equalTo: whiteView.heightAnchor, multiplier: 0.2).isActive = true
        buttonsContainer.bottomAnchor.constraint(equalTo: whiteView.bottomAnchor, constant: -40).isActive = true
        buttonsContainer.centerXAnchor.constraint(equalTo: whiteView.centerXAnchor).isActive = true
        
        let buttonsHStack = UIStackView()
        buttonsContainer.addSubview(buttonsHStack)
        buttonsHStack.axis = .horizontal
        buttonsHStack.distribution = .fillEqually
        buttonsHStack.alignment = .center
        buttonsHStack.spacing = 30
        buttonsHStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsHStack.topAnchor.constraint(equalTo: buttonsContainer.topAnchor).isActive = true
        buttonsHStack.rightAnchor.constraint(equalTo: buttonsContainer.rightAnchor).isActive = true
        buttonsHStack.leftAnchor.constraint(equalTo: buttonsContainer.leftAnchor).isActive = true
        buttonsHStack.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor).isActive = true
        
      
        
        let stopButton = UIButton()
        buttonsHStack.addArrangedSubview(stopButton)
        stopButton.setTitle("Stop", for: .normal)
        stopButton.layer.cornerRadius = 10
        stopButton.layer.masksToBounds = true
        stopButton.backgroundColor = .blue
        stopButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        stopButton.heightAnchor.constraint(equalTo: buttonsContainer.heightAnchor, multiplier: 0.3).isActive = true
    
        let resetButton = UIButton()
        buttonsHStack.addArrangedSubview(resetButton)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.layer.cornerRadius = 10
        resetButton.layer.masksToBounds = true
        resetButton.backgroundColor = .blue
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        resetButton.heightAnchor.constraint(equalTo: buttonsContainer.heightAnchor, multiplier: 0.3).isActive = true
        
        
        let speedContainer = UIView()
        whiteView.addSubview(speedContainer)
        speedContainer.translatesAutoresizingMaskIntoConstraints = false
        speedContainer.widthAnchor.constraint(equalTo: whiteView.widthAnchor, multiplier: 0.8).isActive = true
        speedContainer.heightAnchor.constraint(equalTo: whiteView.heightAnchor, multiplier: 0.18).isActive = true
        speedContainer.centerXAnchor.constraint(equalTo: whiteView.centerXAnchor).isActive = true
        speedContainer.bottomAnchor.constraint(equalTo: buttonsContainer.topAnchor, constant: -20).isActive = true
        
        let speedVStack = UIStackView()
        speedContainer.addSubview(speedVStack)
        speedVStack.axis = .vertical
        speedVStack.alignment = .center
        speedVStack.translatesAutoresizingMaskIntoConstraints = false
        speedVStack.spacing = 0
        speedVStack.distribution = .fill
        speedVStack.topAnchor.constraint(equalTo: speedContainer.topAnchor).isActive = true
        speedVStack.bottomAnchor.constraint(equalTo: speedContainer.bottomAnchor).isActive = true
        speedVStack.leftAnchor.constraint(equalTo: speedContainer.leftAnchor).isActive = true
        speedVStack.rightAnchor.constraint(equalTo: speedContainer.rightAnchor).isActive = true
        
        
       
        
      let speedSlideLabel = UILabel()
        speedVStack.addArrangedSubview(speedSlideLabel)
        speedSlideLabel.attributedText = NSMutableAttributedString(string: "Speed", attributes: style)
        speedSlideLabel.textColor = .black
        speedSlideLabel.translatesAutoresizingMaskIntoConstraints = false
        speedSlideLabel.widthAnchor.constraint(equalTo: speedContainer.widthAnchor).isActive = true
        speedSlideLabel.heightAnchor.constraint(equalTo: speedContainer.heightAnchor, multiplier: 0.55).isActive = true
        
        
       
        speedSlider = UISlider()
        speedVStack.addArrangedSubview(speedSlider)
        speedSlider.maximumValue = 10
        speedSlider.minimumValue = 0
        speedSlider.value = 0
        speedSlider.isContinuous = false
        speedSlider.addTarget(self, action: #selector(speedSlid), for: .valueChanged)
        speedSlider.addTarget(self, action: #selector(snap), for: .allEvents)
        speedSlider.addTarget(self, action: #selector(resetImg), for: .touchUpInside)
        speedSlider.addTarget(self, action: #selector(resetImg), for: .touchUpOutside)
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        speedSlider.widthAnchor.constraint(equalTo: speedContainer.widthAnchor).isActive = true
        speedSlider.heightAnchor.constraint(equalTo: speedContainer.heightAnchor, multiplier: 0.3).isActive = true
        
        
        let numbersSpeedSlider = UIStackView()
        speedVStack.addArrangedSubview(numbersSpeedSlider)
        numbersSpeedSlider.axis = .horizontal
        numbersSpeedSlider.alignment = .center
        numbersSpeedSlider.translatesAutoresizingMaskIntoConstraints = false
        numbersSpeedSlider.spacing = 0
        numbersSpeedSlider.distribution = .fillEqually
        numbersSpeedSlider.leftAnchor.constraint(equalTo: speedContainer.leftAnchor).isActive = true
        numbersSpeedSlider.rightAnchor.constraint(equalTo: speedContainer.rightAnchor).isActive = true


        for i in 0...10{
            let tempValue = UILabel()
            numbersSpeedSlider.addArrangedSubview(tempValue)
            tempValue.textAlignment = .center
            tempValue.textColor = .black
            tempValue.text = String(i)
            tempValue.translatesAutoresizingMaskIntoConstraints = false

        }
        
        
        let angleContainer = UIView()
        whiteView.addSubview(angleContainer)
        angleContainer.translatesAutoresizingMaskIntoConstraints = false
        angleContainer.widthAnchor.constraint(equalTo: whiteView.widthAnchor, multiplier: 0.8).isActive = true
        angleContainer.heightAnchor.constraint(equalTo: whiteView.heightAnchor, multiplier: 0.18).isActive = true
        angleContainer.centerXAnchor.constraint(equalTo: whiteView.centerXAnchor).isActive = true
        angleContainer.bottomAnchor.constraint(equalTo: speedContainer.topAnchor, constant: -20).isActive = true
        
        let angleVStack = UIStackView()
        angleContainer.addSubview(angleVStack)
        angleVStack.axis = .vertical
        angleVStack.alignment = .center
        angleVStack.translatesAutoresizingMaskIntoConstraints = false
        angleVStack.spacing = 0
        angleVStack.distribution = .fill
        angleVStack.topAnchor.constraint(equalTo: angleContainer.topAnchor).isActive = true
        angleVStack.bottomAnchor.constraint(equalTo: angleContainer.bottomAnchor).isActive = true
        angleVStack.leftAnchor.constraint(equalTo: angleContainer.leftAnchor).isActive = true
        angleVStack.rightAnchor.constraint(equalTo: angleContainer.rightAnchor).isActive = true
        
        
       
        
      let angleSlideLabel = UILabel()
        angleVStack.addArrangedSubview(angleSlideLabel)
        angleSlideLabel.attributedText = NSMutableAttributedString(string: "Angle", attributes: style)
        angleSlideLabel.textColor = .black
        angleSlideLabel.translatesAutoresizingMaskIntoConstraints = false
        angleSlideLabel.widthAnchor.constraint(equalTo: angleContainer.widthAnchor).isActive = true
        angleSlideLabel.heightAnchor.constraint(equalTo: angleContainer.heightAnchor, multiplier: 0.55).isActive = true
        
        
       
        angleSlider = UISlider()
        angleVStack.addArrangedSubview(angleSlider)
        angleSlider.maximumValue = 180
        angleSlider.minimumValue = 0
        angleSlider.value = 90
        angleSlider.isContinuous = false
        angleSlider.addTarget(self, action: #selector(imgChange), for: .touchDown)
        angleSlider.addTarget(self, action: #selector(angleSlid), for: .valueChanged)
        angleSlider.addTarget(self, action: #selector(resetImg), for: .touchUpInside)
        angleSlider.addTarget(self, action: #selector(resetImg), for: .touchUpOutside)
        angleSlider.translatesAutoresizingMaskIntoConstraints = false
        angleSlider.widthAnchor.constraint(equalTo: angleContainer.widthAnchor).isActive = true
        angleSlider.heightAnchor.constraint(equalTo: angleContainer.heightAnchor, multiplier: 0.3).isActive = true
        
        
        let numbersAngleSlider = UIStackView()
        angleVStack.addArrangedSubview(numbersAngleSlider)
        numbersAngleSlider.axis = .horizontal
        numbersAngleSlider.alignment = .center
        numbersAngleSlider.translatesAutoresizingMaskIntoConstraints = false
        numbersAngleSlider.spacing = 0
        numbersAngleSlider.distribution = .fillEqually
        numbersAngleSlider.leftAnchor.constraint(equalTo: angleContainer.leftAnchor).isActive = true
        numbersAngleSlider.rightAnchor.constraint(equalTo: angleContainer.rightAnchor).isActive = true


        for i in 0...4{
            let numbers = [-90,-45,0,45,90]
            let tempValue = UILabel()
            numbersAngleSlider.addArrangedSubview(tempValue)
            tempValue.textAlignment = .center
            tempValue.textColor = .black
            tempValue.text = String(numbers[i])
            tempValue.translatesAutoresizingMaskIntoConstraints = false

        }
        
        
        whiteView.addSubview(imageView)
        imageView.image = UIImage(named: "plain image")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: whiteView.widthAnchor, multiplier: 0.8).isActive = true
        imageView.heightAnchor.constraint(equalTo: whiteView.heightAnchor, multiplier: 0.30).isActive = true
        imageView.centerXAnchor.constraint(equalTo: whiteView.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: angleContainer.topAnchor, constant: -15).isActive = true
        imageView.topAnchor.constraint(equalTo: whiteView.topAnchor, constant: 15).isActive = true
   
    }
    
   @objc func speedSlid(){
       speedValue = Int(speedSlider.value)
        writeOutgoingValue(data: String(speedValue) + "|" + String(angleValue) + "\n")
        
    }
    @objc func angleSlid(){
        angleValue = Int(round(angleSlider.value))
        writeOutgoingValue(data: String(speedValue) + "|" + String(angleValue) + "\n")
         
     }
    @objc func imgChange(){
        imageView.image = UIImage(named: "angle image")
        angleSlider.value = angleSlider.value
         
     }
    
    @objc func resetImg(){
        imageView.image = UIImage(named: "plain image")
    }
    
    @objc func snap(){
        let snapPos = round(speedSlider.value)
        speedSlider.value = snapPos
        imageView.image = UIImage(named: "bucket image")
    }
    
    func disconnectFromDevice () {
        if bluefruitPeripheral != nil {
        centralManager?.cancelPeripheralConnection(bluefruitPeripheral!)
        }
     }

    func startScanning() -> Void {
      centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
    }
    
    
    
    @objc func pressed(){
        writeOutgoingValue(data: "0|" + String(angleValue) + "\n")
        print("stop in position")
       
    }
    @objc func reset(){
        speedSlider.value = 0
        angleSlider.value = 90
        speedValue = Int(speedSlider.value)
        angleValue = Int(angleSlider.value)
        writeOutgoingValue(data: "r\n")
    }
   
    
}

extension ViewController: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
     switch central.state {
          case .poweredOff:
         circlePowerStatus.backgroundColor = .red
          case .poweredOn:
         circlePowerStatus.backgroundColor = .green
                startScanning()
          case .unsupported:
         circlePowerStatus.backgroundColor = .yellow
          case .unauthorized:
         circlePowerStatus.backgroundColor = .yellow
          case .unknown:
         circlePowerStatus.backgroundColor = .yellow
          case .resetting:
         circlePowerStatus.backgroundColor = .yellow
          @unknown default:
         circlePowerStatus.backgroundColor = .red
          }
  }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {

        bluefruitPeripheral = peripheral

        bluefruitPeripheral.delegate = self

        
        
            
        centralManager?.stopScan()
        centralManager?.connect(bluefruitPeripheral!, options: nil)
       }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
       bluefruitPeripheral.discoverServices([CBUUIDs.BLEService_UUID])
    }

}

extension ViewController: CBPeripheralDelegate {
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            print("*******************************************************")

            if ((error) != nil) {
                print("Error discovering services: \(error!.localizedDescription)")
                return
            }
            guard let services = peripheral.services else {
                return
            }
            
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        
        label.backgroundColor = .green
        label.text = "Connected"
        label.textColor = .black
        
            print("Discovered Services: \(services)")
        }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

          var characteristicASCIIValue = NSString()

          guard characteristic == rxCharacteristic,

          let characteristicValue = characteristic.value,
          let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }

          characteristicASCIIValue = ASCIIstring

          print("Value Recieved: \((characteristicASCIIValue as String))")
    }
    
    func writeOutgoingValue(data: String){
        print(data)
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = bluefruitPeripheral{
            blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
       
       
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           
               guard let characteristics = service.characteristics else {
              return
          }

          print("Found \(characteristics.count) characteristics.")

          for characteristic in characteristics {

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {

              rxCharacteristic = characteristic

              peripheral.setNotifyValue(true, for: rxCharacteristic!)
              peripheral.readValue(for: characteristic)

              print("RX Characteristic: \(rxCharacteristic.uuid)")
            }

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
              
              txCharacteristic = characteristic
              
              print("TX Characteristic: \(txCharacteristic.uuid)")
            }
          }
    }
}

extension ViewController: CBPeripheralManagerDelegate {

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
        print("Peripheral Is Powered On.")
    case .unsupported:
        print("Peripheral Is Unsupported.")
    case .unauthorized:
    print("Peripheral Is Unauthorized.")
    case .unknown:
        print("Peripheral Unknown")
    case .resetting:
        print("Peripheral Resetting")
    case .poweredOff:
      print("Peripheral Is Powered Off.")
    @unknown default:
      print("Error")
    }
  }
}
