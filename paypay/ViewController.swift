//
//  ViewController.swift
//  paypay
//
//  Created by Thushara Wijekoon on 12/4/19.
//  Copyright © 2019 Thushara Wijekoon. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController , UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate,  UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var etAmount: UITextField!
    @IBOutlet weak var etCurrency: UITextField!
    @IBOutlet weak var tblRates: UITableView!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var titlePicker: UILabel!
    var selCurName : String = "USD"
    var selCurCode : String = "United States Dollar"
    var arrCurrencies = [Currency]()
    var arrExRates = [ExchangeRate]()
    var arrCalculatedRates = [Double]()
    var amount : Double = 1
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrencies()
        usdRates()
        
        etCurrency.delegate  = self
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControl.Event.valueChanged)
        tblRates.addSubview(refreshControl)
    }
    
    @IBAction func refresh(_ sender: Any) {
        fetchCurrencies()
    }
    
    func fetchCurrencies() {
        let url = URL(string: "http://www.apilayer.net/api/list?access_key=7092c71f80d17f42e22eba08ec2e97ad")
        AF.request(url!, method: .get, parameters: ["include_docs": "true"])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let _):
                    let swiftyJsonVar = JSON(response.data)
                    let x : [String : JSON] =  swiftyJsonVar["currencies"].dictionary!
                    for xx in x {
                        let cc = Currency()
                        cc.curCode = xx.key
                        cc.curName = xx.value.rawString()
                        self.arrCurrencies.append(cc)
                    }
                    break
                case .failure(let error):
                    print("Error while fetching remote rooms: \(error)")
                    break
                    //failure
                }
        }
    }

    func usdRates() {
           let url = URL(string: "http://www.apilayer.net/api/live?access_key=7092c71f80d17f42e22eba08ec2e97ad")
           AF.request(url!, method: .get, parameters: ["include_docs": "true"])
               .validate()
               .responseJSON { response in
                   switch response.result {
                   case .success(let _):
                       let swiftyJsonVar = JSON(response.data)
                       let x : [String : JSON] =  swiftyJsonVar["quotes"].dictionary!
                       for xx in x {
                           let cc = ExchangeRate()
                           cc.exchCode = xx.key
                           cc.exchRate = xx.value.rawString()
                           self.arrExRates.append(cc)
                       }
                       self.calculateRate()
                       break
                   case .failure(let error):
                       print("Error while fetching remote rooms: \(error)")
                       break
                       //failure
                   }
           }
       }
    
    func calculateRate(){
        arrCalculatedRates.removeAll()
        amount = Double(etAmount.text!) as! Double
        if(selCurCode != "USD"){
            var selOneCurUsdVal : Double = 0
            for rate in arrExRates {
                if(rate.exchCode!.contains(selCurCode)){
                    selOneCurUsdVal = 1.0/Double(rate.exchRate)!
                    break
                }
            }
            
            for rate in arrExRates {
                var reqRate : Double = 0
               if(rate.exchCode!.contains(selCurCode)){
                    reqRate = 1
               }else{
                 reqRate = selOneCurUsdVal*Double(rate.exchRate)!
                }
                arrCalculatedRates.append(reqRate)
           }
            self.tblRates.reloadData()
        }
    }
    
    //MARK:- picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ("\(self.arrCurrencies[row].curCode!) -- \(self.arrCurrencies[row].curName!)")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selCurCode = self.arrCurrencies[row].curCode
        selCurName = self.arrCurrencies[row].curName
    }
    
    @IBAction func hiddenPicker(_ sender: Any) {
        self.etCurrency.text = selCurCode
         self.calculateRate()
        self.viewPicker.isHidden = true
    }
    
    //MARK:- Table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CurrencyCell = tableView.dequeueReusableCell(withIdentifier: "cur_cell", for: indexPath) as! CurrencyCell
        cell.lblTotalVal.text = "\(arrExRates[indexPath.row].exchCode![3...5]) \(arrCalculatedRates[indexPath.row]*amount)"
//        cell.lblDesc.text = "\(arrExRates[indexPath.row].exchCode![3...5]) --  "
        cell.lblOneVal.text = "1 \(selCurCode) = \(arrCalculatedRates[indexPath.row])  \(arrExRates[indexPath.row].exchCode![3...5])"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCalculatedRates.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == etCurrency {
            self.view.endEditing(true)
            picker.selectRow(0, inComponent: 0, animated:   true)
            viewPicker.isHidden = false
            picker.reloadAllComponents()
            return false
        }
        return true
    }
}


extension String {
  subscript(_ i: Int) -> String {
    let idx1 = index(startIndex, offsetBy: i)
    let idx2 = index(idx1, offsetBy: 1)
    return String(self[idx1..<idx2])
  }

  subscript (r: Range<Int>) -> String {
    let start = index(startIndex, offsetBy: r.lowerBound)
    let end = index(startIndex, offsetBy: r.upperBound)
    return String(self[start ..< end])
  }

  subscript (r: CountableClosedRange<Int>) -> String {
    let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
    let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
    return String(self[startIndex...endIndex])
  }
}
