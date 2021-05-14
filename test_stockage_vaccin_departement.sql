/* Function search selon le type de vaccin / selon la date / selon le départemen*/

/* Fonction 1: stockage de vaccin par département, jour, type vaccin  */
CREATE OR REPLACE FUNCTION select_stockage_vaccin_dep_jour_vaccin(dep varchar, jour DATE, 
            type_vac varchar) RETURNS table (_dep varchar, _jour date, 
            _vaccin varchar, _nb_doses INTEGER, _nb_ucd INTEGER)  as
$$
DECLARE id_stock INTEGER;
DECLARE id_type  INTEGER;
BEGIN
    select id_stockage_vaccin into id_stock from Stockage_vaccin where date_stockage = jour;

    select id_vaccin into id_type from vaccin where type_de_vaccin = type_vac;

    RETURN QUERY select code_departement, jour , type_vac, nb_doses, nb_ucd from stockage_vaccin_departement SV 
        where SV.code_departement = dep AND SV.id_stockage_vaccin = id_stock AND SV.id_vaccin = id_type;
    IF NOT FOUND THEN 
        RAISE NOTICE 'aucune données de stockage pour ce département % ', dep;
    END IF;
    RETURN;
END;
$$ LANGUAGE PLPGSQL;

/* Fonction 2: stockage de vaccin par département, jour */

CREATE OR REPLACE FUNCTION select_stockage_vaccin_jour_dep(jour DATE, dep varchar default null) 
   RETURNS table (_dep varchar, _jour date, _nb_doses INTEGER, _nb_ucd INTEGER)  as
$$
DECLARE id_stock INTEGER;
BEGIN
    select id_stockage_vaccin into id_stock from Stockage_vaccin where date_stockage = jour;

    if dep IS NULL THEN
        RETURN QUERY select code_departement, jour, nb_doses, nb_ucd from stockage_vaccin_departement SV where SV.id_stockage_vaccin = id_stock;
        IF NOT FOUND THEN 
            RAISE NOTICE 'aucune données de stockage pour ce département % ', dep;
        END IF;
        RETURN;
    ELSE
        RETURN QUERY select code_departement, jour, nb_doses, nb_ucd from stockage_vaccin_departement SV where SV.code_departement = dep AND SV.id_stockage_vaccin = id_stock;
        IF NOT FOUND THEN 
            RAISE NOTICE 'aucune données de stockage pour ce département %  et en ce jour %', dep, jour;
        END IF;
        RETURN;
    END IF;
    
END;
$$ LANGUAGE PLPGSQL;

/* Fonction 3: stockage de vaccin par département, type vaccin */

CREATE OR REPLACE FUNCTION select_stockage_vaccin_vaccin_dep(dep varchar, type_vac varchar) 
    RETURNS table (_dep varchar, _vaccin varchar, _nb_doses INTEGER, _nb_ucd INTEGER) as
$$
DECLARE id_type INTEGER;
BEGIN

    select id_vaccin into id_type from vaccin where type_de_vaccin = type_vac;

    RETURN QUERY select code_departement, type_vac, nb_doses, nb_ucd from stockage_vaccin_departement SV where SV.code_departement = dep AND SV.id_vaccin = id_type;
    IF NOT FOUND THEN 
        RAISE NOTICE 'aucune données de stockage pour ce département % ', dep;
    END IF;
    RETURN;
END;
$$ LANGUAGE PLPGSQL;

/* Test de selection */

Select * from stockage_vaccin_departement SD where SD.code_departement = '1' LIMIT 4;

/*  Test d'insertion pour la table stockage_vaccin_departement */ 
\echo avant insertion (modification) d un stockage de vaccin;

SELECT * FROM stockage_vaccin_departement WHERE code_departement = '1' 
    and id_stockage_vaccin IN (select id_stockage_vaccin 
    FROM stockage_vaccin WHERE date_stockage ='2021-02-12') 
    AND id_vaccin IN (SELECT id_vaccin FROM vaccin WHERE type_de_vaccin = 'Pfizer');

select insert_stockage_vaccination_departement('1', '2021-02-12', 'Pfizer', 3, 5);
\echo la donnée est bien insérer dans la base;

SELECT * FROM stockage_vaccin_departement WHERE code_departement = '1' 
    and id_stockage_vaccin IN (select id_stockage_vaccin 
    FROM stockage_vaccin WHERE date_stockage ='2021-02-12') 
    AND id_vaccin IN (SELECT id_vaccin FROM vaccin WHERE type_de_vaccin = 'Pfizer');

select insert_stockage_vaccination_departement('1', '2021-04-20', 'Pfizer', 3, 5);
/* si la donnée exite  déjà dans la table avec le meme code departement et le vaccin 
et la date de stockage*/
select edit_dep_stockage_vaccination_departement('1', '2021-02-12', 'Pfizer', '3');
\echo résultat après modification;
SELECT * FROM stockage_vaccin_departement WHERE code_departement = '3' 
    and id_stockage_vaccin IN (select id_stockage_vaccin 
    FROM stockage_vaccin WHERE date_stockage ='2021-02-12') 
    AND id_vaccin IN (SELECT id_vaccin FROM vaccin WHERE type_de_vaccin = 'Pfizer');


/* Test de séléction */

select * from  select_stockage_vaccin_dep_jour_vaccin('1', '2021-01-22', 'Pfizer');
select * from  select_stockage_vaccin_dep_jour_vaccin('1', '2021-01-23', 'Pfizer');

select * from select_stockage_vaccin_jour_dep('2021-01-22', '1');
select * from select_stockage_vaccin_jour_dep('2021-01-22');
select * from select_stockage_vaccin_vaccin_dep('1', 'Pfizer');

/* Insert , check trigger */
INSERT INTO stockage_vaccin(date_stockage) VALUES ('2021-01-22');

/* avec prepare */
PREPARE insert_into_stockage_vaccin(date) AS
    INSERT INTO stockage_vaccin(date_stockage) VALUES ($1);
EXECUTE insert_into_stockage_vaccin('2025-01-22');

/* avec une date existante déjà */
EXECUTE insert_into_stockage_vaccin('2025-01-22');

/* vérifier si le trigger se déclanche bien on essayant d'insérer une valeur négative*/
INSERT INTO stockage_vaccin_departement VALUES ('1', 1, 1, -3, 5);