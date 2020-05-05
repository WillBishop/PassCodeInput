//
//  PassCodeInputTextField.swift.swift
//  PassCodeInputDemo
//
//  Created by Dev Mukherjee on 4/5/20.
//  Copyright © 2020 Anomaly Software. All rights reserved.
//

import Foundation
import SwiftUI

protocol CharacterFieldBackspaceDelegate {
    func charFieldWillDeleteBackward(_ textField: CharacterField)
}

class CharacterField: UITextField {
    public var willDeleteBackwardDelegate: CharacterFieldBackspaceDelegate?

    override func deleteBackward() {
        willDeleteBackwardDelegate?.charFieldWillDeleteBackward(self)
        super.deleteBackward()
    }

}

struct PassCodeInputCell : UIViewRepresentable {
        
    class Coordinator : NSObject, UITextFieldDelegate, CharacterFieldBackspaceDelegate{
        
        @Binding var selectedCellIndex: Int
        
        init(_ selectedCellIndex: Binding<Int>) {
            // The underscore thing is important?
            // writing self.selectedCellIndex = selectedCellIndex
            // does not work
            _selectedCellIndex = selectedCellIndex
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            let currentText = textField.text!
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // Increment the index if the change was on char
            if updatedText.count <= 1 {
                self.selectedCellIndex += 1
            }
            
            // Stop input if there's more than one character
            return updatedText.count <= 1
            
        }

        func charFieldWillDeleteBackward(_ textField: CharacterField) {
            if(textField.text == "") {
                self.selectedCellIndex -= 1
            }
        }

    }
    
    typealias UIViewType = CharacterField

    var index: Int
    @Binding var selectedCellIndex: Int
    
    func makeUIView(context: UIViewRepresentableContext<PassCodeInputCell>) -> CharacterField {

        let charField = CharacterField()
        charField.textAlignment = .center
        
        charField.delegate = context.coordinator
        charField.willDeleteBackwardDelegate = context.coordinator

        return charField
    }
    
    func updateUIView(_ uiView: CharacterField,
                      context: UIViewRepresentableContext<PassCodeInputCell>) {
        if index == selectedCellIndex {
            uiView.becomeFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self.$selectedCellIndex)
    }

}
