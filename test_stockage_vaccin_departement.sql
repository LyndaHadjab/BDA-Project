/* Function search selon le type de vaccin / selon la date / selon le départemen*/

CREATE OR REPLACE FUNCTION select_stockage_vaccin_dep_jour_date(dep varchar, jour DATE, 
            type_vac varchar) RETURNS SETOF stockage_vaccin_departement as
$$
DECLARE id_stock INTEGER;
DECLARE id_type INTEGER;
BEGIN
    select id_stockage_vaccin into id_stock from Stockage_vaccin where date_stockage = jour;

    select id_vaccin into id_type from vaccin where type_de_vaccin = type_vac;

    RETURN QUERY select * from stockage_vaccin_departement SV where SV.code_departement = dep AND SV.id_stockage_vaccin = id_stock
        AND SV.id_vaccin = id_type;
    IF NOT FOUND THEN 
        RAISE NOTICE 'aucune données de stockage pour ce département % ', dep;
    END IF;
    RETURN;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION select_stockage_vaccin_jour_dep(jour DATE, dep varchar default null) RETURNS SETOF stockage_vaccin_departement as
$$
DECLARE id_stock INTEGER;
BEGIN
    select id_stockage_vaccin into id_stock from Stockage_vaccin where date_stockage = jour;

    if dep IS NULL THEN
        RETURN QUERY select * from stockage_vaccin_departement SV where SV.id_stockage_vaccin = id_stock;
        IF NOT FOUND THEN 
            RAISE NOTICE 'aucune données de stockage pour ce département % ', dep;
        END IF;
        RETURN;
    ELSE
        RETURN QUERY select * from stockage_vaccin_departement SV where SV.code_departement = dep AND SV.id_stockage_vaccin = id_stock;
        IF NOT FOUND THEN 
            RAISE NOTICE 'aucune données de stockage pour ce département %  et en ce jour %', dep, jour;
        END IF;
        RETURN;
    END IF;
    
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION select_stockage_vaccin_vaccin_dep(dep varchar, type_vac varchar) RETURNS SETOF stockage_vaccin_departement as
$$
DECLARE id_type INTEGER;
BEGIN

    select id_vaccin into id_type from vaccin where type_de_vaccin = type_vac;

    RETURN QUERY select * from stockage_vaccin_departement SV where SV.code_departement = dep AND SV.id_vaccin = id_type;
    IF NOT FOUND THEN 
        RAISE NOTICE 'aucune données de stockage pour ce département % ', dep;
    END IF;
    RETURN;
END;
$$ LANGUAGE PLPGSQL;

/* Test de selection */

Select * from stockage_vaccin_departement SD where SD.code_departement = '1' LIMIT 4;
/*Select * from stockage_vaccin_departement SD where SD.code_departement = '1' AND  LIMIT 4;*/


/*  Test d'insertion pour la table stockage_vaccin_departement */ 

select insert_stockage_vaccination_departement('1', '2021-02-12', 'Pfizer', 3, 5);
select insert_stockage_vaccination_departement('1', '2021-04-20', 'Pfizer', 3, 5);