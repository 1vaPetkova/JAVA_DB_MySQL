# 1. Table design
create table towns
(
    id   int primary key auto_increment,
    name varchar(20) not null unique
);

create table addresses
(
    id      int primary key auto_increment,
    name    varchar(50) not null unique,
    town_id int         not null,
    constraint fk_addresses_towns
        foreign key (town_id)
            references towns (id)
);

create table stores
(
    id          int primary key auto_increment,
    name        varchar(20) not null unique,
    rating      float       not null,
    has_parking tinyint(1) default false,
    address_id  int         not null,
    constraint fk_stores_addresses
        foreign key (address_id)
            references addresses (id)
);

create table employees
(
    id          int primary key auto_increment,
    first_name  varchar(15)    not null,
    middle_name char(1),
    last_name   varchar(20)    not null,
    salary      decimal(19, 2) not null default 0,
    hire_date   date           not null,
    manager_id  int,
    store_id    int            not null,
    constraint fk_employees_managers
        foreign key (manager_id)
            references employees (id),
    constraint fk_employees_stores
        foreign key (store_id)
            references stores (id)
);

create table pictures
(
    id       int primary key auto_increment,
    url      varchar(100) not null,
    added_on datetime     not null
);

create table categories
(
    id   int primary key auto_increment,
    name varchar(40) not null unique
);

create table products
(
    id          int primary key auto_increment,
    name        varchar(40)    not null unique,
    best_before date,
    price       decimal(10, 2) not null,
    description text,
    category_id int            not null,
    picture_id  int            not null,
    constraint fk_products_categories
        foreign key (category_id)
            references categories (id),
    constraint fk_products_pictures
        foreign key (picture_id)
            references pictures (id)
);

create table products_stores
(
    product_id int not null,
    store_id   int not null,
    primary key (product_id, store_id),
    constraint fk_ps_products
        foreign key (product_id)
            references products (id),
    constraint fk_ps_stores
        foreign key (store_id)
            references stores (id)
);

# 2. insert
insert into products_stores(product_id, store_id)
select p.id, 1
from products p
where p.id not in (select product_id from products_stores);

# 3. update
update employees
set manager_id = 3,
    salary     = salary - 500
where year(hire_date) > 2003
  and store_id not in (select id from stores where name in ('Cardguard', 'Veribet'));

# 4.delete
delete
from employees
where salary >= 6000
  and manager_id is not null;

# 5. employees
select first_name, middle_name, last_name, salary, hire_date
from employees
order by hire_date desc;

# 6.	Products with old pictures
select p.name                                 product_name,
       p.price,
       p.best_before,
       concat(left(p.description, 10), '...') short_description,
       p2.url
from products p
         join pictures p2 on p.picture_id = p2.id
where year(p2.added_on) < 2019
  and p.price > 20
  and char_length(p.description) > 100
order by p.price desc;

# 7.	Counts of products in stores and their average
select s.name,
       count(ps.product_id)   product_count,
       round(avg(p.price), 2) avg
from stores s
         left join products_stores ps on s.id = ps.store_id
         left join products p on ps.product_id = p.id
group by s.id
order by product_count desc, avg desc, s.id;

# 8.	Specific employee
select concat_ws(' ', e.first_name, e.last_name) Full_name,
       s.name                                    Store_name,
       a.name                                    address,
       e.salary
from employees e
         join stores s on e.store_id = s.id
         join addresses a on s.address_id = a.id
where e.salary < 4000
  and a.name like '%5%'
  and char_length(s.name) > 8
  and e.last_name like '%n';

# 09. Find all information of stores
select reverse(s.name)                    reversed_name,
       concat(upper(t.name), '-', a.name) full_address,
       count(e.id)                        employees_count
from stores s
         join addresses a on s.address_id = a.id
         join towns t on a.town_id = t.id
         join employees e on s.id = e.store_id
group by s.name
having employees_count >= 1
order by full_address;

# 10.	Find full name of top paid employee by store name
create function udf_top_paid_employee_by_store(store_name VARCHAR(50))
    returns varchar(100)
    deterministic
begin
    return
        (
            select concat(e.first_name, ' ', e.middle_name, '. ', e.last_name, ' works in store for ',
                          year('2020/10/18') - year(e.hire_date), ' years'
                       )
            from employees e
                     join stores s on e.store_id = s.id
            where s.name = store_name
            order by e.salary desc
            limit 1
        );
end;

SELECT udf_top_paid_employee_by_store('Stronghold') as 'full_info';
# full_info
# Breena S. Hymans works in store for 3 years

# 11.	Update product price by address
create procedure udp_update_product_price(address_name VARCHAR(50))
    deterministic
begin
    update products
        join products_stores ps on products.id = ps.product_id
        join stores s on ps.store_id = s.id
        join addresses a on s.address_id = a.id
    set price = IF(a.name like '0%', price + 100, price + 200)
    where a.name = address_name;
end;

CALL udp_update_product_price('07 Armistice Parkway');
SELECT name, price FROM products WHERE id = 15;

CALL udp_update_product_price('1 Cody Pass');
SELECT name, price FROM products WHERE id = 17;



