-- Creating tables for EV
CREATE TABLE geoids (
    geoid VARCHAR NOT NULL, 
	state_abbr VARCHAR(2) NOT NULL,
    county VARCHAR(40) NULL,
	state_1 VARCHAR(40) NOT NULL,
     PRIMARY KEY (geoid));

CREATE TABLE ca_ev_reg (
    vehicle_id VARCHAR NOT NULL, 
	geoid VARCHAR NOT NULL,
    regristration_valid_date date NOT NULL,
	dmv_id INT NOT NULL,
	dmv_snapshot VARCHAR NOT NULL,
	regristration_expiration_date VARCHAR,
	state_abbr VARCHAR(2) NOT NULL,
	geography VARCHAR NOT NULL,
	vehicle_name VARCHAR NOT NULL,
--FOREIGN KEY (geoid) REFERENCES geoids (geoid),
PRIMARY KEY (vehicle_id));

CREATE TABLE ev_stations (
	fuel_type_CODE VARCHAR NOT NULL,
	station_name VARCHAR NOT NULL, 
	street_address VARCHAR NOT NULL,
    intersection_directions VARCHAR,
	city VARCHAR,
	state_abbr VARCHAR,
	zip VARCHAR,
	plus4 VARCHAR,
	station_phone VARCHAR,
	status_code VARCHAR,
	expected_date VARCHAR,
	groups_with_access_code VARCHAR,
	access_days_time VARCHAR,
	cards_accepted VARCHAR,
	bd_blends VARCHAR,
	ng_fill_type_code VARCHAR,
	ng_psi VARCHAR,
	ev_level1_evse_num VARCHAR,
	ev_level2_evse_num VARCHAR,
	ev_dc_fast_count VARCHAR,
	ev_other_info VARCHAR,
	ev_network VARCHAR,
	ev_network_web VARCHAR,
	geocode_status VARCHAR,
	latitude VARCHAR,
	longitude VARCHAR,
	date_last_confirmed VARCHAR,
	id_1 int,
	updated_at VARCHAR,
	owner_type_code VARCHAR,
	federal_agency_id VARCHAR,
	federal_agency_name VARCHAR,
	open_date date,
	hydrogen_status_link VARCHAR,
	ng_vehicle_class VARCHAR,
	lpg_primary VARCHAR,
	e85_blender_pump VARCHAR,
	ev_connector_types VARCHAR,
	country VARCHAR,
	intersection_directions_fr VARCHAR,
	access_days_time_fr VARCHAR,
	bd_blends_fr VARCHAR,
	groups_with_access_code_fr VARCHAR,
	hydrogen_is_retail VARCHAR,
	access_code VARCHAR,
	access_detail_code VARCHAR,
	federal_agency_code VARCHAR,
	facility_type VARCHAR,
	cng_dispenser_num VARCHAR,
	cng_onsite_renewable_source VARCHAR,
	cng_total_compression_capacity VARCHAR,
	cng_storage_capacity VARCHAR,
	lng_onsite_renewable_source VARCHAR,
	e85_other_ethanol_blends VARCHAR,
	ev_pricing VARCHAR,
	ev_pricing_fr VARCHAR,
	lpg_nozzle_types VARCHAR,
	hydrogen_pressures VARCHAR,
	hydrogen_standards VARCHAR,
	cng_fill_type_code VARCHAR,
	cng_psi VARCHAR,
	cng_vehicle_class VARCHAR,
	lng_vehicle_class VARCHAR,
	ev_onsite_renewable_source VARCHAR,
	restricted_access VARCHAR,
PRIMARY KEY (id_1));

CREATE TABLE cities (
	id_1 int NOT NULL,
	state_abbr VARCHAR NOT NULL, 
	state_name VARCHAR NOT NULL,
    city VARCHAR NOT NULL,
	county VARCHAR,
	latitude VARCHAR NOT NULL,
	longitude VARCHAR NOT NULL,
PRIMARY KEY (ID_1, city));

-- CA DMV Table
select	ca.geoid,
		ca.state_abbr,
		ca.vehicle_name,
		ca.regristration_valid_date,
		ge.county
INTO ca_dmv
FROM ca_ev_reg as ca
INNER JOIN ca_geoids as ge
ON (ca.geoid = ge.geoid)
where (ca.state_abbr = 'CA')
ORDER BY ca.geoid, ca.regristration_valid_date, ca.vehicle_name;

-- EV County Counts
SELECT COUNT (dm.geoid) as evs,
		dm.geoid,
		dm.county
INTO ca_ev_county_counts
FROM ca_dmv as dm
GROUP BY dm.geoid, dm.county
ORDER BY dm.geoid, dm.county;

-- EV County Year Counts
SELECT COUNT (dm.geoid) as evs,
		dm.geoid,
		dm.county,
		EXTRACT(YEAR FROM dm.regristration_valid_date) AS ryear
INTO ca_ev_year_county_counts
FROM ca_dmv as dm
GROUP BY dm.geoid, dm.regristration_valid_date, dm.county
ORDER BY dm.geoid, dm.regristration_valid_date, dm.county;

-- EV Stations
SELECT ev.fuel_type_code, 
	ev.station_name,
    ev.street_address,
	ev.city,
	ev.state_abbr,
	ev.zip,
	ev.status_code,
	ev.groups_with_access_code,
	ev.access_days_time,
	ev.ev_level1_evse_num,
	ev.ev_level2_evse_num,
	ev.ev_dc_fast_count,
	EXTRACT( YEAR FROM ev.open_date) AS oyear,
	ev.latitude,
	ev.longitude,
	ev.ev_pricing,
	ci.county,
	ge.geoid
INTO ca_ev_stations
FROM ev_stations as ev
INNER JOIN cities as ci
ON (ev.city = ci.city and ev.state_abbr = ci.state_abbr)
INNER JOIN geoids as ge
ON ci.county = ge.county and ci.state_abbr = ge.state_abbr
where (ev.fuel_type_code= 'ELEC' AND ev.state_abbr = 'CA' AND ev.status_code = 'E' and ev.access_code = 'public');

-- Electric Makes Counts by County
SELECT COUNT (dmv.county) as evs,
		dmv.county,
		EXTRACT(YEAR FROM dmv.regristration_valid_date) AS ryear,
		dmv.vehicle_name
INTO ca_make_count
FROM ca_dmv as dmv
GROUP BY dmv.county,dmv.regristration_valid_date, dmv.vehicle_name
ORDER BY dmv.county, dmv.regristration_valid_date, dmv.vehicle_name;

-- CA GEOID CSV File
SELECT CONCAT ('0', ge.geoid) AS geoid,
	ge.state_abbr,
	ge.county,
	ge.state_1
INTO ca_geoids
FROM geoids AS ge
WHERE ge.state_abbr = 'CA';

-- EV Station Counts by County
SELECT COUNT (caev.county) AS stations,
		caev.county,
		ge.geoid
INTO ca_stations_count
FROM ca_ev_stations as caev
INNER JOIN ca_geoids as ge
ON (caev.county = ge.county)
GROUP BY caev.county, ge.geoid
HAVING COUNT (caev.county) > 0
ORDER BY stations DESC;

-- EV Station Counts by County
SELECT COUNT (caev.county) AS stations,
		caev.oyear		
INTO ca_stations_yr_count
FROM ca_ev_stations as caev
INNER JOIN ca_geoids as ge
ON (caev.county = ge.county)
WHERE caev.oyear IS NOT NULL
GROUP BY caev.oyear
HAVING COUNT (caev.county) > 0 
ORDER BY oyear;

-- Ratio Of Stations to Electric Vehicle
SELECT  st.geoid,
		st.county,
		st.stations,
		ev.evs,
		round(cast(st.stations as decimal) / ev.evs, 3) as ratio
INTO ca_stations_ratio
FROM ca_stations_count AS st
INNER JOIN ca_ev_county_counts AS ev
ON (st.geoid = ev.geoid);
		
