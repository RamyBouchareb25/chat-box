/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


// import * as functions from "firebase-functions";
// import * as admin from "firebase-admin";
admin.initializeApp();
const fcm = admin.messaging();


exports.checkHealth = functions.https.onCall(async (data, context) => {
  return "The function is online";
});

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const title = data.title;
  const body = data.body;
  const token = data.token;

  try {
    const payload = {
      token: token,
      notification: {
        title: title,
        body: body,
        image: "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/FCMImages%2FApp%20icon.png?alt=media&token=13eeecc5-afba-4cf7-a4dc-9814c32289a4",
      },
      data: {
        image:"https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/FCMImages%2FApp%20icon.png?alt=media&token=13eeecc5-afba-4cf7-a4dc-9814c32289a4",
        body: body,
      },
    };

    return fcm.send(payload).then((response) => {
      return {success: true, response: "Succefully sent message: " + response};
    }).catch((error) => {
      return {error: error};
    });
  } catch (error) {
    throw new functions.https.HttpsError("invalid-argument", "error:" +error);
  }
});

exports.notifySubscribers = functions.https.onCall(async (data, _) => {

    try {
        const multiCastMessage = {
            notification: {
                title: data.messageTitle,
                body: data.messageBody
            },
            tokens: data.targetDevices
        }

        await fcm.sendEachForMulticast(multiCastMessage);

        return true;

    } catch (ex) {
        return ex;
    }
});