/*Test des fonctions crées pour departement */

/* Test qui concerne la table département*/
SELECT * FROM departement WHERE code_departement = '1';

SELECT departement_insert('765', 'test', '76', 'testRegion');
SELECT departement_insert('987', 'test2', '76', 'testRegion');
SELECT * FROM departement WHERE code_departement = '765' OR code_departement = '987';

/* Try to insert an existant department*/
SELECT departement_insert('1', 'test', '76', 'testRegion');

/* Suppression d'un département par code*/
SELECT departement_delete_code ('765');
SELECT * FROM departement WHERE code_departement = '765';

/* Suppression d'un département par nom qui est unique*/
SELECT departement_delete_nom ('test2');
SELECT * FROM departement WHERE nom_departement = 'test2';

/* essaye de supprimer un département inexistant par code */
SELECT departement_delete_code ('765');
/* essaye de supprimer un département inexistant par nom */
SELECT departement_delete_nom ('test2');

/* Modifier le nom d'un département */
SELECT * FROM departement WHERE code_departement = '1';
SELECT departement_update_nom('1', 'update name');
SELECT * FROM departement WHERE code_departement = '1';

/* Essayer de Modifier le nom d'un département par un nom appartient déjà à un département */
SELECT * FROM departement WHERE code_departement = '2';
SELECT departement_update_nom('2', 'update name');

/* Modifier le nom d'une région d'un département*/
SELECT * FROM departement WHERE code_departement = '3';
SELECT departement_update_region('3', 'Allier', 'Auvergne-Rhône-Alpes update');
SELECT * FROM departement WHERE code_departement = '3';

/*Test des fonctions crées pour adress table */
/* Insertion d'une adresse*/

SELECT adresse_insert('1', 'Rue Joseph Cugnot test rue', '54000', '54395', 'Nancy');
SELECT * FROM adresse WHERE adr_num = '1' AND adr_voie = 'Rue Joseph Cugnot test rue' 
						AND com_cp = '54000' AND  com_insee = '54395' AND com_nom = 'Nancy';

/*Essayer d'inserer une adresse déjà existante*/
/*=> Une exception sera générer*/
SELECT adresse_insert('1', 'Rue Joseph Cugnot test rue', '54000', '54395', 'Nancy');

/* Supprimer une adresse existante */
SELECT adresse_delete('1', 'Rue Joseph Cugnot test rue', '54000', '54395', 'Nancy');
SELECT * FROM adresse WHERE adr_num = '1' AND adr_voie = 'Rue Joseph Cugnot test rue' 
						AND com_cp = '54000' AND  com_insee = '54395' AND com_nom = 'Nancy';