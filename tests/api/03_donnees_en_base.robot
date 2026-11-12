*** Settings ***
Documentation     Vérification des données en base après les appels d'API (requêtes SQL).
...               Chaque test fait une action par l'API, puis contrôle ce qui a été enregistré.
Resource          ../resources/api.resource
Resource          ../resources/base.resource
Suite Setup       Run Keywords    Ouvrir une session sur l'API    AND    Se connecter à la base
Suite Teardown    Se déconnecter de la base
Test Setup        Réinitialiser les données
Test Tags         api    sql


*** Test Cases ***
BD-01 Le jeu de données de référence est en base
    [Tags]    US-01
    Le nombre de livres en base est    3
    Le livre a un emprunt en cours pour    ${ID_MISERABLES}    Alice
    Les livres et les emprunts sont cohérents

BD-02 Un livre ajouté par l'API est enregistré en base
    [Tags]    US-02
    Ajouter un livre    Germinal    Émile Zola    9782253004226
    Le nombre de livres en base est    4
    Le livre est enregistré en base    9782253004226    Germinal    Émile Zola

BD-03 Un ajout refusé n'écrit rien en base
    [Tags]    US-02    négatif
    Ajouter un livre    Germinal    Émile Zola    12345    statut_http=400
    Le nombre de livres en base est    3
    L'ISBN n'existe pas en base    12345

BD-04 Un emprunt est enregistré en base
    [Tags]    US-03
    Emprunter le livre    ${ID_PETIT_PRINCE}    Bob
    L'emprunteur enregistré pour le livre est    ${ID_PETIT_PRINCE}    Bob
    Le livre a un emprunt en cours pour    ${ID_PETIT_PRINCE}    Bob
    Les livres et les emprunts sont cohérents

BD-05 Un retour clôture l'emprunt en base
    [Tags]    US-04
    Rendre le livre    ${ID_MISERABLES}
    L'emprunteur enregistré pour le livre est    ${ID_MISERABLES}    ${None}
    Le livre n'a aucun emprunt en cours    ${ID_MISERABLES}
    Le nombre d'emprunts terminés du livre est    ${ID_MISERABLES}    1
    Les livres et les emprunts sont cohérents

BD-06 Un emprunt refusé n'écrit rien en base
    [Tags]    US-03    négatif
    Emprunter le livre    ${ID_MISERABLES}    Bob    statut_http=409
    L'emprunteur enregistré pour le livre est    ${ID_MISERABLES}    Alice
    Le livre a un emprunt en cours pour    ${ID_MISERABLES}    Alice

BD-07 L'historique garde chaque emprunt
    [Tags]    US-03    US-04
    Emprunter le livre    ${ID_PETIT_PRINCE}    Bob
    Rendre le livre    ${ID_PETIT_PRINCE}
    Emprunter le livre    ${ID_PETIT_PRINCE}    Chloé
    Le nombre d'emprunts terminés du livre est    ${ID_PETIT_PRINCE}    1
    Le livre a un emprunt en cours pour    ${ID_PETIT_PRINCE}    Chloé
    Les livres et les emprunts sont cohérents

BD-08 Un livre supprimé disparaît de la base
    [Tags]    US-05
    Supprimer le livre    ${ID_ETRANGER}
    Le nombre de livres en base est    2
    L'ISBN n'existe pas en base    ${ISBN_ETRANGER}
