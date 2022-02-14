create schema 20220213_db;
use 20220213_db;

# 1. table design
create table categories
(
    id   int primary key auto_increment,
    name varchar(40) not null unique
);

create table brands
(
    id   int primary key auto_increment,
    name varchar(40) not null unique
);

create table reviews
(
    id           int primary key auto_increment,
    content      text,
    rating       decimal(10, 2) not null,
    picture_url  varchar(80)    not null,
    published_at datetime       not null
);

create table products
(
    id                int primary key auto_increment,
    name              varchar(40)    not null,
    price             decimal(19, 2) not null,
    quantity_in_stock int,
    description       text,
    brand_id          int            not null,
    category_id       int            not null,
    review_id         int,
    constraint fk_products_brands
        foreign key (brand_id)
            references brands (id),
    constraint fk_products_categories
        foreign key (category_id)
            references categories (id),
    constraint fk_products_reviews
        foreign key (review_id)
            references reviews (id)
);


create table customers
(
    id            int primary key auto_increment,
    first_name    varchar(20) not null,
    last_name     varchar(20) not null,
    phone         varchar(30) not null unique,
    address       varchar(60) not null,
    discount_card bit(1)      not null default false
);

create table orders
(
    id             int primary key auto_increment,
    order_datetime datetime not null,
    customer_id    int      not null,
    constraint fk_orders_customers
        foreign key (customer_id)
            references customers (id)
);

create table orders_products
(
    order_id   int,
    product_id int,
    constraint fk_op_orders
        foreign key (order_id)
            references orders (id),
    constraint fk_op_products
        foreign key (product_id)
            references products (id)
);

# 2. insert
insert into reviews(content, picture_url, published_at, rating)
select left(description, 15), reverse(name), '2010-10-10', price / 8
from products
where id >= 5;

# 3. update
update products
set quantity_in_stock = quantity_in_stock - 5
where quantity_in_stock between 60 and 70;

# 4. delete
delete
from customers
where id not in (select customer_id from orders);

# 5.categories
select id, name
from categories
order by name desc;

# 6. quantity
select id, brand_id, name, quantity_in_stock quantity
from products
where price > 1000
  and quantity_in_stock < 30
order by quantity_in_stock, id;

# 7. review
select r.id, r.content, r.rating, r.picture_url, r.published_at
from reviews r
where r.content like 'My%'
  and char_length(r.content) > 61
order by rating desc;

# 8. first customers
select concat(c.first_name, ' ', c.last_name) full_name,
       c.address,
       o.order_datetime
                                              order_date
from customers c
         join orders o
              on c.id = o.customer_id
where year(o.order_datetime) <= 2018
order by full_name desc;

# 9.best categories
select count(p.id)              items_count,
       c.name,
       sum(p.quantity_in_stock) total_quantity
from categories c
         join products p on c.id = p.category_id
group by c.id
order by items_count desc, total_quantity asc
limit 5;

# 10.	Extract client cards count
create function udf_customer_products_count(name VARCHAR(30))
    returns int
    deterministic
begin
    return (
        select count(c.id)
        from products
                 join orders_products op on products.id = op.product_id
                 join orders o on op.order_id = o.id
                 join customers c on o.customer_id = c.id
        where c.first_name = name
    );
end;


SELECT c.first_name, c.last_name, udf_customer_products_count('Shirley') as `total_products`
FROM customers c
WHERE c.first_name = 'Shirley';
# first_name	last_name	total_products
# Shirley	Clayfield	5

# 11.	Reduce price
create procedure udp_reduce_price(category_name VARCHAR(50))
    deterministic
begin
    update products p
        join categories c on p.category_id = c.id
        join reviews r on p.review_id = r.id
    set p.price = 0.7 * p.price
    where c.name = category_name
      and r.rating < 4;
end;


