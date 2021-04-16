/* Pour tester la table vaccin */
/*selectionner les type de vaccin existant */
SELECT  * FROM vaccin ORDER BY type_de_vaccin ASC;

/* Inserer un nouveau type de vaccin*/
SELECT  vaccin_insert('newVaccin');
SELECT  * FROM vaccin ORDER BY type_de_vaccin ASC;

/*Inserer un vaccin déjà existant*/
SELECT  vaccin_insert('Pfizer');
SELECT  * FROM vaccin ORDER BY type_de_vaccin ASC;

/*Modifier ule nom d'un vaccin */
SELECT  vaccin_update('Moderna', 'testedit');
SELECT  * FROM vaccin ORDER BY type_de_vaccin ASC;

/* Essaye de modifier un vaccin inexistant*/
SELECT  vaccin_update('inexistant', 'testedit');
SELECT  * FROM vaccin ORDER BY type_de_vaccin ASC;

/*Essayer de modifier un nom de vaccin par un nom déjà existant*/
SELECT  vaccin_update('AstraZeneca', 'Pfizer');
SELECT  * FROM vaccin ORDER BY type_de_vaccin ASC;


/* Supprimer un vaccin qui  n'est pas encore réferent (Cascade)*/
SELECT  vaccin_delete('newVaccin');
SELECT  * FROM vaccin ORDER BY type_de_vaccin ASC;

/*Supprimer un vaccin inexistant*/
SELECT  vaccin_delete('inexistant');
SELECT  * FROM vaccin ORDER BY type_de_vaccin ASC;

/*Supprimer un vaccin réferent par un tuple (Cascade)*/
SELECT  vaccin_delete('Pfizer');
SELECT  * FROM vaccin ORDER BY type_de_vaccin ASC;

/*A une date donné et un vaccin et un département le nombre de dos1 et dos2 effectuer */

CREATE OR REPLACE FUNCTION select_ntotdos1_ntotdos2 (_dep TEXT, _jour DATE, type_vaccin VARCHAR)
                    RETURNS TABLE(n INTEGER, m INTEGER) AS 
$$
BEGIN
    RETURN QUERY SELECT n_tot_dos1 , n_tot_dos2 FROM vaccination 
        WHERE dep = _dep AND jour = _jour AND vaccin IN 
                (SELECT id_vaccin FROM vaccin WHERE type_de_vaccin = type_vaccin);
END;
$$LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION select_ntotdos1_ntotdos2_between (_dep TEXT, _jour1 DATE, _jour2 DATE, type_vaccin VARCHAR)
                    RETURNS TABLE(n INTEGER, m INTEGER) AS 
$$
BEGIN
    RETURN QUERY SELECT n_tot_dos1 , n_tot_dos2 FROM vaccination 
        WHERE dep = _dep AND (jour >=_jour1  AND jour <= _jour2) AND vaccin IN 
                (SELECT id_vaccin FROM vaccin WHERE type_de_vaccin = type_vaccin);
END;
$$LANGUAGE PLPGSQL;

/* test the function */
SELECT select_ntotdos1_ntotdos2('1','2021-04-05', 'AstraZeneca');
SELECT vaccination_insert('1','AstraZeneca','2021-04-10',12,23);
SELECT select_ntotdos1_ntotdos2_between('1','2021-04-05','2021-04-10','AstraZeneca');
select vaccination_update_dos1('1','AstraZeneca','2021-04-10',120);
select vaccination_update_dos2('1','AstraZeneca','2021-04-10',230);
SELECT select_ntotdos1_ntotdos2_between('1','2021-04-05','2021-04-10','AstraZeneca');
select vaccination_delete('1','AstraZeneca','2021-04-10');
SELECT select_ntotdos1_ntotdos2_between('1','2021-04-05','2021-04-10','AstraZeneca');
SELECT vaccin_insert('Pfizer');


/* le stockage d'un vaccin à une date donné et à une date donné */

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
