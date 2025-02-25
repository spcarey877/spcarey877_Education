import 'package:flutter/material.dart';

class LoginState extends ChangeNotifier {
  LoginStates currentState = LoginStates.TermsNotAccepted;

  LoginState(bool termsAccepted) {
    if (termsAccepted)
      currentState = LoginStates.TermsAccepted;
  }

  void updateState() {
    if (currentState == LoginStates.TermsNotAccepted) {
      currentState = LoginStates.TermsAccepted;
      this.notifyListeners();
      return;
    }
    this.notifyListeners();
  }

}

enum LoginStates { TermsNotAccepted, TermsAccepted }
