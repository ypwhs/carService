//
//  ViewController.swift
//  carService
//
//  Created by 杨培文 on 15/3/26.
//  Copyright (c) 2015年 杨培文. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController ,CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var manager = CBCentralManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func click(sender: AnyObject) {
        manager.scanForPeripheralsWithServices(nil, options: nil)
        out("scaning")
    }
    
    func out(str: AnyObject){
        state.text = String(str as NSString)
        println(str)
    }
    
    @IBOutlet weak var state: UILabel!
    var discoverys = NSMutableArray()
    var car:CBPeripheral?
    var rxd:CBCharacteristic?
    var txd:CBCharacteristic?
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        var name = peripheral.name
        if !discoverys.containsObject(name)&(peripheral != central){
            discoverys.addObject(name)
            out("找到:" + name)
            if name == "YPW-Car"{
                println("已找到YPW-Car")
                manager.stopScan()
                car = peripheral
                manager.connectPeripheral(peripheral, options: nil)
            }
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        out("已连接上YPW-Car,搜索服务中")
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services{
            if (service as CBService).UUID == CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455"){
                out("搜索到串口服务,连接中")
                peripheral.discoverCharacteristics(nil, forService: service as CBService)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        for characteristic in service.characteristics{
            var uuid = (characteristic as CBCharacteristic).UUID
            if uuid == CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616"){
                txd = characteristic as? CBCharacteristic
                out("找到TXD")
            }
            if uuid == CBUUID(string: "49535343-8841-43F4-A8D4-ECBE34729BB3"){
                rxd = characteristic as? CBCharacteristic
                out("找到RXD")
            }
        }
        println(txd)
        println(rxd)
        peripheral.setNotifyValue(true, forCharacteristic: txd)
        peripheral.setNotifyValue(true, forCharacteristic: rxd)
        out("连接串口成功")
        peripheral.writeValue("123".dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: txd, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        var data = characteristic.value
        var datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
        out(datastring!)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
    }

}

