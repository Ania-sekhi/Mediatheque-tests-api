*** Settings ***
Documentation     Campagne de tests automatisés de l'API de la Médiathèque.
...               L'application est démarrée avant les tests et arrêtée après :
...               la commande ``robot tests`` suffit, en local comme en intégration continue.
Resource          resources/commun.resource
Suite Setup       Démarrer l'application
Suite Teardown    Arrêter l'application
