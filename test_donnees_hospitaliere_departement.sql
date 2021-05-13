
/* Function 1 : Une fonction qui permet de chercher toutes les données hospitaliere par département */

CREATE OR REPLACE FUNCTION select_donnees_hospi_departement(code_departement VARCHAR) 
        RETURNS SETOF donnees_hospitaliere AS 
$$
BEGIN
    RETURN  QUERY SELECT * FROM donnees_hospitaliere AS D WHERE D.dep = code_departement;
    IF NOT FOUND THEN 
        RAISE NOTICE 'aucune données hospitalere pour ce département % ', code_departement;
    END IF;
    RETURN;
END;
$$ LANGUAGE PLPGSQL;


/* Function 2: Une fonction qui permet de retourner la données hositaliere par jour de chaque département */

CREATE OR REPLACE FUNCTION select_donnees_hospi_departement_jour(code_departement VARCHAR, jourDonne DATE)
        RETURNS SETOF donnees_hospitaliere AS
$$ 
BEGIN
    RETURN QUERY SELECT * FROM donnees_hospitaliere AS D 
                WHERE D.dep = code_departement  AND D.jour = jourDonne;

    IF NOT FOUND THEN
        RAISE NOTICE 'aucune données hospitaliere pour ce département % a ce jour la %', code_departement, jour;
    END IF;
    RETURN;
END;
$$ LANGUAGE PLPGSQL;



/*Function 3: une fonction qui retourne une donnees hopitaliere de département par sexe & jour  */

CREATE OR REPLACE FUNCTION select_donnees_hospi_departement_jour_sexe(code_departement VARCHAR, jourDonne DATE, sexeDonne INTEGER)
        RETURNS SETOF donnees_hospitaliere AS
$$ 
BEGIN
    RETURN QUERY SELECT * FROM donnees_hospitaliere AS D 
                WHERE D.dep = code_departement  AND D.jour = jourDonne AND D.sexe = sexeDonne ;

    IF NOT FOUND THEN
        RAISE NOTICE 'aucune données hospitaliere pour ce département % a ce jour la % et avec ce sexe %', code_departement, jourDonne, sexeDonne;
    END IF;
    RETURN;
END;
$$ LANGUAGE PLPGSQL;

/* Test des Fonctionnalité */

/* Function 1 */
SELECT dep, hosp, rea, HospConv, SSR_USLD, rad, dc FROM select_donnees_hospi_departement('1');
SELECT dep, hosp, rea, HospConv, SSR_USLD, rad, dc FROM select_donnees_hospi_departement('678');


/* Function 2 */

SELECT dep, hosp, rea, HospConv, SSR_USLD, rad, dc FROM select_donnees_hospi_departement_jour('1', '2020-03-18');
SELECT dep, hosp, rea, HospConv, SSR_USLD, rad, dc FROM select_donnees_hospi_departement_jour('4','2020-03-18' );
SELECT dep, hosp, rea, HospConv, SSR_USLD, rad, dc FROM select_donnees_hospi_departement_jour('6',  '2020-03-18');

/* Function 3 */

SELECT dep, hosp, rea, HospConv, SSR_USLD, rad, dc FROM select_donnees_hospi_departement_jour_sexe('1', '2020-03-18', '0');
SELECT dep, hosp, rea, HospConv, SSR_USLD, rad, dc FROM select_donnees_hospi_departement_jour_sexe('4','2020-03-18', '1' );
SELECT dep, hosp, rea, HospConv, SSR_USLD, rad, dc FROM select_donnees_hospi_departement_jour_sexe('6',  '2020-03-18', '2');

/* Function insert Donnee */

SELECT insert_donnee_hospitaliere ('1', 1, '2020-04-12',12, 34, 'NB', 'NB',40, 56);

SELECT insert_donnee_hospitaliere ('1', 1, '2021-04-12',12, 34, 'NB', 'NB',40, 56);

/* Verifier les contraintes imposé sur la table */
INSERT INTO donnees_hospitaliere VALUES ('1', 1, '2029-04-12',12, 34, 'NB', 'NB',-40, -56 );

/* tester le trigger concerné */
INSERT INTO donnees_hospitaliere VALUES ('1', 4, '2029-04-12',12, 34, 'NB', 'NB',40, 56 );