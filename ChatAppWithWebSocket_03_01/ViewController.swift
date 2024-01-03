import UIKit
import Starscream

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var socket: WebSocket!
    
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebSocket()
        tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupWebSocket() {
        var request = URLRequest(url: URL(string: "ws://localhost:8080")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if let message = messageTextField.text, !message.isEmpty {
            socket.write(string: message)
            messageTextField.text = ""
            appendMessage("You:\(message)")
        }
    }
    
    
    func appendMessage(_ message: String) {
        messages.append(message)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
    
}


extension ViewController: WebSocketDelegate
{
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("Connected with headers: \(headers)")
        case .disconnected(let reason, let code):
            print("Disconnected with reason: \(reason), code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            //appendMessage("Other: \(string)")
        case .ping, .pong, .viabilityChanged, .reconnectSuggested, .cancelled:
            break
        case .error(let error):
            print("Error: \(error)")
        case .binary(_):
            break
        case .peerClosed:
            break
        }
    }
    
    
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        cell.messageLabel.text = messages[indexPath.row]
        return cell
    }
}
