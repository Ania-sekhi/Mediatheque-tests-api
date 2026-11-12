*** Settings ***
Documentation     Tests de l'API REST : consultation, ajout, emprunt, retour et suppression de livres.
Resource          ../resources/api.resource
Suite Setup       Ouvrir une session sur l'API
Test Setup        Réinitialiser les données
Test Tags         api


*** Test Cases ***
API-01 Consulter le catalogue
    [Tags]    US-01    smoke
    ${livres}=    Lister les livres
    Length Should Be    ${livres}    ${NB_LIVRES_INITIAL}

API-02 Consulter un livre existant
    [Tags]    US-01
    ${livre}=    Consulter le livre    ${ID_PETIT_PRINCE}
    Should Be Equal    ${livre}[titre]    Le Petit Prince
    Le livre a le statut    ${livre}    disponible

API-03 Consulter un livre inexistant
    [Tags]    US-01    négatif
    ${reponse}=    Consulter le livre    999    statut_http=404
    Le message d'erreur est    ${reponse}    Livre introuvable

API-04 Le format des livres respecte le contrat d'interface
    [Tags]    US-01    contrat
    ${livres}=    Lister les livres
    FOR    ${livre}    IN    @{livres}
        Le livre respecte le contrat d'interface    ${livre}
    END

API-05 Ajouter un livre valide
    [Tags]    US-02    smoke
    ${livre}=    Ajouter un livre    Germinal    Émile Zola    9782253004226
    Le livre a le statut    ${livre}    disponible
    Le catalogue contient l'ISBN    9782253004226
    ${livres}=    Lister les livres
    Length Should Be    ${livres}    4

API-06 Un titre de 100 caractères est accepté
    [Tags]    US-02    limite
    ${titre}=    Evaluate    "T" * 100
    ${livre}=    Ajouter un livre    ${titre}    Auteur    9780000000100
    Length Should Be    ${livre}[titre]    100

API-07 Un ISBN déjà présent est refusé
    [Tags]    US-02    négatif
    ${reponse}=    Ajouter un livre    Copie    Inconnu    ${ISBN_PETIT_PRINCE}    statut_http=409
    Le message d'erreur est    ${reponse}    Un livre avec cet ISBN existe déjà

API-08 Emprunter un livre disponible
    [Tags]    US-03    smoke
    ${livre}=    Emprunter le livre    ${ID_PETIT_PRINCE}    Bob
    Le livre a le statut    ${livre}    emprunté    Bob

API-09 Un livre déjà emprunté ne peut pas être emprunté
    [Tags]    US-03    négatif
    ${reponse}=    Emprunter le livre    ${ID_MISERABLES}    Bob    statut_http=409
    Le message d'erreur est    ${reponse}    Ce livre est déjà emprunté
    ${livre}=    Consulter le livre    ${ID_MISERABLES}
    Le livre a le statut    ${livre}    emprunté    Alice

API-10 Le nom de l'emprunteur est obligatoire
    [Tags]    US-03    négatif
    ${reponse}=    Emprunter le livre    ${ID_PETIT_PRINCE}    ${SPACE}    statut_http=400
    Le message d'erreur est    ${reponse}    Le nom de l'emprunteur est obligatoire

API-11 Rendre un livre emprunté
    [Tags]    US-04    smoke
    ${livre}=    Rendre le livre    ${ID_MISERABLES}
    Le livre a le statut    ${livre}    disponible

API-12 Un livre disponible ne peut pas être rendu
    [Tags]    US-04    négatif
    ${reponse}=    Rendre le livre    ${ID_PETIT_PRINCE}    statut_http=409
    Le message d'erreur est    ${reponse}    Ce livre n'est pas emprunté

API-13 Cycle complet emprunt puis retour
    [Tags]    US-03    US-04
    Emprunter le livre    ${ID_PETIT_PRINCE}    Bob
    Rendre le livre    ${ID_PETIT_PRINCE}
    ${livre}=    Emprunter le livre    ${ID_PETIT_PRINCE}    Chloé
    Le livre a le statut    ${livre}    emprunté    Chloé

API-14 Supprimer un livre disponible
    [Tags]    US-05
    Supprimer le livre    ${ID_PETIT_PRINCE}
    Consulter le livre    ${ID_PETIT_PRINCE}    statut_http=404

API-15 Un livre emprunté ne peut pas être supprimé
    [Tags]    US-05    négatif
    ${reponse}=    Supprimer le livre    ${ID_MISERABLES}    statut_http=409
    Le message d'erreur est    ${reponse.json()}    Impossible de supprimer un livre emprunté
    Consulter le livre    ${ID_MISERABLES}
