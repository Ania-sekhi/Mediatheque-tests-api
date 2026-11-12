*** Settings ***
Documentation     Mots-clés pour vérifier les données directement dans la base, avec des requêtes SQL.
...               L'API dit ce qu'elle a fait ; la base montre ce qui a vraiment été enregistré.
Library           DatabaseLibrary
Resource          commun.resource


*** Variables ***
${BASE}           ${CURDIR}/../../app/mediatheque.db


*** Keywords ***
Se connecter à la base
    Connect To Database    sqlite3    database=${BASE}    isolation_level=${None}

Se déconnecter de la base
    Disconnect From All Databases

Le nombre de livres en base est
    [Arguments]    ${nombre}
    Check Query Result    SELECT COUNT(*) FROM livres    ==    ${nombre}    assert_as_string=True

Le livre est enregistré en base
    [Arguments]    ${isbn}    ${titre}    ${auteur}
    Check Row Count       SELECT id FROM livres WHERE isbn = '${isbn}'    ==    1
    Check Query Result    SELECT titre FROM livres WHERE isbn = '${isbn}'     ==    ${titre}
    Check Query Result    SELECT auteur FROM livres WHERE isbn = '${isbn}'    ==    ${auteur}

L'ISBN n'existe pas en base
    [Arguments]    ${isbn}
    Check Row Count    SELECT id FROM livres WHERE isbn = '${isbn}'    ==    0

L'emprunteur enregistré pour le livre est
    [Arguments]    ${id}    ${emprunteur}
    Check Query Result    SELECT emprunteur FROM livres WHERE id = ${id}    ==    ${emprunteur}

Le livre a un emprunt en cours pour
    [Arguments]    ${id}    ${emprunteur}
    Check Row Count       SELECT id FROM emprunts WHERE livre_id = ${id} AND date_retour IS NULL    ==    1
    Check Query Result    SELECT emprunteur FROM emprunts WHERE livre_id = ${id} AND date_retour IS NULL    ==    ${emprunteur}

Le livre n'a aucun emprunt en cours
    [Arguments]    ${id}
    Check Row Count    SELECT id FROM emprunts WHERE livre_id = ${id} AND date_retour IS NULL    ==    0

Le nombre d'emprunts terminés du livre est
    [Arguments]    ${id}    ${nombre}
    Check Row Count    SELECT id FROM emprunts WHERE livre_id = ${id} AND date_retour IS NOT NULL    ==    ${nombre}

Les livres et les emprunts sont cohérents
    [Documentation]    Un livre est marqué emprunté si et seulement s'il a un emprunt en cours.
    ...                La requête cherche les incohérences : elle doit renvoyer 0 ligne.
    Check Row Count
    ...    SELECT l.id FROM livres l LEFT JOIN emprunts e ON e.livre_id = l.id AND e.date_retour IS NULL WHERE (l.emprunteur IS NULL) <> (e.id IS NULL)
    ...    ==    0
