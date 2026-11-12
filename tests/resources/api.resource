*** Settings ***
Documentation     Mots-clés métier pour tester l'API REST de la Médiathèque.
...               Les tests appellent ces mots-clés, jamais directement les URL :
...               si l'API change, seul ce fichier est à modifier.
Library           RequestsLibrary
Library           Collections
Resource          commun.resource


*** Keywords ***
Ouvrir une session sur l'API
    Create Session    api    ${URL}    disable_warnings=1

# --- Actions -----------------------------------------------------------

Lister les livres
    ${reponse}=    GET On Session    api    /api/livres
    RETURN    ${reponse.json()}

Consulter le livre
    [Arguments]    ${id}    ${statut_http}=200
    ${reponse}=    GET On Session    api    /api/livres/${id}    expected_status=${statut_http}
    RETURN    ${reponse.json()}

Ajouter un livre
    [Arguments]    ${titre}    ${auteur}    ${isbn}    ${statut_http}=201
    ${corps}=    Create Dictionary    titre=${titre}    auteur=${auteur}    isbn=${isbn}
    ${reponse}=    POST On Session    api    /api/livres    json=${corps}    expected_status=${statut_http}
    RETURN    ${reponse.json()}

Emprunter le livre
    [Arguments]    ${id}    ${emprunteur}    ${statut_http}=200
    ${corps}=    Create Dictionary    emprunteur=${emprunteur}
    ${reponse}=    POST On Session    api    /api/livres/${id}/emprunt    json=${corps}    expected_status=${statut_http}
    RETURN    ${reponse.json()}

Rendre le livre
    [Arguments]    ${id}    ${statut_http}=200
    ${reponse}=    POST On Session    api    /api/livres/${id}/retour    expected_status=${statut_http}
    RETURN    ${reponse.json()}

Supprimer le livre
    [Arguments]    ${id}    ${statut_http}=204
    ${reponse}=    DELETE On Session    api    /api/livres/${id}    expected_status=${statut_http}
    RETURN    ${reponse}

# --- Vérifications -----------------------------------------------------

Le message d'erreur est
    [Arguments]    ${reponse}    ${message}
    Should Be Equal    ${reponse}[erreur]    ${message}

Le livre a le statut
    [Arguments]    ${livre}    ${statut}    ${emprunteur}=${None}
    Should Be Equal    ${livre}[statut]    ${statut}
    Should Be Equal    ${livre}[emprunteur]    ${emprunteur}

Le catalogue contient l'ISBN
    [Arguments]    ${isbn}
    ${livres}=    Lister les livres
    ${isbns}=    Evaluate    [livre["isbn"] for livre in $livres]
    List Should Contain Value    ${isbns}    ${isbn}

Le livre respecte le contrat d'interface
    [Documentation]    Vérifie la présence et le type de chaque champ attendu par l'interface web.
    [Arguments]    ${livre}
    ${attendus}=    Create List    id    titre    auteur    isbn    emprunteur    statut
    FOR    ${champ}    IN    @{attendus}
        Dictionary Should Contain Key    ${livre}    ${champ}
    END
    Should Be True    isinstance($livre["id"], int)
    Should Match Regexp    ${livre}[isbn]    ^\\d{13}$
    Should Contain Any    ${livre}[statut]    disponible    emprunté
