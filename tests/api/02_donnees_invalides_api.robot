*** Settings ***
Documentation     Tests pilotés par les données (data-driven) : chaque ligne est un test.
...               Un seul mot-clé modèle, plusieurs jeux de données : ajouter un cas = ajouter une ligne.
Resource          ../resources/api.resource
Suite Setup       Ouvrir une session sur l'API
Test Setup        Réinitialiser les données
Test Template     L'ajout est refusé
Test Tags         api    négatif    US-02


*** Variables ***
${TITRE_101}      ${{ "T" * 101 }}


*** Test Cases ***                  TITRE           AUTEUR         ISBN               MESSAGE ATTENDU
API-20 Titre vide                   ${EMPTY}        Victor Hugo    9780000000001      Le titre est obligatoire
API-21 Titre composé d'espaces      ${SPACE * 3}    Victor Hugo    9780000000001      Le titre est obligatoire
API-22 Titre de 101 caractères      ${TITRE_101}    Victor Hugo    9780000000001      Le titre ne doit pas dépasser 100 caractères
API-23 Auteur vide                  Germinal        ${EMPTY}       9780000000001      L'auteur est obligatoire
API-24 ISBN de 12 chiffres          Germinal        Émile Zola     978000000000       L'ISBN doit contenir exactement 13 chiffres
API-25 ISBN de 14 chiffres          Germinal        Émile Zola     97800000000011     L'ISBN doit contenir exactement 13 chiffres
API-26 ISBN avec une lettre         Germinal        Émile Zola     978000000000X      L'ISBN doit contenir exactement 13 chiffres
API-27 ISBN avec des tirets         Germinal        Émile Zola     978-2-25-300422    L'ISBN doit contenir exactement 13 chiffres


*** Keywords ***
L'ajout est refusé
    [Documentation]    Envoie un livre invalide : l'API doit répondre 400 avec le bon message,
    ...                et le catalogue doit rester inchangé.
    [Arguments]    ${titre}    ${auteur}    ${isbn}    ${message}
    ${reponse}=    Ajouter un livre    ${titre}    ${auteur}    ${isbn}    statut_http=400
    Le message d'erreur est    ${reponse}    ${message}
    ${livres}=    Lister les livres
    Length Should Be    ${livres}    ${NB_LIVRES_INITIAL}
