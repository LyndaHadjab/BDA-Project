\i /home/aurora/Bureau/projet_bdd_Lynda_Hanane_Hadjab/create_all.sql;

/* Sur la table Vaccination */
/* verifier les contraintes => check */
/* si on essaye d'insert une vaccination avec nombre de dose inférieure à zéro */
/* une exception sera elevée*/
INSERT INTO vaccination VALUES ('1',1,'2020-01-01',-12,60);
INSERT INTO vaccination VALUES ('1',0,'2020-01-11',12,-60);
/* La selection par dep, jour / jour / dep sans fonctions */

/* La fonction  par dep, vaccin  */

CREATE OR REPLACE FUNCTION select_vaccination_dep_vaccin(_dep_param varchar, vaccin_type varchar) RETURNS
        table (_dep varchar, _vaccin varchar,_jour date, _n_tot_dos1 INTEGER, _n_tot_dos2 INTEGER) as
$$
DECLARE id_vac INTEGER;

BEGIN 

    select id_vaccin into id_vac from vaccin where type_de_vaccin=vaccin_type;
    if NOT FOUND THEN
        raise NOTICE 'le vaccin % n''existe pas ', vaccin_type;
    ELSE
        return QUERY select dep, vaccin_type, jour, n_tot_dos1, n_tot_dos2 from vaccination
                where vaccin =  id_vac AND dep = _dep_param;
        IF NOT FOUND THEN
            RAISE NOTICE 'aucun vaccin dans ce département % ', _dep_param;
        END IF;
    END IF;

END;
$$ LANGUAGE PLPGSQL;

/* test */

select * from select_vaccination_dep_vaccin('1', 'Pfizer');
select * from select_vaccination_dep_vaccin('1', 'Moderna');
select * from select_vaccination_dep_vaccin('1', 'AstraZeneca');

/* La fonction par departement vaccin jour */

CREATE OR REPLACE FUNCTION select_vaccination_dep_vaccin_jour(_dep_param varchar, vaccin_type varchar, _jour_param date) 
    RETURNS table (_dep varchar, _vaccin varchar,_jour date, _n_tot_dos1 INTEGER, _n_tot_dos2 INTEGER) as 
$$
DECLARE id_vac INTEGER;
BEGIN 
    select id_vaccin into id_vac from vaccin where type_de_vaccin=vaccin_type;
    if NOT FOUND THEN
        raise NOTICE 'le vaccin % existe pas ', vaccin_type;
    ELSE
        return QUERY select dep, vaccin_type, jour, n_tot_dos1, n_tot_dos2 from vaccination
                where vaccin =  id_vac AND dep = _dep_param AND jour = _jour_param;
        IF NOT FOUND THEN
            RAISE NOTICE 'aucune vaccination pour ce département % ', _dep_param;
        END IF;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

/* test */

select * from select_vaccination_dep_vaccin_jour('1', 'Pfizer', '2021-04-05');
select * from select_vaccination_dep_vaccin_jour('1', 'Moderna', '2021-04-05');

/* le nombre de vaccination dans un département à une date donné*/
SELECT COUNT(*) as nombre_vaccin FROM vaccination WHERE dep = '1' and jour = '2021-04-05';

/* le nombre de vaccination dans un département à une date donné pour un vaccin spécifique*/
CREATE OR REPLACE FUNCTION select_nombre_vaccination_dep_date(_dep varchar, _jour date, _vaccin text) 
    RETURNS INTEGER as 
$$
DECLARE id INTEGER;
DECLARE res INTEGER;
BEGIN 

    PERFORM * FROM departement WHERE code_departement = _dep;
    IF (NOT FOUND) THEN RAISE 'le département % n''existe pas',_dep;
    END IF;

    SELECT id_vaccin INTO id FROM vaccin WHERE type_de_vaccin = _vaccin;
    IF (NOT FOUND) THEN RAISE 'le vaccin  % n''existe pas',_vaccin;
    END IF;

    SELECT count(*) INTO res FROM vaccination WHERE dep = _dep and jour = _jour and vaccin = id;
    return res;
END;
$$ LANGUAGE PLPGSQL;

SELECT select_nombre_vaccination_dep_date ('1', '2021-04-05', 'Pfizer') as nombre_de_vaccin_dep_date;

/*pour chaque departement la somme de dose 1 et dose 2 donnée*/

SELECT dep, sum(n_tot_dos1) as total_dep_dos1, sum(n_tot_dos2) as total_dep_dos2
FROM vaccination
GROUP BY dep
ORDER BY dep;

/* insert into vaccination */
SELECT vaccination_insert ('1', 'Pfizer', '2025-05-12', 232, 432);
/* Afficher le tuple insérer*/
PREPARE select_new_insertion_for_vaccination_table(text, date, text) AS
   SELECT * FROM vaccination WHERE dep = $1 and jour = $2
    and vaccin IN (SELECT id_vaccin FROM vaccin WHERE type_de_vaccin = $3);

\echo l''insertion est bien effectuer;
EXECUTE select_new_insertion_for_vaccination_table('1', '2025-05-12', 'Pfizer');

/* suppression d'un vaccination */
SELECT vaccination_delete ('1', 'Pfizer', '2025-05-12');

\echo la suppression est bien effectuer;
EXECUTE select_new_insertion_for_vaccination_table('1', '2025-05-12', 'Pfizer');

/* test the function */
SELECT * FROM select_ntotdos1_ntotdos2('1','2021-04-05', 'AstraZeneca');
SELECT vaccination_insert('1','AstraZeneca','2021-04-10',12,23);

\echo le tuple est insérer avec succès;
EXECUTE select_new_insertion_for_vaccination_table('1', '2021-04-10', 'AstraZeneca');

SELECT * FROM select_ntotdos1_ntotdos2_between('1','2021-04-05','2021-04-10','AstraZeneca');
select vaccination_update_dos1('1','AstraZeneca','2021-04-10',120);

\echo le tuple est modifié avec succès;
EXECUTE select_new_insertion_for_vaccination_table('1', '2021-04-10', 'AstraZeneca');

select vaccination_update_dos2('1','AstraZeneca','2021-04-10',230);

\echo le tuple est modifié avec succès;
EXECUTE select_new_insertion_for_vaccination_table('1', '2021-04-10', 'AstraZeneca');

SELECT * FROM select_ntotdos1_ntotdos2_between('1','2021-04-05','2021-04-10','AstraZeneca');
select vaccination_delete('1','AstraZeneca','2021-04-10');

\echo le tuple est supprimer avec succès;
EXECUTE select_new_insertion_for_vaccination_table('1', '2021-04-10', 'AstraZeneca');

SELECT * FROM select_ntotdos1_ntotdos2_between('1','2021-04-05','2021-04-10','AstraZeneca');

/* si on essaye de modifier par un gid existant */
SELECT edit_gid_lieu_de_vaccination ('89', '1220');

/* si on essaye de modifier par un gid existant */
\echo avant modification;
SELECT * FROM lieu_de_vaccination WHERE gid = '89';

SELECT edit_gid_lieu_de_vaccination ('89', '89220');
\echo le tuple est bien modofier;
SELECT * FROM lieu_de_vaccination WHERE gid = '89220';