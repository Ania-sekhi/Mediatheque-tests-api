*** Settings ***
Documentation     Variables et mots-clés communs à toutes les suites.
Library           Process
Library           RequestsLibrary


*** Variables ***
${PORT}               5000
${URL}                http://127.0.0.1:${PORT}
${APP}                ${CURDIR}/../../app/app.py

# Livres présents au démarrage (jeu de données de référence)
${NB_LIVRES_INITIAL}        3
${ISBN_PETIT_PRINCE}        9782070408504
${ISBN_ETRANGER}            9782070360024
${ISBN_MISERABLES}          9782253096344
${ID_PETIT_PRINCE}          1
${ID_ETRANGER}              2
${ID_MISERABLES}            3


*** Keywords ***
Démarrer l'application
    [Documentation]    Lance l'application avec le même interpréteur Python que Robot,
    ...                puis attend qu'elle réponde (au plus 15 secondes).
    ${python}=    Evaluate    sys.executable    modules=sys
    Start Process    ${python}    ${APP}    alias=app    stdout=${OUTPUT DIR}/app.log    stderr=STDOUT
    Wait Until Keyword Succeeds    30x    0.5s    GET    ${URL}/api/livres    expected_status=200

Arrêter l'application
    Terminate All Processes

Réinitialiser les données
    [Documentation]    Remet le jeu de données de référence : chaque test démarre dans le même état.
    POST    ${URL}/api/test/reset    expected_status=200
