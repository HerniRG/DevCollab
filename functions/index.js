/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Si no necesitas 'onRequest' ni 'logger', elimínalos o coméntalos:
// // const {onRequest} = require("firebase-functions/v2/https");
// // const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

// Obtén la clave API de Brevo de las variables de entorno
const BREVO_API_KEY = functions.config().brevo.apikey;

// Cloud Function que se dispara cuando se actualiza un documento en la colección "solicitudes"
exports.sendEmailOnApproval = functions.firestore
    .document("solicitudes/{solicitudId}")
    .onUpdate(async (change, context) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();

      // Verifica si el estado cambió a "Aceptada"
      if (beforeData.estado !== "Aceptada" && afterData.estado === "Aceptada") {
        try {
        // Obtén la información necesaria
          const proyectoID = afterData.proyectoID;
          const usuarioID = afterData.usuarioID;

          // Obtener el documento del proyecto
          const proyectoDoc = await admin.firestore().collection("proyectos").doc(proyectoID).get();
          const proyectoData = proyectoDoc.data();
          const creadorID = proyectoData.creadorID;

          // Obtener el correo del creador consultando la colección "usuarios"
          const creadorDoc = await admin.firestore().collection("usuarios").doc(creadorID).get();
          const creadorEmail = creadorDoc.data()?.correo;

          // Obtener el correo del solicitante
          const solicitanteDoc = await admin.firestore().collection("usuarios").doc(usuarioID).get();
          const solicitanteEmail = solicitanteDoc.data()?.correo;

          // Configurar asunto y cuerpo del correo
          const subject = `Contacto para el proyecto: ${proyectoData.nombre}`;
          const body = `
          Hola,

          La solicitud para participar en el proyecto "${proyectoData.nombre}" ha sido aprobada.

          Aquí tienes los datos de contacto:
          - Creador: ${creadorEmail}
          - Participante: ${solicitanteEmail}

          Por favor, pónganse en contacto.

          Saludos.
        `;

          // Enviar el correo a través de la API de Brevo
          const response = await axios.post(
              "https://api.brevo.com/v3/smtp/email",
              {
                sender: {email: "devcollab.hrgapps@gmail.com", name: "DevCollab"},
                to: [{email: creadorEmail}, {email: solicitanteEmail}],
                subject: subject,
                htmlContent: `<p>${body.replace(/\n/g, "<br>")}</p>`,
              },
              {
                headers: {
                  "api-key": BREVO_API_KEY,
                  "Content-Type": "application/json",
                  "accept": "application/json",
                },
              },
          );
          console.log("Correo enviado correctamente:", response.data);
        } catch (error) {
          console.error("Error enviando correo:", error);
        }
      }
      return null;
    });
