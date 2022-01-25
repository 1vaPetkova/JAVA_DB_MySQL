create schema exam_20210620;
use exam_20210620;

# 1.Table design

create table clients
(
    id           int primary key auto_increment,
    full_name    varchar(50) not null,
    phone_number varchar(20) not null
);

create table drivers
(
    id         int primary key auto_increment,
    first_name varchar(30) not null,
    last_name  varchar(30) not null,
    age        int         not null,
    rating     float
);

create table addresses
(
    id   int primary key auto_increment,
    name varchar(100) not null
);

create table categories
(
    id   int primary key auto_increment,
    name varchar(10) not null
);

create table cars
(
    id          int primary key auto_increment,
    make        varchar(20) not null,
    model       varchar(20),
    year        int         not null,
    mileage     int,
    `condition` char(1)     not null,
    category_id int         not null,
    constraint fk_cars_categories
        foreign key (category_id)
            references categories (id)
);

create table cars_drivers
(
    car_id    int,
    driver_id int,
    primary key (car_id, driver_id),
    constraint fk_cd_cars
        foreign key (car_id)
            references cars (id),
    constraint fk_cd_drivers
        foreign key (driver_id)
            references drivers (id)
);
create table courses
(
    id              int primary key auto_increment,
    from_address_id int      not null,
    start           datetime not null,
    car_id          int      not null,
    client_id       int      not null,
    bill            decimal(10, 2),
    constraint fk_courses_addresses
        foreign key (from_address_id)
            references addresses (id),
    constraint fk_courses_clients
        foreign key (client_id)
            references clients (id),
    constraint fk_courses_cars
        foreign key (car_id)
            references cars (id)
);

# 2. insert
insert into clients(full_name, phone_number)
select concat(first_name, ' ', last_name) as full_name,
       concat('(088) 9999', d.id * 2)     as phone_number
from drivers d
where d.id between 10 and 20;

# 3. update
update cars c
set c.`condition`='C'
where (c.mileage >= 8000 or c.mileage is null)
  and c.year <= 2010
  and c.make not in ('Mercedes-Benz');

# 4. delete
delete
from clients where id not in (select client_id from courses)
  and char_length(full_name) > 3;

# 5. cars