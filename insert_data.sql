\set path '/home/aurora/Bureau/projetBDD/DonneesCsv/'
\set file 'centres-vaccination.csv'
\set pf :path:file 
\set quoted_myvariable '\'' :pf '\''

COPY adresse_trigger FROM :quoted_myvariable DELIMITER ';' CSV HEADER;

/* Insert INTO departement Table */
\set file 'departements-france.csv'
\set pf :path:file 
\set quoted_myvariable '\'' :pf '\''

COPY departement FROM :quoted_myvariable DELIMITER ',' CSV HEADER;

/* ADD SOME DEPARTMENT TO THE TABLE departement  */
INSERT Into departement(code_departement, nom_departement, code_region, nom_region) VALUES (975, 'Saint-Pierre-et-Miquelon', '05', 'Saint-Pierre-et-Miquelon');
INSERT Into departement(code_departement, nom_departement, code_region, nom_region) VALUES (977, 'SAINT-BARTHÉLEMY', '07', 'SAINT-BARTHÉLEMY');
INSERT Into departement(code_departement, nom_departement, code_region, nom_region) VALUES (978, 'Saint-Martin', '08', 'Saint-Martin');

/*  INSERT INTO test table */
\set file 'test-dep-2021-04-04-19h52.csv'
\set pf :path:file 
\set quoted_myvariable '\'' :pf '\''

COPY test(id_departement, jour,pop, t) FROM :quoted_myvariable DELIMITER ';' CSV HEADER;

/* Insert Into vaccin Stockage_vaccin stockage_vaccin_departement Table */

INSERT INTO vaccin (id_vaccin, type_de_vaccin) VALUES (0, 'Tous vaccins');

\set file 'stocks-es-par-dep.csv'
\set pf :path:file 
\set quoted_myvariable '\'' :pf '\''

COPY stocks_doses_vaccin_trigger(code_departement, departement,type_de_vaccin, nb_doses, nb_ucd,_date) FROM :quoted_myvariable DELIMITER ',' CSV HEADER;
INSERT INTO vaccin (id_vaccin, type_de_vaccin) VALUES (4, 'Janssen');

/* Insert into Site_Prelevement_pour_les_tests table */
\set file 'sites-prelevements-grand-public.csv'
\set pf :path:file 
\set quoted_myvariable '\'' :pf '\''

COPY site_prelevement_pour_les_tests FROM  :quoted_myvariable DELIMITER ',' CSV HEADER;

\set file 'vacsi-tot-v-dep-2021-05-13-19h09.csv'
\set pf :path:file 
\set quoted_myvariable '\'' :pf '\''

COPY vaccination FROM :quoted_myvariable DELIMITER ';' CSV HEADER;

\set file 'donnees-hospitalieres-covid19-2021-04-06-19h06.csv'
\set pf :path:file 
\set quoted_myvariable '\'' :pf '\''

COPY donnees_hospitaliere(dep, sexe, jour, hosp, rea, HospConv, SSR_USLD, autres, rad, dc) FROM :quoted_myvariable DELIMITER ';'  CSV HEADER;

\set file '2021-04-01-prise-rdv-par-dep.csv'
\set pf :path:file 
\set quoted_myvariable '\'' :pf '\''

COPY rendez_vous_par_departement_trigger  FROM :quoted_myvariable DELIMITER ','  CSV HEADER;

/* Fonctions qui permettent d'inserer , de supprimer de modifier un tuple ds/de la base de donnée*/

/* pour la table  vaccin */

/* insertion */
CREATE OR REPLACE FUNCTION vaccin_insert(type_vaccin TEXT) RETURNS VOID AS 
$$
DECLARE id INTEGER;
BEGIN
    IF (type_vaccin = '') 
        THEN RAISE 'Le type doit pas etre null'; 
    END IF;

    SELECT id_vaccin INTO id FROM vaccin WHERE type_de_vaccin = type_vaccin;
    IF (NOT FOUND) THEN INSERT INTO vaccin (type_de_vaccin) VALUES (type_vaccin);
        ELSE RAISE 'le vaccin % existe  deja dans la base ', type_vaccin;
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* Suppression */
CREATE OR REPLACE FUNCTION vaccin_delete(type_vaccin TEXT) RETURNS VOID AS 
$$
DECLARE id INTEGER;
BEGIN
    SELECT id_vaccin INTO id FROM vaccin WHERE type_de_vaccin = type_vaccin;
    IF (FOUND) THEN DELETE FROM vaccin WHERE id_vaccin = id;
        ELSE RAISE 'Le vaccin % n''existe pas dans la table',type_vaccin;
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

    SELECT id_vaccin INTO id FROM vaccin WHERE type_de_vaccin = type_vaccin;
    IF (Found) 
        THEN 
            SELECT id_vaccin INTO test FROM vaccin WHERE type_de_vaccin = new_value_type;
            IF (FOUND) 
                THEN RAISE  'le vaccin avec le nom % existe déjà',new_value_type;
            ELSE UPDATE vaccin set type_de_vaccin = new_value_type WHERE id_vaccin = id;
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
    SELECT code_departement INTO code FROM departement WHERE code_departement = codedepartement or nom_departement = nomdepartement;
    IF (NOT FOUND) THEN INSERT INTO departement VALUES (codedepartement, nomdepartement, coderegion, nomregion);
        ELSE RAISE 'le departemtn % existe  déjà dans la base avec le nom %', codedepartement, nomdepartement;
    END IF;
END;
$$  LANGUAGE PLPGSQL;


/* suppression par code departement */
CREATE OR REPLACE FUNCTION departement_delete_code(codedepartement TEXT) RETURNS VOID AS 
$$
DECLARE code TEXT;
BEGIN
    SELECT code_departement INTO code FROM departement WHERE code_departement = codedepartement;
    IF (FOUND) THEN DELETE FROM departement WHERE code_departement = codedepartement;
        ELSE RAISE 'le departemtn %  n''existe  pas dans la base ', codedepartement;
    END IF;
END;
$$  LANGUAGE PLPGSQL;


/* suppression par nom  du departement */
CREATE OR REPLACE FUNCTION departement_delete_nom(nomdepartement TEXT) RETURNS VOID AS 
$$
DECLARE code TEXT;
BEGIN
    SELECT code_departement INTO code FROM departement WHERE nom_departement = nomdepartement;
    IF (FOUND) THEN DELETE FROM departement WHERE code_departement = code;
        ELSE RAISE 'le departemtn  avec le nom % n''existe  pas dans la base ',nomdepartement;
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* Modifier le nom d'un département */
CREATE OR REPLACE FUNCTION departement_update_nom(codedepartement TEXT, nom_departement_new Text) RETURNS VOID AS
$$
DECLARE test departement%ROWTYPE;
DECLARE test_1 departement%ROWTYPE;
BEGIN
    SELECT * INTO test FROM departement WHERE code_departement = codedepartement;
    IF (NOT FOUND) 
        THEN RAISE 'le departement % n''existe pas dans la base ',codedepartement;
    ELSE 
        SELECT * INTO test_1 FROM departement WHERE nom_departement = nom_departement_new;
        IF (FOUND) 
            THEN RAISE 'le departement % avec le nom % existe déja dans la base ',codedepartement,nom_departement_new;
            ELSE UPDATE departement set nom_departement = nom_departement_new WHERE code_departement = codedepartement;
        END IF;
    END IF;

END;
$$ LANGUAGE PLPGSQL;

/*Modifier la region d'un département */
CREATE OR REPLACE FUNCTION departement_update_region(codedepartement TEXT, coderegion Text, nomregion TEXT) RETURNS VOID AS
$$
DECLARE test departement%ROWTYPE;
DECLARE test_1 departement%ROWTYPE;
BEGIN
    SELECT * INTO test FROM departement WHERE code_departement = codedepartement;
    IF (NOT FOUND) 
        THEN RAISE 'le departement % n''existe pas dans la base ',codedepartement;
    ELSE 
        SELECT * INTO test_1 FROM departement WHERE code_region = coderegion AND nom_region = nomregion;
        IF (FOUND) 
            THEN RAISE 'la region avec le code % et le nom % existe déjà dans la base ',coderegion,nomregion;
            ELSE UPDATE departement set code_region = coderegion, nom_region = nomregion WHERE code_departement = codedepartement;
        END IF;
    END IF;

END;
$$ LANGUAGE PLPGSQL;

/* Pour la table adresse */
/*Ajouter une adresse */

CREATE OR REPLACE FUNCTION adresse_insert(adrnum TEXT, adrvoie TEXT, comcp TEXT, cominsee TEXT, comnom Text) RETURNS VOID AS 
$$
DECLARE id INTEGER;
BEGIN
    SELECT id_adresse INTO id FROM adresse WHERE adr_num = adrnum AND adr_voie = adrvoie AND com_cp = comcp AND com_insee = cominsee AND  com_nom = comnom ;
    IF (NOT FOUND) THEN 
        INSERT INTO adresse(adr_num, adr_voie, com_cp, com_insee, com_nom) VALUES (adrnum, adrvoie, comcp, cominsee, comnom);
    ELSE RAISE 'l''adresse  existe  deja dans la base';
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* Suppression d'une adresse */

CREATE OR REPLACE FUNCTION adresse_delete(adrnum TEXT, adrvoie TEXT, comcp TEXT, cominsee TEXT, comnom Text) RETURNS VOID AS 
$$
DECLARE id INTEGER;
BEGIN
    SELECT id_adresse INTO id FROM adresse WHERE adr_num = adrnum AND adr_voie = adrvoie AND com_cp = comcp AND com_insee = cominsee AND  com_nom = comnom ;
    IF (FOUND) THEN DELETE FROM  adresse WHERE id_adresse = id;
        ELSE RAISE 'l''adresse  n''existe pas dans la base';
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* suppression d'une adresse par id */

CREATE OR REPLACE FUNCTION  adresse_delete_by_id(id INTEGER) RETURNS VOID AS 
$$
DECLARE element RECORD;
BEGIN
    SELECT * INTO element FROM adresse WHERE id_adresse = id ;
    IF (FOUND) THEN DELETE FROM  adresse WHERE id_adresse = id;
        ELSE RAISE 'l''adresse  n''existe pas dans la base';
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* Pour la table vaccination */

/* ajouter une vaccination*/
CREATE OR REPLACE FUNCTION vaccination_insert(_dep TEXT, type_vaccin VARCHAR, _jour DATE, ntotdos1 INTEGER, ntotdos2 INTEGER) RETURNS VOID AS 
$$
DECLARE test_dep VARCHAR;
DECLARE test_vaccin INTEGER;
DECLARE test_exist VARCHAR;
BEGIN
    IF (ntotdos1 < 0 OR ntotdos2 < 0) 
        THEN  RAISE 'le nombre de dos doit etre supérieure ou égale à zéro'; 
    END IF;

    SELECT code_departement INTO test_dep FROM departement WHERE code_departement = _dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table departement',_dep;
    END IF;

    SELECT id_vaccin INTO test_vaccin FROM vaccin WHERE type_de_vaccin = type_vaccin;
    IF (NOT FOUND) THEN RAISE 'Le vaccin % n''existe pas dans la table vaccin',_vaccin;
    END IF;

    SELECT _dep INTO test_exist FROM vaccination WHERE dep = _dep AND jour = _jour AND vaccin = test_vaccin;
    IF (NOT FOUND) 
        THEN  INSERT INTO vaccination VALUES (_dep, test_vaccin, _jour, ntotdos1, ntotdos2);
    ELSE UPDATE vaccination set n_tot_dos1 = n_tot_dos1 + ntotdos1,   n_tot_dos2 = n_tot_dos2 + ntotdos2 
                WHERE dep = _dep AND jour = _jour AND vaccin = test_vaccin;
    END IF;
END;
$$  LANGUAGE PLPGSQL;

/* supprimer une vaccination*/

CREATE OR REPLACE FUNCTION vaccination_delete(_dep TEXT, type_vaccin VARCHAR, _jour DATE) RETURNS VOID AS 
$$
DECLARE test RECORD;
DECLARE id INTEGER;

BEGIN
    SELECT id_vaccin INTO id FROM vaccin WHERE type_de_vaccin = type_vaccin;

    SELECT * INTO test FROM vaccination WHERE dep = _dep AND vaccin = id AND jour = _jour;
    IF (NOT FOUND) 
        THEN RAISE 'la donnée n''exite pas dans la table';
    END IF;

    DELETE FROM vaccination WHERE dep = _dep AND vaccin = id AND jour = _jour;
END;
$$  LANGUAGE PLPGSQL;

/* Modifier le nombre de dos1 */
CREATE OR REPLACE FUNCTION vaccination_update_dos1(_dep TEXT, type_vaccin VARCHAR, _jour DATE, ntotdos1 INTEGER) RETURNS VOID AS 
$$
DECLARE test_dep VARCHAR;
DECLARE ligne RECORD;
DECLARE id INTEGER;
BEGIN
    IF (ntotdos1 < 0) 
        THEN  RAISE 'le nombre de dos doit etre supérieure ou égale à zéro'; 
    END IF;

    SELECT code_departement INTO test_dep FROM departement WHERE code_departement = _dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table departement',_dep;
    END IF;

    SELECT id_vaccin INTO id FROM vaccin WHERE type_de_vaccin = type_vaccin;

    SELECT * INTO ligne FROM vaccination WHERE dep = _dep AND vaccin = id AND jour = _jour;
    IF (NOT FOUND) THEN RAISE 'La donnée  n''existe pas dans la table vaccination';
    END IF;

    UPDATE vaccination SET n_tot_dos1 = ntotdos1 WHERE dep = _dep AND vaccin = id AND jour = _jour;
END;
$$  LANGUAGE PLPGSQL;

/* Modifier le nombre de dos2 pour un vaccin */
CREATE OR REPLACE FUNCTION vaccination_update_dos2(_dep TEXT, type_vaccin VARCHAR, _jour DATE, ntotdos2 INTEGER) RETURNS VOID AS 
$$
DECLARE test_dep VARCHAR;
DECLARE ligne RECORD;
DECLARE id INTEGER;

BEGIN
    IF (ntotdos2 < 0) 
        THEN  RAISE 'le nombre de dos doit etre supérieure ou égale à zéro'; 
    END IF;

    SELECT code_departement INTO test_dep FROM departement WHERE code_departement = _dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table departement',_dep;
    END IF;

    SELECT id_vaccin INTO id FROM vaccin WHERE type_de_vaccin = type_vaccin;

    SELECT * INTO ligne FROM vaccination WHERE dep = _dep AND vaccin = id AND jour = _jour;
    IF (NOT FOUND) THEN RAISE 'La donnée  n''existe pas dans la table vaccination';
    END IF;

    UPDATE vaccination SET n_tot_dos2 = ntotdos2 WHERE dep = _dep AND vaccin = id AND jour = _jour;
END;
$$  LANGUAGE PLPGSQL;
/* ajouter une donnée test*/

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

    SELECT code_departement INTO test_dep FROM departement WHERE code_departement = id_dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table departement',id_dep;
    END IF;

    SELECT * INTO ligne FROM test WHERE id_departement = id_dep AND jour = _jour;
    IF (FOUND) 
        THEN RAISE 'la donnée existe déjà dans la table test';
    END IF;

    INSERT INTO test VALUES (id_dep, _jour, _pop, _t);

END;
$$  LANGUAGE PLPGSQL;

/* supprimer une donnée test*/

CREATE OR REPLACE FUNCTION test_delete(id_dep TEXT, _jour DATE) RETURNS VOID AS 
$$
DECLARE test RECORD;

BEGIN
    SELECT * INTO test FROM test WHERE id_departement = id_dep AND jour = _jour;
    IF (NOT FOUND) 
        THEN RAISE 'la donnée n''exite pas dans la table';
    END IF;

    DELETE FROM test WHERE id_departement = id_dep AND jour = _jour;
END;
$$  LANGUAGE PLPGSQL;


/* modifier la pop et le nombre de test t pour une donner test*/

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

    SELECT code_departement INTO test_dep FROM departement WHERE code_departement = id_dep;
    IF (NOT FOUND) 
        THEN RAISE 'le département % n''existe pas dans la table departement',id_dep;
    END IF;

    SELECT * INTO ligne FROM test WHERE id_departement = id_dep AND jour = _jour;
    IF (NOT FOUND) 
        THEN RAISE 'la donnée n''existe pas dans la table test';
    END IF;

    Update test set pop = _pop , t = _t WHERE id_departement = id_dep AND jour = _jour;

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

    SELECT t INTO old_t FROM test WHERE id_departement = id_dep AND jour = _jour;
    IF (NOT FOUND) 
        THEN RAISE 'la donnée dep = %, jour = % n''existe pas dans la table test',id_dep, _jour;
    END IF;

    Update test set t = old_t + new_t WHERE id_departement = id_dep AND jour = _jour;

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

    SELECT t INTO old_t FROM test WHERE id_departement = id_dep AND jour = _jour;
    
    IF (NOT FOUND) 
        THEN RAISE 'la donnée dep = %, jour = % n''existe pas dans la table test',id_dep, _jour;
    END IF;

    IF (old_t < new_t) 
        THEN RAISE 'le nombre % à soustraire doit etre inférieure au nombre de test déjà renseigné %',new_t,old_t;
    END IF;

    Update test set t = old_t - new_t WHERE id_departement = id_dep AND jour = _jour;

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

    PERFORM * FROM donnees_hospitaliere D WHERE D.dep = depDonnee  
                        AND D.jour = jourDonnee AND D.sexe = sexeDonnee ;
    IF NOT FOUND THEN 
        INSERT INTO donnees_hospitaliere VALUES (depDonnee, sexeDonnee, jourDonnee,hospDonnee, 
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

     IF (rangvaccinal < 0) 
        THEN RAISE 'erreur le rang vaccinal doit etre supérieure ou égale à zéro';
    END IF;

    select * INTO ligne FROM rendez_vous_par_departement WHERE id_departement = dep AND rang_vaccinal = rangvaccinal
            AND date_debut_semaine = datedebutsemaine;

    IF (NOT FOUND) 
        THEN SELECT * INTO  test FROM departement WHERE code_departement = dep;
            IF (NOT FOUND) 
                THEN RAISE 'Le département avce le code % n''existe  pas dans notre base',dep;
            ELSE INSERT INTO rendez_vous_par_departement VALUES (dep, rangvaccinal, datedebutsemaine, _nb);
            END IF;

    ELSE  UPDATE rendez_vous_par_departement set nb = nb + _nb WHERE  id_departement = dep AND rang_vaccinal = rangvaccinal
            AND date_debut_semaine = datedebutsemaine;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

/* La Table stockage_vaccin_par_departement */
/* 1: Insertion */
CREATE OR REPLACE FUNCTION insert_stockage_vaccination_departement(dep varchar, jour Date, type_vaccin varchar,
                nb_dosesV INTEGER, nb_ucdV INTEGER) RETURNS void as 
$$
DECLARE id_stockage INTEGER;
DECLARE vaccin_id INTEGER;
BEGIN
    /* si le type de vaccin n'existe pas alors c est pas possible d'inserer */
    PERFORM type_de_vaccin FROM vaccin WHERE type_de_vaccin = type_vaccin ;

    IF NOT FOUND THEN 
        raise exception 'Le vaccin % n existe pas', type_vaccin;
    ELSE 
        /* verifier si on a déja une date présente dans la table avec le département */
        PERFORM id_stockage_vaccin FROM Stockage_vaccin WHERE  date_stockage = jour;

        IF NOT FOUND THEN
            INSERT INTO Stockage_vaccin(date_stockage) VALUES (jour) RETURNING id_stockage_vaccin into id_stockage;
            
            Select id_vaccin into vaccin_id from vaccin WHERE type_de_vaccin = type_vaccin; 

            INSERT INTO stockage_vaccin_departement VALUES (dep, id_stockage, vaccin_id, nb_dosesV, nb_ucdV);
        ELSE
            Select id_vaccin into vaccin_id from vaccin WHERE type_de_vaccin = type_vaccin; 

            Update stockage_vaccin_departement set nb_doses = nb_doses + nb_dosesV , nb_ucd = nb_ucd + nb_ucdV 
                WHERE code_departement = dep AND id_vaccin = vaccin_id AND jour = jour;
        END IF;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

/* Table lieu de vaccination*/
/* Insert */
CREATE OR REPLACE FUNCTION insert_lieu_de_vaccination(
        _gid TEXT, _nom TEXT, _id_adr TEXT,
        _id_adresse INTEGER, _lat_coor1 TEXT, _long_coor1 TEXT,
        _structure_siren TEXT, _structure_type TEXT, _structure_rais TEXT, 
        _id_structure_adresse INTEGER, _lieu_accessibilite TEXT,_rdv_lundi TEXT,
        _rdv_mardi TEXT, _rdv_mercredi TEXT, _rdv_jeudi TEXT, 
        _rdv_vendredi TEXT, _rdv_samedi TEXT, _rdv_dimanche TEXT, 
        _rdv TEXT, _date_fermeture DATE, _date_ouverture DATE, 
        _rdv_tel TEXT, _rdv_consultation_prevaccination Boolean) RETURNS void as 
$$
DECLARE ligne_1 RECORD;
DECLARE ligne_2 RECORD;
BEGIN

   SELECT *  INTO ligne_1 FROM lieu_de_vaccination  WHERE gid = _gid;

   IF (FOUND) THEN RAISE 'Le gid % existe déjà dans la base de donnée ', _gid ;
   END IF;
   
   SELECT * INTO ligne_2 FROM adresse WHERE id_adresse = _id_adresse;

   IF (NOT FOUND) THEN RAISE 'l''adresse  % n''existe pas dans la base de donnée ', _id_adresse ;
   END IF;

   SELECT * INTO ligne_2 FROM adresse WHERE id_adresse = _id_structure_adresse;

   IF (NOT FOUND) THEN RAISE 'l''adresse  % n''existe pas dans la base de donnée ', _id_structure_adresse ;
   END IF;

   INSERT INTO lieu_de_vaccination VALUES (
            _gid, _nom, _id_adr, 
            _id_adresse, _lat_coor1, _long_coor1,
			_structure_siren,_structure_type, _structure_rais, 
            _id_structure_adresse, _lieu_accessibilite, _rdv_lundi,
            _rdv_mardi, _rdv_mercredi, _rdv_jeudi, 
            _rdv_vendredi, _rdv_samedi, _rdv_dimanche, 
            _rdv, _date_fermeture, _date_ouverture, 
            _rdv_tel, _rdv_consultation_prevaccination
            );
END;
$$ LANGUAGE PLPGSQL;