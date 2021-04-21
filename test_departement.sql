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

