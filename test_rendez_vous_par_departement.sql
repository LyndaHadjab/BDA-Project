\i /home/aurora/Bureau/projetBDD/create_all.sql;

/* Effectuer un ensemble de test sur la table rendez_vous_par_departement */
PREPARE select_new_insertion(text, int, date) AS 
    SELECT * FROM rendez_vous_par_departement WHERE date_debut_semaine = $3 
    AND id_departement = $1 AND rang_vaccinal = $2;

/* si le rendez vous n'existe pas on l'insere sinon on incrémente le nombre de rendez vous */
SELECT rendez_vous_par_departement_add('1', 2, '2023-01-16', 5);
EXECUTE select_new_insertion('1', 2, '2023-01-16');

/* si on essaye d'insérer un rendez déja existant */
SELECT rendez_vous_par_departement_add('1', 2, '2023-01-16', 5);
select * from rendez_vous_par_departement where date_debut_semaine='2023-01-16';

/* inserer un rendez vous par département*/
/* inserer un rendez vous inexistant*/
INSERT INTO rendez_vous_par_departement VALUES ('2', 1, '2025-01-16', 15);
EXECUTE select_new_insertion('2', 1, '2025-01-16');

/* inserer un rendez vous existant => error */
INSERT INTO rendez_vous_par_departement VALUES ('2', 1, '2025-01-16', 15);

/* modifier */
UPDATE rendez_vous_par_departement set nb = 14 WHERE id_departement = '2' and date_debut_semaine = '2025-01-16'
    and rang_vaccinal = 1;
EXECUTE select_new_insertion('2', 1, '2025-01-16');

/* quelques requete */
/* le nombre de rendez vous par departement à une date donnée pour n'importe quel rang*/
PREPARE select_nb_rendez_vous(text, date) AS 
    SELECT nb as nombre FROM rendez_vous_par_departement WHERE date_debut_semaine = $2 AND id_departement = $1;

EXECUTE select_nb_rendez_vous('2', '2025-01-16');

/* nombre de rendez vous pour un rang quelconque pour un
département donnée */
SELECT rang_vaccinal,date_debut_semaine, count(*) FROM rendez_vous_par_departement 
WHERE rang_vaccinal = 1 AND id_departement = '2'
GROUP BY id_departement, date_debut_semaine, rang_vaccinal;