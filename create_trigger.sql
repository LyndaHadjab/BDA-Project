CREATE OR REPLACE FUNCTION departement_trigger_edit_code() RETURNS TRIGGER AS
$$
BEGIN
	New.code_departement = LTRIM(New.code_departement, '0');
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER departement_audit
	BEFORE INSERT OR UPDATE OF code_departement
	ON departement
	FOR EACH ROW
	EXECUTE PROCEDURE departement_trigger_edit_code(); 


CREATE OR REPLACE FUNCTION test_trigger_edit_code() RETURNS TRIGGER AS
$$
BEGIN
	New.id_departement = LTRIM(New.id_departement, '0');
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER test_audit
	BEFORE INSERT OR UPDATE OF id_departement
	ON test
	FOR EACH ROW
	EXECUTE PROCEDURE test_trigger_edit_code(); 


CREATE OR REPLACE FUNCTION adresse_import_csv() RETURNS TRIGGER AS 
$$
	DECLARE id_adr INTEGER;
	DECLARE id_structure_adresse INTEGER;
	DECLARE ligne INTEGER;
BEGIN 
	IF TG_OP = 'INSERT' THEN 
		INSERT INTO adresse (adr_num, adr_voie, com_cp, com_insee, com_nom)
		   VALUES (NEW.adr_num, NEW.adr_voie, NEW.com_cp, NEW.com_insee, NEW.com_nom) RETURNING adresse.id_adresse INTO id_adr;

		SELECT id_adresse INTO ligne FROM  adresse WHERE NEW.structure_voie = adr_voie AND NEW.structure_cp  = com_cp
		   AND NEW.structure_insee = com_insee AND NEW.structure_com = com_nom;

		/*raise notice 'Value found: % %', ligne,id_adr ;*/

		IF FOUND THEN  id_structure_adresse = ligne;
				 ELSE  INSERT INTO adresse (adr_num, adr_voie, com_cp, com_insee, com_nom)
		   				VALUES (NEW.structure_num, NEW.structure_voie, NEW.structure_cp, 
		   					NEW.structure_insee, NEW.structure_com) RETURNING adresse.id_adresse INTO id_structure_adresse;
	
		END IF;

		INSERT INTO lieu_de_vaccination (gid, nom, arrete_pref_numero, xy_precis, id_adr, id_adresse, lat_coor1, long_coor1,
			structure_siren, structure_type, structure_rais, id_structure_adresse, _edit_datemaj, lieu_accessibilite,
			rdv_lundi,rdv_mardi, rdv_mercredi, rdv_jeudi, rdv_vendredi, rdv_samedi, rdv_dimanche, rdv, date_fermeture,
			date_ouverture, rdv_site_web, rdv_tel, rdv_tel2, rdv_modalites, rdv_consultation_prevaccination, centre_svi_repondeur, 
			centre_fermeture, reserve_professionels_sante) VALUES (New.gid, New.nom, New.arrete_pref_numero, New.xy_precis, New.id_adr, id_adr, New.lat_coor1, New.long_coor1,
			New.structure_siren, New.structure_type, New.structure_rais, id_structure_adresse, New._edit_datemaj, New.lieu_accessibilite,
			New.rdv_lundi,New.rdv_mardi, New.rdv_mercredi, New.rdv_jeudi, New.rdv_vendredi, New.rdv_samedi, New.rdv_dimanche, New.rdv, New.date_fermeture,
			New.date_ouverture, New.rdv_site_web, New.rdv_tel, New.rdv_tel2, New.rdv_modalites, New.rdv_consultation_prevaccination, New.centre_svi_repondeur, 
			New.centre_fermeture, New.reserve_professionels_sante);

	END IF;

	RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER adresse_audit 
	BEFORE INSERT OR UPDATE 
	ON adresse_trigger
	FOR EACH ROW EXECUTE PROCEDURE adresse_import_csv();


CREATE OR REPLACE FUNCTION stocks_doses_vaccin_import_csv() RETURNS TRIGGER AS 
$$
DECLARE ligne INTEGER;
DECLARE ligne_1 INTEGER;
DECLARE departement VARCHAR;

BEGIN
	/*insert type of vaccin to vaccin table*/
	SELECT id_vaccin INTO ligne FROM vaccin WHERE  type_de_vaccin = New.type_de_vaccin;
	IF (NOT FOUND) THEN INSERT INTO vaccin(type_de_vaccin) VALUES (NEW.type_de_vaccin) RETURNING vaccin.id_vaccin INTO ligne;
	END IF;

	/* Insert into stockage_vaccin */
	

	SELECT id_stockage_vaccin INTO ligne_1 FROM stockage_vaccin WHERE  date_stockage = New._date;
	IF (NOT FOUND) THEN INSERT INTO stockage_vaccin(date_stockage) VALUES (NEW._date) RETURNING stockage_vaccin.id_stockage_vaccin INTO ligne_1;
	END IF;

	/* INSERT INTO stockage_vaccin_Departement */

	/*raise notice 'Value found: % ', NEW.code_departement ;*/
	INSERT INTO stockage_vaccin_Departement VALUES (NEW.code_departement, ligne_1, ligne, New.nb_doses, NEW.nb_ucd);

	RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;


CREATE TRIGGER stocks_doses_vaccin_audit
BEFORE INSERT OR UPDATE 
ON stocks_doses_vaccin_trigger
FOR EACH ROW EXECUTE PROCEDURE stocks_doses_vaccin_import_csv();



CREATE OR REPLACE FUNCTION vaccination_edit_id_departement() RETURNS TRIGGER AS
$$
DECLARE ligne VARCHAR;
DECLARE ligne_1 VARCHAR;
BEGIN
	New.dep = LTRIM(New.dep, '0');

	SELECT code_departement INTO ligne FROM departement  WHERE code_departement = New.dep; 
	SELECT type_de_vaccin INTO ligne_1 FROM vaccin  WHERE id_vaccin = New.vaccin; 
	
	IF (ligne != '' and ligne_1 != '') THEN  RETURN New;
	END IF;
	RETURN NULL;
	
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER vaccination_audit
	BEFORE INSERT OR UPDATE
	ON vaccination
	FOR EACH ROW EXECUTE PROCEDURE vaccination_edit_id_departement();


CREATE OR REPLACE FUNCTION donnees_hospitaliere_edit_id_departement() RETURNS TRIGGER AS
$$
DECLARE ligne VARCHAR;
DECLARE ligne_1 VARCHAR;
BEGIN
	New.dep = LTRIM(New.dep, '0');

	SELECT code_departement INTO ligne FROM departement  WHERE code_departement = New.dep; 
	
	IF (ligne != '' AND NEW.sexe > 0) THEN  RETURN New;
	END IF;
	RETURN NULL;
	
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER donnees_hospitaliere_audit
	BEFORE INSERT OR UPDATE
	ON donnees_hospitaliere
	FOR EACH ROW EXECUTE PROCEDURE donnees_hospitaliere_edit_id_departement();

CREATE OR REPLACE FUNCTION rendez_vous_par_departement_import_csv() RETURNS TRIGGER AS
$$
DECLARE ligne VARCHAR;
BEGIN
	New.dep = LTRIM(New.dep, '0');

	SELECT code_departement INTO ligne FROM departement  WHERE code_departement = New.dep; 

	IF (ligne != '') THEN INSERT INTO rendez_vous_par_departement VALUES (New.dep, New.rang_vaccinal, New.date_debut_semaine, New.nb);
	END IF;
	RETURN NULL;
	
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER rendez_vous_par_departement_audit
	BEFORE INSERT OR UPDATE
	ON rendez_vous_par_departement_trigger
	FOR EACH ROW EXECUTE PROCEDURE rendez_vous_par_departement_import_csv();
