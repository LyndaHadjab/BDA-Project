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