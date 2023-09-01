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
const { Client } = require('@elastic/elasticsearch');
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


  const elasticClient = new Client({
    cloud: {
      id: 'ChatBox:ZXVyb3BlLXdlc3QxLmdjcC5jbG91ZC5lcy5pbyQ5OGUzZjFjZDk5ZDU0MDdhYWIwMDIwMDAzNWRiNmUwOCQzMDY2YmUyMmI4OTE0OTI1ODhiNmE5YWMyZGMwNzkwOA==',
    },
    auth: {
      apiKey : 'Y3VVdVRvb0IwZGh4RUV2M2piRno6RDRjNEdweGhUZWlVWUo1Y2I1ZFh5dw=='
    }
  })

exports.indexUsersToElasticsearch = functions.firestore
      .document('Users/{userId}')
      .onCreate(async (snap, context) => {
        const documentId = context.params.userId;
        const userData = snap.data();

        const indexParams = {
          index: 'search-users',
          body: {
            // Customize the document structure based on your needs
            documentId: documentId,
            userId: userData.userId,
            name: userData.name,
            email: userData.email,
            profilePicture: userData.profilePicture,
            // ...
          },
        };

        try {
          await elasticClient.index(indexParams);
          console.log('Document indexed in Elasticsearch');
        } catch (error) {
          console.error('Error indexing document:', error);
        }
      });

exports.indexMessageToElasticsearch = functions.firestore
    .document('Rooms/{roomId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
        const roomId = context.params.roomId;
        const messageId = context.params.messageId;
        const messageData = snap.data();



        const indexParams = {
            index: 'search-messages',
            body: {
                // Customize the document structure based on your needs
                roomId: roomId,
                messageId: messageId,
                message: messageData.message,
                senderId: messageData.senderId,
                receiverId: messageData.receiverId,
                timestamp: messageData.timestamp,
                type: messageData.type,
                isRead: messageData.isRead,
                // ...
            },
        };

        try {
            await elasticClient.index(indexParams);
            console.log('Document indexed in Elasticsearch');
        } catch (error) {
            console.error('Error indexing document:', error);
        }
    });
