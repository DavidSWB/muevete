import 'package:muevete/features/privacy/domain/privacy_policy.dart';

/// One heading of the privacy policy with its paragraphs. A paragraph that
/// starts with "• " is shown as a list item.
class PrivacyPolicySection {
  const PrivacyPolicySection(this.title, this.paragraphs);

  final String title;
  final List<String> paragraphs;
}

const String privacyPolicyContactEmail = 'davidc.eraso221@umariana.edu.co';

/// The policy text for [languageCode]. The Spanish text is the reference
/// version; the English one is a translation.
List<PrivacyPolicySection> privacyPolicySections(String languageCode) =>
    languageCode == 'en' ? _en : _es;

const List<PrivacyPolicySection> _es = [
  PrivacyPolicySection('1. Responsable del tratamiento', [
    'El responsable del tratamiento de tus datos personales en Muévete es David Camilo Eraso Oñate, con domicilio en San Juan de Pasto (Nariño, Colombia).',
    'Dirección: Calle 18 No. 34-104, San Juan de Pasto. Teléfono: 317 330 0662. Correo de contacto: $privacyPolicyContactEmail.',
    'Esta política se rige por la Ley 1581 de 2012 y el Decreto 1377 de 2013, compilado en el Decreto 1074 de 2015.',
  ]),
  PrivacyPolicySection('2. Datos que tratamos', [
    '• Datos de la cuenta: correo electrónico, nombre y el identificador de la cuenta de Google o Apple si inicias sesión con ellas.',
    '• Datos del perfil: edad, sexo biológico, peso y estatura.',
    '• Datos de salud (datos sensibles): las condiciones médicas que decidas escribir, las respuestas al diagnóstico de movilidad y el nivel calculado para hombro, cadera, rodilla y tobillo.',
    '• Datos de actividad: plan y horario de entrenamiento, preferencias de recordatorios, fechas de los entrenamientos y pausas activas completadas, racha, puntos de movimiento, progreso por articulación y medallas.',
    '• Datos guardados solo en tu teléfono: el progreso del recorrido guiado, tus preferencias de consejos e idioma y los recordatorios programados.',
  ]),
  PrivacyPolicySection('3. Datos sensibles', [
    'Los datos de salud son datos sensibles. Por eso te informamos que no estás obligado a autorizar su tratamiento y que las condiciones médicas son opcionales. Su tratamiento requiere una autorización expresa, separada de la aceptación de esta política.',
    'Actualmente, la aplicación usa el diagnóstico de movilidad para calcular tu nivel y generar tu plan de entrenamiento, por lo que lo pide antes de mostrar el plan.',
    'Si no deseas suministrar estos datos, puedes no crear la cuenta o solicitar en cualquier momento la eliminación de los que ya registraste.',
  ]),
  PrivacyPolicySection('4. Finalidades', [
    '• Crear y administrar tu cuenta e iniciar tu sesión.',
    '• Calcular tu nivel de movilidad y recomendarte variantes de ejercicios y rutinas acordes con ese nivel.',
    '• Programar en tu teléfono los recordatorios de entrenamiento y de pausas activas.',
    '• Registrar tu progreso, tu racha, tus puntos de movimiento y tus medallas.',
    '• Mostrarte consejos breves de salud.',
    '• Atender tus consultas, reclamos y solicitudes sobre tus datos.',
    'Tus datos no se venden ni se usan con fines publicitarios.',
  ]),
  PrivacyPolicySection('5. Proveedores y transferencia internacional', [
    'Para funcionar, la aplicación usa servicios de terceros que tratan datos por cuenta del responsable:',
    '• Google Firebase (Authentication y Cloud Firestore) almacena tu cuenta y los datos de la aplicación. La base de datos está en la región multirregional nam5, en Estados Unidos.',
    '• Google o Apple procesan tu inicio de sesión cuando eliges esas opciones.',
    '• Los videos de los ejercicios se cargan desde YouTube (Google) en su modo de privacidad mejorada; al reproducirlos, YouTube recibe datos técnicos de tu dispositivo, como la dirección IP.',
    'Esto implica una transferencia internacional de datos a Estados Unidos, país incluido por la Superintendencia de Industria y Comercio entre los que cuentan con un nivel adecuado de protección (Circular Externa 005 de 2017). Al aceptar esta política autorizas de forma expresa esa transferencia.',
  ]),
  PrivacyPolicySection('6. Tus derechos', [
    'Como titular de los datos tienes derecho a:',
    '• Conocer, actualizar y rectificar tus datos personales.',
    '• Solicitar prueba de la autorización que otorgaste.',
    '• Ser informado, previa solicitud, sobre el uso que se ha dado a tus datos.',
    '• Presentar quejas ante la Superintendencia de Industria y Comercio.',
    '• Revocar la autorización y solicitar la supresión de tus datos.',
    '• Acceder de forma gratuita a tus datos personales.',
  ]),
  PrivacyPolicySection('7. Cómo ejercer tus derechos', [
    'Escribe a $privacyPolicyContactEmail indicando tu nombre, el correo de tu cuenta en Muévete y tu solicitud.',
    '• Las consultas se responden en un máximo de 10 días hábiles. Si no es posible, te informaremos el motivo y la nueva fecha, que no superará 5 días hábiles adicionales.',
    '• Los reclamos (corrección, actualización, supresión o revocación) se atienden en un máximo de 15 días hábiles, prorrogables hasta 8 días hábiles más con aviso previo. Si el reclamo está incompleto, te pediremos completarlo dentro de los 5 días siguientes.',
    'Antes de acudir a la Superintendencia de Industria y Comercio debes haber presentado tu consulta o reclamo al responsable.',
  ]),
  PrivacyPolicySection('8. Conservación y seguridad', [
    'Tus datos se conservan mientras tu cuenta exista. Puedes eliminar tu cuenta y sus datos en cualquier momento desde Ajustes > Eliminar cuenta, o solicitarlo por correo; en ambos casos se borran de la aplicación, salvo que una obligación legal exija conservarlos.',
    'Los datos viajan cifrados entre tu teléfono y los servidores de Firebase.',
  ]),
  PrivacyPolicySection('9. Cambios y vigencia', [
    'Esta política está vigente desde el $currentPrivacyPolicyVersion. Si cambia, la aplicación te pedirá revisarla y aceptarla de nuevo antes de continuar.',
  ]),
];

const List<PrivacyPolicySection> _en = [
  PrivacyPolicySection('1. Data controller', [
    'The controller of your personal data in Muévete is David Camilo Eraso Oñate, domiciled in San Juan de Pasto (Nariño, Colombia).',
    'Address: Calle 18 No. 34-104, San Juan de Pasto. Phone: +57 317 330 0662. Contact email: $privacyPolicyContactEmail.',
    'This policy is governed by Colombian Law 1581 of 2012 and Decree 1377 of 2013, compiled in Decree 1074 of 2015. The Spanish version is the reference text.',
  ]),
  PrivacyPolicySection('2. Data we process', [
    '• Account data: email address, name and the identifier of your Google or Apple account if you sign in with them.',
    '• Profile data: age, biological sex, weight and height.',
    '• Health data (sensitive data): the medical conditions you choose to write, your answers to the mobility diagnosis and the level calculated for shoulder, hip, knee and ankle.',
    '• Activity data: training plan and schedule, reminder preferences, dates of completed workouts and active breaks, streak, movement points, joint progress and badges.',
    '• Data stored only on your phone: guided tour progress, your tip and language preferences and the scheduled reminders.',
  ]),
  PrivacyPolicySection('3. Sensitive data', [
    'Health data is sensitive data. You are therefore not obliged to authorize its processing, and medical conditions are optional. Its processing requires an express authorization, separate from accepting this policy.',
    'Currently, the app uses the mobility diagnosis to calculate your level and build your training plan, so it asks for it before showing the plan.',
    'If you do not wish to provide this data, you can choose not to create an account or ask at any time for the data you already entered to be deleted.',
  ]),
  PrivacyPolicySection('4. Purposes', [
    '• Create and manage your account and sign you in.',
    '• Calculate your mobility level and recommend exercise variants and routines that match it.',
    '• Schedule training and active-break reminders on your phone.',
    '• Record your progress, streak, movement points and badges.',
    '• Show you short health tips.',
    '• Handle your inquiries, complaints and requests about your data.',
    'Your data is not sold or used for advertising.',
  ]),
  PrivacyPolicySection('5. Providers and international transfer', [
    'To work, the app uses third-party services that process data on behalf of the controller:',
    '• Google Firebase (Authentication and Cloud Firestore) stores your account and app data. The database is in the nam5 multi-region, in the United States.',
    '• Google or Apple process your sign-in when you choose those options.',
    '• Exercise videos load from YouTube (Google) in its privacy-enhanced mode; when you play them, YouTube receives technical data from your device, such as your IP address.',
    'This involves an international transfer of data to the United States, a country the Superintendencia de Industria y Comercio lists as having an adequate level of protection (External Circular 005 of 2017). By accepting this policy you expressly authorize that transfer.',
  ]),
  PrivacyPolicySection('6. Your rights', [
    'As the data subject you have the right to:',
    '• Know, update and correct your personal data.',
    '• Request proof of the authorization you gave.',
    '• Be informed, on request, about how your data has been used.',
    '• File complaints with the Superintendencia de Industria y Comercio.',
    '• Revoke your authorization and request deletion of your data.',
    '• Access your personal data free of charge.',
  ]),
  PrivacyPolicySection('7. How to exercise your rights', [
    'Write to $privacyPolicyContactEmail with your name, the email of your Muévete account and your request.',
    '• Inquiries are answered within 10 business days at most. If that is not possible, we will tell you why and give a new date, no more than 5 additional business days later.',
    '• Complaints (correction, update, deletion or revocation) are handled within 15 business days at most, extendable by up to 8 more business days with prior notice. If a complaint is incomplete, we will ask you to complete it within the next 5 days.',
    'Before going to the Superintendencia de Industria y Comercio you must have filed your inquiry or complaint with the controller.',
  ]),
  PrivacyPolicySection('8. Retention and security', [
    'Your data is kept while your account exists. You can delete your account and its data at any time from Settings > Delete account, or request it by email; either way it is removed from the app unless a legal obligation requires keeping it.',
    'Data travels encrypted between your phone and the Firebase servers.',
  ]),
  PrivacyPolicySection('9. Changes and effective date', [
    'This policy has been in effect since $currentPrivacyPolicyVersion. If it changes, the app will ask you to review and accept it again before continuing.',
  ]),
];
