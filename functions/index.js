const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationOnDueDate = functions.firestore
    .document("cuotas/{cuotaId}")
    .onUpdate((change, context) => {
        const newValue = change.after.data();
        const previousValue = change.before.data();

        // Check if the due date is near
        const dueDate = newValue.dueDate.toDate();
        const today = new Date();
        const timeDiff = dueDate.getTime() - today.getTime();
        const dayDiff = timeDiff / (1000 * 3600 * 24);

        if (dayDiff <= 3 && newValue.estado === "Pendiente") {
            const payload = {
                notification: {
                    title: "Cuota Próxima a Vencerse",
                    body: `Tu cuota con ID ${context.params.cuotaId} está próxima a vencerse.`,
                },
            };

            return admin.messaging().sendToTopic("cuotasPendientes", payload)
                .then((response) => {
                    console.log("Successfully sent message:", response);
                    return null;
                })
                .catch((error) => {
                    console.log("Error sending message:", error);
                    throw new Error("Error sending message");
                });
        } else {
            return null;
        }
    });
