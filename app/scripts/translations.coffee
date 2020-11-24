"use strict";

angular.module('dcida20App.translations', [])

.constant('TRANSLATIONS', 
  'DECISION-AID-LOAD-ERROR': 
    en: "There was an error loading the decision aid with the name {{slug}}. Please contact the survey administrator."
    fr: "Une erreur s'est produite lors du chargement de cet outil d'aide à la décision avec le nom {{slug}}. S'il vous plaît contacter l'administrateur de l'enquête"
  'NEXT-BUTTON':
    en: "Next"
    fr: "Suivant"
  'BEGIN-BUTTON':
    en: "Begin"
    fr: "Commencer"
  'BACK-BUTTON':
    en: "Back"
    fr: "Retour"
  'OOPS':
    en: "Oops"
    fr: "Oups"
  'RESPONSE-REQUIRED-DETAILS':
    en: 'Please give a response'
    fr: 'Veuillez fournir une réponse'
  'DISMISS-BUTTON':
    en: 'Dismiss'
    fr: 'Omettre'
  'BTN-CLOSE':
    en: 'Close'
    fr: 'Fermer'
  'RESET-QUESTION-BUTTON':
    en: 'Reset this question'
    fr: 'Réinitialiser cette question'
  'DCE-PREFERENCE-QUESTION':
    en: 'Which do you prefer?'
    fr: 'Lequel préférez-vous?'
  'SECTION-X-OF-N':
    en: 'Section {{x}} of {{n}}: {{title}}'
    fr: 'Section {{x}} de {{n}}: {{title}}'
  'SECTION-X':
    en: 'Section {{x}}'
    fr: 'Section {{x}}'
  'SKIP-QUESTION':
    en: 'Warning'
    fr: 'Attention'
  'SKIP-QUESTION-DETAILS':
    en: 'Are you sure you want to skip this question?'
    fr: 'Êtes-vous sûr(e) de vouloir ignorer cette question?'
  'MUST-SELECT-DCE-OPTION':
    en: 'You must complete the question to continue!'
    fr: 'Vous devez compléter la question pour continuer!'
  'MUST-SELECT-ALL-PROPERTIES':
    en: 'You must select an option for each issue'
    fr: 'TODO'
  'BTN-CONFIRM':
    en: "Confirm"
    fr:  'Confirmer'
  'BTN-CANCEL':
    en: 'Cancel'
    fr: 'Annuler'
  'DECISION-AID-STATIC-PAGE-ERROR':
    en: "No static page found with slug {{slug}}"
    fr: "No static page found with slug {{slug}}"
  'NUMBER-RESPONSE-TOO-LARGE':
    en: "The number you entered is too large. It must be less than or equal to {{max_number}}."
    fr: "Le nombre que vous avez entré est trop grand. Il doit être inférieur ou égal à {{max_number}}."
  'NUMBER-RESPONSE-TOO-SMALL':
    en: "The number you entered is too small. It must be greater than or equal to {{min_number}}."
    fr: "Le nombre que vous avez entré est trop petit. Il doit être supérieur ou égal à {{min_number}}."
  'NUMBER-RESPONSE-DIGITS-NOT-EQUAL':
    en: "The number of digits must be equal to {{max_chars}} digits."
    fr: "Le nombre de chiffres doit être égal à {{max_chars}} chifres."
  'NUMBER-RESPONSE-DIGITS-TOO-MANY':
    en: "The number of digits must be less than or equal to {{max_chars}} digits."
    fr: "Le nombre de chiffres doit être inférieur ou égal à {{max_chars}} chiffres."
  'NUMBER-RESPONSE-DIGITS-TOO-FEW':
    en: "The number of digits must be greater than or equal to {{min_chars}} digits."
    fr: "Le nombre de chiffres doit être supérieur ou égal à {{min_chars}} chiffres."
  'CLEAR-SESSION-HEADER':
    en: 'Welcome to DCIDA!'
    fr: 'Bienvenue à DCIDA!'
  'CLEAR-SESSION-1':
    en: 'Please enter a PID number which enable your responses to be saved as you go. We recommend you do it now in case you lose internet connection, so you don’t have to start it all over.'
    fr: "Veuillez saisir un numéro PID qui enregistrera vos réponses au fur et à mesure. Nous vous recommandons de le faire maintenant, donc si vous perdez votre connexion Internet, vous n'avez pas à tout recommencer."
  'CLEAR-SESSION-2':
    en: "Your PID can be any number you will remember – if you can’t think of a number, one idea is to use the last 4 digits of your phone number, backwards. For example, if your phone number is 123 456 7891 your PID would be 1987."
    fr: "Votre PID peut être n'importe quel numéro dont vous vous souvenez - si vous ne pouvez pas penser à un numéro, une idée est d'utiliser les 4 derniers chiffres de votre numéro de téléphone, à l'envers. Par exemple, si votre numéro de téléphone est 123 456 7891, votre PID serait 1987."
  'CLEAR-SESSION-3':
    en: "Please do not choose a number that starts with zero (0)."
    fr: "Veuillez ne pas choisir un nombre commençant par zéro (0)."
  'CLEAR-SESSION-4':
    en: "Please enter a PID for this session:"
    fr: "Veuillez saisir un PID pour cette session:"
  'SELECT-AN-OPTION':
    en: "Select an option"
    fr: "Veuillez choisir une option"
  'DCE-CONFIRM-YES-TEXT':
    en: "Yes, I would actually choose this treatment"
    fr: "Oui, dans la vraie vie, je choisirais ce traitement"
  'DCE-CONFIRM-NO-TEXT':
    en: "No, I would not actually choose this treatment"
    fr: "Non, dans la vraie vie, je ne choisirais pas ce traitement"
  'GRID-YES-NO-MIN-SELECTION-SINGULAR':
    en: "Must select at least 1 response."
    fr: "Veuillez sélectionner au moins 1 réponse"
  'GRID-YES-NO-MIN-SELECTION-PLURAL':
    en: "Must select at least {{min}} responses."
    fr: "Veuillez sélectionner au moins {{min}} réponses"
  'HELP-ME-BTN':
    en: "Help me"
    fr: "Besoin d'aide"
  'CONTACT-INFO-HEADER':
    en: "Contact information"
    fr: "Coordonnées"
  'QUESTION-X-OF-N':
    en: "Question {{x}} of {{n}}"
    fr: "Question {{x}} de {{n}}"
)

.constant('SUPPORTED_LANGUAGES', ['en', 'fr'])