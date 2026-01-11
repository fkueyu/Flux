import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var bonjourBrowser: NetServiceBrowser?
  private var discoveredServices: [NetService] = []
  private var resolvedDevices: [[String: Any]] = []
  private var discoveryChannel: FlutterMethodChannel?
  private var pendingResult: FlutterResult?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    discoveryChannel = FlutterMethodChannel(
      name: "flux/mdns_discovery",
      binaryMessenger: controller.binaryMessenger
    )
    
    discoveryChannel?.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "startDiscovery":
        self?.startDiscovery(result: result)
      case "stopDiscovery":
        self?.stopDiscovery()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func startDiscovery(result: @escaping FlutterResult) {
    // 清理之前的状态
    stopDiscovery()
    
    discoveredServices = []
    resolvedDevices = []
    pendingResult = result
    
    bonjourBrowser = NetServiceBrowser()
    bonjourBrowser?.delegate = self
    bonjourBrowser?.searchForServices(ofType: "_wled._tcp.", inDomain: "local.")
    
    // 8 秒后返回结果
    DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
      self?.finishDiscovery()
    }
  }
  
  private func stopDiscovery() {
    bonjourBrowser?.stop()
    bonjourBrowser = nil
    for service in discoveredServices {
      service.stop()
    }
    discoveredServices = []
  }
  
  private func finishDiscovery() {
    guard let result = pendingResult else { return }
    pendingResult = nil
    stopDiscovery()
    result(resolvedDevices)
  }
}

// MARK: - NetServiceBrowserDelegate
extension AppDelegate: NetServiceBrowserDelegate {
  func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
    print("[Bonjour] Found service: \(service.name)")
    discoveredServices.append(service)
    service.delegate = self
    service.resolve(withTimeout: 5.0)
  }
  
  func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
    print("[Bonjour] Search error: \(errorDict)")
  }
}

// MARK: - NetServiceDelegate
extension AppDelegate: NetServiceDelegate {
  func netServiceDidResolveAddress(_ sender: NetService) {
    guard let addresses = sender.addresses else { return }
    
    for addressData in addresses {
      var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
      
      addressData.withUnsafeBytes { ptr in
        let sockaddr = ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self)
        getnameinfo(
          sockaddr,
          socklen_t(addressData.count),
          &hostname,
          socklen_t(hostname.count),
          nil,
          0,
          NI_NUMERICHOST
        )
      }
      
      let ipAddress = String(cString: hostname)
      
      // 只处理 IPv4 地址
      if ipAddress.contains(".") && !ipAddress.contains(":") {
        let device: [String: Any] = [
          "name": sender.name,
          "ip": ipAddress,
          "port": sender.port
        ]
        
        // 避免重复
        if !resolvedDevices.contains(where: { $0["ip"] as? String == ipAddress }) {
          print("[Bonjour] Resolved: \(sender.name) -> \(ipAddress):\(sender.port)")
          resolvedDevices.append(device)
        }
        break
      }
    }
  }
  
  func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
    print("[Bonjour] Failed to resolve \(sender.name): \(errorDict)")
  }
}
