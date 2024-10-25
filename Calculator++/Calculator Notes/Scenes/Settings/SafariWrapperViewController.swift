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
    private let closeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        loadURL("https://www.google.com")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Configuração do botão de fechar (X)
        closeButton.setTitle("x", for: .normal)
        closeButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        view.addSubview(closeButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Configuração da barra de URL
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "Digite a URL"
        urlTextField.autocapitalizationType = .none
        urlTextField.returnKeyType = .go
        urlTextField.delegate = self
        view.addSubview(urlTextField)
        
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlTextField.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 8),
            urlTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            urlTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -58) // espaço para botões
        ])
    }
    
    private func loadURL(_ urlString: String) {
        // Verifica se a string é uma URL válida
        var formattedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !formattedURLString.hasPrefix("http://") && !formattedURLString.hasPrefix("https://") {
            formattedURLString = "https://\(formattedURLString)"
        }
        
        // Tenta criar a URL
        guard let url = URL(string: formattedURLString) else {
            performGoogleSearch(for: urlString)
            return
        }
        
        // Carrega a URL na webView
        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func performGoogleSearch(for query: String) {
        let googleSearchURL = "https://www.google.com/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        if let url = URL(string: googleSearchURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc private func closePressed() {
        dismiss(animated: true, completion: nil)
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
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Se falhar ao carregar, realiza uma pesquisa no Google
        if let failingURL = (error as NSError).userInfo[NSURLErrorFailingURLStringErrorKey] as? String {
            let sanitizedQuery = failingURL
                .replacingOccurrences(of: "https://", with: "")
                .replacingOccurrences(of: "http://", with: "")
                .replacingOccurrences(of: "/", with: "") // Remove barras adicionais
            performGoogleSearch(for: sanitizedQuery)
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
