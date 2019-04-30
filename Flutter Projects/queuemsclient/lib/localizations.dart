import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:queuemsclient/l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) async {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    print('localeName is '+localeName);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

 String get title {
    return Intl.message('QueueMS',
        name: 'title', desc: 'The application title');
 }

  String get hello {
    return Intl.message('Hello', name: 'hello');
  }

  String get peopleWait {
    return Intl.message('People in waiting', name: 'peopleWait');
  }

  String get tokenNumber {
    return Intl.message('Token Number', name: 'tokenNumber');
  }

  String get proceedTo {
    return Intl.message('Proceed to', name: 'proceedTo');
  }

  String get counter {
    return Intl.message('Counter', name: 'counter');
  }

  String get createdDate {
    return Intl.message('Created', name: 'createdDate');
  }

  String get statusQueue {
    return Intl.message('Status', name: 'statusQueue');
  }

  String get currentToken {
    return Intl.message('Current Token', name: 'currentToken');
  }

  String get myQueue {
    return Intl.message('My Queue', name: 'myQueue');
  }

  String get more {
    return Intl.message('More', name: 'more');
  }

  String get myQueueToday {
    return Intl.message('My Queue Today', name: 'myQueueToday');
  }

  String get openWebSite {
    return Intl.message('Open Web Site', name: 'openWebSite');
  }

  String get subscribe {
    return Intl.message('Subscribe', name: 'subscribe');
  }

  String get unsubscribe {
    return Intl.message('Unsubscribe', name: 'unsubscribe');
  }

  String get notification {
    return Intl.message('Notification', name: 'notification');
  }

  String get name {
    return Intl.message('Name', name: 'name');
  }

  String get runningOn {
    return Intl.message('Running On', name: 'runningOn');
  }

  String get versionName {
    return Intl.message('Version Name', name: 'versionName');
  }

  String get versionCode {
    return Intl.message('Version Code', name: 'versionCode');
  }

  String get appId {
    return Intl.message('App ID', name: 'appId');
  }

  String get localTime {
    return Intl.message('Local Time', name: 'localTime');
  }

  String get timezone {
    return Intl.message('Timezone', name: 'timezone');
  }

  String get myPhoneNumber {
    return Intl.message('My Phone Number', name: 'myPhoneNumber');
  }

  String get signout {
    return Intl.message('Signout', name: 'signout');
  }

  String get phone {
    return Intl.message('Phone', name: 'phone');
  }

  String get loginMessage {
    return Intl.message('We\'ll send an SMS message to verify your identity, please enter your number right below!', name: 'loginMessage');
  }

  String get verificationCode {
    return Intl.message('Verification Code', name: 'verificationCode');
  }

  String get pinNotArrive {
    return Intl.message('If your code does not arrive in 1 minute, touch', name: 'pinNotArrive');
  }

  String get here {
    return Intl.message('here', name: 'here');
  }

  String get wantExit {
    return Intl.message('Do you want exit', name: 'wantExit');
  }

  String get ok {
    return Intl.message('OK', name: 'ok');
  }

  String get cancel {
    return Intl.message('cancel', name: 'cancel');
  }

  String get ago {
    return Intl.message('ago', name: 'ago');
  }

  String get wrongVerifyCode {
    return Intl.message('We couldn\'t verify your code, please try again!', name: 'wrongVerifyCode');
  }

  String get cannotCreateProfile {
    return Intl.message('We couldn\'t create your profile for now, please try again later', name: 'cannotCreateProfile');
  }
  
  String get cannotRetry {
    return Intl.message('You can\'t retry yet!', name: 'cannotRetry');
  }
  
  String get cannotPhoneEmpty {
    return Intl.message('Your phone number can\'t be empty!', name: 'cannotPhoneEmpty');
  }
  
  String get invalidPhone {
    return Intl.message('This phone number is invalid!', name: 'invalidPhone');
  }

  String get cannotVerificationCodeEmpty {
    return Intl.message('Your verification code can\'t be empty!', name: 'cannotVerificationCodeEmpty');
  }

  String get invalidVerificationCode {
    return Intl.message('This verification code is invalid!', name: 'invalidVerificationCode');
  }

  String get selectLanguage {
    return Intl.message('Select Language', name: 'selectLanguage');
  }

  String get openDisplayUnit {
    return Intl.message('Open Display Unit', name: 'openDisplayUnit');
  }

  String get showQueueHistory {
    return Intl.message('Show Queue History', name: 'showQueueHistory');
  }

  String get issueToken {
    return Intl.message('Issue Token', name: 'issueToken');
  }
  
  String get home {
    return Intl.message('Home', name: 'home');
  }

  String get waitedForComplete {
    return Intl.message('Waited for Complete', name: 'waitedForComplete');
  }

  String get cannotIssueTokenHoliday {
    return Intl.message('You cannot issue the token during holiday. Today is ', name: 'cannotIssueTokenHoliday');
  }

  String get mustIssueTokenOfficeHours {
    return Intl.message('You must issue the token during office hours\nOffice Hours:-', name: 'mustIssueTokenOfficeHours');
  }

  String get notMeetTimeInterval {
    return Intl.message('Does not meet the time interval for create next token.', name: 'notMeetTimeInterval');
  }

  String get tokenList {
    return Intl.message('Token List', name: 'tokenList');
  }

  String get nextToken {
    return Intl.message('Next Token', name: 'nextToken');
  }

  String get selectDepartment {
    return Intl.message('Select a Department', name: 'selectDepartment');
  }

  String get selectCounter {
    return Intl.message('Select a Counter', name: 'selectCounter');
  }

  String get recall {
    return Intl.message('Recall', name: 'recall');
  }

  String get currentStore {
    return Intl.message('CURRENT STORE', name: 'currentStore');
  }

  String get storeList {
    return Intl.message('Store List', name: 'storeList');
  }

  String get doYouWantRecall {
    return Intl.message('Do you want recall?', name: 'doYouWantRecall');
  }

  String get deparment {
    return Intl.message('Deparment', name: 'deparment');
  }

  String get insightCompare {
    return Intl.message('Insight Compare', name: 'insightCompare');
  }

  String get insightLast7days {
    return Intl.message('Insight Last 7 Days', name: 'insightLast7days');
  }

  String get insightToday {
    return Intl.message('Insight Today', name: 'insightToday');
  }

  String get officeHours {
    return Intl.message('Office Hours', name: 'officeHours');
  }

  String get publicHolidays {
    return Intl.message('Public Holidays', name: 'publicHolidays');
  }

  String get storeForm {
    return Intl.message('Store Form', name: 'storeForm');
  }
  
  String get reportCompare {
    return Intl.message('Report Compare', name: 'reportCompare');
  }
  
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday');
  }

  String get today {
    return Intl.message('Today', name: 'today');
  }
  
  String get totalTokenCount {
    return Intl.message('Total Token Count', name: 'totalTokenCount');
  }
  
  String get report7daysAgo {
    return Intl.message('Report 7 Days Ago', name: 'report7daysAgo');
  }
  
  String get reportPercentageToday {
    return Intl.message('Report Percentage Today', name: 'reportPercentageToday');
  }

  String get counterList {
    return Intl.message('Counter List', name: 'counterList');
  }
  
  String get createCounter {
    return Intl.message('Create Counter', name: 'createCounter');
  }

  String get departmentList {
    return Intl.message('Department List', name: 'departmentList');
  }
  
  String get departmentForm {
    return Intl.message('Department Form', name: 'departmentForm');
  }

  String get createDepartment {
    return Intl.message('Create Department', name: 'createDepartment');
  }

  String get letter {
    return Intl.message('LETTER', name: 'letter');
  }

  String get start {
    return Intl.message('START', name: 'start');
  }

  String get timeIntervalToIssueToken {
    return Intl.message('Time Interval to Issue Token', name: 'timeIntervalToIssueToken');
  }

  String get timeIntervalToIssueTokenText {
    return Intl.message('Time Interval is for prevent the user repeat issue the token. This is a setting in minitue unit.', name: 'timeIntervalToIssueTokenText');
  }  
  
  String get timeInterval {
    return Intl.message('Time Interval', name: 'timeInterval');
  }

  String get timeIntervalHint {
    return Intl.message('Example: 2 minutes', name: 'timeIntervalHint');
  }

  String get save {
    return Intl.message('SAVE', name: 'save');
  }
  
  String get holidayList {
    return Intl.message('Holiday List', name: 'holidayList');
  }  
  
  String get holidayDate {
    return Intl.message('Holiday Date', name: 'holidayDate');
  }  
  
  String get whatIsHolidayName {
    return Intl.message('What is Holiday Name?', name: 'whatIsHolidayName');
  }
  
  String get pleaseEnterSomeText {
    return Intl.message('Please Enter Some Text?', name: 'pleaseEnterSomeText');
  }

  String get createHoliday {
    return Intl.message('Create Holiday', name: 'createHoliday');
  }
  
  String get holidayForm {
    return Intl.message('Holiday Form', name: 'holidayForm');
  }
  
  String get enableHolidayText {
    return Intl.message('To enable Holiday, the switch MUST be ON.', name: 'enableHolidayText');
  }

  String get officeHoursList {
    return Intl.message('Office Hours List', name: 'officeHoursList');
  }
  
  String get createOfficeHours {
    return Intl.message('Create Office Hours', name: 'createOfficeHours');
  }
  
  String get enableThisStore {
    return Intl.message('Enable This Store', name: 'enableThisStore');
  }

  String get edit {
    return Intl.message('Edit', name: 'edit');
  }

  String get submit {
    return Intl.message('Submit', name: 'submit');
  }

  String get counterForm {
    return Intl.message('Counter Form', name: 'counterForm');
  }

  String get wantResetTokenNumber {
    return Intl.message('Do you want reset the token number to start number?', name: 'wantResetTokenNumber');
  }
  
  String get resetTokenNumber {
    return Intl.message('Reset Token Number', name: 'resetTokenNumber');
  }
  
  String get toStartNumber {
    return Intl.message('to Start Number', name: 'toStartNumber');
  }
  
  String get officeHoursForm {
    return Intl.message('Office Hours Form', name: 'officeHoursForm');
  }
  
  String get enableOfficeHours {
    return Intl.message('To enable issue the token on client APP, the switch MUST be ON.', name: 'enableOfficeHours');
  }

  String get monday {
    return Intl.message('Monday', name: 'monday');
  }

  String get tuesday {
    return Intl.message('Tuesday', name: 'tuesday');
  }

  String get wednesday {
    return Intl.message('Wednesday', name: 'wednesday');
  }

  String get thursday {
    return Intl.message('Thursday', name: 'thursday');
  }

  String get friday {
    return Intl.message('Friday', name: 'friday');
  }

  String get saturday {
    return Intl.message('Saturday', name: 'saturday');
  }

  String get sunday {
    return Intl.message('Sunday', name: 'sunday');
  }

  String get admin {
    return Intl.message('Admin', name: 'admin');
  }
  
  String get captured {
    return Intl.message('Captured', name: 'captured');
  }

  String get meter {
    return Intl.message('meter', name: 'meter');
  }

  String get kilometer {
    return Intl.message('kilometer', name: 'kilometer');
  }

  String get away {
    return Intl.message('away', name: 'away');
  }
  
  String get distance {
    return Intl.message('Distance', name: 'distance');
  }
  
  String get userProfile {
    return Intl.message('User Profile', name: 'userProfile');
  }
  
  String get online {
    return Intl.message('Online', name: 'online');
  }

  String get offline {
    return Intl.message('Offline', name: 'offline');
  }
  
  String get noMoreNextToken {
    return Intl.message('No More Next Token', name: 'noMoreNextToken');
  }
  
  String get issueTokenAdminText {
    return Intl.message('The user with this phone number should login with the client APP to check the real time latest token number.', name: 'issueTokenAdminText');
  }

  String get remove {
    return Intl.message('Remove', name: 'remove');
  }
  
  String get wantRemove {
    return Intl.message('Do you want remove?', name: 'wantRemove');
  }
  
  String get store {
    return Intl.message('Store', name: 'store');
  }

  String get availableStore {
    return Intl.message('Available Store', name: 'availableStore');
  }

  String get address {
    return Intl.message('Address', name: 'address');
  }

  String get email {
    return Intl.message('Email', name: 'email');
  }

  String get coordinates {
    return Intl.message('Coordinates', name: 'coordinates');
  }
  
  String get showWaitingQueueHistory {
    return Intl.message('Show Waiting Queue History', name: 'showWaitingQueueHistory');
  }

  
  String get wantConfirm {
    return Intl.message('Confirm?', name: 'wantConfirm');
  }
  
  String get storeSetting {
    return Intl.message('Store Setting', name: 'storeSetting');
  }

  String get insight {
    return Intl.message('Insight', name: 'insight');
  }
  
  String get otherSetting {
    return Intl.message('Other Setting', name: 'otherSetting');
  }

  String get options {
    return Intl.message('Options', name: 'options');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh', 'ms'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}