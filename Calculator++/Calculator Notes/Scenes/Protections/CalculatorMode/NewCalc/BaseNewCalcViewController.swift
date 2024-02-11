import Foundation
import UIKit

class BaseNewCalcViewController: UIViewController {
    
    // MARK: - Public Vars
    var keyTemp = ""
    var captureKey = 0
    var runningNumber = ""
    var leftValue = ""
    var rightValue = ""
    var result = ""
    var currentOperation: Operation = .NULL
    var key = Defaults.getString(.password)
    let recoveryKey = "314159"
    
    // MARK: - IBOutlets
    @IBOutlet weak var outputLbl: UILabel!
    
    // MARK: - Lifecycle Methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Operations
    
    /// Limpa todas as variáveis e define o estado inicial da calculadora
    func clear() {
        runningNumber = ""
        leftValue = ""
        rightValue = ""
        result = ""
        currentOperation = .NULL
        outputLbl.text = "0 "
    }
    
    /// Realiza a operação especificada
    func operation(operation: Operation) {
        if currentOperation != .NULL {
            completeOperation()
        } else {
            startOperation(operation: operation)
        }
    }
    
    /// Adiciona um ponto decimal ao número atual, se possível
    func dotPressed() {
        if runningNumber.count <= 8 {
            runningNumber += "."
            outputLbl.text = runningNumber
        }
    }
    
    // MARK: - Private Helpers
    
    /// Começa uma nova operação
    private func startOperation(operation: Operation) {
        leftValue = runningNumber
        runningNumber = ""
        currentOperation = operation
    }
    
    /// Completa a operação atual e atualiza `leftValue` e `result`
    private func completeOperation() {
        if runningNumber.isEmpty { return }
        
        rightValue = runningNumber
        runningNumber = ""
        
        switch currentOperation {
        case .Add:
            performAddition()
        case .Subtract:
            performSubtraction()
        case .Multiply:
            performMultiplication()
        case .Divide:
            performDivision()
        default:
            break
        }
        
        updateUI()
    }
    
    /// Realiza a operação de adição
    private func performAddition() {
        result = "\((Double(leftValue) ?? 0) + (Double(rightValue) ?? 0))"
    }
    
    /// Realiza a operação de subtração
    private func performSubtraction() {
        result = "\((Double(leftValue) ?? 0) - (Double(rightValue) ?? 0))"
    }
    
    /// Realiza a operação de multiplicação
    private func performMultiplication() {
        result = "\((Double(leftValue) ?? 0) * (Double(rightValue) ?? 0))"
    }
    
    /// Realiza a operação de divisão
    private func performDivision() {
        result = "\((Double(leftValue) ?? 0) / (Double(rightValue) ?? 0))"
    }
    
    /// Atualiza a interface do usuário
    private func updateUI() {
        leftValue = result
        if (Double(result)?.truncatingRemainder(dividingBy: 1) == 0) {
            result = "\(Int(Double(result) ?? 0))"
        }
        outputLbl.text = result
    }
}
