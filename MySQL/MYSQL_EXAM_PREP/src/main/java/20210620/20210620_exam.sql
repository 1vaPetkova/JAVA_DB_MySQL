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
from clients
where id not in (select client_id from courses)
  and char_length(full_name) > 3;

# 5. cars
select c.make, c.model, c.condition
from cars c
order by c.id;

# 6. drivers and cars
select d.first_name, d.last_name, c.make, c.model, c.mileage
from drivers d
         join cars_drivers cd on d.id = cd.driver_id
         join cars c on c.id = cd.car_id
where c.mileage is not null
order by c.mileage desc, d.first_name;

# 7. number of courses
select c.id as car_id, c.make, c.mileage, count(co.id) count_of_courses, round(avg(co.bill), 2) avg_bill
from cars c
         left join courses co on c.id = co.car_id
group by c.id
having count_of_courses != 2
order by count_of_courses desc, c.id;

# 8. regular clients
select cl.full_name, count(co.car_id) count_of_cars, sum(co.bill) total_sum
from clients as cl
         join courses co on cl.id = co.client_id
where cl.full_name like '_a%'
group by cl.full_name
having count_of_cars > 1
order by cl.full_name;

# 9. full information of courses
select a.name,
       case
           when hour(co.start) between 6 and 20 then 'Day'
           else 'Night'
           end
               day_time,
       round(co.bill, 2),
       cl.full_name,
       c.make,
       c.model,
       ca.name category_name
from courses co
         join addresses a on co.from_address_id = a.id
         join clients cl on co.client_id = cl.id
         join cars c on co.car_id = c.id
         join categories ca on c.category_id = ca.id
order by co.id;

# 10. find all courses by clients phone number
create function udf_courses_by_client(phone_number varchar(20))
    returns int
    deterministic
begin
    return (select count(*)
            from courses co
                     cross join clients cl on co.client_id = cl.id
            where cl.phone_number = phone_number);
end;

SELECT udf_courses_by_client('(704) 2502909') as count;


# 11. full info address
create procedure udp_courses_by_address(address_name varchar(100))
    deterministic
begin
    select a.name,
           cl.full_name full_names,
           (
               case
                   when co.bill <= 20 then 'Low'
                   when co.bill <= 30 then 'Medium'
                   else 'High'
                   end) level_of_bill,
           c.make,
           c.`condition`,
           cat.name     cat_name
    from addresses a
             join courses co on a.id = co.from_address_id
             join clients cl on co.client_id = cl.id
             join cars c on co.car_id = c.id
             join categories cat on c.category_id = cat.id
    where a.name = address_name
    order by c.make, cl.full_name;
end;

CALL udp_courses_by_address('700 Monterey Avenue');
CALL udp_courses_by_address('66 Thompson Drive');


