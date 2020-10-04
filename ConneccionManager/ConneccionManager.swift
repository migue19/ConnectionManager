//
//  ConneccionManager.swift
//  ConneccionManager
//
//  Created by Miguel Mexicano Herrera on 04/10/20.
//

import Foundation

class ConneccionManager {
    let time: Int
    
    init() {
        self.time = 180
    }
    init(time: Int) {
        self.time = time
    }
    func getSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(time)
        configuration.timeoutIntervalForResource = TimeInterval(time)
        return configuration
    }
    func printResultHttpConnection(data: Data?){
        guard let data = data else {
            return
        }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            print(jsonObject)
        } catch {
            print(error)
        }
    }
    func conneccionRequest(url: String, method: String, headers: [String: String], parameters: [String: Any]?, closure: @escaping (Data?,String?) -> Void) {
        let configuration = getSessionConfiguration()
        let session = URLSession(configuration: configuration)
        guard let url = URL(string: url) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        if let param = parameters {
            do{
                let httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                request.httpBody = httpBody
            }catch {
                print(error)
            }
        }
        session.dataTask(with: request) { (data, response, error) in
            if(error != nil){
                closure(nil,"Error de conexion")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else{
                return
            }
            self.printResultHttpConnection(data: data)
            switch(httpResponse.statusCode){
            case 200:
                closure(data,nil)
                print("Servicio exitoso")
                break
            case 404:
                closure(nil,"Servicio no Encontrado")
                print("Servicio no Encontrado")
                break
            case 500:
                closure(nil,"Error en el Servicio")
                break
            default:
                closure(nil,"el servicio regreso un codigo \(httpResponse.statusCode)")
                print("el servicio regreso un codigo \(httpResponse.statusCode)")
                break
            }
        }.resume()
    }
}