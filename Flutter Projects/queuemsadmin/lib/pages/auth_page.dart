import 'dart:async';
import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:queuemsadmin/common_widgets/masked_text.dart';
import 'package:queuemsadmin/common_widgets/reactive_refresh_indicator.dart';
import 'package:queuemsadmin/localizations.dart';
import 'package:queuemsadmin/logger.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:queuemsadmin/pages/ways_page.dart';
import 'package:queuemsadmin/utils/constants.dart';
import 'package:queuemsadmin/utils/functions.dart';

enum AuthStatus { PHONE_AUTH, SMS_AUTH, PROFILE_AUTH }

class AuthPage extends StatefulWidget {

  final Country country;

  AuthPage({Key key, this.country}): super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  static const String TAG = "AUTH";
  AuthStatus status = AuthStatus.PHONE_AUTH;

  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<MaskedTextFieldState> _maskedPhoneKey =
      GlobalKey<MaskedTextFieldState>();

  // Controllers
  TextEditingController smsCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  // Variables
  String _errorMessage;
  String _verificationId;
  Timer _codeTimer;

  bool _isRefreshing = false;
  bool _codeTimedOut = false;
  bool _codeVerified = false;
  Duration _timeOut = const Duration(minutes: 1);

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _profileRef;
  

  @override
  void initState() {
    super.initState();
    _profileRef = FirebaseDatabase.instance.reference().child('/profile');

    // Change Locale manual
    assignLanguage(); 
  }

  // PhoneVerificationCompleted
  verificationCompleted(FirebaseUser user) async {
    Logger.log(TAG, message: "onVerificationCompleted, user: $user");
    if (await _onCodeVerified(user)) {
      await _finishSignIn(user);
    } else {
      setState(() {
        this.status = AuthStatus.SMS_AUTH;
        Logger.log(TAG, message: "Changed status to $status");
      });
    }
  }

  // PhoneVerificationFailed
  verificationFailed(AuthException authException) {
    _showErrorSnackbar(
        "We couldn't verify your code for now, please try again!");
    Logger.log(TAG,
        message:
            'onVerificationFailed, code: ${authException.code}, message: ${authException.message}');
  }

  // PhoneCodeSent
  codeSent(String verificationId, [int forceResendingToken]) async {
    Logger.log(TAG, message:'Verification code sent to number ${widget.country.phoneCode} ${phoneNumberController.text}');
    _codeTimer = Timer(_timeOut, () {
      setState(() {
        _codeTimedOut = true;
      });
    });
    _updateRefreshing(false);
    setState(() {
      this._verificationId = verificationId;
      this.status = AuthStatus.SMS_AUTH;
      Logger.log(TAG, message: "Changed status to $status");
    });
  }

  // PhoneCodeAutoRetrievalTimeout
  codeAutoRetrievalTimeout(String verificationId) {
    Logger.log(TAG, message: "onCodeTimeout");
    _updateRefreshing(false);
    setState(() {
      this._verificationId = verificationId;
      this._codeTimedOut = true;
    });
  }

  // Styling

  final decorationStyle = TextStyle(color: Colors.grey[50], fontSize: 16.0);
  final hintStyle = TextStyle(color: Colors.white24);

  //

  @override
  void dispose() {
    _codeTimer?.cancel();
    super.dispose();
  }

  // async

  Future<Null> _updateRefreshing(bool isRefreshing) async {
    Logger.log(TAG,
        message: "Setting _isRefreshing ($_isRefreshing) to $isRefreshing");
    if (_isRefreshing) {
      setState(() {
        this._isRefreshing = false;
      });
    }
    setState(() {
      this._isRefreshing = isRefreshing;
    });
  }

  _showErrorSnackbar(String message) {
    _updateRefreshing(false);
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<Null> _submitPhoneNumber() async {
    final error = _phoneInputValidator();
    if (error != null) {
      _updateRefreshing(false);
      setState(() {
        _errorMessage = error;
      });
      return null;
    } else {
      _updateRefreshing(false);
      setState(() {
        _errorMessage = null;
      });
      final result = await _verifyPhoneNumber();
      Logger.log(TAG, message: "Returning $result from _submitPhoneNumber");
      return result;
    }
  }

  String get phoneNumber {
    String unmaskedText = _maskedPhoneKey.currentState.unmaskedText.trim();
    String formatted = '+${widget.country.phoneCode}$unmaskedText';
    return formatted;
  }

  Future<Null> _verifyPhoneNumber() async {
    Logger.log(TAG, message: "Got phone number as: ${this.phoneNumber}");
    await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        timeout: _timeOut,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed);
    Logger.log(TAG, message: "Returning null from _verifyPhoneNumber");
    return null;
  }

  Future<Null> _submitSmsCode() async {
    final error = _smsInputValidator();
    if (error != null) {
      _updateRefreshing(false);
      _showErrorSnackbar(error);
      return null;
    } else {
      if (this._codeVerified) {
        await _finishSignIn(await _auth.currentUser());
      } else {
        Logger.log(TAG, message: "_signInWithPhoneNumber called");
        await _signInWithPhoneNumber();
      }
      return null;
    }
  }

  Future<void> _signInWithPhoneNumber() async {
    final errorMessage = AppLocalizations.of(context).wrongVerifyCode; 
    AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: smsCodeController.text,
    );
    await _auth.signInWithCredential(credential).then((user) async {
      await _onCodeVerified(user).then((codeVerified) async {
        this._codeVerified = codeVerified;
        Logger.log(
          TAG,
          message: "Returning ${this._codeVerified} from _onCodeVerified",
        );
        if (this._codeVerified) {
          await _finishSignIn(user);
        } else {
          _showErrorSnackbar(errorMessage);
        }
      });
    }, onError: (error) {
      print("Failed to verify SMS code: $error");
      _showErrorSnackbar(errorMessage);
    });
    
  }

  Future<bool> _onCodeVerified(FirebaseUser user) async {
    final isUserValid = (user != null &&
        (user.phoneNumber != null && user.phoneNumber.isNotEmpty));
    if (isUserValid) {
      setState(() {
        // Here we change the status once more to guarantee that the SMS's
        // text input isn't available while you do any other request
        // with the gathered data
        this.status = AuthStatus.PROFILE_AUTH;
        Logger.log(TAG, message: "Changed status to $status");
      });
    } else {
      _showErrorSnackbar(AppLocalizations.of(context).wrongVerifyCode);
    }
    return isUserValid;
  }

  

  _finishSignIn(FirebaseUser user) async {
    await _onCodeVerified(user).then((result) {

      // update user profile
      DateTime _now = new DateTime.now();
      _profileRef.child(user.phoneNumber).update({
        'createdDate': _now.toLocal().millisecondsSinceEpoch,
        'uid': user.uid,
        'platform': PlatformQueue.ADMIN,
        'phone': user.phoneNumber,
        'authResult': result,
      });

      if (result) {
        // Here, instead of navigating to another screen, you should do whatever you want
        // as the user is already verified with Firebase from both
        // Google and phone number methods
        // Example: authenticate with your own API, use the data gathered
        // to post your profile/user, etc.

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WaysPage()
          ),
        );
      } else {
        setState(() {
          this.status = AuthStatus.SMS_AUTH;
        });
        _showErrorSnackbar(
            AppLocalizations.of(context).cannotCreateProfile);
      }
    });
  }


  Widget _buildConfirmInputButton() {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(Icons.check),
      color: theme.accentColor,
      disabledColor: theme.buttonColor,
      onPressed: (this.status == AuthStatus.PROFILE_AUTH)
          ? null
          : () => _updateRefreshing(true),
    );
  }


  Widget _buildPhoneNumberInput() {
    return MaskedTextField(
      key: _maskedPhoneKey,
      mask: "xx-xxxx-xxx",
      keyboardType: TextInputType.number,
      maskedTextFieldController: phoneNumberController,
      maxLength: 15,
      onSubmitted: (text) => _updateRefreshing(true),
      style: Theme
          .of(context)
          .textTheme
          .subhead
          .copyWith(fontSize: 18.0, color: Colors.white),
      inputDecoration: InputDecoration(
        isDense: false,
        enabled: this.status == AuthStatus.PHONE_AUTH,
        counterText: "",
        labelText: AppLocalizations.of(context).phone,
        labelStyle: decorationStyle,
        hintText: "99-999-9999",
        hintStyle: hintStyle,
        errorText: _errorMessage,
      ),
    );
  }
  
  Widget _buildPhoneAuthBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Text(
            AppLocalizations.of(context).loginMessage,
            style: decorationStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(flex: 2, child: Text('(+${widget.country.phoneCode}) ', style: decorationStyle)),
              Flexible(flex: 7, child: _buildPhoneNumberInput()),
              Flexible(flex: 1, child: _buildConfirmInputButton())
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsCodeInput() {
    final enabled = this.status == AuthStatus.SMS_AUTH;
    return TextField(
      keyboardType: TextInputType.number,
      enabled: enabled,
      textAlign: TextAlign.center,
      controller: smsCodeController,
      maxLength: 6,
      onSubmitted: (text) => _updateRefreshing(true),
      style: Theme.of(context).textTheme.subhead.copyWith(
            fontSize: 32.0,
            color: enabled ? Colors.white : Theme.of(context).buttonColor,
          ),
      decoration: InputDecoration(
        counterText: "",
        enabled: enabled,
        hintText: "--- ---",
        hintStyle: hintStyle.copyWith(fontSize: 42.0),
      ),
    );
  }

  Widget _buildResendSmsWidget() {
    return InkWell(
      onTap: () async {
        if (_codeTimedOut) {
          await _verifyPhoneNumber();
        } else {
          _showErrorSnackbar(AppLocalizations.of(context).cannotRetry);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: AppLocalizations.of(context).pinNotArrive,
            style: decorationStyle,
            children: <TextSpan>[
              TextSpan(
                text: " "+ AppLocalizations.of(context).here,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmsAuthBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Text(
            AppLocalizations.of(context).verificationCode,
            style: decorationStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 64.0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(flex: 5, child: _buildSmsCodeInput()),
              Flexible(flex: 2, child: _buildConfirmInputButton())
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _buildResendSmsWidget(),
        )
      ],
    );
  }

  String _phoneInputValidator() {
    if (phoneNumberController.text.isEmpty) {
      return AppLocalizations.of(context).cannotPhoneEmpty;
    } else if (phoneNumberController.text.length < 8) {
      return AppLocalizations.of(context).invalidPhone;
    }
    return null;
  }

  String _smsInputValidator() {
    if (smsCodeController.text.isEmpty) {
      return AppLocalizations.of(context).cannotVerificationCodeEmpty;
    } else if (smsCodeController.text.length < 6) {
      return AppLocalizations.of(context).invalidVerificationCode;
    }
    return null;
  }

  Widget _buildBody() {
    Widget body;
    switch (this.status) {
      case AuthStatus.PHONE_AUTH:
        body = _buildPhoneAuthBody();
        break;
      case AuthStatus.SMS_AUTH:
      case AuthStatus.PROFILE_AUTH:
        body = _buildSmsAuthBody();
        break;
    }
    return body;
  }

  Future<Null> _onRefresh() async {
    switch (this.status) {
      case AuthStatus.PHONE_AUTH:
        return await _submitPhoneNumber();
        break;
      case AuthStatus.SMS_AUTH:
        return await _submitSmsCode();
        break;
      case AuthStatus.PROFILE_AUTH:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: ReactiveRefreshIndicator(
          onRefresh: _onRefresh,
          isRefreshing: _isRefreshing,
          child: Container(child: _buildBody()),
        ),
      ),
    );
  }
}