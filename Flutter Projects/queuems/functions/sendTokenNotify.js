const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.handler = ((change, context) => {

    var key = '';
    const document = change.after.exists ? change.after.data() : null;
    if (document !=null && document.isOnQueue) {
        console.log('data is '+JSON.stringify(document));
        key = document.key;
        var tokenLetter = document.tokenLetter;
        var tokenNumber = document.tokenNumber;
        var depName = document.depName;
        var depKey = document.depKey;
        var tokenStr = tokenLetter+'-'+tokenNumber;
        console.log(key+', tokenStr='+tokenStr+', depName is '+depName+', depKey is '+ depKey);

        const profileRef = admin.database().ref('profile');
        var now = new Date();
        const firestore = admin.firestore();
        var topic = formatDate(new Date)+'-'+depKey;
        console.log('topic is '+ topic);
        // FCM
        var title = 'Current Token Number';
        var msg = tokenStr;
        var message = {
            android: {
                ttl: 3600 * 1000, // 1 hour in milliseconds
                priority: 'high',
                notification: {
                    title: title,
                    body: msg,
                    icon: 'ic_launcher',
                    color: '#f45342',
                    sound: 'alert'
                }
            },
            topic: topic
        };        
        return admin.messaging().send(message).then((response) => {
            // Response is a message ID string.
            console.log('Successfully sent message:', response);
        }).catch((error) => {
            console.log('Error sending message:', error);
        });
    }
    return key;
});

function formatDate(date) {
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;

    return [year, month, day].join('');
}