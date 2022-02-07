create schema 20210620_db;
use 20210620_db;

# 1.table design
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

create table drivers
(
    id         int primary key auto_increment,
    first_name varchar(30) not null,
    last_name  varchar(30) not null,
    age        int         not null,
    rating     float default 5.5
);

create table cars_drivers
(
    car_id    int not null,
    driver_id int not null,
    primary key (car_id, driver_id),
    constraint fk_cd_cars
        foreign key (car_id)
            references cars (id),
    constraint
        fk_cd_drivers
        foreign key (driver_id)
            references drivers (id)
);

create table clients
(
    id           int primary key auto_increment,
    full_name    varchar(50) not null,
    phone_number varchar(20) not null
);
create table addresses
(
    id   int primary key auto_increment,
    name varchar(100) not null
);

create table courses
(
    id              int primary key auto_increment,
    from_address_id int      not null,
    start           datetime not null,
    car_id          int      not null,
    client_id       int      not null,
    bill            decimal(10, 2) default 10,
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
select concat(d.first_name, ' ', d.last_name), concat('(088) 9999', d.id * 2)
from drivers d
where id between 10 and 20;

# 3. update
update cars c
set c.condition = 'C'
where (c.mileage >= 800000 or c.mileage is null)
  and c.year <= 2010
  and c.make != 'Mercedes-Benz';

# 4. delete
delete
from clients
where id not in (select client_id from courses)
  and char_length(full_name) > 3;

# 5. cars
select make, model, `condition`
from cars
order by id;

# 6.drivers and cars
select d.first_name, d.last_name, c.make, c.model, c.mileage
from drivers d
         join cars_drivers cd on d.id = cd.driver_id
         join cars c on cd.car_id = c.id
where c.mileage is not null
order by c.mileage desc, d.first_name;

# 7.number of courses
select c.id as                car_id,
       c.make,
       c.mileage,
       count(c2.car_id)       count_of_courses,
       round(avg(c2.bill), 2) avg_bill
from cars c
         left join courses c2 on c.id = c2.car_id
group by c.id
having count_of_courses != 2
order by count_of_courses desc, c.id;

# 8. regular clients
select cl.full_name,
       count(c.car_id) count_of_cars,
       sum(c.bill)
from clients cl
         join courses c on cl.id = c.client_id
where cl.full_name like '_a%'
group by cl.full_name
having count_of_cars > 1
order by cl.full_name;

# 9. full information of courses
select a.name,
       case
           when hour(start) between 6 and 20 then 'Day'
           else 'Night'
           end date_time,
       co.bill,
       c.full_name,
       c2.make,
       c2.model,
       c3.name category_name
from courses co
         join addresses a on co.from_address_id = a.id
         join clients c on co.client_id = c.id
         join cars c2 on co.car_id = c2.id
         join categories c3 on c2.category_id = c3.id
order by co.id;


# 10. Find all courses by client’s phone number
create function udf_courses_by_client(phone_num VARCHAR(20))
    returns int
    deterministic
begin
    return (
        select count(c.client_id)
        from courses c
                 join clients c2 on c.client_id = c2.id
        where c2.phone_number = phone_num
        group by c.client_id
    );
end;

SELECT udf_courses_by_client('(803) 6386812') as `count`;
# 5

# 11.full info for address
create procedure udp_courses_by_address(address_name varchar(100))
    deterministic
begin
    select a.name,
           cl.full_name full_names,
           case
               when co.bill <= 20 then 'Low'
               when co.bill <= 30 then 'Medium'
               else 'High'
               end      level_of_bill,
           c.make,
           c.condition,
           ca.name      cat_name
    from addresses a
             join courses co on co.from_address_id = a.id
             join clients cl on co.client_id = cl.id
             join cars c on c.id = co.car_id
             join categories ca on ca.id = c.category_id
    where a.name = address_name
    order by c.make, cl.full_name;
end;

CALL udp_courses_by_address('66 Thompson Drive');

