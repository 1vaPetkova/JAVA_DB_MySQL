create schema 20200331_db;
use 20200331_db;

# 1. table design
create table users
(
    id        int primary key auto_increment,
    username  varchar(30) not null unique,
    password  varchar(30) not null,
    email     varchar(50) not null,
    gender    char(1)     not null,
    age       int         not null,
    job_title varchar(40) not null,
    ip        varchar(30) not null
);

create table addresses
(
    id      int primary key auto_increment,
    address varchar(30) not null,
    town    varchar(30) not null,
    country varchar(30) not null,
    user_id int         not null,
    constraint fk_addresses_users
        foreign key (user_id)
            references users (id)
);

create table photos
(
    id          int primary key auto_increment,
    description text     not null,
    date        datetime not null,
    views       int      not null default 0
);

create table comments
(
    id       int primary key auto_increment,
    comment  varchar(255) not null,
    date     datetime     not null,
    photo_id int          not null,
    constraint fk_comments_photos
        foreign key (photo_id)
            references photos (id)
);

create table likes
(
    id       int primary key auto_increment,
    photo_id int,
    user_id  int,
    constraint fk_likes_photos
        foreign key (photo_id)
            references photos (id),
    constraint fk_likes_users
        foreign key (user_id)
            references users (id)
);

create table users_photos
(
    user_id  int not null,
    photo_id int not null,
    constraint fk_up_users
        foreign key (user_id)
            references users (id),
    constraint fk_up_photos
        foreign key (photo_id)
            references photos (id)
);

# 2. insert
insert into addresses(address, town, country, user_id)
select u.username, u.password, u.ip, u.age
from users u
where u.gender = 'M';

# 3. update
update addresses
set country =
        case
            when country like 'B%' then 'Blocked'
            when country like 'T%' then 'Test'
            when country like 'P%' then 'In Progress'
            end
where country like 'B%'
   or country like 'T%'
   or country like 'P%';

# 4. delete
delete
from addresses
where id % 3 = 0;

# 5. users
select username, gender, age
from users
order by age desc, username;

# 06. Extract 5 most commented photos
select p.id,
       p.date           date_and_time,
       p.description,
       count(c.comment) commentsCount
from photos p
         join comments c on p.id = c.photo_id
group by p.id
order by commentsCount desc, p.id
limit 5;

# 7. lucky users
select concat(u.id, ' ', u.username) id_username,
       u.email
from users u
         join users_photos up on u.id = up.user_id
where up.user_id = up.photo_id
order by u.id;

# 08.	Count Likes and Comments
select p.id as                                                photo_id,
       (select count(id) from likes where photo_id = p.id)    likes_count,
       (select count(id) from comments where photo_id = p.id) comments_count
from photos p
group by p.id
order by likes_count desc, comments_count desc, p.id;

select p.id as              photo_id,
       count(distinct l.id) likes_count,
       count(distinct c.id) comments_count
from photos p
         left join comments c on p.id = c.photo_id
         left join likes l on p.id = l.photo_id
group by p.id
order by likes_count desc, comments_count desc, p.id;

# 09.	The Photo on the Tenth Day of the Month
select concat(left(p.description, 30), '...') summary, p.date
from photos p
where day(p.date) = 10
order by date desc;

# 10.	Get User’s Photos Count
create function udf_users_photos_count(username VARCHAR(30))
    returns int
    deterministic
begin
    return (select count(up.photo_id)
            from users_photos up
                     join users u on up.user_id = u.id
            where u.username = username
    );
end;

# Query
SELECT udf_users_photos_count('ssantryd') AS photosCount;
# photosCount
# 2

# 11.	Increase User Age
create procedure udp_modify_user(user_address VARCHAR(30), user_town VARCHAR(30))
    deterministic
begin
    update users u join addresses a on u.id = a.user_id
    set age = age + 10
    where a.town = user_town and a.address = user_address;
end;

CALL udp_modify_user ('97 Valley Edge Parkway', 'DivinГіpolis');
SELECT u.username, u.email,u.gender,u.age,u.job_title FROM users AS u
WHERE u.username = 'eblagden21';


update users u join addresses a on u.id = a.user_id
set age = age + 10
where a.town = 'DivinГіpolis' and a.address ='97 Valley Edge Parkway';