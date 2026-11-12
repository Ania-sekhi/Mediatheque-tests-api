-- =====================================================================
-- Médiathèque : requêtes SQL de vérification des données
-- À lancer dans un client SQL (par exemple DBeaver) ouvert sur le fichier app/mediatheque.db,
-- après une action faite dans l'interface, dans Postman ou par les tests Robot.
-- Les mêmes contrôles sont automatisés dans tests/api/03_donnees_en_base.robot.
-- =====================================================================

-- 1. Le catalogue, tel qu'il est enregistré
SELECT id, titre, auteur, isbn, emprunteur
FROM livres
ORDER BY id;

-- 2. L'historique des emprunts (date_retour vide = emprunt en cours)
SELECT e.id, l.titre, e.emprunteur, e.date_emprunt, e.date_retour
FROM emprunts e
JOIN livres l ON l.id = e.livre_id
ORDER BY e.id;

-- 3. Après un ajout : le livre est-il bien enregistré ? (remplacer l'ISBN)
SELECT titre, auteur, isbn
FROM livres
WHERE isbn = '9782253004226';

-- 4. Après un emprunt : un emprunt en cours existe-t-il pour ce livre ? (remplacer l'id)
SELECT emprunteur, date_emprunt
FROM emprunts
WHERE livre_id = 1 AND date_retour IS NULL;

-- 5. Contrôle de cohérence : un livre est emprunté si et seulement s'il a un emprunt en cours.
--    Résultat attendu : aucune ligne.
SELECT l.id, l.titre, l.emprunteur, e.id AS emprunt_en_cours
FROM livres l
LEFT JOIN emprunts e ON e.livre_id = l.id AND e.date_retour IS NULL
WHERE (l.emprunteur IS NULL) <> (e.id IS NULL);

-- 6. Contrôle : aucun ISBN en double. Résultat attendu : aucune ligne.
SELECT isbn, COUNT(*) AS nombre
FROM livres
GROUP BY isbn
HAVING COUNT(*) > 1;

-- 7. Contrôle : aucun ISBN qui ne fait pas 13 caractères. Résultat attendu : aucune ligne.
SELECT id, isbn
FROM livres
WHERE LENGTH(isbn) <> 13;

-- 8. Statistiques : nombre d'emprunts par livre
SELECT l.titre, COUNT(e.id) AS nombre_emprunts
FROM livres l
LEFT JOIN emprunts e ON e.livre_id = l.id
GROUP BY l.id, l.titre
ORDER BY nombre_emprunts DESC;
