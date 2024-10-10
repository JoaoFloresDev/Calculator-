//
//  SafariWrapperViewController.swift
//  Calculator Notes
//
//  Created by João Flores on 10/10/24.
//  Copyright © 2024 MakeSchool. All rights reserved.
//

import UIKit
import WebKit

class SafariWrapperViewController: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private let urlTextField = UITextField()
    private let backButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        loadURL("https://www.google.com")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Configuração da barra de URL
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "Digite a URL"
        urlTextField.autocapitalizationType = .none
        urlTextField.returnKeyType = .go
        urlTextField.delegate = self
        view.addSubview(urlTextField)
        
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            urlTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            urlTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            urlTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Configuração dos botões de navegação
        let stackView = UIStackView(arrangedSubviews: [backButton, forwardButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        backButton.setTitle("◀️", for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        forwardButton.setTitle("▶️", for: .normal)
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -58) // espaço para botões
        ])
    }
    
    private func loadURL(_ urlString: String) {
        guard var url = URL(string: urlString) else {
            performGoogleSearch(for: urlString)
            return
        }
        
        // Adiciona "https://" se a URL não tiver esquema
        if url.scheme == nil {
            url = URL(string: "https://\(urlString)") ?? url
        }
        
        if UIApplication.shared.canOpenURL(url) {
            webView.load(URLRequest(url: url))
        } else {
            performGoogleSearch(for: urlString)
        }
    }
    
    private func performGoogleSearch(for query: String) {
        let googleSearchURL = "https://www.google.com/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        guard let url = URL(string: googleSearchURL) else { return }
        webView.load(URLRequest(url: url))
    }
    
    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc private func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
}

// MARK: - UITextFieldDelegate
extension SafariWrapperViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let urlString = textField.text, !urlString.isEmpty {
            loadURL(urlString)
        }
        return true
    }
}
