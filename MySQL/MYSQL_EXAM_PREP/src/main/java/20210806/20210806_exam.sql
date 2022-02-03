create schema 20210806_db;
use 20210806_db;

create table addresses
(
    id   int primary key auto_increment,
    name varchar(50) not null
);

create table offices
(
    id                 int primary key auto_increment,
    workspace_capacity int not null,
    website            varchar(50),
    address_id         int not null,
    constraint fk_offices_addresses
        foreign key (address_id)
            references addresses (id)
);

create table employees
(
    id              int primary key auto_increment,
    first_name      varchar(30)    not null,
    last_name       varchar(30)    not null,
    age             int            not null,
    salary          decimal(10, 2) not null,
    job_title       varchar(20)    not null,
    happiness_level char(1)        not null
);

create table teams
(
    id        int primary key auto_increment,
    name      varchar(40) not null,
    office_id int         not null,
    leader_id int         not null unique,
    constraint fk_teams_employees
        foreign key (leader_id)
            references employees (id),
    constraint fk_teams_offices
        foreign key (office_id)
            references offices (id)
);

create table games
(
    id           int primary key auto_increment,
    name         varchar(50)    not null unique,
    description  text,
    rating       float          not null default 5.5,
    budget       decimal(10, 2) not null,
    release_date date,
    team_id      int            not null,
    constraint fk_games_teams
        foreign key (team_id)
            references teams (id)
);

create table categories
(
    id   int primary key auto_increment,
    name varchar(10) not null
);

create table games_categories
(
    game_id     int not null,
    category_id int not null,
    primary key (game_id, category_id),
    constraint fk_gc_games
        foreign key (game_id)
            references games (id),
    constraint fk_gc_categories
        foreign key (category_id)
            references categories (id)
);

# 2. insert
insert into games(name, rating, budget, team_id)
select reverse(substring(lower(t.name), 2)),
       t.id,
       t.leader_id * 1000,
       t.id
from teams t
where t.id between 1 and 9;

# 3. update
update employees e
set e.salary = e.salary + 1000
where e.id in (select leader_id from teams)
  and e.age < 40
  and e.salary < 5000;

# 4. delete
delete
from games
where release_date is null
  and id not in (select game_id from games_categories);

# 5. employees
select first_name, last_name, age, salary, happiness_level
from employees
order by salary, id;

# 6. addresses of the teams
select t.name team_name, a.name address_name, char_length(a.name) count_of_characters
from teams t
         join offices o on t.office_id = o.id
         join addresses a on o.address_id = a.id
where o.website is not null
order by t.name, a.name;

# 7. categories info
select c.name,
       count(gc.game_id)       games_count,
       round(avg(g.budget), 2) avg_budget,
       max(g.rating)           max_rating
from categories c
         join games_categories gc on c.id = gc.category_id
         join games g on gc.game_id = g.id
group by c.name
having max_rating >= 9.5
order by games_count desc, c.name;

# 8. games of 2022
select g.name,
       g.release_date,
       concat(left(g.description, 10), '...'),
       case
           when
               month(g.release_date) in (1, 2, 3) then 'Q1'
           when
               month(g.release_date) in (4, 5, 6) then 'Q2'
           when
               month(g.release_date) in (7, 8, 9) then 'Q3'
           else 'Q4'
           end quarter,
       t.name  team_name
from games g
         join teams t on g.team_id = t.id
where year(g.release_date) = 2022
  and month(g.release_date) % 2 = 0
  and g.name like '%2'
order by quarter;

# 9. full info of games
select g.name,
       case
           when g.budget < 50000 then 'Normal budget'
           else 'Insufficient budget'
           end budget_level,
       t.name  team_name,
       a.name  address_name
from games g
         join teams t on g.team_id = t.id
         join offices o on t.office_id = o.id
         join addresses a on o.address_id = a.id
where g.release_date is null
  and g.id not in (select game_id from games_categories)
order by g.name;

# 10.	Find all basic information for a game

# o	The "game_name" is developed by a "team_name" in an office with an address "address_text"

create function udf_game_info_by_name(game_name VARCHAR(20))
    returns varchar(200)
    deterministic
begin
    return (
        select concat('The ', g.name, ' is developed by a ', t.name, ' in an office with an address ', a.name)
        from games g
                 join teams t on g.team_id = t.id
                 join offices o on t.office_id = o.id
                 join addresses a on o.address_id = a.id
        where g.name = game_name
    );
end;

SELECT udf_game_info_by_name('Bitwolf') AS info;
# The Bitwolf is developed by a Rempel-O'Kon in an office with an address 92 Memorial Park

SELECT udf_game_info_by_name('Fix San') AS info;
# The Fix San is developed by a Schulist in an office with an address 75 Harper Way

SELECT udf_game_info_by_name('Job') AS info;
# The Job is developed by a Shields Group in an office with an address 036 Stuart Pass

# 11. Update budget of the games

create procedure udp_update_budget(min_game_rating float(10, 2))
    deterministic
begin
    update games g
    set g.budget       = g.budget + 100000,
        g.release_date = date_add(g.release_date, interval 1 year)
    where g.id not in (select game_id from games_categories)
      and g.rating > min_game_rating
      and g.release_date is not null;
end;


CALL udp_update_budget(8);
# This execution will update three games – Quo Lux, Daltfresh and Span.
#                         Result
#                         Quo Lux - 23384.32 -> 123384.32 | 2022-06-26 -> 2023-06-26
#                         Daltfresh - 86012.38 -> 186012.38 | 2021-06-17 -> 2022-06-17
#                         Span - 47468.36 -> 147468.36 | 2022-06-05 -> 2023-06-05


