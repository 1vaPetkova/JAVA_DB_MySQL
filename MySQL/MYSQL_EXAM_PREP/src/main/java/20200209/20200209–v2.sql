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