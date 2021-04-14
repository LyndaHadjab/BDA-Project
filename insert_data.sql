COPY adresse_trigger FROM '/home/aurora/Bureau/projetBDD/centres-vaccination.csv' DELIMITER ';' CSV HEADER;

/* Insert INTO departement Table */

COPY Departement FROM '/home/aurora/Bureau/projetBDD/departements-france.csv' DELIMITER ',' CSV HEADER;

/* ADD SOME DEPARTMENT TO THE TABLE DEPARTEMENT  */
INSERT Into Departement(code_departement, nom_departement, code_region, nom_region) VALUES (975, 'Saint-Pierre-et-Miquelon', '05', 'Saint-Pierre-et-Miquelon');
INSERT Into Departement(code_departement, nom_departement, code_region, nom_region) VALUES (977, 'SAINT-BARTHÉLEMY', '07', 'SAINT-BARTHÉLEMY');
INSERT Into Departement(code_departement, nom_departement, code_region, nom_region) VALUES (978, 'Saint-Martin', '08', 'Saint-Martin');

/*  INSERT INTO Test table */

COPY test(id_departement, jour,pop, t) FROM '/home/aurora/Bureau/projetBDD/test-dep-2021-04-04-19h52.csv' DELIMITER ';' CSV HEADER;

/* Insert Into Vaccin Stockage_Vaccin Stockage_Vaccin_Departement Table */

INSERT INTO Vaccin (id_vaccin, type_de_vaccin) VALUES (0, 'Tous vaccins');

COPY stocks_doses_vaccin_trigger(code_departement, departement,type_de_vaccin, nb_doses, nb_ucd,_date) FROM '/home/aurora/Bureau/projetBDD/stocks-es-par-dep.csv' DELIMITER ',' CSV HEADER;

/* Insert into Site_Prelevement_pour_les_Tests table */
COPY Site_Prelevement_pour_les_Tests FROM '/home/aurora/Bureau/projetBDD/sites-prelevements-grand-public.csv' DELIMITER ',' CSV HEADER;

COPY Vaccination FROM '/home/aurora/Bureau/projetBDD/vacsi-tot-v-dep-2021-04-06-19h16.csv' DELIMITER ';' CSV HEADER;


COPY Donnees_Hospitaliere(dep, sexe, jour, hosp, rea, HospConv, SSR_USLD, autres, rad, dc) FROM '/home/aurora/Bureau/projetBDD/donnees-hospitalieres-covid19-2021-04-06-19h06.csv' DELIMITER ';'  CSV HEADER;

COPY Rendez_vous_par_departement_trigger  FROM '/home/aurora/Bureau/projetBDD/2021-04-01-prise-rdv-par-dep.csv' DELIMITER ','  CSV HEADER;

/* Fonctions qui permettent d'inserer , de supprimer de modifier un tuple ds/de la base de donnée*/

/* pour la table  Vaccin */

/* insertion */
CREATE OR REPLACE FUNCTION vaccin_insert(type_vaccin TEXT) RETURNS VOID AS 
$$
DECLARE id INTEGER;
BEGIN
    IF (type_vaccin = '') 
        THEN RAISE 'Le type doit pas etre null'; 
    END IF;

    SELECT id_vaccin INTO id FROM Vaccin WHERE type_de_vaccin = type_vaccin;
    IF (NOT FOUND) THEN INSERT INTO Vaccin (type_de_vaccin) VALUES (type_vaccin);
        ELSE RAISE 'le vaccin % existe  deja dans la base ', type_vaccin;
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* Suppression */
CREATE OR REPLACE FUNCTION vaccin_delete(type_vaccin TEXT) RETURNS VOID AS 
$$
DECLARE id INTEGER;
BEGIN
    SELECT id_vaccin INTO id FROM Vaccin WHERE type_de_vaccin = type_vaccin;
    IF (FOUND) THEN DELETE FROM Vaccin WHERE id_vaccin = id;
        ELSE RAISE 'Le vaccin % n''existe pas dans la table',id;
    END IF;
    
END;
$$  LANGUAGE PLPGSQL;

/* Modification */
CREATE OR REPLACE FUNCTION vaccin_update(type_vaccin TEXT, new_value_type TEXT) RETURNS VOID AS 
$$
DECLARE id INTEGER;
DECLARE test INTEGER;
BEGIN
    IF (new_value_type = '') 
        THEN RAISE 'le nouveau type ne doit pas etre null';
    END IF;

    SELECT id_vaccin INTO id FROM Vaccin WHERE type_de_vaccin = type_vaccin;
    IF (Found) 
        THEN 
            SELECT id_vaccin INTO test FROM Vaccin WHERE type_de_vaccin = new_value_type;
            IF (FOUND) 
                THEN RAISE  'le vaccin avec le nom % existe déjà',new_value_type;
            ELSE UPDATE Vaccin set type_de_vaccin = new_value_type WHERE id_vaccin = id;
            END IF;

    ELSE RAISE  'Le vaccin % n''existe pas dans la table',type_vaccin;
    END IF;
END;
$$  LANGUAGE PLPGSQL;


/* pour la table  departement */

/* insertion */
CREATE OR REPLACE FUNCTION departement_insert(codedepartement TEXT, nomdepartement TEXT, coderegion TEXT, nomregion TEXT) RETURNS VOID AS 
$$
DECLARE code TEXT;
BEGIN
    SELECT code_departement INTO code FROM Departement WHERE code_departement = codedepartement or nom_departement = nomdepartement;
    IF (NOT FOUND) THEN INSERT INTO Departement VALUES (codedepartement, nomdepartement, coderegion, nomregion);
        ELSE RAISE 'le departemtn % existe  deja dans la base avec le nom %', codedepartement, nomdepartement;
    END IF;
END;
$$  LANGUAGE PLPGSQL;


/* suppression par code departement */
CREATE OR REPLACE FUNCTION departement_delete_code(codedepartement TEXT) RETURNS VOID AS 
$$
DECLARE code TEXT;
BEGIN
    SELECT code_departement INTO code FROM Departement WHERE code_departement = codedepartement;
    IF (FOUND) THEN DELETE FROM Departement WHERE code_departement = codedepartement;
        ELSE RAISE 'le departemtn %  n''existe  pas dans la base ', codedepartement;
    END IF;
END;
$$  LANGUAGE PLPGSQL;


/* suppression par nom  du departement */
CREATE OR REPLACE FUNCTION departement_delete_nom(nomdepartement TEXT) RETURNS VOID AS 
$$
DECLARE code TEXT;
BEGIN
    SELECT code_departement INTO code FROM Departement WHERE nom_departement = nomdepartement;
    IF (FOUND) THEN DELETE FROM Departement WHERE code_departement = code;
        ELSE RAISE 'le departemtn  avec le nom % n''existe  pas dans la base ',nomdepartement;
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* Modifier le nom d'un département */
CREATE OR REPLACE FUNCTION departement_update_nom(codedepartement TEXT, nom_departement_new Text) RETURNS VOID AS
$$
DECLARE test Departement%ROWTYPE;
DECLARE test_1 Departement%ROWTYPE;
BEGIN
    SELECT * INTO test FROM Departement WHERE code_departement = codedepartement;
    IF (NOT FOUND) 
        THEN RAISE 'le departement % n''existe pas dans la base ',codedepartement;
    ELSE 
        SELECT * INTO test_1 FROM Departement WHERE nom_departement = nom_departement_new;
        IF (FOUND) 
            THEN RAISE 'le departement % avec le nom % existe déja dans la base ',codedepartement,nom_departement_new;
            ELSE UPDATE Departement set nom_departement = nom_departement_new WHERE code_departement = codedepartement;
        END IF;
    END IF;

END;
$$ LANGUAGE PLPGSQL;

/*Modifier la region d'un département */
CREATE OR REPLACE FUNCTION departement_update_region(codedepartement TEXT, coderegion Text, nomregion TEXT) RETURNS VOID AS
$$
DECLARE test Departement%ROWTYPE;
DECLARE test_1 Departement%ROWTYPE;
BEGIN
    SELECT * INTO test FROM Departement WHERE code_departement = codedepartement;
    IF (NOT FOUND) 
        THEN RAISE 'le departement % n''existe pas dans la base ',codedepartement;
    ELSE 
        SELECT * INTO test_1 FROM Departement WHERE code_region = coderegion AND nom_region = nomregion;
        IF (FOUND) 
            THEN RAISE 'la region avec le code % et le nom % existe déjà dans la base ',coderegion,nomregion;
            ELSE UPDATE Departement set code_region = coderegion, nom_region = nomregion WHERE code_departement = codedepartement;
        END IF;
    END IF;

END;
$$ LANGUAGE PLPGSQL;


/*Ajouter une adresse */

CREATE OR REPLACE FUNCTION adresse_insert(adrnum TEXT, adrvoie TEXT, comcp TEXT, cominsee TEXT, comnom Text) RETURNS VOID AS 
$$
DECLARE id INTEGER;
BEGIN
    SELECT id_adresse INTO id FROM Adresse WHERE adr_num = adrnum AND adr_voie = adrvoie AND com_cp = comcp AND com_insee = cominsee AND  com_nom = comnom ;
    IF (NOT FOUND) THEN INSERT INTO Adresse VALUES (adrnum, adrvoie, comcp, cominsee, comnom);
        ELSE RAISE 'l''adresse  existe  deja dans la base';
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* Suppression d'une adresse */

CREATE OR REPLACE FUNCTION adresse_delete(adrnum TEXT, adrvoie TEXT, comcp TEXT, cominsee TEXT, comnom Text) RETURNS VOID AS 
$$
DECLARE id INTEGER;
BEGIN
    SELECT id_adresse INTO id FROM Adresse WHERE adr_num = adrnum AND adr_voie = adrvoie AND com_cp = comcp AND com_insee = cominsee AND  com_nom = comnom ;
    IF (FOUND) THEN DELETE FROM  Adresse WHERE id_adresse = id;
        ELSE RAISE 'l''adresse  n''existe pas dans la base';
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* suppression d'une adresse par id */

CREATE OR REPLACE FUNCTION  adresse_delete_by_id(id INTEGER) RETURNS VOID AS 
$$
DECLARE element RECORD;
BEGIN
    SELECT * INTO element FROM Adresse WHERE id_adresse = id ;
    IF (FOUND) THEN DELETE FROM  Adresse WHERE id_adresse = id;
        ELSE RAISE 'l''adresse  n''existe pas dans la base';
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* ajouter une vaccination*/

CREATE OR REPLACE FUNCTION vaccination_insert(_dep TEXT, _vaccin INTEGER, _jour DATE, ntotdos1 INTEGER, ntotdos2 INTEGER) RETURNS VOID AS 
$$
DECLARE test_dep VARCHAR;
DECLARE test_vaccin INTEGER;

BEGIN
    IF (ntotdos1 < 0 OR ntotdos2 < 0) 
        THEN  RAISE 'le nombre de dos doit etre supérieure ou égale à zéro'; 
    END IF;

    SELECT code_departement INTO test_dep FROM Departement WHERE code_departement = _dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table Departement',_dep;
    END IF;

    SELECT id_vaccin INTO test_vaccin FROM Vaccin WHERE id_vaccin = _vaccin;
    IF (NOT FOUND) THEN RAISE 'Le vaccin % n''existe pas dans la table Vaccin',_vaccin;
    END IF;

    INSERT INTO Vaccination VALUES (_dep, _vaccin, _jour, ntotdos1, ntotdos2);

END;
$$  LANGUAGE PLPGSQL;

/* supprimer une vaccination*/

CREATE OR REPLACE FUNCTION vaccination_delete(_dep TEXT, _vaccin INTEGER, _jour DATE) RETURNS VOID AS 
$$
DECLARE test RECORD;

BEGIN
    SELECT * INTO test FROM Vaccination WHERE dep = _dep AND vaccin = _vaccin AND jour = _jour;
    IF (NOT FOUND) 
        THEN RAISE 'la donnée n''exite pas dans la table';
    END IF;

    DELETE FROM Vaccination WHERE dep = _dep AND vaccin = _vaccin AND jour = _jour;
END;
$$  LANGUAGE PLPGSQL;

/* Modifier le nombre de dos1 pour un vaccin */
CREATE OR REPLACE FUNCTION vaccination_update_dos1(_dep TEXT, _vaccin INTEGER, _jour DATE, ntotdos1 INTEGER) RETURNS VOID AS 
$$
DECLARE test_dep VARCHAR;
DECLARE ligne RECORD;

BEGIN
    IF (ntotdos1 < 0) 
        THEN  RAISE 'le nombre de dos doit etre supérieure ou égale à zéro'; 
    END IF;

    SELECT code_departement INTO test_dep FROM Departement WHERE code_departement = _dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table Departement',_dep;
    END IF;

    SELECT * INTO ligne FROM Vaccination WHERE dep = _dep AND vaccin = _vaccin AND jour = _jour;
    IF (NOT FOUND) THEN RAISE 'La donnée  n''existe pas dans la table vaccination';
    END IF;

    UPDATE Vaccination SET n_tot_dos1 = ntotdos1 WHERE dep = _dep AND vaccin = _vaccin AND jour = _jour;
END;
$$  LANGUAGE PLPGSQL;

/* Modifier le nombre de dos2 pour un vaccin */
CREATE OR REPLACE FUNCTION vaccination_update_dos2(_dep TEXT, _vaccin INTEGER, _jour DATE, ntotdos2 INTEGER) RETURNS VOID AS 
$$
DECLARE test_dep VARCHAR;
DECLARE ligne RECORD;

BEGIN
    IF (ntotdos2 < 0) 
        THEN  RAISE 'le nombre de dos doit etre supérieure ou égale à zéro'; 
    END IF;

    SELECT code_departement INTO test_dep FROM Departement WHERE code_departement = _dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table Departement',_dep;
    END IF;

    SELECT * INTO ligne FROM Vaccination WHERE dep = _dep AND vaccin = _vaccin AND jour = _jour;
    IF (NOT FOUND) THEN RAISE 'La donnée  n''existe pas dans la table vaccination';
    END IF;

    UPDATE Vaccination SET n_tot_dos2 = ntotdos2 WHERE dep = _dep AND vaccin = _vaccin AND jour = _jour;
END;
$$  LANGUAGE PLPGSQL;
/* ajouter une donnée Test*/

CREATE OR REPLACE FUNCTION test_insert(id_dep TEXT, _jour DATE, _pop INTEGER, _t INTEGER) RETURNS VOID AS 
$$
DECLARE test_dep VARCHAR;
DECLARE ligne RECORD;

BEGIN
    IF (_pop < 0) 
        THEN  RAISE 'la Population doit etre supérieure à zéro'; 
    END IF;

    IF (_t < 0) 
        THEN  RAISE 'le nombre de test doit etre supérieure à zéro'; 
    END IF;

    SELECT code_departement INTO test_dep FROM Departement WHERE code_departement = id_dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table Departement',id_dep;
    END IF;

    SELECT * INTO ligne FROM Test WHERE id_departement = id_dep AND jour = _jour;
    IF (FOUND) 
        THEN RAISE 'la donnée existe déjà dans la table Test';
    END IF;

    INSERT INTO Test VALUES (id_dep, _jour, _pop, _t);

END;
$$  LANGUAGE PLPGSQL;

/* supprimer une donnée Test*/

CREATE OR REPLACE FUNCTION test_delete(id_dep TEXT, _jour DATE) RETURNS VOID AS 
$$
DECLARE test RECORD;

BEGIN
    SELECT * INTO test FROM Test WHERE id_departement = id_dep AND jour = _jour;
    IF (NOT FOUND) 
        THEN RAISE 'la donnée n''exite pas dans la table';
    END IF;

    DELETE FROM Test WHERE id_departement = id_dep AND jour = _jour;
END;
$$  LANGUAGE PLPGSQL;


/* modifier la pop et le nombre de test t pour une donner Test*/

CREATE OR REPLACE FUNCTION test_update(id_dep TEXT, _jour DATE, _pop INTEGER, _t INTEGER) RETURNS VOID AS 
$$
DECLARE test_dep VARCHAR;
DECLARE ligne RECORD;

BEGIN
    IF (_pop < 0) 
        THEN  RAISE 'la Population doit etre supérieure à zéro'; 
    END IF;

    IF (_t < 0) 
        THEN  RAISE 'le nombre de test doit etre supérieure à zéro'; 
    END IF;

    SELECT code_departement INTO test_dep FROM Departement WHERE code_departement = id_dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table Departement',id_dep;
    END IF;

    SELECT * INTO ligne FROM Test WHERE id_departement = id_dep AND jour = _jour;
    IF (NOT FOUND) 
        THEN RAISE 'la donnée n''existe pas dans la table Test';
    END IF;

    Update Test set pop = _pop , t = _t WHERE id_departement = id_dep AND jour = _jour;

END;
$$  LANGUAGE PLPGSQL;


/*Ajouter le nombre de test effectuer pour un département à une date donnée */

CREATE OR REPLACE FUNCTION test_add_t_number(id_dep TEXT, _jour DATE, new_t INTEGER) RETURNS VOID AS 
$$
DECLARE old_t INTEGER;
BEGIN
    IF (new_t < 0) 
        THEN  RAISE 'le nombre de test à ajouter doit etre supérieure à zéro'; 
    END IF;

    SELECT t INTO old_t FROM Test WHERE id_departement = id_dep AND jour = _jour;
    IF (NOT FOUND) 
        THEN RAISE 'la donnée dep = %, jour = % n''existe pas dans la table Test',id_dep, _jour;
    END IF;

    Update Test set t = old_t + new_t WHERE id_departement = id_dep AND jour = _jour;

END;
$$  LANGUAGE PLPGSQL;


/*soustraire le nombre de test éffectuer dans un département à une date donnée */

CREATE OR REPLACE FUNCTION test_sub_t_number(id_dep TEXT, _jour DATE, new_t INTEGER) RETURNS VOID AS 
$$
DECLARE old_t INTEGER;
BEGIN
    IF (new_t < 0) 
        THEN  RAISE 'le nombre de test à soustraire doit etre supérieure à zéro'; 
    END IF;

    SELECT t INTO old_t FROM Test WHERE id_departement = id_dep AND jour = _jour;
    
    IF (NOT FOUND) 
        THEN RAISE 'la donnée dep = %, jour = % n''existe pas dans la table Test',id_dep, _jour;
    END IF;

    IF (old_t < new_t) 
        THEN RAISE 'le nombre % à soustraire doit etre inférieure au nombre de test déjà renseigné %',new_t,old_t;
    END IF;

    Update Test set t = old_t - new_t WHERE id_departement = id_dep AND jour = _jour;

END;
$$  LANGUAGE PLPGSQL;


/*Une fonction pour inserer une données hospitaliere */

CREATE OR REPLACE FUNCTION insert_donnee_hospitaliere(depDonnee varchar, sexeDonnee INTEGER, 
jourDonnee DATE, hospDonnee INTEGER, reaDonnee INTEGER, HospConvDonnee VARCHAR,
        SSRUSLDDonnee varchar, radDonne INTEGER, dcDonnee INTEGER
        ) RETURNS void AS $$
BEGIN
    IF (hospDonnee < 0) 
        THEN RAISE 'le nombre d''hosp doit etre supérieure ou égale à zéro';
    END IF;
     IF (reaDonnee < 0) 
        THEN RAISE 'le nombre de rea doit etre supérieure ou égale à zéro';
    END IF;
    IF (radDonne < 0) 
        THEN RAISE 'le nombre de rad doit etre supérieure ou égale à zéro';
    END IF;
     IF (dcDonnee < 0) 
        THEN RAISE 'le nombre de dc doit etre supérieure ou égale à zéro';
    END IF;

    PERFORM * FROM Donnees_Hospitaliere D WHERE D.dep = depDonnee  
                        AND D.jour = jourDonnee AND D.sexe = sexeDonnee ;
    IF NOT FOUND THEN 
        INSERT INTO Donnees_Hospitaliere VALUES (depDonnee, sexeDonnee, jourDonnee,hospDonnee, 
            reaDonnee, HospConvDonnee, SSRUSLDDonnee, radDonne, dcDonnee);
    ELSE 
        RAISE 'La donnee existe déja avec departement % et jour % et sexe %', depDonnee, jourDonnee, sexeDonnee;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

/* ajouter un rendez vous par département*/
CREATE OR REPLACE FUNCTION rendez_vous_par_departement_add(
                        dep VARCHAR, rangvaccinal INTEGER, datedebutsemaine DATE, _nb INTEGER) RETURNS VOID AS
$$
DECLARE  ligne RECORD;
DECLARE test RECORD;
BEGIN
    IF (_nb < 0) 
        THEN RAISE 'erreur le nombre de rendez vous doit etre supérieure ou égale à zéro';
    END IF;

    select * INTO ligne FROM Rendez_vous_par_departement WHERE id_departement = dep AND rang_vaccinal = rangvaccinal
            AND date_debut_semaine = datedebutsemaine;

    IF (NOT FOUND) 
        THEN SELECT * INTO  test FROM Departement WHERE code_departement = dep;
            IF (NOT FOUND) 
                THEN RAISE 'Le département avce le code % n''existe  pas dans notre base',dep;
            ELSE INSERT INTO Rendez_vous_par_departement VALUES (dep, rangvaccinal, datedebutsemaine, _nb);
            END IF;

    ELSE  UPDATE Rendez_vous_par_departement set nb = nb + _nb WHERE  id_departement = dep AND rang_vaccinal = rangvaccinal
            AND date_debut_semaine = datedebutsemaine;
    END IF;
END;
$$ LANGUAGE PLPGSQL;