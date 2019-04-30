'use strict';
const admin = require('firebase-admin');
const functions = require('firebase-functions');
admin.initializeApp(functions.config().firebase);
admin.firestore().settings( { timestampsInSnapshots: true })

const sendTokenNotifyModule = require('./sendTokenNotify');

exports.sendTokenNotify = functions.firestore.document('/tokenIssued/{documentId}').onWrite(sendTokenNotifyModule.handler);
