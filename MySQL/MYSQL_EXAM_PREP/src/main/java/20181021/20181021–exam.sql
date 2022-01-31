create schema 20181021_exam;
use 20181021_exam;

create table planets
(
    id   int primary key auto_increment,
    name varchar(30) not null
);

create table spaceports
(
    id        int primary key auto_increment,
    name      varchar(50) not null,
    planet_id int,
    constraint fk_spaceports_planets
        foreign key (planet_id)
            references planets (id)
);

create table spaceships
(
    id               int primary key auto_increment,
    name             varchar(50) not null,
    manufacturer     varchar(30) not null,
    light_speed_rate int
);

create table journeys
(
    id                       int primary key auto_increment,
    journey_start            datetime                                                 not null,
    journey_end              datetime                                                 not null,
    purpose                  enum ('Medical', 'Technical', 'Educational', 'Military') not null,
    destination_spaceport_id int,
    spaceship_id             int,
    constraint fk_journeys_spaceport
        foreign key (destination_spaceport_id)
            references spaceports (id),
    constraint fk_journeys_spaceships
        foreign key (spaceship_id)
            references spaceships (id)
);
create table colonists
(
    id         int primary key auto_increment,
    first_name varchar(20) not null,
    last_name  varchar(20) not null,
    ucn        char(10)    not null,
    birth_date date        not null
);

create table travel_cards
(
    id                 int auto_increment primary key,
    card_number        char(10)                                                 not null,
    job_during_journey enum ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook') not null,
    colonist_id        int,
    journey_id         int,
    constraint fk_tr_c_colonists
        foreign key (colonist_id)
            references colonists (id),
    constraint fk_tr_c_journeys
        foreign key (journey_id)
            references journeys (id)
);

-- 1. insert
insert into travel_cards (card_number, job_during_journey, colonist_id, journey_id)
select(
          case
              when c.birth_date > '1980-01-01' then concat_ws('', year(c.birth_date), day(c.birth_date),
                                                              left(c.ucn, 4))
              else
                  concat_ws('', year(c.birth_date), month(c.birth_date), right(c.ucn, 4))
              end),
      (
          case
              when c.id % 2 = 0 then 'Pilot'
              when c.id % 3 = 0 then 'Cook'
              else 'Engineer'
              end),
      c.id,
      left(c.ucn, 1)
from colonists c
where c.id between 96 and 100;


# 2. update
update journeys j
set j.purpose = (case
                     when mod(j.id, 2) = 0 then 'Medical'
                     when mod(j.id, 3) = 0 then 'Technical'
                     when mod(j.id, 5) = 0 then 'Educational'
                     when mod(j.id, 7) = 0 then 'Military'
                     else j.purpose
    end);

# 3. delete
delete
from colonists
where id not in (select t.colonist_id from travel_cards t);

# 4. extract all travel cards
select t.card_number, t.job_during_journey
from travel_cards as t
order by card_number asc;

# 5. extract all colonists
select c.id, concat_ws(' ', c.first_name, c.last_name) full_name, c.ucn
from colonists c
order by c.first_name, c.last_name, c.id;

# 6. extract all military journeys
select j.id, j.journey_start, j.journey_end
from journeys j
where j.purpose = 'Military'
order by journey_start;

# 7. extract all pilots
select c.id, concat_ws(' ', c.first_name, c.last_name)
from colonists c
         join travel_cards tc on c.id = tc.colonist_id
where tc.job_during_journey = 'Pilot'
order by id;

# 8. count all colonists that are on technical journey
select count(c.id) count
from colonists c
         join travel_cards tc on c.id = tc.colonist_id
         join journeys j on tc.journey_id = j.id
where j.purpose = 'Technical';

# 9.extract the fastest ship
select sps.name spaceship_name, s.name spaceport_name
from spaceships sps
         join journeys j on sps.id = j.spaceship_id
         join spaceports s on s.id = j.destination_spaceport_id
order by sps.light_speed_rate desc
limit 1;

# 10. extract spaceships with pilots younger than 30 years
select s.name, s.manufacturer
from spaceships s
         right join journeys j on s.id = j.spaceship_id
         right join travel_cards tc on j.id = tc.journey_id
         right join colonists c on tc.colonist_id = c.id
where tc.job_during_journey = 'Pilot'
  and year('2019-01-01') - year(c.birth_date) < 30
order by s.name;

# 11. extract all educational mission
select p.name planet_name, s.name spaceport_name
from planets p
         join spaceports s on p.id = s.planet_id
         join journeys j on s.id = j.destination_spaceport_id
where j.purpose = 'educational'
order by spaceport_name desc;

# 12. extract all planets and their journey count
select p.name planet_name, count(j.id) journeys_count
from planets p
         join spaceports s on p.id = s.planet_id
         join journeys j on s.id = j.destination_spaceport_id
group by planet_name
order by journeys_count desc, planet_name;

# 13. extract the shortest journey
select j.id, p.name planet_name, s.name spaceport_name, j.purpose journey_purpose
from journeys j
         join spaceports s on j.destination_spaceport_id = s.id
         join planets p on s.planet_id = p.id
order by j.journey_end - j.journey_start
limit 1;

# 14. extract the less popular job
select t.job_during_journey job_name
from travel_cards t
         join journeys j on t.journey_id = j.id
group by j.journey_end - j.journey_start desc, (select count(t.colonist_id))
limit 1;

# 15. get colonists count
create function udf_count_colonists_by_destination_planet(planet_name VARCHAR(30))
    returns int
    deterministic
begin
    return (
        select count(tc.colonist_id)
        from travel_cards tc
                 join journeys j on tc.journey_id = j.id
                 join spaceports s on j.destination_spaceport_id = s.id
                 join planets p on s.planet_id = p.id
        where p.name = planet_name);
end;

SELECT p.name, udf_count_colonists_by_destination_planet('Otroyphus') AS count
FROM planets AS p
WHERE p.name = 'Otroyphus';

# 16. modify spaceship
create procedure udp_modify_spaceship_light_speed_rate(spaceship_name VARCHAR(50), light_speed_rate_increse INT(11))
    deterministic
begin
    start transaction;
    if spaceship_name not in (select name from spaceships) then
        signal sqlstate '45000'
            SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
        rollback;
    else
        update spaceships s
        set s.light_speed_rate = s.light_speed_rate + light_speed_rate_increse
        where s.name = spaceship_name;
    end if;
    commit;
end;

CALL udp_modify_spaceship_light_speed_rate('Na Pesho koraba',1914);
SELECT name, light_speed_rate FROM spaceships WHERE name = 'Na Pesho koraba';

CALL udp_modify_spaceship_light_speed_rate('USS Templar',5);

SELECT name, light_speed_rate FROM spaceships WHERE name = 'USS Templar';