////
////  SceneDelegate.swift
////  Sueca
////
////  Created by Joao Flores on 01/12/19.
////  Copyright © 2019 Joao Flores. All rights reserved.
////
//import UIKit
//
///// Calculadora Básica com operações simples
//class Calculator: NSObject {
//
//    // o private(set) nos apributos public abaixo
//    // garante que será uma propriedade readonly externamente
//    // isto é, externamente pode se ler o valor mas
//    // não atribuí-lo
//
//    // MARK: Atributos
//
//    /// Resutado final calculado
//    public private(set) var result: Float
//
//    /// Número que está sendo inserido para
//    /// executar a próxima operaçao
//    public private(set) var number: Float
//
//    /// Operação a ser executada usando o número
//    /// e o resultado acumulado
//    public private(set) var operation: String
//
//    /// Construtor padrão da Classe
//    public override init()
//    {
//        self.result = Float()
//        self.number = Float()
//        self.operation = "="
//    }
//
//
//    // MARK: Operações
//
//    /// Limpa e reinicia os atributos
//    func clear()
//    {
//        self.result = 0
//        self.number = 0
//        self.operation = "="
//    }
//
//    /// Insere um dígito no número corrente que a calculadora está exibindo
//    ///
//    /// - Parameter digit: dígito a ser acrescentado o numero
//    /// - Returns: valor numerico final após inserção do dígito
//    func input(digit:Float) -> Float
//    {
//        // TODO: Implementar "."
//
//        // para cada digito novo é considerado uma unidade, os anteriores
//        // são multiplicados por 10 para virarem dezenas, centenas, etc...
//        self.number = self.number * 10 + digit
//
//        return self.number
//    }
//
//    /// Executa uma operação básica da calculadora
//    ///
//    /// - Parameter op: String com a operação a ser executada
//    /// - Returns: valor final da operação
//    func operation(_ op:String) -> Float{
//
//        // TODO: Implementar "%" e "+/-"
//
//        // Seleciona e executa a operação corrente
//        switch self.operation {
//
//        case "=":
//            self.result = self.number
//
//        case "+":
//            self.result += self.number
//
//        case "-":
//            self.result -= self.number
//
//        case "x":
//            self.result *= self.number
//
//        case "/":
//            self.result /= self.number
//
//        default:
//            // Operação não implementada
//            print("error:\(self.operation)")
//
//        }
//
//        // Reinicia o valor de número após cada operação
//        self.number = 0
//
//        // armazena a próxima operação
//        self.operation = op
//
//        return self.result
//    }
//
//
//
//}
