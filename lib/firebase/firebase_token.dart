// import 'package:googleapis_auth/auth_io.dart';

// Future<String> getAccessToken() async {
//   final credentials = ServiceAccountCredentials.fromJson({
//     "type": "service_account",
//     "project_id": "fanari-84d40",
//     "private_key_id": "97d6cd6093b8f3b8c9c54091fd60267f7a626676",
//     "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDR34pihIWOclWm\nFAK8O13ULo2c4L/5FvIcybchviJTwTvQjtu69A9K8ChltKTT28RCxKMlypFPE3RU\nKrBdBfhj0e9oh5iuf1NCgq4R2POY2RKDxQvZUnPwKQsQOYONxiTdmLm6t5SI8gum\ntOuG6evvfQFZbjKfRRyBPkKdIuL0iX3wUt5Umc9yeGbFVJ3mNuwjWaGusyaKyv1O\nBH5YxlnhdpC7XNNkdOgjlBX7JtcrIYlG+KUYPdC/WoiOtU4EIoDQOa58z/cO5zLD\niQWc/i5A4McWns4HhV5ImzkC9ght0dxaOWNukYHrI+kOo+aaLDfaj5eeRKj+Fr/f\n93C+363vAgMBAAECggEABGzVXaNpWioLUppMaSH1UK0p8OYE64sc0BeUDsLpYAu3\nJ6bDd6CAFraT8M+2GVN3wr1OVVR9QNtqUgCpFvpdFORkdbdE3wpckTlGffuC6LT3\nAM6YToeVszl3psAXsoG8MuyZSe28qjCJp1pcNvbasdeDE5rRDW5RyLXX22P/a2Qq\n8fnG2yzzZNts6LAa/Q67lVsKN27UHzr2/GuM6EZbMoBwN5Qf8eq92Cfcrd3i4Pj/\nB7gt2m1jSGJ6eQXkCabMqLCS8ZwgqqUIee/GWqMO1GVOtJH9OJKIxF5rIeV6eg7S\nS7EkCpdkn/tmJtBtavvsu4gaK5KbSM25N3U7X9JDKQKBgQD+AXikH50aODmTlmyd\nCyV6dXvMfaZ1jVRo0Hve0E4TbctZ2LteDAFExPNPZ83eaRlHpVprHQqsg0a4jPIQ\nkGiyXquGt7IbLohXx1EZNNP3siysHdfPZP3NFHgYFrL3+FatAml/SicAnwyVR5In\nIriUyI2zLAnnLrsifirOT4+wZwKBgQDThV3q3L744igE93LiuHnX7Uut4/ETyPzC\n+zoDBRIjxcavZP2+s4D9hKk0bIXx1jfOY8tylvWwRcFWAx2a+F8/s65lnPan5CGi\nlC299B13l7mdFCEKFCu9AUeQJQ4KleiMCGiYg0BBnxVrRCruanNpXpzTbnkX0ZRc\n2L8cU6cBOQKBgDkt2ZuQpkv9tjBcH20m0jQD+G9rJaq2uvaxYAEjgT/samd6W4tr\nRmnVsDQC2RwlKpSvS3BrZDi7gJMQ33kNGRR2LUSxW3209upTqxTyiHjs+hNw0GEW\nie+9mN9LVNRvagueTGNkLO194FZGe0cmEMklcIiR9FS/d07neflhfaYnAoGAKGe2\njBHE7TgOWvyF1qdUpxmuNjZvq87d8cUZzM/gKjMyg/ivvAkAH+2CgQAmCg9Ys7U+\nfNI3doesqeiIdDzzvPBu5Pw55dJfVnYl0r5aDqlODKJ2uT0nKcCf0foyF3WRaYaF\nrHSOBrsD1Wy9IrP0/fDT1lOpEBK5246P2zJjmYkCgYANQWdofAztsjwCi8nA18Zu\n04wKQ4Z7WBm3plcgd2jvaGTxhQ71fXfXDByVdWVl3ENm0dP7cEXs8jsHqyvOKuSv\nC84UVKeMdilnuyvutgqiXuISel+Mph4xfhU/ZbAVGpUqFZD0DPh6U5ZHrRLry9dL\nvbbqRQT9iVe4xxrBGXZICA==\n-----END PRIVATE KEY-----\n",
//     "client_email": "firebase-adminsdk-5b38r@fanari-84d40.iam.gserviceaccount.com",
//     "client_id": "114373079244793837289",
//     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//     "token_uri": "https://oauth2.googleapis.com/token",
//     "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//     "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-5b38r%40fanari-84d40.iam.gserviceaccount.com",
//     "universe_domain": "googleapis.com"
//   });

//   final client = await clientViaServiceAccount(
//     credentials,
//     ["https://www.googleapis.com/auth/firebase.messaging"],
//   );

//   final accessToken = client.credentials.accessToken.data;

//   return accessToken;
// }