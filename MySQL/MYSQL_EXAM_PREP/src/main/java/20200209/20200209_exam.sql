# 1. Table design
create schema fsd;
use fsd;

create table skills_data
(
    id        int primary key auto_increment,
    dribbling int,
    pace      int,
    passing   int,
    shooting  int,
    speed     int,
    strength  int
);

create table coaches
(
    id          int primary key auto_increment,
    first_name  varchar(10)    not null,
    last_name   varchar(20)    not null,
    salary      decimal(10, 2) not null,
    coach_level int            not null
);

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

create table players
(
    id             int primary key auto_increment,
    first_name     varchar(10)    not null,
    last_name      varchar(20)    not null,
    age            int            not null,
    position       char(1)        not null,
    salary         decimal(10, 2) not null,
    hire_date      datetime,
    skills_data_id int            not null,
    team_id        int,
    constraint fk_players_skills_data
        foreign key (skills_data_id)
            references skills_data (id),
    constraint
        fk_players_teams
        foreign key (team_id)
            references teams (id)
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
insert into coaches(first_name, last_name, salary, coach_level)
select p.first_name, p.last_name, 2 * p.salary, char_length(p.first_name)
from players p
where p.age >= 45;

# 3. update
update coaches c
set c.coach_level = c.coach_level + 1
where (select count(player_id)
       from players_coaches
       where coach_id = c.id
      ) >= 1
  and c.first_name like 'A%';

# 4. delete
delete
from players
where age >= 45;

# 5. players
select first_name, age, salary
from players
order by salary desc;

# 6.young offense players without contract
select p.id, concat_ws(' ', first_name, last_name), p.position, p.hire_date
from players p
         join skills_data sd on p.skills_data_id = sd.id
where p.age < 23
  and p.position = 'A'
  and p.hire_date is null
  and sd.strength > 50
order by p.salary, p.age;

# 7. detail info for all teams
select t.name team_name,
       t.established,
       t.fan_base,
       (
           select count(id)
           from players
           where team_id = t.id
       )      players_count
from teams t
order by players_count desc, t.fan_base desc;

# 8. the fastest player in town
select max(sd.speed) max_speed, t2.name town_name
from skills_data sd
         right join players p on sd.id = p.skills_data_id
         right join teams t on p.team_id = t.id
         right join stadiums s on t.stadium_id = s.id
         right join towns t2 on s.town_id = t2.id
where t.name != 'Devify'
group by t2.name
order by max_speed desc, town_name;