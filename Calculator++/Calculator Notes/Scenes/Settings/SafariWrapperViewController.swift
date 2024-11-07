//
//  SafariWrapperViewController.swift
//  Calculator Notes
//
//  Created by João Flores on 10/10/24.
//  Copyright © 2024 MakeSchool. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

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
        view.backgroundColor = .lightGray

        closeButton.setTitle("x", for: .normal)
        closeButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "Digite a URL"
        urlTextField.autocapitalizationType = .none
        urlTextField.returnKeyType = .go
        urlTextField.delegate = self

        // Stack para alinhar closeButton e urlTextField
        let horizontalStack = UIStackView(arrangedSubviews: [closeButton, urlTextField])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 8
        horizontalStack.alignment = .center
        
        view.addSubview(horizontalStack)
        
        // Configurando layout com SnapKit
        horizontalStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        urlTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        // Configuração dos botões de navegação
        let stackView = UIStackView(arrangedSubviews: [backButton, forwardButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        backButton.setTitle("◀️", for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        forwardButton.setTitle("▶️", for: .normal)
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(50)
        }
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
