\i /home/aurora/Bureau/projet_bdd_Lynda_Hanane_Hadjab/create_all.sql;

/* Pour tester la table vaccin */
/*selectionner les type de vaccin existant */
\echo Les vaccin développés sont :;
SELECT * FROM vaccin;

/* Inserer un nouveau type de vaccin*/
SELECT vaccin_insert('newVaccin');
\echo le tuple est bien insérer ;
SELECT * FROM vaccin;

/*Inserer un vaccin déjà existant*/
SELECT vaccin_insert('Pfizer');
SELECT * FROM vaccin;

/*Modifier le nom d'un vaccin */
SELECT vaccin_update('Moderna', 'testedit');
\echo le tuple est bien modifier ;
SELECT * FROM vaccin;

/* Essaye de modifier un vaccin inexistant*/
SELECT vaccin_update('inexistant', 'testedit');
SELECT * FROM vaccin;

/*Essayer de modifier un nom de vaccin par un nom déjà existant*/
SELECT vaccin_update('AstraZeneca', 'Pfizer');
SELECT * FROM vaccin;

/* Supprimer un vaccin qui  n'est pas encore réferent (Cascade)*/
SELECT vaccin_delete('newVaccin');
SELECT * FROM vaccin;

/*Supprimer un vaccin inexistant*/
SELECT vaccin_delete('inexistant');
SELECT * FROM vaccin;

/*Supprimer un vaccin réferent par un tuple (Cascade)*/
SELECT vaccin_delete('Pfizer');
SELECT * FROM vaccin;

/*retourner le nombre de dos1 et dos2 effectuer dans un département à une date donné avec un vaccin*/

CREATE OR REPLACE FUNCTION select_ntotdos1_ntotdos2 (_dep TEXT, _jour DATE, type_vaccin VARCHAR)
                    RETURNS TABLE(dos1 INTEGER, dos2 INTEGER) AS 
$$
BEGIN
    RETURN QUERY SELECT n_tot_dos1 , n_tot_dos2 FROM vaccination 
        WHERE dep = _dep AND jour = _jour AND vaccin IN 
                (SELECT id_vaccin FROM vaccin WHERE type_de_vaccin = type_vaccin);
END;
$$LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION select_ntotdos1_ntotdos2_between (_dep TEXT, _jour1 DATE, _jour2 DATE, type_vaccin VARCHAR)
                    RETURNS TABLE(dos1 INTEGER, dos2 INTEGER) AS 
$$
BEGIN
    RETURN QUERY SELECT n_tot_dos1 , n_tot_dos2 FROM vaccination 
        WHERE dep = _dep AND (jour >=_jour1  AND jour <= _jour2) AND vaccin IN 
                (SELECT id_vaccin FROM vaccin WHERE type_de_vaccin = type_vaccin);
END;
$$LANGUAGE PLPGSQL;

/*-------------------------------------------------------*/
/* le stockage d'un vaccin à une date donné  */

CREATE OR REPLACE FUNCTION test_vaccin_with_stockage_vaccin(_dep VARCHAR, _jour DATE, type_vaccin VARCHAR) 
        RETURNS SETOF stockage_vaccin_departement AS
$$
BEGIN
    RETURN QUERY SELECT *  FROM stockage_vaccin_departement WHERE code_departement = _dep 
        AND  id_stockage_vaccin IN (SELECT id_stockage_vaccin FROM stockage_vaccin WHERE date_stockage = _jour)
        AND id_vaccin IN ( SELECT id_vaccin FROM vaccin WHERE type_de_vaccin = type_vaccin);
END;
$$ LANGUAGE PLPGSQL;

SELECT test_vaccin_with_stockage_vaccin('6','2021-01-24','testedit');

/* tester les fonctionnalité de la table tests */

/*ajouter un test avec un departement existant */
SELECT test_insert('1','2021-04-10',2341,3133);
SELECT * from test WHERE id_departement = '1' AND jour = '2021-04-10'; 

/*ajouter un test avec un departement inexistant dans notre système*/
SELECT test_insert('9875','2021-04-10',2341,3133);
SELECT * from test WHERE id_departement = '9875' AND jour = '2021-04-10'; 

/*Modifier la Population ou le nombre de test effectuer à une date donné pour un département donnée */
SELECT test_update('1','2021-04-10',2341,42357);
SELECT * from test WHERE id_departement = '1' AND jour = '2021-04-10'; 

/*Nombre de test négative => une exception est généré*/
SELECT test_update('1','2021-04-10',2341,-42357);

/*Ajouter le nombre de test effectuer pour un département à une date donné */
SELECT test_add_t_number('1','2021-04-10',2);
SELECT * from test WHERE id_departement = '1' AND jour = '2021-04-10'; 

/*Si on essaye d'ajouter un nombre négative une exception est généré*/
SELECT test_add_t_number('1','2021-04-10',-2);

/*soustraire le nombre de test effectuer pour un département à une date donné */
SELECT test_sub_t_number('1','2021-04-10',2);
SELECT * from test WHERE id_departement = '1' AND jour = '2021-04-10'; 

/*Si on essaye de soustraire un nombre négative une exception est généré*/
SELECT test_sub_t_number('1','2021-04-10',-2);

/* si on essaye d'inserer une pop négative , le trigger correspondant est déclanché */
INSERT INTO test VALUES ('176865445','2020-05-13',-1,40);

/* si on essaye d'inserer un département inexistant , le trigger correspondant est déclanché */
INSERT INTO test VALUES ('176865445','2020-05-13',1,40);

\echo le contenu de la 'table vaccin' est ;
SELECT * FROM vaccin;
/* Si on essaye d'inserer un vaccin déjà existant , le trigger se déclanche et raise */
INSERT INTO vaccin(type_de_vaccin) values('Tous vaccins');
/* sinon */
INSERT INTO vaccin(type_de_vaccin) values('test');
\echo le tuple est bien inserer dans la 'table vaccin':;
SELECT * FROM vaccin;

/* Si on essaye de modifierun vaccin (type) par un type déjà existant , le trigger se déclanche et raise */
UPDATE vaccin set type_de_vaccin = 'Pfizer' where type_de_vaccin='test';
/* Sinon */
update vaccin set type_de_vaccin = 'Pfizer' where type_de_vaccin='test edit';

/* On utilisant  PREPARE */
/*sur la table vaccin*/
PREPARE insert_into_vaccin (text) AS
    INSERT INTO vaccin(type_de_vaccin) VALUES ($1);
EXECUTE insert_into_vaccin ('test prepare');

/*sur la table test*/
PREPARE insert_into_test(text, date, int, int) AS
    INSERT INTO test VALUES ($1, $2, $3, $4);
EXECUTE insert_into_test('1','2020-07-13',19,40);