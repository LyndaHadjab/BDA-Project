/* Sur la table Vaccination */
/* verifier les contraintes => check */
/* si on essaye d'insert une vaccination avec nombre de dose inférieure à zéro */
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
        raise NOTICE 'le vaccin % existe pas ', vaccin_type; 
    ELSE
        return QUERY select dep, vaccin_type, jour, n_tot_dos1, n_tot_dos2 from vaccination 
                where vaccin =  id_vac AND dep = _dep_param;
        IF NOT FOUND THEN 
            RAISE NOTICE 'aucune vaccination pour ce département % ', _dep_param;
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