/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Remove unused imports or use them
// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// Create a transport for sending emails
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL ||
          "your-email@gmail.com", // Set this in Firebase environment
    pass: process.env.PASSWORD ||
          "your-app-password", // Set this in Firebase environment
  },
});

exports.sendVerificationEmail = functions.https.onCall((data, context) => {
  const {email, code} = data;
  console.log(`Sending verification code ${code} to ${email}`);

  // Actually use nodemailer to send the email
  return transporter.sendMail({
    from: "Verdant Bank <noreply@verdantbank.com>",
    to: email,
    subject: "Your Verification Code",
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px; 
           text-align: center;">
        <h2>Verdant Bank Email Verification</h2>
        <p>Your verification code is:</p>
        <h1 style="letter-spacing: 5px; color: #4CAF50;">${code}</h1>
        <p>This code will expire in 10 minutes.</p>
      </div>
    `,
  })
      .then(() => {
        return {success: true};
      })
      .catch((error) => {
        console.error("Email sending failed:", error);
        return {success: false, error: error.message};
      });
});
