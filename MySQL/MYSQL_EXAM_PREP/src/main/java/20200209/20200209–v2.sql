create schema 20200209_db;
use 20200209_db;

# 1. table design
create table countries
(
    id   int primary key auto_increment,
    name varchar(45) not null
);

create table towns
(
    id         int primary key auto_increment,
    name       varchar(45) not null,
    country_id int         not null,
    constraint fk_towns_countries
        foreign key (country_id)
            references countries (id)
);

create table stadiums
(
    id       int primary key auto_increment,
    name     varchar(45) not null,
    capacity int         not null,
    town_id  int         not null,
    constraint fk_stadiums_towns
        foreign key (town_id)
            references towns (id)
);

create table teams
(
    id          int primary key auto_increment,
    name        varchar(45) not null,
    established date        not null,
    fan_base    bigint(20)  not null,
    stadium_id  int         not null,
    constraint fk_teams_stadiums
        foreign key (stadium_id)
            references stadiums (id)
);

create table skills_data
(
    id        int primary key auto_increment,
    dribbling int default 0,
    pace      int default 0,
    passing   int default 0,
    shooting  int default 0,
    speed     int default 0,
    strength  int default 0
);

create table players
(
    id             int primary key auto_increment,
    first_name     varchar(10)    not null,
    last_name      varchar(20)    not null,
    age            int            not null default 0,
    position       char(1)        not null,
    salary         decimal(10, 2) not null default 0,
    hire_date      datetime,
    skills_data_id int            not null,
    team_id        int,
    constraint fk_players_skills_data
        foreign key (skills_data_id)
            references skills_data (id),
    constraint fk_players_team_id
        foreign key (team_id)
            references teams (id)
);

create table coaches
(
    id          int primary key auto_increment,
    first_name  varchar(10)    not null,
    last_name   varchar(20)    not null,
    salary      decimal(10, 2) not null default 0,
    coach_level int            not null default 0
);

create table players_coaches
(
    player_id int not null,
    coach_id  int not null,
    primary key (player_id, coach_id),
    constraint fk_pc_players
        foreign key (player_id)
            references players (id),
    constraint fk_pc_coaches
        foreign key (coach_id)
            references coaches (id)
);

# 2. insert
insert coaches (first_name, last_name, salary, coach_level)
select p.first_name, p.last_name, p.salary * 2, char_length(p.first_name)
from players p
where p.age >= 45;

# 3. update
update coaches
set coach_level = coach_level + 1
where first_name like 'A%'
  and id in (select coach_id from players_coaches);

update coaches c
set c.coach_level = c.coach_level + 1
where c.first_name like 'A%'
  and (
          select count(player_id)
          from players_coaches
          where coach_id = c.id
      ) >= 1;

# 4. delete
delete
from players
where age >= 45;

# 5. players
select first_name, age, salary
from players
order by salary desc;

# 06. Young offense players without contract
select p.id,
       concat_ws(' ', p.first_name, p.last_name) full_name,
       p.age,
       p.position,
       p.hire_date
from players p
         join skills_data sd on p.skills_data_id = sd.id
where p.hire_date is null
  and p.position = 'A'
  and p.age < 23
  and sd.strength > 50
order by p.salary, p.age;

# 07. Detail info for all teams
select t.name      team_name,
       t.established,
       t.fan_base,
       count(p.id) players_count
from teams t
         join players p on t.id = p.team_id
group by t.id, t.fan_base
order by players_count desc, t.fan_base desc;

# 08. The fastest player by towns
select max(sd.speed) max_speed, t2.name town_name
from skills_data sd
         right join players p on sd.id = p.skills_data_id
         right join teams t on p.team_id = t.id
         right join stadiums s on t.stadium_id = s.id
         right join towns t2 on s.town_id = t2.id
where t.name != 'Devify'
group by t2.name
order by max_speed desc, t2.name;

# 09. Total salaries and players by country
select co.name,
       count(p.id)   total_count_of_players,
       sum(p.salary) total_sum_of_salaries

from countries co
         left join towns t on co.id = t.country_id
         left join stadiums s on t.id = s.town_id
         left join teams t2 on s.id = t2.stadium_id
         left join players p on t2.id = p.team_id
group by co.name
order by total_count_of_players desc, co.name;

# 10.	Find all players that play on stadium
create function udf_stadium_players_count(stadium_name VARCHAR(30))
    returns int
    deterministic
begin
    return (
        select count(p.id)
        from players p
                 join teams t on p.team_id = t.id
                 join stadiums s on t.stadium_id = s.id
        where s.name = stadium_name
    );
end;


# Query
SELECT udf_stadium_players_count('Jaxworks') as `count`;
# count
# 14

# Query
SELECT udf_stadium_players_count('Linklinks') as `count`;
# count
# 0

# 11.	Find good playmaker by teams
create procedure udp_find_playmaker(min_dribble_points int, team_name varchar(45))
    deterministic
begin
    select concat_ws(' ', p.first_name, p.last_name) full_name,
           p.age,
           p.salary,
           sd.dribbling,
           sd.speed,
           t.name                                    team_name
    from players p
             join teams t on p.team_id = t.id
             join skills_data sd on sd.id = p.skills_data_id
    where sd.dribbling > min_dribble_points
      and t.name = team_name
      and sd.speed >
          (
              select avg(speed)
              from skills_data
              where id in (select skills_data_id from players)
          )
    order by sd.speed desc
    limit 1;
end;

CALL udp_find_playmaker (20, 'Skyble');

