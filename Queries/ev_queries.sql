-- Creating tables for EV Analysis
-- Geoid Table
CREATE TABLE Geoids (
    geoid VARCHAR NOT NULL, 
	state_abbr VARCHAR(2) NOT NULL,
    county VARCHAR(40) NULL,
	state_1 VARCHAR(40) NOT NULL,
     PRIMARY KEY (geoid)
);

-- California EV Registrations Table
CREATE TABLE ca_ev_Registrations (
    vehicle_id VARCHAR NOT NULL, 
	geoid VARCHAR NOT NULL,
    regristration_valid_date date NOT NULL,
	dmv_id INT NOT NULL,
	dmv_snapshot VARCHAR NOT NULL,
	regristration_expiration_date VARCHAR,
	state_abbr VARCHAR(2) NOT NULL,
	geography VARCHAR NOT NULL,
	vehicle_name VARCHAR NOT NULL,
FOREIGN KEY (geoid) REFERENCES geoids (geoid),
PRIMARY KEY (vehicle_id)
	
);

-- EV Charging Stations Table
CREATE TABLE ev_charging_stations (
	station_name VARCHAR NOT NULL, 
	address VARCHAR NOT NULL,
    city VARCHAR NOT NULL,
	access_time VARCHAR NOT NULL,
	level_1_count VARCHAR,
	level_2_count VARCHAR,
	dc_fast_count VARCHAR,
	ec_other VARCHAR,
	latitude VARCHAR NOT NULL,
	longitude VARCHAR NOT NULL
	
);

-- Cities Information
CREATE TABLE cities (
	id_1 int NOT NULL,
	state_abbr VARCHAR NOT NULL, 
	state_name VARCHAR NOT NULL,
    city VARCHAR NOT NULL,
	county VARCHAR,
	latitude VARCHAR NOT NULL,
	longitude VARCHAR NOT NULL,
PRIMARY KEY (ID_1, city)
	
);

-- DMV
select	ca.geoid,
		ca.state_abbr,
		ca.vehicle_name,
		ca.regristration_valid_date,
		ge.county
FROM ca_ev_Registrations as ca
INNER JOIN geoids as ge
ON (ca.geoid = ge.geoid)
where (ca.state_abbr = 'CA')
ORDER BY ca.geoid, ca.regristration_valid_date, ca.vehicle_name;

-- County EV Counts
SELECT COUNT (dm.geoid),
		dm.geoid,
		dm.county
INTO county_counts
FROM ca_dmv as dm
GROUP BY dm.geoid, dm.county
ORDER BY dm.geoid, dm.county;

-- EV Stations
SELECT ev.station_name, 
	ev.address,
    ev.city,
	ev.access_time,
	ev.level_1_count,
	ev.level_2_count,
	ev.dc_fast_count,
	ev.ec_other,
	ev.latitude,
	ev.longitude,
	ci.county
FROM ev_charging_stations as ev
INNER JOIN cities as ci
ON (ev.latitude = ci.latitude and ev.longitude = ci.longitude);

-- California EV Stations
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
	ev.latitude,
	ev.longitude,
	ev.ev_pricing,
	ci.county,
	ge.geoid
INTO ca_ev_stations
FROM ev_stations as ev
INNER JOIN cities as ci
ON (ev.city = ci.city and ev.state_abbr = ci.state_abbr)
INNER JOIN  geoids as ge
ON concat(ci.county, ' County') = ge.county
where (ev.fuel_type_code = 'ELEC' and ev.state_abbr = 'CA');
