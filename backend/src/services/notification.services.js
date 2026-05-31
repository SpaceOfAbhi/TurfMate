import admin from "firebase-admin";
import serviceAccount from "../../serviceAccountKey.json" with { type: "json" };
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const sendNotification = async (
  token,
  title,
  body
) => {

  if (!token) return;

  await admin.messaging().send({
    token,
    notification: {
      title,
      body,
    },
  });
};