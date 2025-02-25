import 'package:flutter/cupertino.dart';
import 'package:main_app/data/smart_widget.dart';
import 'package:main_app/util/terms_and_conditions.dart';
import 'package:provider/provider.dart';

import 'login_state.dart';

class LoginStateWidget extends StatelessWidget {
  SmartWidget _widget;

  LoginStateWidget(this._widget);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginState>(builder: (final BuildContext context,
        final LoginState loginState, final Widget child) {
      return loginState.currentState == LoginStates.TermsNotAccepted
              ? TermsAndConditions(_widget.getDb()) : _widget;
    });
  }
}
